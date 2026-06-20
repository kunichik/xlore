# xlore

**A git-versioned knowledge base that your AI coding agents maintain for you — across tools, across chats, across machines.**

Claude Code, Windsurf, Cursor (and any future agent) read and write the same wiki under one shared protocol. Every write is human-approved. Long in the making — [Karpathy's LLM-wiki note](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) was the nudge to finally ship it.

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

## Set up your own xlore (full walkthrough)

Everything you need to stand up a fresh archive on a new machine. Steps 1–3, 5, and 6 are the core; step 4 and steps 7–9 are optional.

1. **Create your repo from this template — Private.** On this template's GitHub page: **"Use this template" → Create a new repository → set visibility to Private.** Never public — it will hold sensitive notes. (See [PRIVACY.md](./PRIVACY.md).)

2. **Clone it** on the machine you'll work on:
   ```bash
   git clone git@github.com:<you>/<your-xlore>.git
   cd <your-xlore>
   ```

3. **Turn on the privacy guard** — blocks ever pushing your data to the public template:
   ```bash
   git config core.hooksPath tools/hooks
   ```

4. **(Optional) wire up protocol updates** from this template:
   ```bash
   git remote add upstream <this-template's-git-url>   # fetch-only; later run ./tools/update.sh
   ```

5. **Open the folder in your AI tool** — Claude Code, Cursor, Windsurf, Copilot, Cline/Roo, or Gemini CLI. It auto-reads [`CLAUDE.md`](./CLAUDE.md) / [`AGENTS.md`](./AGENTS.md) and the matching pointer file.

6. **Onboard:** say `xlore onboarding`. A short questionnaire writes [`config/profile.md`](./config/profile.example.md) — your handle, machine, which tools you use, the **repo-private gate**, sync mode, and which repos to track.

7. **(Optional) seed context from your repos:**
   ```bash
   cp tools/sources.conf.example tools/sources.conf   # then edit it to list your repos
   ./tools/collect-raw.sh claude-code                 # pulls redacted context into raw/
   ```
   And `xlore_scan` to index past IDE chat sessions you never wrapped up.

8. **(Optional) read the archive from a chat assistant (MCP):**
   ```bash
   cd mcp && npm install && npm run build
   ```
   then point Claude Desktop / Cursor at `mcp/dist/index.js` — see [`mcp/README.md`](./mcp/README.md).

9. **Work.** After meaningful sessions the agent offers *"Worth running xlore_wrapup?"* → it shows a numbered triage → you reply `go` → it writes. Then commit & push to **your** `origin`:
   ```bash
   git add -A && git commit -m "xlore: <topic>" && git pull --rebase --autostash && git push
   ```

> ⚠️ Before storing anything real, read [PRIVACY.md](./PRIVACY.md). Keep the repo **private**; the guard in step 3 stops accidental pushes to the public template.

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

**The agent only sees xlore when its folder is in the workspace.** Open it as a folder (VS Code, Cursor, Windsurf), add it to your solution/workspace (Visual Studio), or pass it as a working directory (CLI agents). A multi-root / multi-folder workspace lets you keep xlore open *alongside* your project repo so the same agent can read both.

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

## Make every project aware of xlore

By default an agent only knows the `xlore_*` commands when xlore's `CLAUDE.md` is in its context.
Three ways to make a project aware — use whichever fits:

1. **Open xlore in the same workspace** (ad-hoc). Add the xlore folder to your multi-root workspace
   (VS Code / Cursor / Windsurf) or solution (Visual Studio), *alongside* the project. The agent reads
   both folders → it knows `xlore_wrapup` etc. for as long as that workspace is open. **Yes — this is
   all it takes for that session.**

2. **Set it once, globally** (best for "everywhere, every repo"). Add a one-line pointer to your
   *user-level* agent instructions, so every session knows without touching each repo:
   - Claude Code → `~/.claude/CLAUDE.md`
   - Cursor → Settings → Rules (User Rules)
   - Codex CLI → your global `AGENTS.md`
   ```
   This machine uses xlore at ~/xlore. After significant work, offer "xlore_wrapup"
   and follow ~/xlore/CLAUDE.md for the protocol.
   ```

3. **Per-repo pointer** (for tools without a global option, e.g. GitHub Copilot). Drop the same
   one-liner into that repo's `.github/copilot-instructions.md` / `CLAUDE.md` / `AGENTS.md`.

**Recommended:** do #2 once (works everywhere), and use #1 when you actually want the agent to
read/write xlore in a given session. You only need per-repo pointers (#3) for tools that have no
global-instruction mechanism.

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

## About

Built by [Oleksandr Kunichik](https://github.com/kunichik) — also building [KAPT](https://www.kapt.ai/about) (multi-agent AI orchestration) and [Demina](https://demina.ai).
