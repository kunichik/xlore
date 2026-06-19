# AGENTS.md

This repository is an **xlore** knowledge & session archive. The full operating protocol lives in
[`CLAUDE.md`](./CLAUDE.md) — read it and follow it exactly. This file exists so that tools which look
for `AGENTS.md` (Cursor and others) pick up the same protocol as tools that read `CLAUDE.md`.

**Before doing anything:**
- This is a knowledge base, not a code project. You maintain `wiki/` under the protocol in `CLAUDE.md`.
- **Never** write to `wiki/` without producing a numbered triage and getting the user's `go`.
- **Never** push without `git pull --ff-only` first.
- Treat this repo as **private**. See [`PRIVACY.md`](./PRIVACY.md). Never push the user's data to a
  remote named `upstream` (that is the public template).

Operations: `xlore_wrapup`, `xlore_import`, `xlore_query`, `xlore_where`, `xlore_scan`, `xlore_lint`, `xlore_undo`, `xlore onboarding`.
See [`CLAUDE.md`](./CLAUDE.md) for what each does.

> **Single source of truth:** the protocol lives only in `CLAUDE.md`. This file, `.github/copilot-instructions.md`, `.cursorrules`, and `.windsurfrules` are all thin pointers to it — do not duplicate the protocol into them.
