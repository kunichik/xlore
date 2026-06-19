---
last_tool: claude-code
last_machine: example-host
updated: 2026-06-19
status: accepted
---
# 0001 — EXAMPLE: Rotating refresh tokens over long-lived sessions

> Sample ADR showing the Context / Decision / Consequences / Status format. Delete once you have real ones.

## Context
[[wiki/projects/EXAMPLE-project]] originally issued 30-day session cookies. A leaked cookie meant a
month of access with no revocation path, and security review flagged it before the v2 launch.

## Decision
Switch to short-lived (15 min) JWT access tokens plus rotating refresh tokens. Each refresh issues a
new pair and invalidates the previous refresh token (reuse detection ⇒ revoke the whole chain).

## Consequences
- ✅ Stolen access tokens expire fast; stolen refresh tokens are single-use and detectable.
- ⚠️ Clients must handle silent refresh and the 401→refresh→retry loop.
- Token store moves to Redis (new infra dependency).

## Status
Accepted, shipped in v2. Superseded-by: _none_.
