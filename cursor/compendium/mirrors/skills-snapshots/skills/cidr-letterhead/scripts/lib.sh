#!/usr/bin/env bash
# Shared helpers for cidr-letterhead skill scripts.
set -euo pipefail

# Resolve the cidrlab/library root. Resolution order:
#   1. $CIDR_LIBRARY (if it points at a valid library checkout)
#   2. the repo that contains this skill (script location, symlink-safe)
#   3. the enclosing git work tree
# No machine-specific paths: the skill lives inside the library repo, so its
# own location identifies the checkout even when symlinked into ~/.cursor/skills.
resolve_cidr_library() {
  if [[ -n "${CIDR_LIBRARY:-}" && -f "$CIDR_LIBRARY/templates/_build/cidr_brand.js" ]]; then
    printf '%s\n' "$CIDR_LIBRARY"
    return 0
  fi

  local script_dir repo_root toplevel
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # scripts → cidr-letterhead → skills → .cursor → repo root
  repo_root="$(cd "$script_dir/../../../.." && pwd)"

  if [[ -f "$repo_root/templates/_build/cidr_brand.js" ]]; then
    printf '%s\n' "$repo_root"
    return 0
  fi

  if toplevel="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null)"; then
    if [[ -f "$toplevel/templates/_build/cidr_brand.js" ]]; then
      printf '%s\n' "$toplevel"
      return 0
    fi
  fi

  echo "cidr-letterhead: cannot find cidrlab/library checkout (set CIDR_LIBRARY)" >&2
  return 1
}

export_cidr_library() {
  CIDR_LIBRARY="$(resolve_cidr_library)"
  export CIDR_LIBRARY
  export NODE_PATH="$CIDR_LIBRARY/templates/node_modules"
}

logo_path() {
  printf '%s/brand/logos/cidr-logos-v14/png-2x/wide-a-light.png' "$CIDR_LIBRARY"
}
