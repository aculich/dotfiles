#!/usr/bin/env bash
# Map ~/.cursor/projects/*/canvases → project slug + canvas files.
# Optionally correlate with workspaceStorage workspace.json folder URIs.
set -euo pipefail

CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
WS_ROOT="${CURSOR_WS_ROOT:-$HOME/Library/Application Support/Cursor/User/workspaceStorage}"
INCLUDE_WS="${INCLUDE_WS:-0}"

echo "# Cursor canvas catalog"
echo "# CURSOR_HOME=$CURSOR_HOME"
echo "# generated $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

if [[ ! -d "$CURSOR_HOME/projects" ]]; then
  echo "# No $CURSOR_HOME/projects"
  exit 0
fi

count=0
while IFS= read -r -d '' dir; do
  slug=$(basename "$(dirname "$dir")")
  files=$(find "$dir" -maxdepth 1 \( -name '*.canvas.tsx' -o -name '*.canvas.ts' -o -name '*.canvas.data.json' \) -type f 2>/dev/null | sort || true)
  n=$(printf '%s\n' "$files" | grep -c . || true)
  [[ "$n" -eq 0 ]] && continue
  count=$((count + 1))
  echo "## $slug"
  echo "path: $dir"
  # Reverse Cursor project slug: path separators became '-'. Prefer existing dirs.
  if [[ "$slug" == Users-me-* || "$slug" == Users-* ]]; then
    guessed=$(python3 -c "
import os
s = '''$slug'''
if s.startswith('Users-me-'):
    rest = s[len('Users-me-'):]
    prefixes = ('projects', 'tools', 'dotfiles', 'ops', 'ern', 'Library')
    cands = []
    for p in prefixes:
        if rest == p:
            cands.append('/Users/me/' + p)
        elif rest.startswith(p + '-'):
            rem = rest[len(p)+1:]
            cands.append('/Users/me/' + p + '/' + rem)
            cands.append('/Users/me/' + p + '/' + rem.replace('-', '/'))
    cands.append('/Users/me/' + rest)
    cands.append('/Users/me/' + rest.replace('-', '/'))
    for c in cands:
        if os.path.isdir(c):
            print(c)
            raise SystemExit
    print(cands[0] if cands else '')
elif s.startswith('Users-'):
    print('/' + s.replace('-', '/'))
" 2>/dev/null || true)
    if [[ -n "$guessed" ]]; then
      echo "guessed_folder: $guessed"
      [[ -d "$guessed" ]] && echo "guessed_exists: yes" || echo "guessed_exists: no"
    fi
  fi
  printf '%s\n' "$files" | while read -r f; do
    [[ -n "$f" ]] && echo "  - $(basename "$f")"
  done
  echo ""
done < <(find "$CURSOR_HOME/projects" -maxdepth 2 -type d -name canvases -print0 2>/dev/null)

echo "# projects_with_canvases=$count"

if [[ "$INCLUDE_WS" == "1" && -d "$WS_ROOT" ]]; then
  echo ""
  echo "## workspaceStorage folder map (sample)"
  find "$WS_ROOT" -name workspace.json -type f 2>/dev/null | head -50 | while read -r wj; do
    id=$(basename "$(dirname "$wj")")
    folder=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1])).get('folder',''))" "$wj" 2>/dev/null || true)
    echo "$id	$folder"
  done
fi

echo ""
echo "# Tip: INCLUDE_WS=1 $0  to include workspaceStorage folder URIs."
echo "# Managed canvases live under ~/.cursor/projects/<id>/canvases/ (outside repo git)."
