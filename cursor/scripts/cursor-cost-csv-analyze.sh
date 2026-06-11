#!/usr/bin/env bash
# Analyze a Cursor usage CSV export using vendored tools.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  cat <<'EOF'
Usage: cursor-cost-csv-analyze.sh <export.csv> [--sethstrz-only | --explorer-only]

Runs vendored post-hoc analyzers on a dashboard Usage CSV export.
Export: cursor.com/dashboard?tab=usage → date range → Export CSV
EOF
}

CSV=""
MODE="all"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sethstrz-only) MODE=sethstrz; shift ;;
    --explorer-only) MODE=explorer; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "unknown: $1" >&2; usage; exit 1 ;;
    *)
      if [[ -z "$CSV" ]]; then CSV="$1"; else echo "extra arg: $1" >&2; exit 1; fi
      shift
      ;;
  esac
done

if [[ -z "$CSV" || ! -f "$CSV" ]]; then
  echo "error: provide path to export CSV" >&2
  usage
  exit 1
fi

WORK="$ROOT/.cache/cursor-csv-analyze"
mkdir -p "$WORK"
COPY="$WORK/$(basename "$CSV")"
cp "$CSV" "$COPY"

if [[ "$MODE" == "all" || "$MODE" == "sethstrz" ]]; then
  SETH="$ROOT/upstream/sethstrz__cursor-costs/cursor_cost.py"
  if [[ -f "$SETH" ]]; then
    printf '\n=== sethstrz/cursor-costs ===\n'
    python3 "$SETH" "$COPY"
  else
    echo "skip: upstream/sethstrz__cursor-costs not cloned" >&2
  fi
fi

if [[ "$MODE" == "all" || "$MODE" == "explorer" ]]; then
  EXP="$ROOT/upstream/dalssoft__cursor_cost_explorer"
  if [[ -d "$EXP" ]]; then
    printf '\n=== dalssoft/cursor_cost_explorer ===\n'
    if [[ ! -d "$EXP/node_modules" ]]; then
      (cd "$EXP" && npm install --silent)
    fi
    node "$EXP/src/cli/index.js" analyze "$COPY"
  else
    echo "skip: upstream/dalssoft__cursor_cost_explorer not cloned" >&2
  fi
fi

printf '\nTip: import the same CSV into kingdomseed calculator (scripts/run-cursor-calculator-local.sh) for plan-tier replay.\n'
