---
last_tool: claude-code
last_machine: example-host
updated: 2026-06-19
---
# EXAMPLE — Acme API

> This is a sample page showing the format. Delete it once you have real pages.

**Acme API** — a TypeScript/Node service that powers Acme's public REST + webhook surface.
Repo: `~/code/acme-api`. Owner: backend team.

## What it is
- REST API (Fastify) + a webhook dispatcher, Postgres via Prisma, deployed on Fly.io.
- Auth: short-lived JWT access tokens + rotating refresh tokens (see [[wiki/concepts/example-concept]]).

## Current state
- v2 auth migration in progress — tracked in `active.md`.
- Open decision on multi-region read replicas (no ADR yet).

## Key facts an agent should know
- Migrations are one-off scripts in `prisma/`, run with `npx tsx`. They are idempotent.
- Never log raw refresh tokens; redaction middleware lives in `src/mw/redact.ts`.

## Sources
- raw/claude-code/2026-06-19/acme-api-CLAUDE.md
- raw/claude-code/2026-06-19/git-logs/acme-api.txt
