#!/usr/bin/env bash
# Fetch Teams filtered usage events and sum chargedCents by model.
# Docs: https://cursor.com/docs/account/teams/admin-api
set -euo pipefail

API_BASE="${CURSOR_API_BASE:-https://api.cursor.com}"
API_KEY="${CURSOR_ADMIN_API_KEY:-}"

usage() {
  cat <<'EOF'
Usage: fetch-cursor-usage-events.sh --start TIME --end TIME [options]

Options:
  --start START     Start time (required): ISO8601 (2026-06-10T00:00:00Z) or epoch ms
  --end END         End time (required): ISO8601 or epoch ms
  --email EMAIL     Filter to one user email (repeatable; API uses last if multiple)
  --page-size N     Page size (default 100, max per API docs)
  --raw             Print full JSON from last page fetch only
  --all-pages       Fetch all pages (default: first page only)

Environment:
  CURSOR_ADMIN_API_KEY   Team admin API key (Basic auth user) from cursor.com/settings
  CURSOR_API_BASE        Default https://api.cursor.com

Requires a Cursor Teams plan with Admin API access (not available on individual Pro).
EOF
}

to_epoch_ms() {
  local value="$1"
  if [[ "$value" =~ ^[0-9]+$ ]]; then
    echo "$value"
    return
  fi
  python3 - "$value" <<'PY'
import sys
from datetime import datetime, timezone

raw = sys.argv[1].replace("Z", "+00:00")
dt = datetime.fromisoformat(raw)
if dt.tzinfo is None:
    dt = dt.replace(tzinfo=timezone.utc)
print(int(dt.timestamp() * 1000))
PY
}

START_MS=""
END_MS=""
EMAIL=""
PAGE_SIZE=100
RAW=0
ALL_PAGES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --start) START_MS="$(to_epoch_ms "$2")"; shift 2 ;;
    --end) END_MS="$(to_epoch_ms "$2")"; shift 2 ;;
    --email) EMAIL="$2"; shift 2 ;;
    --page-size) PAGE_SIZE="$2"; shift 2 ;;
    --raw) RAW=1; shift ;;
    --all-pages) ALL_PAGES=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$START_MS" || -z "$END_MS" ]]; then
  echo "error: --start and --end are required" >&2
  usage
  exit 1
fi

if [[ -z "$API_KEY" ]]; then
  echo "error: set CURSOR_ADMIN_API_KEY (team admin key from https://cursor.com/settings)" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq is required" >&2
  exit 1
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

page=1
while true; do
  BODY=$(jq -n \
    --argjson start "$START_MS" \
    --argjson end "$END_MS" \
    --argjson page "$page" \
    --argjson pageSize "$PAGE_SIZE" \
    --arg email "$EMAIL" \
    '{
      startDate: $start,
      endDate: $end,
      page: $page,
      pageSize: $pageSize
    } + (if ($email | length) > 0 then {email: $email} else {} end)')

  HTTP_CODE=$(curl -sS -o "$TMP" -w "%{http_code}" -u "${API_KEY}:" \
    -H "Content-Type: application/json" \
    -X POST "${API_BASE}/teams/filtered-usage-events" \
    -d "$BODY")

  if [[ "$HTTP_CODE" != "200" ]]; then
    echo "error: HTTP $HTTP_CODE" >&2
    jq . "$TMP" 2>/dev/null || cat "$TMP" >&2
    exit 1
  fi

  if [[ "$RAW" -eq 1 && "$ALL_PAGES" -eq 0 ]]; then
    jq . "$TMP"
    exit 0
  fi

  if [[ "$page" -eq 1 ]]; then
    cp "$TMP" "${TMP}.all"
  else
    jq -s '{usageEvents: (.[0].usageEvents + .[1].usageEvents), totalUsageEventsCount: .[0].totalUsageEventsCount, pagination: .[1].pagination, period: .[0].period}' \
      "${TMP}.all" "$TMP" > "${TMP}.merged"
    mv "${TMP}.merged" "${TMP}.all"
  fi

  has_next="$(jq -r '.pagination.hasNextPage // false' "$TMP")"
  if [[ "$ALL_PAGES" -eq 0 || "$has_next" != "true" ]]; then
    break
  fi
  page=$((page + 1))
done

DATA="${TMP}.all"
if [[ ! -f "$DATA" ]]; then
  cp "$TMP" "$DATA"
fi

if [[ "$RAW" -eq 1 ]]; then
  jq . "$DATA"
  exit 0
fi

jq -r --argjson start "$START_MS" --argjson end "$END_MS" '
  .usageEvents // [] |
  "window_ms: \($start) – \($end)",
  "totalUsageEventsCount: \(. | length)",
  (group_by(.model) | map({
    model: (.[0].model // "unknown"),
    count: length,
    cents: (map(.chargedCents // 0) | add)
  }) | sort_by(-.cents)[] |
    "\(.model)\t\(.count) events\t$\((.cents / 100) | tonumber | . * 100 | round / 100)"
  ),
  "",
  "total_cents: \(map(.chargedCents // 0) | add)",
  "total_usd: $\((map(.chargedCents // 0) | add) / 100)"
' "$DATA"
