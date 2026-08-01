#!/usr/bin/env bash
# Verify the ops/compendium remote is PRIVATE, then commit dirty tree and push.
#
# Usage (from CURSOR_COMPENDIUM_ROOT, or with env set):
#   ./scripts/commit-and-push.sh
#
# Requires: git, gh (for privacy check). Opt out of calling this via COMPENDIUM_AUTO_PUSH=0
# on snapshot-all.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${CURSOR_COMPENDIUM_ROOT:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
cd "${ROOT}"

if [[ ! -d "${ROOT}/.git" ]]; then
  echo "commit-and-push: not a git repo: ${ROOT}" >&2
  echo "Tip: live ops tree is usually ~/ops/dotfiles-cursor-compendium (set CURSOR_COMPENDIUM_ROOT)." >&2
  exit 1
fi

DOTFILES_CURSOR="${DOTFILES_CURSOR:-$HOME/dotfiles/cursor}"
VERIFY="${DOTFILES_CURSOR}/scripts/verify-private-remotes.sh"
if [[ -x "${VERIFY}" ]]; then
  "${VERIFY}" "${ROOT}"
else
  # Fallback if verify script missing: require gh + PRIVATE
  remote="$(git remote | head -1)"
  [[ -n "${remote}" ]] || { echo "commit-and-push: no git remote" >&2; exit 1; }
  url="$(git remote get-url "${remote}")"
  if [[ "$url" =~ github\.com[:/]([^/]+)/([^/.]+) ]]; then
    visibility="$(gh repo view "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}" --json visibility -q .visibility 2>/dev/null || echo UNKNOWN)"
    if [[ "${visibility}" != "PRIVATE" ]]; then
      echo "commit-and-push: FAIL remote is ${visibility} (expected PRIVATE): ${url}" >&2
      exit 1
    fi
  fi
fi

git add -A
if git diff --cached --quiet; then
  echo "commit-and-push: nothing to commit."
else
  git commit -m "chore(compendium): snapshot $(date +%Y-%m-%d)"
  echo "commit-and-push: committed."
fi

branch="$(git rev-parse --abbrev-ref HEAD)"
upstream="$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || true)"
if [[ -z "${upstream}" ]]; then
  echo "commit-and-push: no upstream for ${branch}; pushing with -u origin ${branch}"
  git push -u origin "${branch}"
elif [[ -n "$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null)" ]] && \
     [[ "$(git rev-list --count '@{upstream}..HEAD')" != "0" ]]; then
  git push
  echo "commit-and-push: pushed to ${upstream}."
else
  echo "commit-and-push: already up to date with ${upstream}."
fi
