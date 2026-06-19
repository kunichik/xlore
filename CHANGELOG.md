# Changelog — xlore protocol

The protocol version is declared at the top of [`CLAUDE.md`](./CLAUDE.md). `tools/update.sh` reads it
to tell you when an upstream pull changes the protocol.

## 1.3.0 — 2026-06-19
- `xlore_scan` operation: index past sessions straight from local IDE chat stores (Claude Code jsonl, Cursor/Copilot/Windsurf VS Code workspaceStorage) — recovers work the user forgot to `wrapup`. Offered at first-run onboarding and as a fallback when `xlore_query`/`xlore_where` come up empty.
- `mcp/` — a read-only local-stdio MCP server (`xlore_query` / `xlore_where` / `xlore_read` / `xlore_recent`) so chat assistants (Claude Desktop, etc.) can read the archive without write access. Hosted transport = roadmap.

## 1.2.0 — 2026-06-19
- Broader tool coverage: added thin pointer files `.clinerules` (Cline + Roo Code) and `GEMINI.md` (Gemini CLI), both open-source agents. `AGENTS.md` is documented as the umbrella standard covering Codex CLI, Zed, Continue, OpenHands, Aider, Amp, etc.
- README gains a "Supported tools" matrix (which file each agent reads).

## 1.1.0 — 2026-06-19
- `xlore_where` operation: cross-chat locator ("in which tool/chat did I do X?"), index-first with search fallback.
- Log entries now record the chat id/name so sessions are findable later.
- Sync modes (`auto` / `semi-auto` / `manual`) selectable in onboarding → `config/profile.md`; conflicts/secrets always ask in every mode.
- "Consistency & conflicts" protocol section: one canonical page per fact, contradictions surfaced not overwritten, never-delete/supersede, lint as the periodic sweep.
- Instruction-file coverage: `.github/copilot-instructions.md`, `.cursorrules`, `.windsurfrules` added as thin pointers to `CLAUDE.md` (single source of truth) so Copilot/Cursor/Windsurf pick up the protocol.

## 1.0.0 — 2026-06-19
- Initial public template extracted from a private xlore archive.
- Protocol: triage-first writes, `active.md` cross-chat board, bootstrap mode, secret redaction.
- Tooling: `collect-raw.sh` (config-driven via `sources.conf`), `update.sh` (fetch-only upstream sync),
  `pre-push` privacy guard.
- First-run onboarding questionnaire → `config/profile.md`.
- Obsidian-vault compatible out of the box.
