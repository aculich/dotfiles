#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UP="$ROOT/upstream/kingdomseed__cursor-calculator"

if [[ ! -d "$UP" ]]; then
  echo "error: clone upstream/kingdomseed__cursor-calculator first" >&2
  exit 1
fi

cd "$UP"
if [[ ! -d node_modules ]]; then
  npm install
fi
exec npm run dev
