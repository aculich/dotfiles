#!/usr/bin/env bash
# @raycast.schemaVersion 1
# @raycast.title Open New Classic Window
# @raycast.mode silent
# @raycast.packageName Cursor Classic
# @raycast.icon 🖥️
# @raycast.description Open a new classic Cursor IDE window (--classic)
# @raycast.author Aaron Culich

set -euo pipefail

python3 "$HOME/dotfiles/cursor/scripts/cursor-classic-open.py" new-window
echo "Opened classic Cursor window"
