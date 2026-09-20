#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title Search Recent Projects (Classic)
# @raycast.mode fullOutput
# @raycast.packageName Cursor Classic
# @raycast.icon 🖥️
# @raycast.description Open a recent Cursor workspace or folder in the classic IDE
# @raycast.author Aaron Culich
# @raycast.argument1 { "type": "text", "placeholder": "pet-master, rrid, peeq…", "optional": true }

set -euo pipefail

python3 "$HOME/dotfiles/cursor/scripts/cursor-classic-open.py" open "${1:-}"
