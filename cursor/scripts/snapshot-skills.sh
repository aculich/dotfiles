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
DEST="${1:-$REPO_CURSOR/compendium/mirrors/skills-snapshots}"
CURSOR_DIR="${CURSOR_DIR:-$HOME/.cursor}"

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

for tree in skills skills-cursor; do
  src="$CURSOR_DIR/$tree"
  if [[ ! -d "$src" ]]; then
    echo "skip: $src not found" >&2
    continue
  fi
  rsync -aL --delete "${RSYNC_EXCLUDES[@]}" "$src/" "$DEST/$tree/"
  echo "mirrored: $src -> $DEST/$tree" >&2
done

# Provenance / quick-diff manifest, including which entries were symlinks.
{
  echo "# Cursor skills snapshot"
  echo "generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "source: $CURSOR_DIR/{skills,skills-cursor}"
  echo "note: symlinked skills are dereferenced (real content copied into mirror)"
  echo
  echo "## symlinked skills at snapshot time"
  find "$CURSOR_DIR/skills" "$CURSOR_DIR/skills-cursor" -maxdepth 1 -type l \
    -exec sh -c 'printf "%s -> %s\n" "$1" "$(readlink "$1")"' _ {} \; 2>/dev/null | sort
} > "$DEST/MANIFEST.txt"

echo "Skills mirrored to: $DEST" >&2
echo "$DEST"
