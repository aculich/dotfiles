#!/usr/bin/env bash
# Copy Origin-SoT sync helpers into a local clone and add a just recipe.
# Uses 'sync' unless that recipe already exists, then 'origin-gh-sync'.
set -euo pipefail

_skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dest="${1:-.}"

if [[ ! -d "$dest" ]]; then
  echo "install-just-sync: not a directory: $dest" >&2
  exit 1
fi

dest="$(cd "$dest" && pwd)"

if ! git -C "$dest" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "install-just-sync: not a git work tree: $dest" >&2
  exit 1
fi

mkdir -p "${dest}/scripts"
cp "${_skill_dir}/scripts/lib-remotes.sh" "${dest}/scripts/lib-remotes.sh"
cp "${_skill_dir}/scripts/push-both.sh" "${dest}/scripts/push-both.sh"
cp "${_skill_dir}/scripts/sync.sh" "${dest}/scripts/origin-gh-sync.sh"
chmod +x "${dest}/scripts/lib-remotes.sh" "${dest}/scripts/push-both.sh" "${dest}/scripts/origin-gh-sync.sh"

justfile="${dest}/justfile"
recipe="sync"
snippet="${_skill_dir}/justfile.sync-snippet"

if [[ -f "$justfile" ]]; then
  if (
    cd "$dest"
    just --list 2>/dev/null | grep -qE '^[[:space:]]*sync([[:space:]]|$)'
  ); then
    recipe="origin-gh-sync"
    snippet="${_skill_dir}/justfile.origin-gh-sync-snippet"
  fi
  if (
    cd "$dest"
    just --list 2>/dev/null | grep -qE "^[[:space:]]*${recipe}([[:space:]]|$)"
  ); then
    echo "install-just-sync: recipe '${recipe}' already present; helpers copied" >&2
    echo "$recipe"
    exit 0
  fi
  printf '\n' >>"$justfile"
  cat "$snippet" >>"$justfile"
  echo "install-just-sync: appended '${recipe}' to ${justfile}" >&2
else
  cp "$snippet" "$justfile"
  echo "install-just-sync: wrote ${justfile} with '${recipe}'" >&2
fi

echo "$recipe"
