#!/usr/bin/env bash
# Capture Cursor process state and write a human-readable perf report.
#
# Usage:
#   cursor-perf-report.sh                    # capture + report → observability/perf/run-<ts>/
#   cursor-perf-report.sh --no-capture DIR   # summarize existing cursor-status.log in DIR
#   cursor-perf-report.sh --jsonl PATH       # also analyze Process Explorer JSONL export
#
# Requires: cursor CLI, python3; optional rg for ps-top.txt

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CURSOR="$(cd "$SCRIPT_DIR/.." && pwd)"
SUMMARIZER="$SCRIPT_DIR/lib/summarize-cursor-status.py"
TS="$(date -u +%Y-%m-%dT%H-%M-%SZ)"

NO_CAPTURE=0
OUT_DIR=""
JSONL_PATH=""

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-capture)
      NO_CAPTURE=1
      shift
      OUT_DIR="${1:-}"
      [[ -n "$OUT_DIR" ]] || {
        echo "Usage: $0 --no-capture <dir-with-cursor-status.log>" >&2
        exit 1
      }
      shift
      ;;
    --jsonl)
      JSONL_PATH="${2:-}"
      [[ -n "$JSONL_PATH" ]] || {
        echo "Usage: $0 --jsonl <path.jsonl>" >&2
        exit 1
      }
      shift 2
      ;;
    -h|--help|help)
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

if [[ "$NO_CAPTURE" -eq 0 ]]; then
  OUT_DIR="$REPO_CURSOR/observability/perf/run-$TS"
  mkdir -p "$OUT_DIR"

  if ! command -v cursor >/dev/null 2>&1; then
    echo "cursor CLI not found on PATH" >&2
    exit 1
  fi

  echo "Capturing cursor -s → $OUT_DIR/cursor-status.log"
  cursor -s >"$OUT_DIR/cursor-status.log" 2>"$OUT_DIR/cursor-status.err" || true

  if command -v rg >/dev/null 2>&1; then
    ps ax -o %cpu,rss,comm,args 2>/dev/null \
      | rg -i 'Cursor|Electron' \
      | sort -nr \
      | head -40 >"$OUT_DIR/ps-top.txt" || true
  else
    ps ax -o %cpu,rss,comm,args 2>/dev/null \
      | grep -iE 'Cursor|Electron' \
      | grep -v grep \
      | sort -nr \
      | head -40 >"$OUT_DIR/ps-top.txt" || true
  fi

  printf '%s\n' "$TS" >"$OUT_DIR/capture-timestamp.txt"
else
  OUT_DIR="$(cd "$OUT_DIR" && pwd)"
fi

STATUS_LOG="$OUT_DIR/cursor-status.log"
if [[ ! -f "$STATUS_LOG" ]]; then
  echo "Missing $STATUS_LOG" >&2
  exit 1
fi

if [[ ! -x "$SUMMARIZER" ]]; then
  chmod +x "$SUMMARIZER" 2>/dev/null || true
fi

JSONL_ARGS=()
if [[ -n "$JSONL_PATH" && -f "$JSONL_PATH" ]]; then
  JSONL_ARGS=(--jsonl "$JSONL_PATH")
fi

python3 "$SUMMARIZER" "$STATUS_LOG" -o "$OUT_DIR/report.md" "${JSONL_ARGS[@]}"

echo ""
echo "Report: $OUT_DIR/report.md"
echo "Status log: $STATUS_LOG"
if [[ -f "$OUT_DIR/ps-top.txt" ]]; then
  echo "ps top: $OUT_DIR/ps-top.txt"
fi
echo "$OUT_DIR"
