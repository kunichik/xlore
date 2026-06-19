#!/usr/bin/env node
/**
 * xlore-mcp — a read-only MCP server over a local xlore archive.
 *
 * Exposes four tools so any MCP-capable chat assistant (Claude Desktop, etc.) can READ the archive:
 *   xlore_query  — keyword search across wiki/ + raw/, ranked, with sources
 *   xlore_where  — locate the tool/chat a piece of work was done in (log.md + active.md)
 *   xlore_read   — read one wiki page by relative path
 *   xlore_recent — recent log entries + the live active.md board
 *
 * Writes are intentionally NOT exposed: the triage-first write guarantee lives in the filesystem
 * agent flow (CLAUDE.md). Keeping this server read-only means it can never bypass that.
 *
 * The archive root is `XLORE_ROOT` (env) or the repo this file ships in (../.. from dist/).
 */
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { promises as fs } from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(process.env.XLORE_ROOT ?? path.join(__dirname, "..", ".."));

const SEARCH_DIRS = ["wiki", "raw"];
const text = (s: string) => ({ content: [{ type: "text" as const, text: s }] });

/** Recursively list *.md files under a directory (absolute paths). */
async function listMarkdown(dir: string): Promise<string[]> {
  const out: string[] = [];
  let entries: import("node:fs").Dirent[];
  try {
    entries = await fs.readdir(dir, { withFileTypes: true });
  } catch {
    return out;
  }
  for (const e of entries) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (e.name === "node_modules" || e.name.startsWith(".")) continue;
      out.push(...(await listMarkdown(full)));
    } else if (e.isFile() && e.name.toLowerCase().endsWith(".md")) {
      out.push(full);
    }
  }
  return out;
}

function tokenize(q: string): string[] {
  return [...new Set(q.toLowerCase().match(/[a-zа-яёіїєґ0-9_-]{3,}/giu) ?? [])];
}

function snippet(body: string, terms: string[], len = 240): string {
  const lower = body.toLowerCase();
  let at = -1;
  for (const t of terms) {
    const i = lower.indexOf(t);
    if (i !== -1 && (at === -1 || i < at)) at = i;
  }
  if (at === -1) at = 0;
  const start = Math.max(0, at - len / 4);
  return body.slice(start, start + len).replace(/\s+/g, " ").trim();
}

/** Reject path traversal: resolved target must stay inside ROOT and be a .md file. */
function safeResolve(rel: string): string | null {
  const full = path.resolve(ROOT, rel);
  if (full !== ROOT && !full.startsWith(ROOT + path.sep)) return null;
  if (!full.toLowerCase().endsWith(".md")) return null;
  return full;
}

const server = new McpServer({ name: "xlore", version: "0.1.0" });

server.registerTool(
  "xlore_query",
  {
    title: "Search xlore",
    description:
      "Keyword-search the xlore knowledge archive (wiki/ + raw/) and return the most relevant pages with snippets and source paths. Read-only.",
    inputSchema: {
      question: z.string().describe("What you're looking for (keywords or a question)."),
      limit: z.number().int().min(1).max(20).optional().describe("Max results (default 6)."),
    },
  },
  async ({ question, limit }) => {
    const terms = tokenize(question);
    if (terms.length === 0) return text("Empty query.");
    const files: string[] = [];
    for (const d of SEARCH_DIRS) files.push(...(await listMarkdown(path.join(ROOT, d))));
    const scored: { rel: string; score: number; snip: string }[] = [];
    for (const f of files) {
      const body = await fs.readFile(f, "utf8").catch(() => "");
      if (!body) continue;
      const lower = body.toLowerCase();
      let score = 0;
      for (const t of terms) score += lower.split(t).length - 1;
      if (score > 0) scored.push({ rel: path.relative(ROOT, f), score, snip: snippet(body, terms) });
    }
    scored.sort((a, b) => b.score - a.score);
    const top = scored.slice(0, limit ?? 6);
    if (top.length === 0)
      return text(
        `No matches for "${question}". It may simply not be indexed yet — consider running xlore_scan (re-index local chat stores) or an xlore_wrapup of the relevant session.`
      );
    return text(top.map((r) => `### ${r.rel}  (score ${r.score})\n${r.snip}…`).join("\n\n"));
  }
);

server.registerTool(
  "xlore_where",
  {
    title: "Locate which tool/chat",
    description:
      'Answer "in which tool/chat did I do X?" by scanning log.md (chat-stamped history) and active.md (in-flight tracks). Returns matching session entries.',
    inputSchema: {
      topic: z.string().describe("The work/topic to locate (keywords)."),
    },
  },
  async ({ topic }) => {
    const terms = tokenize(topic);
    const hits: string[] = [];
    const log = await fs.readFile(path.join(ROOT, "log.md"), "utf8").catch(() => "");
    for (const entry of log.split(/\n(?=## )/)) {
      const lower = entry.toLowerCase();
      if (terms.some((t) => lower.includes(t))) {
        const header = entry.split("\n")[0];
        hits.push(`LOG · ${header.replace(/^##\s*/, "")}`);
      }
    }
    const active = await fs.readFile(path.join(ROOT, "active.md"), "utf8").catch(() => "");
    for (const line of active.split("\n")) {
      if (line.startsWith("|") && terms.some((t) => line.toLowerCase().includes(t))) {
        const cells = line.split("|").map((c) => c.trim());
        hits.push(`ACTIVE · ${cells[1]} — owner ${cells[2] ?? "?"}`);
      }
    }
    if (hits.length === 0)
      return text(
        `Couldn't find where "${topic}" was done. It was likely never wrapped up. Want to run xlore_scan to re-index your local IDE chat stores, then ask again?`
      );
    return text(hits.slice(0, 15).join("\n"));
  }
);

server.registerTool(
  "xlore_read",
  {
    title: "Read a wiki page",
    description: "Read one markdown page from the archive by path relative to the repo root (e.g. wiki/projects/foo.md).",
    inputSchema: { path: z.string().describe("Relative .md path inside the archive.") },
  },
  async ({ path: rel }) => {
    const full = safeResolve(rel);
    if (!full) return text(`Refused: "${rel}" is outside the archive or not a .md file.`);
    const body = await fs.readFile(full, "utf8").catch(() => null);
    return body === null ? text(`Not found: ${rel}`) : text(body);
  }
);

server.registerTool(
  "xlore_recent",
  {
    title: "Recent activity + active board",
    description: "Return the most recent log.md entries and the current active.md board.",
    inputSchema: { limit: z.number().int().min(1).max(20).optional().describe("How many log entries (default 5).") },
  },
  async ({ limit }) => {
    const log = await fs.readFile(path.join(ROOT, "log.md"), "utf8").catch(() => "");
    const entries = log.split(/\n(?=## )/).filter((e) => e.startsWith("## "));
    const recent = entries.slice(-(limit ?? 5)).reverse().join("\n\n");
    const active = await fs.readFile(path.join(ROOT, "active.md"), "utf8").catch(() => "(no active.md)");
    return text(`# Active board\n${active}\n\n# Recent log\n${recent}`);
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error(`xlore-mcp ready (root: ${ROOT})`);
}

main().catch((err) => {
  console.error("xlore-mcp fatal:", err);
  process.exit(1);
});
