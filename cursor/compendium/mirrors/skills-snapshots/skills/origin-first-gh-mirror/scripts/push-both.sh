#!/usr/bin/env bash
# Push the current branch to Origin (SoT) then the GitHub backup remote.
# Does not create, rename, or rewrite remotes.
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "push-both: not inside a git work tree" >&2
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "push-both: missing remote 'origin' (expected origin.cursor.com)" >&2
  exit 1
fi

if ! git remote get-url github >/dev/null 2>&1; then
  echo "push-both: missing remote 'github' (private GitHub backup)" >&2
  exit 1
fi

origin_url="$(git remote get-url origin)"
case "$origin_url" in
  *origin.cursor.com*)
    ;;
  *)
    echo "push-both: remote 'origin' is not origin.cursor.com: $origin_url" >&2
    exit 1
    ;;
esac

branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ "$branch" == "HEAD" ]]; then
  echo "push-both: detached HEAD; checkout a branch first" >&2
  exit 1
fi

git push origin "$branch"
git push github "$branch"
