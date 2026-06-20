# xlore — Knowledge & Session Archive

<!-- protocol version: 1.5.0 -->

xlore is a git-versioned, agent-maintained knowledge base. This repo IS the archive — clone it wherever you like and open it in your AI coding tool of choice. All paths below are relative to this repo's root.

You become a knowledge maintainer when invoked via `xlore_wrapup`, `xlore_import`, `xlore_query`, `xlore_where`, `xlore_scan`, `xlore_status`, `xlore_lint`, `xlore_undo`, or `xlore onboarding`.

## ⚠️ Privacy & safety (non-negotiable)
This archive holds private knowledge. Enforce these at all times — see `PRIVACY.md`:
- **Treat this repo as private.** If onboarding hasn't confirmed `repo_private: yes`, do not help populate it with real, sensitive content — tell the user to make the repo private first.
- **Never push the user's data to `upstream`.** `upstream` is the public template; it is fetch-only (protocol updates flow IN via `tools/update.sh`, data never flows OUT). Push only to the user's `origin`.
- **Redact secrets before anything enters `raw/`** (keys, DB strings, tokens, third-party PII) → `<REDACTED:type>`. If unsure, ask.
- **Never write to `wiki/` without triage + an explicit `go`.** This is the core safety contract; no exceptions.

## Layers
- `raw/` — immutable source dumps, one folder per agent. Read only, never modify.
- `wiki/` — LLM-synthesized pages. You own this. Structure is content-driven, not predefined.
- `index.md` / `log.md` / `active.md` — catalog, history, live coordination board.
- This file — the protocol. Follow it exactly.

## Session start (any tool)
1. `git pull --ff-only`. If it fails (diverged) — **HALT**. Tell the user: "xlore diverged, manual merge needed."
2. `cat index.md`. If it has no catalog entries (only the placeholder comment) — enter **bootstrap mode** (see below).
3. `tail -20 log.md` — recent activity. Note `last_tool` entries.
4. `cat active.md` — **live cross-chat board**: the state of every in-flight track and who owns it. This is how a fresh session "knows everything" without replaying other chats.
5. Load relevant `wiki/` pages for the current project context.

## First-run onboarding (no `config/profile.md` yet)
If `config/profile.md` does not exist — or the user says `xlore onboarding` — run a short questionnaire **before** doing other work, then write the answers to `config/profile.md` (copy the shape from `config/profile.example.md`). Ask, one at a time, accepting plain answers:
1. Your handle (stamped on contributions)?
2. This machine's hostname?
3. Which AI tools will maintain this archive? (claude-code / windsurf / cursor / …)
4. **Is this repository private?** If the user can't confirm `yes`, warn clearly and do **not** proceed to store real content until it is.
5. Audience: personal / work-solo / work-shared? (If `work-shared`, recommend keeping personal/finance in a separate private repo.)
6. Which repos should `collect-raw.sh` track? → also write these into `tools/sources.conf`.
7. Any extra `wiki/` namespaces beyond projects/concepts/decisions?
8. **Sync mode** — `auto` / `semi-auto` / `manual`? (See "Sync modes" below. Default `manual`; can be changed any time by editing `config/profile.md` or asking the agent.)
9. **Scan existing chat history?** Offer to run `xlore_scan` (below) — index past sessions sitting in your local IDE chat stores so old work is findable. Many people don't `wrapup` every session; this recovers that backlog.
10. **Make every project aware of xlore?** Offer to add a one-line pointer to the user's *global* agent instructions (`~/.claude/CLAUDE.md`, Cursor → User Rules, or a global `AGENTS.md`) so every session in **any** repo knows about xlore — not only when this folder is open in the workspace. (See README → "Make every project aware of xlore".) Only write it on an explicit `yes`, and show the exact line + file first.

Write `config/profile.md`, confirm it back to the user, and offer to run `tools/collect-raw.sh` + bootstrap. `config/` is per-user and lives only in the private archive — never sync it upstream.

## Staying current with the template
The protocol and `tools/` improve in the public template. `tools/update.sh` pulls ONLY engine files (`CLAUDE.md`, `AGENTS.md`, `PRIVACY.md`, `tools/*`) from the `upstream` remote, shows a diff, and never touches `wiki/`, `raw/`, `config/`, or the user's data — and never pushes. Suggest it when the user asks about updates; never run it unprompted.

## active.md (live coordination layer)
The third xlore layer alongside `index.md` (knowledge catalog) and `log.md` (history):
`active.md` = the current state of all in-flight work across chats/tools.
- **Read at session start** (step 4 above).
- **Update your track's row** when you take or finish work — State + Next action + Owner (chat id / tool name so another session can resume it).
- **When a track is fully done**, move its line into `log.md` and remove it from `active.md`. Keep `active.md` to one screen — it is state, not history.
- Goal: any chat can pick up any other chat's work via this board + the linked `wiki/` pages, without dragging a heavy chat's full context.

## Bootstrap mode (empty wiki)
Triggered when `index.md` has no catalog entries. Run once, by whichever agent is first.
1. Read everything in `raw/<your-name>/` (run `tools/collect-raw.sh` first if it's empty).
2. Scan the project repos in your workspace (their `CLAUDE.md` / `AGENTS.md` / `README.md`, recent git log, key sources).
3. Produce a **bootstrap triage** — propose the initial wiki structure (which pages, which namespaces).
4. Wait for `go`. Write. Initialize `index.md` and `log.md`.

## Proactive trigger rule
After sessions involving architectural decisions / bug root-causes / feature completions / schema changes —
offer **exactly**: "Worth running xlore_wrapup?" Do not auto-run.

## Sync modes (`config/profile.md → sync_mode`)
Controls how proactively you maintain the archive. **Two invariants hold in every mode and are never overridden:** (a) anything touching a *conflict/contradiction*, a *deletion*, or *sensitive/secret data* always stops for explicit user approval; (b) data is never pushed to `upstream`.

- **`manual`** (default, = baseline above): never write unprompted. The user runs `xlore_wrapup`. You only *offer* "Worth running xlore_wrapup?". Full triage every time.
- **`semi-auto`**: after significant work, proactively prepare a wrapup. **Auto-apply purely additive, non-conflicting writes** (a new fact, a new page) without waiting — but **stop for triage** the moment a write would contradict an existing page, delete/supersede content, or store anything sensitive. Tell the user what you auto-applied.
- **`auto`**: maintain the archive continuously as work happens; auto-apply non-conflicting additions and index/log/active updates silently. Still escalate per invariant (a) — conflicts, deletions, and sensitive data always surface for approval. Run `xlore_lint` opportunistically and report drift.

Mode is read at session start from `config/profile.md`. The user can change it any time by editing that file or telling the agent ("switch xlore to semi-auto").

## xlore_wrapup (triage-first — ALWAYS)
1. Produce a **numbered** triage report before touching any file:
   ```
   ## Triage: <session topic>
   [N1] NEW wiki/<path> — <why>
   [E1] EXTEND wiki/<path> — <what>
   [C1] CONTRADICTS wiki/<path> says X / session shows Y [both quoted]
   [R1] RESTRUCTURE — <reason>
   [S1] SKIP — <not worth storing>
   ```
2. Wait for the user's response. Accepted forms:
   - `go` — do everything
   - `go N1 E1` — only those items
   - `go N1-N5` — a range
   - `go all except C1` — everything except C1
   - `rewrite` — redo triage with feedback
   - `abort` — cancel, no writes
3. Write only approved items.
4. Update `index.md` (add/move/rename entries as the tree changes).
5. Append `log.md`: `## [YYYY-MM-DD HH:MM] <tool> · <author> | wrapup | <title> (chat: <id-or-name>)` + touched files. `<author>` = the handle from `config/profile.md` (so a team archive shows *who* did what without `git blame`). Always record the chat identifier so `xlore_where` can find it later — for Claude Code use the resume id; for other tools use the chat title.
6. Suggest: `git add -A && git commit -m "xlore(<tool>): <topic>" && git pull --rebase --autostash && git push`.

## xlore_import <source>
Same as wrapup but for an explicit source (file, URL, paste).
1. Place the source in `raw/<your-name>/` (after secret redaction — see below).
2. Run triage. Wait. Write. Log.

## xlore_query <question>
1. Read `index.md` → drill into relevant pages → synthesize with `[[wiki/path]]` cross-references.
2. Cite only `raw/` sources. Never invent.
3. If the answer is valuable, offer: "File this back as `wiki/<path>`?"
4. Log: `## [date] <tool> | query | <question>`

## xlore_where <what you're looking for>
"In which tool/chat did I do X?" — the cross-chat locator.
1. **Index first (fast, deterministic):** scan `log.md` (chat-stamped history) + `active.md` (in-flight tracks). Match on the topic.
2. **Search fallback (flexible):** grep / semantic-match across `wiki/` and `raw/` if the index has no clear hit.
3. Return, ranked: **tool + chat (+ how to resume) + the wiki page(s) touched + date.** Example:
   `→ Copilot · chat "Acme API hardening" · 2026-05-12 · see [[wiki/projects/acme-api]]` (Claude Code resume: `claude --resume <id>`).
4. If nothing is found, say so plainly — it likely means that session was never wrapped up. Do not invent a chat. **Offer to run `xlore_scan`**, then retry.
5. Log: `## [date] <tool> | where | <query>`

## xlore_scan
Index past sessions that were never wrapped up, by reading the **local IDE chat stores** directly — so old work becomes findable even though the user forgot to save it. Also useful when `xlore_query`/`xlore_where` come up empty: *"that may not be indexed — want me to `xlore_scan`?"*
1. Locate chat stores on this machine (best-effort; skip what's absent):
   - **Claude Code** — `~/.claude/projects/<encoded-workspace-path>/*.jsonl`
   - **Cursor** — `~/Library/Application Support/Cursor/User/workspaceStorage/<hash>/state.vscdb` (SQLite)
   - **VS Code + Copilot** — `~/Library/Application Support/Code/User/workspaceStorage/<hash>/` (chat sessions)
   - **Windsurf** — `~/.codeium/windsurf/` and its VS Code-style workspaceStorage
   - (Linux/Windows: the equivalent `~/.config` / `%APPDATA%` paths.)
2. For the workspaces the user cares about, extract conversation text **grouped by workspace**, redact secrets (same rules as `raw/`), and write to `raw/<tool>/<date>/scan-<workspace>.md`.
3. Run a normal **triage** over what was found (NEW/EXTEND pages, or just "indexed N sessions, here's what's now findable"). Wait for `go`.
4. This is heavy and format-specific per tool — do it for the workspaces requested, not blindly for everything. In `auto`/`semi-auto` mode it can be part of periodic maintenance.
5. Log: `## [date] <tool> · <author> | scan | <workspaces>`

## xlore_status
A team/solo status snapshot — "what's in flight, who owns what, what's blocked" — grounded in the recorded artifacts (no surveys, no inference).
1. Read `active.md` (the in-flight board) + the recent `log.md` entries.
2. Summarize **grouped by owner / `author`**: each person's active tracks (State + Next action), surfacing **blockers (🔴)** and stale tracks first.
3. This is **situational awareness, not productivity policing.** Report only what's recorded; attribute via the `author` stamp / git authorship; never infer or score performance. (See the team-mode note in README.)
4. `tools/status.sh [N]` is the quick non-LLM glance (the board + the last N log headers).
5. Log: `## [date] <tool> · <author> | status | <scope>`

## xlore_lint
Find: contradictions between pages, stale claims, orphan pages, missing cross-refs, knowledge gaps.
Output an ordered list. **Do NOT auto-fix.** Log: `## [date] <tool> | lint`

## xlore_undo
Reverts the last wiki write.
1. `git log --oneline -5` — show recent commits.
2. Confirm with the user which to revert.
3. `git revert <sha> --no-edit && git push`.
4. Log: `## [date] <tool> | undo | <reverted sha>`

## Secret redaction (BEFORE writing to raw/)
When placing sources in `raw/`, scan and redact:
- API keys (`sk-...`, `AIza...`, env-style `KEY=...`)
- DB connection strings (`postgres://user:pass@...`, `mongodb+srv://...`)
- OAuth tokens, JWTs, bearer tokens
- Email/phone of third parties (not yours)

Replace with `<REDACTED:type>`. If unsure — **ask the user** before saving. `tools/collect-raw.sh` applies a first pass automatically, but you are still responsible for a manual review.

## Consistency & conflicts (how the archive stays trustworthy)
Multiple tools and chats write here, so contradictions are expected. The rules that keep it coherent:
- **Storage layer:** session start does `git pull --ff-only`. If it can't fast-forward, two chats diverged — **HALT** and ask the user to merge. Never auto-merge conflicting knowledge silently. Before trusting "up to date", also check `git status` for an uncommitted concurrent wrapup from another tool.
- **One canonical page per fact.** Each entity/decision has a single home page; other pages *link* to it (`[[wiki/...]]`), never duplicate it. Duplication is how archives rot.
- **Contradictions are surfaced, never overwritten.** When a new fact conflicts with an existing page, raise it as a `[C1]` triage item with **both versions quoted**. Resolve by either (a) updating the canonical page and noting what changed, or (b) marking the old page `superseded_by: [[new-page]]`. Never silently replace.
- **Never delete.** Supersede instead (`superseded_by:`), so history and provenance survive.
- **Provenance on every page** (`last_tool` / `last_machine` / `updated`) — so when two claims disagree you can see which is newer and who wrote it.
- **`xlore_lint` is the periodic consistency sweep** — it *finds* contradictions/stale claims/orphans but does **not** auto-fix; it hands you a list to resolve. In `auto`/`semi-auto` mode, run it opportunistically and report drift.

## Conventions
- `[[wiki/path/to-page]]` for cross-references
- `kebab-case.md` filenames
- Decisions: `wiki/decisions/NNNN-slug.md` with sections: Context / Decision / Consequences / Status
- Minimal frontmatter on every wiki page from day 1:
  ```yaml
  ---
  last_tool: claude-code | windsurf | cursor | <your-tool>
  last_machine: <hostname>
  last_author: <your-handle>   # from config/profile.md — who, for team archives (vs git blame)
  updated: YYYY-MM-DD
  ---
  ```
- Never delete pages. Add a `superseded_by: [[new-page]]` field instead.
- Never invent sources. Cite only what's in `raw/`.
- Never write without triage + `go` from the user.
- Never push without `git pull --ff-only` first.

## Wiki structure (initial namespaces)
These are starting points — create whatever the content demands and justify it in triage under `RESTRUCTURE`.
- `wiki/projects/` — one page per project/repo you work on
- `wiki/concepts/` — cross-cutting concepts (architecture, RAG, auth, etc.)
- `wiki/decisions/` — ADRs (`NNNN-slug.md`)
- `wiki/personal/` — life, health, notes (optional)
- `wiki/finance/` — taxes, investments (optional)

## Symmetry
You are a **peer contributor**. No agent is "primary". The first agent that runs against an empty wiki does bootstrap; others add their perspective via `xlore_wrapup`. Every contribution is logged with its tool + machine for provenance.
