#!/usr/bin/env bash
# Compare plan cost estimates with optional Teams usage API totals.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLAN=""
START=""
END=""
EMAIL=""
CSV=""

usage() {
  cat <<'EOF'
Usage: reconcile-plan-budget.sh --plan path.plan.md [options]

Options:
  --start ISO8601     Teams API window start (with --end and CURSOR_* env)
  --end ISO8601       Teams API window end
  --email ADDR        Filter usage events to this user
  --csv FILE          Also analyze a dashboard CSV export

Prints annotated plan estimates and optional actuals for ## Cost budget fill-in.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plan) PLAN="$2"; shift 2 ;;
    --start) START="$2"; shift 2 ;;
    --end) END="$2"; shift 2 ;;
    --email) EMAIL="$2"; shift 2 ;;
    --csv) CSV="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$PLAN" ]]; then
  echo "error: --plan required" >&2
  usage
  exit 1
fi

printf '=== Plan estimate (annotated todos) ===\n'
python3 "$ROOT/scripts/estimate-plan-cost.py" --compute "$PLAN"

if [[ -n "$CSV" && -f "$CSV" ]]; then
  printf '\n=== Dashboard CSV actuals ===\n'
  "$ROOT/scripts/cursor-cost-csv-analyze.sh" --sethstrz-only "$CSV"
fi

if [[ -n "$START" && -n "$END" ]]; then
  printf '\n=== Teams API actuals ===\n'
  ARGS=(--start "$START" --end "$END")
  if [[ -n "$EMAIL" ]]; then ARGS+=(--email "$EMAIL"); fi
  "$ROOT/scripts/fetch-cursor-usage-events.sh" "${ARGS[@]}"
fi

cat <<'EOF'

=== Reconciliation template ===
Copy into plan ## Cost budget:

| Scenario | Est API $ | Actual $ | Delta |
|----------|-----------|----------|-------|
| Lean     |           |          |       |
| Balanced |           |          |       |
| Premium  |           |          |       |

Actual $: dashboard Usage tab, CSV export, or Teams chargedCents sum.
EOF
