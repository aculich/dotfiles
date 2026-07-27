#!/usr/bin/env bash
# Read-only Agents Window / Composer inventory wrapper.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec python3 "$ROOT/scripts/cursor-agents-inventory.py" "$@"
