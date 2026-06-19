#!/bin/bash
# update.sh — Pull protocol/tooling updates from the public xlore template.
#
# Syncs ONLY the engine files (CLAUDE.md, AGENTS.md, PRIVACY.md, CHANGELOG.md, tools/*).
# It NEVER touches your wiki/, raw/, config/, index.md, log.md, active.md, or sources.conf.
# It NEVER pushes. Your private data cannot leave through this script.
#
# One-time setup:
#   git remote add upstream git@github.com:<owner>/xlore.git
# Then run:  ./tools/update.sh

set -euo pipefail

XLORE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$XLORE"

if ! git remote get-url upstream >/dev/null 2>&1; then
  echo "ERROR: no 'upstream' remote. Add the public template first:"
  echo "  git remote add upstream git@github.com:<owner>/xlore.git"
  exit 1
fi

# Engine files that update.sh is allowed to overwrite. Your content is NOT in this list.
ENGINE=(
  CLAUDE.md
  AGENTS.md
  PRIVACY.md
  CHANGELOG.md
  tools/collect-raw.sh
  tools/update.sh
  tools/.wikignore
  tools/sources.conf.example
  tools/hooks
)

echo "→ Fetching upstream…"
git fetch --quiet upstream

# Resolve upstream default branch (main or master)
UPSTREAM_BRANCH="$(git remote show upstream | sed -n 's/.*HEAD branch: //p')"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-main}"
REF="upstream/${UPSTREAM_BRANCH}"

ver() { grep -m1 -iE 'protocol version' "$1" 2>/dev/null | tr -d '\r' || true; }
LOCAL_VER="$(ver CLAUDE.md)"
NEW_VER="$(git show "$REF:CLAUDE.md" 2>/dev/null | grep -m1 -iE 'protocol version' || true)"

echo ""
echo "  local protocol:    ${LOCAL_VER:-<none>}"
echo "  upstream protocol: ${NEW_VER:-<none>}"
echo ""
echo "→ Engine-file changes vs ${REF}:"
if git diff --quiet "$REF" -- "${ENGINE[@]}"; then
  echo "  (already up to date — nothing to apply)"
  exit 0
fi
git --no-pager diff --stat "$REF" -- "${ENGINE[@]}"

echo ""
read -r -p "Apply these engine updates to your working tree? [y/N] " ans
case "$ans" in
  y|Y|yes)
    git checkout "$REF" -- "${ENGINE[@]}"
    echo ""
    echo "✅ Engine files updated. Review with 'git diff --staged', then commit:"
    echo "   git commit -m 'xlore: sync protocol from upstream'"
    echo "   (push goes to YOUR origin — never upstream.)"
    ;;
  *)
    echo "Aborted. Nothing changed."
    ;;
esac
