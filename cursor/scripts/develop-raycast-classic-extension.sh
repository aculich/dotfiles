#!/usr/bin/env bash
# Install deps and register the local Cursor Classic Raycast extension.
# Requires Raycast to be running. First run uses `ray develop`.

set -euo pipefail

EXT="$HOME/dotfiles/cursor/raycast/cursor-classic-extension"

if [[ ! -f "$EXT/package.json" ]]; then
  echo "error: missing $EXT/package.json" >&2
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "error: npm is required to build the Raycast extension" >&2
  exit 1
fi

echo "Installing npm deps in $EXT"
(cd "$EXT" && npm install)

echo ""
echo "Keep the Store Cursor extension disabled so titles do not collide."
echo "Raycast must be running. Starting ray develop (Ctrl+C after commands appear)."
echo "Later updates: cd $EXT && npm run dev"
echo ""

cd "$EXT"
exec npm run dev
