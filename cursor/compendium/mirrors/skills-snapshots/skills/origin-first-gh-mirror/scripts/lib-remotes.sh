#!/usr/bin/env bash
# Shared remote checks for Origin-SoT + GitHub backup. Sourced, not executed.
# Does not create, rename, or rewrite remotes.

origin_gh_require_remotes() {
  local prefix="${1:-origin-gh}"
  local origin_url

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "${prefix}: not inside a git work tree" >&2
    return 1
  fi

  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "${prefix}: missing remote 'origin' (expected origin.cursor.com)" >&2
    return 1
  fi

  if ! git remote get-url github >/dev/null 2>&1; then
    echo "${prefix}: missing remote 'github' (private GitHub backup)" >&2
    return 1
  fi

  origin_url="$(git remote get-url origin)"
  case "$origin_url" in
    *origin.cursor.com*)
      ;;
    *)
      echo "${prefix}: remote 'origin' is not origin.cursor.com: $origin_url" >&2
      return 1
      ;;
  esac

  ORIGIN_GH_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "$ORIGIN_GH_BRANCH" == "HEAD" ]]; then
    echo "${prefix}: detached HEAD; checkout a branch first" >&2
    return 1
  fi
}
