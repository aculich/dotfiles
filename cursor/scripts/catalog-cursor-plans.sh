#!/usr/bin/env bash
# List Cursor plan files: ~/.cursor/plans, optional ~/.cursor/projects, optional PROJECT_ROOTS.
set -euo pipefail

CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
PROJECT_ROOTS="${PROJECT_ROOTS:-}"

echo "# Cursor plan catalog (paths ending in .plan.md)"
echo "# CURSOR_HOME=$CURSOR_HOME"
echo "# generated $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

if [[ -d "$CURSOR_HOME/plans" ]]; then
  echo "## $CURSOR_HOME/plans"
  find "$CURSOR_HOME/plans" -maxdepth 1 -name '*.plan.md' -type f 2>/dev/null | sort || true
  echo ""
fi

if [[ -d "$CURSOR_HOME/projects" ]]; then
  echo "## Under $CURSOR_HOME/projects (if any)"
  find "$CURSOR_HOME/projects" -name '*.plan.md' -type f 2>/dev/null | sort | head -200 || true
  echo ""
fi

if [[ -n "$PROJECT_ROOTS" ]]; then
  echo "## From PROJECT_ROOTS (each .../.cursor/plans)"
  for r in $PROJECT_ROOTS; do
    [[ -d "$r/.cursor/plans" ]] || continue
    echo "### $r"
    find "$r/.cursor/plans" -maxdepth 1 -name '*.plan.md' -type f 2>/dev/null | sort || true
  done
  echo ""
fi

echo "# Tip: set PROJECT_ROOTS='~/projects/foo ~/dotfiles' to include workspace-saved plans."
echo "# There is no single global plans database; .plan.md files on disk are the source of truth."
