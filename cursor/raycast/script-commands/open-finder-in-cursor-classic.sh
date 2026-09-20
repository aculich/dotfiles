#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title Open Finder Selection in Classic
# @raycast.mode silent
# @raycast.packageName Cursor Classic
# @raycast.icon 🖥️
# @raycast.description Open the Finder selection (or front window) in classic Cursor IDE
# @raycast.author Aaron Culich

set -euo pipefail

python3 "$HOME/dotfiles/cursor/scripts/cursor-classic-open.py" finder
echo "Opened Finder item in classic Cursor"
