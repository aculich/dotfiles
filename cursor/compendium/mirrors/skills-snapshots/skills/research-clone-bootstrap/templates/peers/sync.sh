#!/usr/bin/env zsh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
LIST="$ROOT/repos.txt"
DEST="$ROOT/clones"
mkdir -p "$DEST"
ok=0
fail=0
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%%#*}"
  line="${line// /}"
  [[ -z "$line" ]] && continue
  repo="$line"
  repo="${repo#https://github.com/}"
  repo="${repo%.git}"
  owner="${repo%%/*}"
  name="${repo#*/}"
  dir="$DEST/${owner}__${name}"
  if [[ -d "$dir/.git" ]]; then
    echo "fetch  $repo"
    git -C "$dir" fetch --depth 1 origin 2>/dev/null || true
    git -C "$dir" reset --hard FETCH_HEAD 2>/dev/null || true
    ((ok++)) || true
    continue
  fi
  echo "clone  $repo → $dir"
  if git clone --depth 1 "https://github.com/${repo}.git" "$dir"; then
    ((ok++)) || true
  else
    echo "FAIL   $repo" >&2
    ((fail++)) || true
  fi
done < "$LIST"
echo "Done: $ok ok, $fail failed → $DEST"
