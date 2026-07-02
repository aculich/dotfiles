#!/usr/bin/env bash
# Mirror live Cursor skills into the dotfiles repo for version control + backup.
#
# Copies ~/.cursor/skills and ~/.cursor/skills-cursor into
# cursor/compendium/mirrors/skills-snapshots/, dereferencing symlinks so skills
# that actually live in other repos are captured too. Junk (caches, .DS_Store,
# node_modules, .git) is excluded. Run periodically or before big changes, then
# commit the result.
#
# Usage:
#   snapshot-skills.sh              # mirror into the default location
#   snapshot-skills.sh /path/to/dir # custom destination root

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CURSOR="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPENDIUM_ROOT="${CURSOR_COMPENDIUM_ROOT:-$REPO_CURSOR/compendium}"
DEST="${1:-$COMPENDIUM_ROOT/mirrors/skills-snapshots}"
CURSOR_DIR="${CURSOR_DIR:-$HOME/.cursor}"
AGENTS_DIR="${AGENTS_DIR:-$HOME/.agents/skills}"

command -v rsync >/dev/null 2>&1 || { echo "rsync is required" >&2; exit 1; }

mkdir -p "$DEST"

# -a archive, -L dereference symlinks (capture linked skill content),
# --delete keep the mirror in sync with the live tree.
RSYNC_EXCLUDES=(
  --exclude '.git/'
  --exclude '__pycache__/'
  --exclude '*.pyc'
  --exclude '.DS_Store'
  --exclude 'node_modules/'
  --exclude '.venv/'
)

mirror_tree() {
  local src="$1" dest_name="$2"
  if [[ ! -d "$src" ]]; then
    echo "skip: $src not found" >&2
    return 0
  fi
  rsync -aL --delete "${RSYNC_EXCLUDES[@]}" "$src/" "$DEST/$dest_name/"
  echo "mirrored: $src -> $DEST/$dest_name" >&2
}

mirror_tree "$CURSOR_DIR/skills" "skills"
mirror_tree "$CURSOR_DIR/skills-cursor" "skills-cursor"
mirror_tree "$AGENTS_DIR" "agents-skills"

# Provenance / quick-diff manifest, including which entries were symlinks.
{
  echo "# Cursor skills snapshot"
  echo "generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "source: $CURSOR_DIR/{skills,skills-cursor}, $AGENTS_DIR"
  echo "note: symlinked skills are dereferenced (real content copied into mirror)"
  echo
  echo "## symlinked skills at snapshot time"
  find "$CURSOR_DIR/skills" "$CURSOR_DIR/skills-cursor" "$AGENTS_DIR" -maxdepth 1 -type l \
    -exec sh -c 'printf "%s -> %s\n" "$1" "$(readlink "$1")"' _ {} \; 2>/dev/null | sort
} > "$DEST/MANIFEST.txt"

echo "Skills mirrored to: $DEST" >&2
echo "$DEST"
