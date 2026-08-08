#!/usr/bin/env bash
# Mirror live Cursor skills into the dotfiles repo for version control + backup.
#
# Copies ~/.cursor/skills and ~/.cursor/skills-cursor into
# cursor/compendium/mirrors/skills-snapshots/, dereferencing symlinks so skills
# that actually live in other repos are captured too. Junk (caches, .DS_Store,
# node_modules, .git) is excluded. Run periodically or before big changes, then
# commit the result.
#
# Logging: COMPENDIUM_LOG=quiet|progress|verbose (default progress).
#   progress — emits `skills +|~|- <tree>/<name>` signal lines for changed
#              skills (capped) plus one closing status line
#   quiet    — no output
#   verbose  — legacy chatty output plus uncapped per-skill change lines
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

# Shared logging helpers (canonical copy lives in the dotfiles scaffold).
LOG_LIB="$REPO_CURSOR/compendium/scripts/lib/logging.sh"
if [[ -f "$LOG_LIB" ]]; then
  # shellcheck source=../compendium/scripts/lib/logging.sh
  source "$LOG_LIB"
else
  COMP_LOG_MODE="${COMPENDIUM_LOG:-verbose}"
  comp_signal() { printf '%s\n' "$1"; }
  comp_verbose() { printf '%s\n' "$1"; }
fi

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

CHANGES_FILE="$(mktemp)"
trap 'rm -f "$CHANGES_FILE"' EXIT
TREES_DONE=0

# rsync --itemize-changes format: 11-char flag field, space, then the path
# (filename = substr(line, 13) — uniform for updates and `*deleting` lines).
# Classify per top-level skill dir: A = new skill dir, D = skill dir deleted,
# M = content changed inside an existing skill. Attribute-only lines (leading
# '.') are ignored to avoid mtime false positives.
mirror_tree() {
  local src="$1" dest_name="$2"
  if [[ ! -d "$src" ]]; then
    comp_verbose "skip: $src not found"
    return 0
  fi
  rsync -aiL --delete "${RSYNC_EXCLUDES[@]}" "$src/" "$DEST/$dest_name/" \
    | awk -v tree="$dest_name" '
        {
          flags = substr($0, 1, 11)
          # Only true itemize lines ("*deleting" or "<YXtype..." with a file
          # type in column 2); skips messages like "created directory /x".
          if (flags !~ /^\*deleting/ && flags !~ /^[<>ch.][dfLDS]/) next
          path  = substr($0, 13)
          sub(/\/$/, "", path)
          if (path == "." || path == "") next
          top = path
          sub(/\/.*/, "", top)
          if (flags ~ /^\*deleting/) {
            if (path !~ /\//) print "D\t" tree "/" top
            else               print "M\t" tree "/" top
          } else if (substr(flags, 1, 2) == "cd" && path !~ /\//) {
            print "A\t" tree "/" top
          } else if (flags ~ /^[<>ch]/) {
            print "M\t" tree "/" top
          }
        }
      ' >> "$CHANGES_FILE"
  TREES_DONE=$(( TREES_DONE + 1 ))
  comp_verbose "mirrored: $src -> $DEST/$dest_name"
}

mirror_tree "$CURSOR_DIR/skills" "skills"
mirror_tree "$CURSOR_DIR/skills-cursor" "skills-cursor"
mirror_tree "$AGENTS_DIR" "agents-skills"

# Collapse to one line per skill (A/D win over M), then report with a cap.
report_changes() {
  local collapsed n_added n_mod n_del total cap shown line kind name sym
  collapsed="$(awk -F'\t' '
    $1 == "A" { s[$2] = "A"; next }
    $1 == "D" { if (s[$2] != "A") s[$2] = "D"; next }
    $1 == "M" { if (!($2 in s)) s[$2] = "M" }
    END { for (k in s) print s[k] "\t" k }
  ' "$CHANGES_FILE" | sort -t "$(printf '\t')" -k2,2)"

  if [[ -z "$collapsed" ]]; then
    comp_signal "skills mirrored (${TREES_DONE} trees): no changes"
    return 0
  fi

  n_added="$(printf '%s\n' "$collapsed" | grep -c '^A' || true)"
  n_mod="$(printf '%s\n' "$collapsed" | grep -c '^M' || true)"
  n_del="$(printf '%s\n' "$collapsed" | grep -c '^D' || true)"
  total=$(( n_added + n_mod + n_del ))

  # Volume cap: past 20 deltas show only the first 10 names (verbose: uncapped).
  cap="$total"
  if [[ "${COMP_LOG_MODE:-progress}" != "verbose" && "$total" -gt 20 ]]; then
    cap=10
  fi

  shown=0
  while IFS=$'\t' read -r kind name; do
    if [[ "$shown" -ge "$cap" ]]; then
      break
    fi
    case "$kind" in
      A) sym='+' ;;
      D) sym='-' ;;
      *) sym='~' ;;
    esac
    comp_signal "skills ${sym} ${name}"
    shown=$(( shown + 1 ))
  done <<< "$collapsed"

  if [[ "$shown" -lt "$total" ]]; then
    comp_signal "skills ... and $(( total - shown )) more changes"
  fi
  comp_signal "skills mirrored (${TREES_DONE} trees): +${n_added} ~${n_mod} -${n_del}"
}

report_changes

# Provenance / quick-diff manifest, including which entries were symlinks.
# No timestamp here on purpose: git commit date records "when"; keeping the file
# content stable means backups only commit when skill content actually changes.
{
  echo "# Cursor skills snapshot"
  echo "source: $CURSOR_DIR/{skills,skills-cursor}, $AGENTS_DIR"
  echo "note: symlinked skills are dereferenced (real content copied into mirror)"
  echo
  echo "## symlinked skills at snapshot time"
  find "$CURSOR_DIR/skills" "$CURSOR_DIR/skills-cursor" "$AGENTS_DIR" -maxdepth 1 -type l \
    -exec sh -c 'printf "%s -> %s\n" "$1" "$(readlink "$1")"' _ {} \; 2>/dev/null | sort
} > "$DEST/MANIFEST.txt"

if [[ "${COMP_LOG_MODE:-progress}" == "verbose" ]]; then
  echo "Skills mirrored to: $DEST" >&2
  echo "$DEST"
fi
