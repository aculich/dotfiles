#!/usr/bin/env bash
# Fail if any configured git remote for skills/compendium repos is not private.
#
# Usage:
#   verify-private-remotes.sh              # check dotfiles + compendium
#   verify-private-remotes.sh /path/repo   # check one repo

set -euo pipefail

check_repo() {
  local repo="$1"
  [[ -d "$repo/.git" ]] || { echo "skip (not a git repo): $repo" >&2; return 0; }

  local remote url owner name visibility
  remote="$(git -C "$repo" remote 2>/dev/null | head -1)"
  if [[ -z "$remote" ]]; then
    echo "ok (no remote): $repo" >&2
    return 0
  fi

  url="$(git -C "$repo" remote get-url "$remote" 2>/dev/null || true)"
  if [[ -z "$url" ]]; then
    echo "warn: cannot read remote URL for $repo" >&2
    return 0
  fi

  if [[ "$url" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
    owner="${BASH_REMATCH[1]}"
    name="${BASH_REMATCH[2]}"
    if ! command -v gh >/dev/null 2>&1; then
      echo "warn: gh not installed; cannot verify $owner/$name" >&2
      return 0
    fi
    visibility="$(gh repo view "$owner/$name" --json visibility -q .visibility 2>/dev/null || echo UNKNOWN)"
    if [[ "$visibility" == "PRIVATE" ]]; then
      echo "ok (PRIVATE): $owner/$name ($repo)" >&2
    elif [[ "$visibility" == "UNKNOWN" ]]; then
      echo "warn: could not verify visibility for $owner/$name" >&2
    else
      echo "FAIL: $owner/$name is $visibility (expected PRIVATE)" >&2
      return 1
    fi
  else
    echo "ok (non-GitHub remote): $url" >&2
  fi
}

fail=0
if [[ "${#}" -gt 0 ]]; then
  for repo in "$@"; do
    check_repo "$repo" || fail=1
  done
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  DOTFILES_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
  COMPENDIUM="${CURSOR_COMPENDIUM_ROOT:-$HOME/src/dotfiles-cursor-compendium}"

  check_repo "$DOTFILES_ROOT" || fail=1
  check_repo "$COMPENDIUM" || fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "One or more remotes are not private. Fix before pushing skills/compendium data." >&2
  exit 1
fi

echo "All checked remotes are private (or local-only)." >&2
