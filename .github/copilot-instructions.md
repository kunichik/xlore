# Copilot instructions

This repository is an **xlore** knowledge & session archive. The operating protocol lives in
[`../CLAUDE.md`](../CLAUDE.md) — read it and follow it exactly. (This file exists only so GitHub
Copilot picks up the same protocol; it is a pointer, not a second copy.)

Non-negotiable:
- This is a knowledge base. You maintain `wiki/` under the protocol in `CLAUDE.md`.
- **Never** write to `wiki/` without a numbered triage + the user's `go`.
- **Never** push without `git pull --ff-only` first, and **never** push to a remote named `upstream`
  (that is the public template). Treat this repo as **private** — see `PRIVACY.md`.

Operations: `xlore_wrapup`, `xlore_import`, `xlore_query`, `xlore_where`, `xlore_lint`, `xlore_undo`.
