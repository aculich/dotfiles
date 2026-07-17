#!/usr/bin/env bash
# Scan open Cursor workspaces and apply ignore/watcher purification.
#
# Usage:
#   ./scripts/cursor-purification.sh --scan
#   ./scripts/cursor-purification.sh --apply
#   ./scripts/cursor-purification.sh --scan --workspace rrid
#   ./scripts/cursor-purification.sh --apply --status-log observability/perf/run-.../cursor-status.log
#
# See observability/cursor-purification/README.md and docs/IGNORING.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CURSOR="$(cd "$SCRIPT_DIR/.." && pwd)"
PURIFY="$SCRIPT_DIR/lib/purify-workspace.py"

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

if [[ ! -f "$PURIFY" ]]; then
  echo "Missing $PURIFY" >&2
  exit 1
fi

chmod +x "$PURIFY" 2>/dev/null || true

cd "$REPO_CURSOR"
exec python3 "$PURIFY" "$@"
