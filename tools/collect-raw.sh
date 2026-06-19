#!/bin/bash
# collect-raw.sh — Collect raw context from your project repos into xlore, with secrets redacted.
#
# Usage:
#   ./tools/collect-raw.sh <agent-name>
# where <agent-name> is one of: claude-code | windsurf | cursor (or any label you use).
#
# Which repos get scanned is configured in tools/sources.conf (one path per line).
# Output goes to raw/<agent-name>/<date>/ with a first automated redaction pass.
# ALWAYS review the output before committing — see PRIVACY.md.

set -euo pipefail

AGENT="${1:-}"
if [ -z "$AGENT" ]; then
  echo "Usage: $0 <agent-name>   (e.g. claude-code | windsurf | cursor)"
  exit 1
fi

XLORE="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$XLORE/tools/sources.conf"
WIKIGNORE="$XLORE/tools/.wikignore"
DATE="$(date +%Y-%m-%d)"
DST="$XLORE/raw/$AGENT/$DATE"

if [ ! -f "$CONF" ]; then
  echo "ERROR: no tools/sources.conf found."
  echo "  Create it from the example:  cp tools/sources.conf.example tools/sources.conf"
  echo "  Then list the repos you want scanned (one path per line)."
  exit 1
fi

mkdir -p "$DST"
echo "→ Collecting raw context for '$AGENT' into raw/$AGENT/$DATE"

# ── Redaction (order matters: most specific first) ──────────────────────────
REDACT='
s/sk-[A-Za-z0-9_-]{20,}/<REDACTED:openai-key>/g
s/sk_(test|live)_[A-Za-z0-9]{20,}/<REDACTED:stripe-secret>/g
s/whsec_[A-Za-z0-9]{20,}/<REDACTED:stripe-webhook>/g
s/pk_(test|live)_[A-Za-z0-9]{20,}/<REDACTED:stripe-pub>/g
s/AIza[0-9A-Za-z_-]{30,}/<REDACTED:google-key>/g
s/gh[pousr]_[A-Za-z0-9]{30,}/<REDACTED:github-token>/g
s/postgres(ql)?:\/\/[^[:space:]"]+/<REDACTED:postgres-url>/g
s/mongodb(\+srv)?:\/\/[^[:space:]"]+/<REDACTED:mongo-url>/g
s/redis(s)?:\/\/[^[:space:]"]+/<REDACTED:redis-url>/g
s/Bearer [A-Za-z0-9._-]{20,}/Bearer <REDACTED:token>/g
s/eyJ[A-Za-z0-9._-]{40,}/<REDACTED:jwt-or-jwe>/g
s/[A-Z_]+(KEY|SECRET|TOKEN|PASSWORD|PASS|PWD)=[^[:space:]"]+/<REDACTED:env>/g
'
redact() { sed -E "$REDACT" "$1"; }

# ── .wikignore matching ─────────────────────────────────────────────────────
should_skip() {
  local fname; fname="$(basename "$1")"
  [ -f "$WIKIGNORE" ] || return 1
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    [[ -z "$pattern" || "$pattern" == \#* ]] && continue
    pattern="${pattern%/}"
    [[ "$fname" == $pattern ]] && return 0
    [[ "$1" == *"$pattern"* ]] && return 0
  done < "$WIKIGNORE"
  return 1
}

# Resolve a configured path to an absolute one (supports absolute, ~, or $HOME-relative).
resolve_path() {
  local p="$1"
  case "$p" in
    /*) echo "$p" ;;
    "~/"*) echo "${HOME}/${p#\~/}" ;;
    *) echo "${HOME}/${p}" ;;
  esac
}

# ── Walk each configured project ────────────────────────────────────────────
while IFS= read -r line || [ -n "$line" ]; do
  line="${line%%#*}"; line="$(echo "$line" | xargs)"   # strip comments + trim
  [ -z "$line" ] && continue
  P="$(resolve_path "$line")"
  NAME="$(basename "$P")"
  if [ ! -d "$P" ]; then
    echo "  ⚠ skip (not found): $line"
    continue
  fi
  echo "  • $NAME  ($P)"

  # Agent-instruction & readme files at repo root
  for doc in CLAUDE.md AGENTS.md README.md; do
    if [ -f "$P/$doc" ]; then
      redact "$P/$doc" > "$DST/${NAME}-${doc}"
    fi
  done

  # docs/**/*.md
  if [ -d "$P/docs" ]; then
    while IFS= read -r -d '' f; do
      should_skip "$f" && continue
      rel="${f#"$P/docs/"}"
      dd="$DST/${NAME}-docs/$(dirname "$rel")"; mkdir -p "$dd"
      redact "$f" > "$dd/$(basename "$f")"
    done < <(find "$P/docs" -name '*.md' -not -path '*/node_modules/*' -print0)
  fi

  # other root-level *.md (excluding the ones captured above)
  for f in "$P"/*.md; do
    [ -f "$f" ] || continue
    case "$(basename "$f")" in CLAUDE.md|AGENTS.md|README.md) continue ;; esac
    should_skip "$f" && continue
    mkdir -p "$DST/${NAME}-root"
    redact "$f" > "$DST/${NAME}-root/$(basename "$f")"
  done

  # full git log (provenance / timeline)
  if [ -d "$P/.git" ]; then
    mkdir -p "$DST/git-logs"
    git -C "$P" log --oneline > "$DST/git-logs/${NAME}.txt" 2>/dev/null || true
  fi
done < "$CONF"

# ── Agent-specific captures (best-effort) ───────────────────────────────────
case "$AGENT" in
  windsurf)
    if [ -d "$HOME/.windsurf/plans" ]; then
      mkdir -p "$DST/windsurf-plans"
      for f in "$HOME/.windsurf/plans"/*.md; do
        [ -f "$f" ] || continue
        should_skip "$f" && continue
        redact "$f" > "$DST/windsurf-plans/$(basename "$f")"
      done
    fi
    ;;
esac

echo ""
echo "✅ Collected to: raw/$AGENT/$DATE"
echo ""
echo "⚠️  REVIEW for residual secrets before committing (see PRIVACY.md):"
echo "    grep -rE 'sk-|postgres:|mongodb:|Bearer |AIza|eyJ|_KEY=|_SECRET=|_TOKEN=' \"$DST\""
