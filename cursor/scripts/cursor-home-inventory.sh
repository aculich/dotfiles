#!/usr/bin/env bash
# Walk ~/.cursor and write JSON path inventory (excludes high-churn dirs).
set -euo pipefail

export CURSOR_HOME="${CURSOR_HOME:-$HOME/.cursor}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="${OUT_DIR:-$REPO_ROOT/observability/inventories}"
export OUT_DIR
export MAX_SHA_BYTES="${MAX_SHA_BYTES:-200000}"
TS="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
OUT="${OUT_DIR}/cursor-home-${TS}.json"
mkdir -p "$OUT_DIR"

if [[ ! -d "$CURSOR_HOME" ]]; then
  echo "Not a directory: $CURSOR_HOME" >&2
  exit 1
fi

export OUT_PATH="$OUT"
export TS="$TS"
python3 <<'PY'
import hashlib, json, os
from pathlib import Path

root = Path(os.environ["CURSOR_HOME"]).resolve()
out_path = Path(os.environ["OUT_PATH"])
max_sha = int(os.environ.get("MAX_SHA_BYTES", "200000"))
ts = os.environ.get("TS", "")

exclude = frozenset({
    "chats", "projects", "worktrees", "extensions",
    "browser-logs", "ai-tracking", "workers",
})
skip_dirnames = frozenset({".git", "node_modules"})

def under_excluded(relp: Path) -> bool:
    return len(relp.parts) > 0 and relp.parts[0] in exclude

def rel(p: Path) -> Path:
    return p.relative_to(root)

entries = []
for dirpath, dirnames, filenames in os.walk(root, topdown=True):
    dpath = Path(dirpath)
    try:
        rd = dpath.relative_to(root)
    except ValueError:
        continue
    if under_excluded(rd):
        continue
    dirnames[:] = [d for d in dirnames if d not in skip_dirnames]
    for d in sorted(dirnames):
        p = dpath / d
        try:
            r = p.relative_to(root)
        except ValueError:
            continue
        if under_excluded(r):
            continue
        st = p.stat(follow_symlinks=False)
        entries.append({
            "relpath": str(r).replace(os.sep, "/"),
            "type": "symlink" if p.is_symlink() else "dir",
            "size": 0,
            "mtime": int(st.st_mtime),
        })
    for f in sorted(filenames):
        p = dpath / f
        try:
            r = p.relative_to(root)
        except ValueError:
            continue
        if under_excluded(r):
            continue
        try:
            st = p.stat(follow_symlinks=False)
        except OSError:
            continue
        e = {
            "relpath": str(r).replace(os.sep, "/"),
            "type": "symlink" if p.is_symlink() else "file",
            "size": st.st_size if p.is_file() and not p.is_symlink() else 0,
            "mtime": int(st.st_mtime),
        }
        if p.is_file() and not p.is_symlink() and 0 < st.st_size <= max_sha:
            try:
                b = p.read_bytes()
                e["sha256"] = hashlib.sha256(b).hexdigest()
            except OSError:
                e["sha256"] = None
        entries.append(e)
doc = {
    "cursor_home": str(root),
    "generated_utc": ts,
    "excludes_toplevel": sorted(exclude),
    "max_sha256_bytes": max_sha,
    "entries": entries,
}
out_path.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
print(str(out_path))
PY

echo "Wrote: $OUT"
