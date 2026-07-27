#!/usr/bin/env bash
# Ensure cidrlab/library is present, up to date, and templates deps are installed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

export_cidr_library
cd "$CIDR_LIBRARY"

echo "CIDR_LIBRARY=$CIDR_LIBRARY"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a git repo — skipping pull" >&2
elif git diff --quiet && git diff --cached --quiet; then
  echo "Pulling latest..."
  git pull --ff-only || echo "Pull skipped (no upstream or non-fast-forward)"
else
  echo "Working tree has local changes — skipping pull (commit or stash first)"
fi

if [[ ! -f templates/_build/cidr_brand.js ]]; then
  echo "Missing templates/_build/cidr_brand.js after pull" >&2
  exit 1
fi

if [[ ! -d templates/node_modules/docx ]]; then
  echo "Installing templates npm deps..."
  (cd templates && npm install)
else
  echo "templates/node_modules OK"
fi

echo "Library ready."
