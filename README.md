# xlore

**A git-versioned knowledge base that your AI coding agents maintain for you — across tools, across chats, across machines.**

Claude Code, Windsurf, Cursor (and any future agent) read and write the same wiki under one shared protocol. Every write is human-approved. Inspired by [Karpathy's LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

> ## ⚠️ PRIVACY — READ THIS FIRST
> **This template is public. Your archive must be PRIVATE.**
> Your wiki will contain decisions, business context, finances, and notes you do **not** want public.
> When you create your own xlore from this template, **make the new repo private** and keep it private.
> See [PRIVACY.md](./PRIVACY.md) before you store anything real. The included `tools/` guard hooks
> exist to stop you from ever pushing your data to the public template by accident.

---

## Why it's different

- **Triage-first.** No agent writes silently. It proposes numbered changes (`N1 NEW…`, `E1 EXTEND…`, `C1 CONTRADICTS…`); you reply `go`, `go N1 E1`, or `abort`. You stay in the loop on every fact stored.
- **Multi-agent & symmetric.** No "primary" tool. Whichever agent you're in can read the whole archive and contribute back. Every entry is stamped with the tool + machine that wrote it.
- **`active.md` cross-chat board.** A one-screen live state of every in-flight track and who owns it — so any chat can resume any other chat's work without replaying its context. This is the part you'll miss the most once you have it.
- **Just markdown + git.** No database, no service, no lock-in. Works offline. Diffs in PRs. Yours forever.

## Quickstart

1. Click **"Use this template" → Create a new repository**, and **set it to Private**.
2. Clone your new private repo wherever you like:
   ```bash
   git clone git@github.com:<you>/<your-xlore>.git
   cd <your-xlore>
   ```
3. Open the folder in your AI tool (Claude Code / Windsurf / Cursor). It reads [`CLAUDE.md`](./CLAUDE.md) (and [`AGENTS.md`](./AGENTS.md)) automatically.
4. Say `xlore onboarding` (or just run any xlore command) — on first run the agent walks you through a short questionnaire and writes your setup to `config/profile.md`.
5. Optionally pull raw context from your repos: `./tools/collect-raw.sh claude-code` (configure which repos in `tools/sources.conf`).
6. Start working. After meaningful sessions, the agent offers: *"Worth running xlore_wrapup?"*

## Operations

Trigger these in any AI tool with this folder open:

| Command | What it does |
|---|---|
| `xlore_wrapup` | Save what was learned this session (triage → you approve → write) |
| `xlore_import <source>` | Ingest a specific file / URL / paste |
| `xlore_query <question>` | Ask the archive, cited from sources |
| `xlore_where <what>` | Locate which tool/chat you did something in (the cross-chat finder) |
| `xlore_scan` | Index past sessions from your local IDE chat stores (recovers work you forgot to save) |
| `xlore_lint` | Health check: contradictions, orphans, stale claims, gaps |
| `xlore_undo` | Revert the last write |

Full protocol: [`CLAUDE.md`](./CLAUDE.md).

## Supported tools

Any agent that can open this folder and read an instruction file works. The protocol lives **once** in
`CLAUDE.md`; every file below is a thin pointer to it (single source of truth — never duplicate the protocol).

| Tool | Picks it up via | Notes |
|---|---|---|
| Claude Code | `CLAUDE.md` | filesystem agent |
| GitHub Copilot | `.github/copilot-instructions.md` | filesystem agent |
| Cursor | `.cursorrules` (+ `AGENTS.md`) | filesystem agent |
| Windsurf | `.windsurfrules` | filesystem agent |
| Cline / Roo Code | `.clinerules` | open source |
| Gemini CLI | `GEMINI.md` | open source |
| Codex CLI · Zed · Continue · OpenHands · Aider · Amp · … | `AGENTS.md` | the cross-tool umbrella standard |
| Claude / ChatGPT (web & mobile) | xlore **MCP connector** | *roadmap — chat assistants, not filesystem agents* |

## Use it with Obsidian

xlore is **already an [Obsidian](https://obsidian.md) vault** — it's a folder of markdown with `[[wikilinks]]`, which is exactly Obsidian's native format. Just **open this folder as a vault** and you get, for free:

- Graph view of how your projects / decisions / concepts connect
- Backlinks and unlinked-mention discovery
- Fast full-text search and tag browsing

The agents write the content; Obsidian gives you a human-friendly way to read and navigate it. Volatile Obsidian files (`.obsidian/workspace*`, cache) are git-ignored so they don't create noise; your graph/appearance config can be committed if you want it shared across machines.

## Read it from a chat assistant (MCP)

Filesystem coding agents read the folder directly. **Chat** assistants (Claude Desktop, …) can't —
so [`mcp/`](./mcp) ships a small **read-only** MCP server that exposes `xlore_query`, `xlore_where`,
`xlore_read`, and `xlore_recent`. Build it (`cd mcp && npm install && npm run build`) and point your
MCP client at `mcp/dist/index.js`. It stays read-only on purpose: the triage-first write guarantee
lives in the agent flow, so a connector can never bypass it. A **hosted** transport (for Claude
web/mobile + ChatGPT) is on the roadmap — note it puts your archive on a server, a privacy surface to
secure. See [`mcp/README.md`](./mcp/README.md).

## Customization

Per-user / per-machine setup lives in `config/` and is created by the first-run onboarding:

- `config/profile.md` — your handle, machine name, which AI tools you use, which repos to track, work-vs-personal posture, extra namespaces. **This is yours; it never goes to the public template.**
- `tools/sources.conf` — the list of repos `collect-raw.sh` pulls context from.

Edit either by hand any time, or re-run `xlore onboarding` to regenerate.

## Staying up to date with the template

Your archive is yours, but the **protocol/tooling** (`CLAUDE.md`, `AGENTS.md`, `tools/`) keeps improving upstream. To pull only the engine files — never touching your `wiki/`, `raw/`, or `config/`:

```bash
# one-time: point at the public template as a fetch-only remote
git remote add upstream git@github.com:<owner>/xlore.git

# whenever you want the latest protocol:
./tools/update.sh
```

`update.sh` fetches the engine files from `upstream` and stops to show you the diff before applying. **It never pushes**, and the bundled `pre-push` hook refuses any push whose target is `upstream` — so your private data physically cannot flow to the public template. See [PRIVACY.md](./PRIVACY.md).

## Structure

```
xlore/
├── CLAUDE.md          ← the protocol (read this)
├── AGENTS.md          ← same protocol, for AGENTS.md-aware tools
├── README.md          ← you are here
├── PRIVACY.md         ← privacy rules — read before storing real data
├── index.md           ← page catalog (agents keep it current)
├── log.md             ← append-only operation history
├── active.md          ← live cross-chat coordination board
├── config/            ← your per-user setup (profile.md) — private
├── tools/
│   ├── collect-raw.sh ← pull redacted context from your repos
│   ├── update.sh      ← pull protocol updates from upstream (fetch-only)
│   ├── sources.conf   ← which repos to scan
│   └── hooks/pre-push ← guard: blocks pushing data to upstream
├── mcp/               ← read-only MCP server (lets chat assistants read the archive)
├── raw/               ← immutable, redacted source dumps per agent
└── wiki/              ← the LLM-maintained knowledge
    ├── projects/      ├── concepts/   ├── decisions/
    └── personal/ (optional)   finance/ (optional)
```

## License

[MIT](./LICENSE) — the protocol & tooling are free to fork and use. Your archive content is, of course, yours.
