#!/usr/bin/env bash
# Pull Origin (fast-forward only), then push Origin and GitHub.
# Does not pull from github. Does not create, rename, or rewrite remotes.
set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib-remotes.sh
source "${_script_dir}/lib-remotes.sh"

origin_gh_require_remotes "sync"

git fetch origin
if ! git pull --ff-only origin "$ORIGIN_GH_BRANCH"; then
  echo "sync: Origin is not a fast-forward. Resolve locally; do not merge or rebase silently." >&2
  exit 1
fi

"${_script_dir}/push-both.sh"
