#!/usr/bin/env bash
set -euo pipefail

ROOT="${CURSOR_COMPENDIUM_ROOT:?Set CURSOR_COMPENDIUM_ROOT to compendium git root}"
SRC="${HOME}/.cursor/plans"
DST="${ROOT}/plans/global"

if [[ ! -d "${SRC}" ]]; then
  echo "No global plans dir at ${SRC}; skipping."
  exit 0
fi

mkdir -p "${DST}"
# No --delete by default (removed plans in ~/.cursor/plans stay in compendium until you prune manually)
rsync -a \
  --exclude='mcp.json' \
  "${SRC}/" "${DST}/"

echo "Synced ${SRC} -> ${DST}"
