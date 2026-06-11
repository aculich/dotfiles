#!/usr/bin/env bash
# Refresh data/cursor-plan-rates.json model rates from kingdomseed catalog.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CATALOG="$ROOT/upstream/kingdomseed__cursor-calculator/src/data/cursor-pricing.json"
OUT="$ROOT/data/cursor-plan-rates.json"

if [[ ! -f "$CATALOG" ]]; then
  echo "error: missing $CATALOG — clone upstream/kingdomseed__cursor-calculator first" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq required" >&2
  exit 1
fi

TODAY="$(date -u +%Y-%m-%d)"
jq \
  --arg retrieved "$TODAY" \
  --arg source "upstream/kingdomseed__cursor-calculator/src/data/cursor-pricing.json" \
  '
  def slim: {pool, input: .rates.input, output: .rates.output};
  .models as $all |
  ($all | map(select(.id == "claude-4-6-sonnet"))[0] | slim) as $sonnet |
  {
    meta: {
      source: $source,
      official_url: "https://cursor.com/docs/models-and-pricing",
      retrieved_at: $retrieved,
      note: "Subset for plan-cost scripts. Refresh with scripts/sync-cursor-pricing-snapshot.sh"
    },
    plans: {
      pro: {api_pool_usd: .plans.pro.api_pool},
      pro_plus: {api_pool_usd: .plans.pro_plus.api_pool},
      ultra: {api_pool_usd: .plans.ultra.api_pool}
    },
    models: (
      [$all[] | select(.id == "auto" or .id == "composer-2.5" or .id == "claude-4-5-haiku"
        or .id == "gpt-5.3-codex" or .id == "claude-4-6-sonnet" or .id == "claude-opus-4-8"
        or .id == "claude-fable-5" or .id == "gemini-3.1-pro")]
      | map({key: .id, value: slim})
      | from_entries
      + (if $sonnet then {"claude-sonnet-4-6": $sonnet} else {} end)
    )
  }
  ' "$CATALOG" > "$OUT"

echo "wrote $OUT"
