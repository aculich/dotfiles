#!/usr/bin/env bash
# Symlink this skill into ~/.cursor/skills for global discovery.
set -euo pipefail

SRC="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${HOME}/.cursor/skills/ern-cidr-mail"

if [[ ! -d "$SRC" ]]; then
  echo "Missing skill source: $SRC" >&2
  exit 1
fi

mkdir -p "${HOME}/.cursor/skills"
ln -sfn "$SRC" "$DEST"
echo "Linked $DEST -> $SRC"
ls -la "$DEST"
