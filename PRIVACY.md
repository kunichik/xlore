# ⚠️ PRIVACY & SAFETY — read before you store anything real

xlore is designed to hold the things you tell your AI agents: architecture, business
context, deals, finances, personal notes. That is exactly the data that must **never**
become public. This file is the safety contract. The protocol in `CLAUDE.md` enforces it,
and the `tools/` hooks back it up — but **you are the last line of defense.**

## The five rules

1. **Your archive repo MUST be private.**
   The repo you create from this template is your knowledge base. Set it Private on creation
   and keep it private. If you are not 100% sure it is private, stop and check before pushing.

2. **Never push your data to the public template.**
   You pull *protocol updates* from the template (`upstream`, fetch-only). You never push to it.
   The bundled `tools/hooks/pre-push` hook blocks any push whose destination is `upstream`.
   Install it: `git config core.hooksPath tools/hooks`.

3. **Redact secrets before they enter `raw/`.**
   API keys, DB connection strings, OAuth/JWT/bearer tokens, and third parties' email/phone
   get replaced with `<REDACTED:type>`. `tools/collect-raw.sh` does a first automated pass,
   but **always run the review grep it prints** and eyeball the output before committing:
   ```bash
   grep -rE 'sk-|postgres:|mongodb:|Bearer |AIza|eyJ|_KEY=|_SECRET=|_TOKEN=' raw/
   ```

4. **Separate work and personal if they have different audiences.**
   If colleagues may ever get read access to a work archive, keep personal/finance in a
   *second* private repo (`xlore-personal`). One repo's access controls apply to everything in it.

5. **No agent writes without your `go`.**
   Triage-first is not optional. If a tool ever writes to the wiki without showing you a numbered
   triage and waiting for approval, that is a bug — report it and `xlore_undo`.

## First-run gate

On first run the onboarding questionnaire asks: *"Is this repository private?"* and
*"Will this hold sensitive data?"*. If you cannot confirm the repo is private, the agent should
**not** help you populate it with real content — fix the repo visibility first.

## If something leaked

If private content reached a public repo:
1. Make the repo private / delete it immediately — but assume it was already indexed/cached.
2. **Rotate every credential** that appeared in the leak (do not just delete the commit — git history and forks/caches persist).
3. Treat business/personal facts as disclosed and act accordingly.

Deleting a public commit does **not** undo exposure. Rotation and damage control do.
