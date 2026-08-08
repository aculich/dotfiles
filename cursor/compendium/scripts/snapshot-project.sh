#!/usr/bin/env bash
set -euo pipefail

# Usage: snapshot-project.sh <slug> <absolute-project-root>
# Mirrors .cursor/ (excluding mcp.json), .cursor/plans, and .specstory/**/*.mdc rules if present (not full history by default).

if [[ "${#}" -ne 2 ]]; then
  echo "Usage: $0 <slug> <absolute-project-root>" >&2
  exit 1
fi

SLUG="$1"
PROJ="$2"
ROOT="${CURSOR_COMPENDIUM_ROOT:?Set CURSOR_COMPENDIUM_ROOT}"

if [[ ! -d "${PROJ}" ]]; then
  echo "Project path not a directory: ${PROJ}" >&2
  exit 1
fi

MIRROR="${ROOT}/mirrors/by-project/${SLUG}"
mkdir -p "${MIRROR}"

if [[ -d "${PROJ}/.cursor" ]]; then
  rsync -a \
    --exclude='mcp.json' \
    --exclude='.DS_Store' \
    "${PROJ}/.cursor/" "${MIRROR}/.cursor/"
fi

if [[ -d "${PROJ}/.cursor/plans" ]]; then
  mkdir -p "${ROOT}/plans/by-project/${SLUG}"
  rsync -a "${PROJ}/.cursor/plans/" "${ROOT}/plans/by-project/${SLUG}/"
fi

# SpecStory: rules and small text only (tune excludes for your policy)
if [[ -d "${PROJ}/.specstory" ]]; then
  mkdir -p "${MIRROR}/.specstory"
  rsync -a \
    --exclude='history/' \
    "${PROJ}/.specstory/" "${MIRROR}/.specstory/" || true
fi

# Per-path log line only under COMPENDIUM_LOG=verbose (progress/quiet stay silent;
# snapshot-all.sh owns the progress counter and summary).
if [[ "${COMPENDIUM_LOG:-progress}" == "verbose" ]]; then
  echo "Snapshot ${PROJ} -> mirrors/by-project/${SLUG}/ (+ plans if any)"
fi
