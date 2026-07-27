#!/usr/bin/env bash
# Symlink this repo skill into ~/.cursor/skills/cidr-letterhead for global Cursor use.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_DST="$HOME/.cursor/skills/cidr-letterhead"

mkdir -p "$HOME/.cursor/skills"
ln -sfn "$SKILL_SRC" "$SKILL_DST"

echo "Installed: $SKILL_DST -> $SKILL_SRC"
echo "Invoke in Cursor: /cidr-letterhead"
