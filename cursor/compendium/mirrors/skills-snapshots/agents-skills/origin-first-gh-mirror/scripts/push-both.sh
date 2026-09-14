#!/usr/bin/env bash
# Push the current branch to Origin (SoT) then the GitHub backup remote.
# Does not create, rename, or rewrite remotes.
set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib-remotes.sh
source "${_script_dir}/lib-remotes.sh"

origin_gh_require_remotes "push-both"

git push origin "$ORIGIN_GH_BRANCH"
git push github "$ORIGIN_GH_BRANCH"
