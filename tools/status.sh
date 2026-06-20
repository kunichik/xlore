#!/bin/bash
# status.sh — quick status glance: the in-flight board + recent log headers (who did what).
# A non-LLM companion to the `xlore_status` operation. Situational awareness, not productivity policing.
#
# Usage: ./tools/status.sh [N]    (N = how many recent log entries, default 10)

set -euo pipefail
XLORE="$(cd "$(dirname "$0")/.." && pwd)"
N="${1:-10}"

echo "=== Active board — in-flight tracks · owners · blockers ==="
if [ -f "$XLORE/active.md" ]; then
  grep -E '^\|' "$XLORE/active.md" || echo "(board empty)"
else
  echo "(no active.md)"
fi

echo ""
echo "=== Last $N log entries — who did what ==="
if [ -f "$XLORE/log.md" ]; then
  grep -E '^## \[' "$XLORE/log.md" | tail -n "$N"
else
  echo "(no log.md)"
fi
