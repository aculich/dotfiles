#!/usr/bin/env bash
# Snapshot all skill tiers: global Cursor, agents, and refresh inventory.
#
# Project-local skills are mirrored when you run compendium/scripts/snapshot-all.sh
# (snapshot-project.sh rsyncs each project's .cursor/, including .cursor/skills/).
#
# Usage:
#   snapshot-all-skills.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CURSOR="$(cd "$SCRIPT_DIR/.." && pwd)"
COMPENDIUM_ROOT="${CURSOR_COMPENDIUM_ROOT:-$REPO_CURSOR/compendium}"
DOTFILES_CURSOR="${DOTFILES_CURSOR:-$REPO_CURSOR}"

export CURSOR_COMPENDIUM_ROOT="$COMPENDIUM_ROOT"
export DOTFILES_CURSOR

echo "==> verify remotes are private" >&2
"$SCRIPT_DIR/verify-private-remotes.sh" "$(cd "$REPO_CURSOR/.." && pwd)" "$COMPENDIUM_ROOT" 2>/dev/null || \
  "$SCRIPT_DIR/verify-private-remotes.sh" "$(cd "$REPO_CURSOR/.." && pwd)"

echo "==> mirror global ~/.cursor/skills + skills-cursor + ~/.agents/skills" >&2
"$SCRIPT_DIR/snapshot-skills.sh" "$COMPENDIUM_ROOT/mirrors/skills-snapshots"

if [[ "${SKILL_DISCOVER:-1}" == "1" ]]; then
  echo "==> discover skills inventory (set SKILL_DISCOVER=0 to skip the slow project scan)" >&2
  DISCOVER_PY="$COMPENDIUM_ROOT/scripts/discover-skills.py"
  if [[ ! -f "$DISCOVER_PY" ]]; then
    DISCOVER_PY="$DOTFILES_CURSOR/compendium/scripts/discover-skills.py"
  fi
  python3 "$DISCOVER_PY" --compendium-root "$COMPENDIUM_ROOT"
else
  echo "==> skipping inventory discovery (SKILL_DISCOVER=0)" >&2
fi

if [[ -f "$COMPENDIUM_ROOT/scripts/snapshot-all.sh" && "${SNAPSHOT_PROJECT_SKILLS:-0}" == "1" ]]; then
  echo "==> snapshot project .cursor/ trees (including project-local skills)" >&2
  "$COMPENDIUM_ROOT/scripts/snapshot-all.sh"
fi

echo "snapshot-all-skills complete: $COMPENDIUM_ROOT" >&2
