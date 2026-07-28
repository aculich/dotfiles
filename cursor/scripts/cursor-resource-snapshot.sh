#!/usr/bin/env bash
# Capture an Activity-Monitor-style Cursor + system resource snapshot.
#
# Usage:
#   ./scripts/cursor-resource-snapshot.sh
#   ./scripts/cursor-resource-snapshot.sh --no-sample
#   ./scripts/cursor-resource-snapshot.sh --out-dir DIR
#
# Writes under observability/perf/resource-<UTC-ts>/ by default.
# Diagnose-only: never kills processes or applies tuning.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CURSOR="$(cd "$SCRIPT_DIR/.." && pwd)"
SUMMARIZER="$SCRIPT_DIR/lib/summarize-cursor-resource.py"

NO_SAMPLE=0
OUT_DIR=""

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-sample)
      NO_SAMPLE=1
      shift
      ;;
    --out-dir)
      OUT_DIR="${2:-}"
      [[ -n "$OUT_DIR" ]] || {
        echo "Usage: $0 --out-dir <dir>" >&2
        exit 1
      }
      shift 2
      ;;
    -h | --help | help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

TS="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
if [[ -z "$OUT_DIR" ]]; then
  OUT_DIR="$REPO_CURSOR/observability/perf/resource-$TS"
fi
mkdir -p "$OUT_DIR"

echo "Capturing Cursor/Electron processes → $OUT_DIR/ps-cursor.txt"
# %cpu %mem-like: use rss (KB) for stable parsing
ps ax -o %cpu=,rss=,pid=,args= 2>/dev/null \
  | grep -iE 'Cursor|Electron' \
  | grep -v grep \
  | sort -nr >"$OUT_DIR/ps-cursor.txt" || true

echo "Capturing memory_pressure (max 15s) → $OUT_DIR/memory_pressure.txt"
if command -v gtimeout >/dev/null 2>&1; then
  gtimeout 15 memory_pressure >"$OUT_DIR/memory_pressure.txt" 2>&1 || echo "(memory_pressure timed out or failed)" >"$OUT_DIR/memory_pressure.txt"
elif command -v timeout >/dev/null 2>&1; then
  timeout 15 memory_pressure >"$OUT_DIR/memory_pressure.txt" 2>&1 || echo "(memory_pressure timed out or failed)" >"$OUT_DIR/memory_pressure.txt"
else
  memory_pressure >"$OUT_DIR/memory_pressure.txt" 2>&1 &
  mpid=$!
  (
    sleep 15
    if kill -0 "$mpid" 2>/dev/null; then
      kill "$mpid" 2>/dev/null || true
      echo "(memory_pressure timed out after 15s)" >>"$OUT_DIR/memory_pressure.txt"
    fi
  ) &
  wait "$mpid" 2>/dev/null || true
fi

# cursor -s often hangs when the IDE is under heavy extension-host load.
# Opt in with CURSOR_STATUS=1. Default: skip for a responsive snapshot.
if [[ "${CURSOR_STATUS:-0}" == "1" ]] && command -v cursor >/dev/null 2>&1; then
  echo "Capturing cursor -s (max 12s) → $OUT_DIR/cursor-status.log"
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout 12 cursor -s >"$OUT_DIR/cursor-status.log" 2>"$OUT_DIR/cursor-status.err" || true
  elif command -v timeout >/dev/null 2>&1; then
    timeout 12 cursor -s >"$OUT_DIR/cursor-status.log" 2>"$OUT_DIR/cursor-status.err" || true
  else
    cursor -s >"$OUT_DIR/cursor-status.log" 2>"$OUT_DIR/cursor-status.err" &
    cpid=$!
    (
      sleep 12
      if kill -0 "$cpid" 2>/dev/null; then
        kill "$cpid" 2>/dev/null || true
        echo "cursor -s timed out after 12s" >>"$OUT_DIR/cursor-status.err"
      fi
    ) &
    wait "$cpid" 2>/dev/null || true
  fi
elif [[ "${CURSOR_STATUS:-0}" == "1" ]]; then
  echo "(cursor CLI not on PATH; skipping cursor -s)" >&2
else
  echo "(skipping cursor -s; set CURSOR_STATUS=1 to include)" >&2
fi

echo "loadavg: $(sysctl -n vm.loadavg 2>/dev/null || true)" >"$OUT_DIR/loadavg.txt"
sysctl vm.swapusage >"$OUT_DIR/swapusage.txt" 2>&1 || true

SUM_ARGS=("$OUT_DIR")
if [[ "$NO_SAMPLE" -eq 1 ]]; then
  SUM_ARGS+=(--no-sample)
fi

python3 "$SUMMARIZER" "${SUM_ARGS[@]}"

# Convenience pointer for canvas / doit
printf '%s\n' "$OUT_DIR" >"$REPO_CURSOR/observability/perf/last-resource-snapshot.txt"
echo "OUT_DIR=$OUT_DIR"
