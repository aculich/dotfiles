#!/usr/bin/env bash
# Point the user at the Cursor Classic Raycast script-command directory.
# Raycast has no supported CLI to register a script folder; this opens it
# and prints the Settings path.

set -euo pipefail

DIR="$HOME/dotfiles/cursor/raycast/script-commands"

if [[ ! -d "$DIR" ]]; then
  echo "error: missing $DIR" >&2
  exit 1
fi

chmod +x "$DIR"/*.sh "$HOME/dotfiles/cursor/scripts/cursor-classic-open.py"

echo "Raycast Script Commands directory:"
echo "  $DIR"
echo ""
echo "Add it once: Raycast Settings → Extensions → Script Commands → Add Script Directory"
echo "Then search Raycast for: Search Recent Projects (Classic)"
echo ""
echo "Do not rewrite ~/.config/raycast/extensions/*/js — Store copies are integrity-checked."
echo "If the Store Cursor commands still error, quit Raycast (Cmd+Q) and reopen it."
echo "Those files were restored; disable the Store Cursor extension if you want only Classic."

open "$DIR"
