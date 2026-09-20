#!/usr/bin/env python3
"""Open Cursor recent projects / Finder selection via the --classic wrapper.

Reads history.recentlyOpenedPathsList from Cursor's state.vscdb (one ~100KB
row; does not scan the rest of the DB). Falls back to storage.json
backupWorkspaces if sqlite is unavailable.

Usage:
  cursor-classic-open.py list [--limit N]
  cursor-classic-open.py open [query]
  cursor-classic-open.py finder
  cursor-classic-open.py new-window
"""

from __future__ import annotations

import argparse
import json
import sqlite3
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote

WRAPPER = Path.home() / "dotfiles/cursor/scripts/cursor-classic-wrapper.sh"
STATE_DB = (
    Path.home()
    / "Library/Application Support/Cursor/User/globalStorage/state.vscdb"
)
STORAGE_JSON = (
    Path.home()
    / "Library/Application Support/Cursor/User/globalStorage/storage.json"
)
RECENT_KEY = "history.recentlyOpenedPathsList"


def uri_to_path(uri: str) -> str:
    raw = uri.strip()
    if raw.startswith("file://"):
        raw = unquote(raw[len("file://") :])
    return raw


def entry_path(entry: dict) -> tuple[str, str] | None:
    if "workspace" in entry:
        cfg = (entry.get("workspace") or {}).get("configPath")
        if cfg:
            return uri_to_path(cfg), "workspace"
    if "folderUri" in entry:
        return uri_to_path(entry["folderUri"]), "folder"
    if "fileUri" in entry:
        return uri_to_path(entry["fileUri"]), "file"
    if "configURIPath" in entry:
        return uri_to_path(entry["configURIPath"]), "workspace"
    return None


def load_recent_from_sqlite() -> list[tuple[str, str]]:
    if not STATE_DB.is_file():
        return []
    uri = f"file:{STATE_DB}?mode=ro"
    con = sqlite3.connect(uri, uri=True)
    try:
        row = con.execute(
            "SELECT value FROM ItemTable WHERE key = ?", (RECENT_KEY,)
        ).fetchone()
    finally:
        con.close()
    if not row or not row[0]:
        return []
    data = json.loads(row[0])
    out: list[tuple[str, str]] = []
    seen: set[str] = set()
    for entry in data.get("entries") or []:
        parsed = entry_path(entry)
        if parsed is None:
            continue
        path, kind = parsed
        if path in seen:
            continue
        seen.add(path)
        out.append((path, kind))
    return out


def load_recent_from_storage_json() -> list[tuple[str, str]]:
    if not STORAGE_JSON.is_file():
        return []
    data = json.loads(STORAGE_JSON.read_text())
    backup = data.get("backupWorkspaces") or {}
    out: list[tuple[str, str]] = []
    seen: set[str] = set()
    for entry in backup.get("workspaces") or []:
        parsed = entry_path(entry)
        if parsed is None:
            continue
        path, kind = parsed
        if path not in seen:
            seen.add(path)
            out.append((path, kind))
    for entry in backup.get("folders") or []:
        parsed = entry_path(entry)
        if parsed is None:
            continue
        path, kind = parsed
        if path not in seen:
            seen.add(path)
            out.append((path, kind))
    return out


def load_recent() -> list[tuple[str, str]]:
    try:
        items = load_recent_from_sqlite()
        if items:
            return items
    except (sqlite3.Error, json.JSONDecodeError, OSError):
        pass
    return load_recent_from_storage_json()


def run_wrapper(args: list[str]) -> int:
    if not WRAPPER.is_file():
        print(f"error: missing wrapper {WRAPPER}", file=sys.stderr)
        return 127
    proc = subprocess.run([str(WRAPPER), *args], check=False)
    return proc.returncode


def cmd_new_window() -> int:
    return run_wrapper(["--classic", "--new-window"])


def finder_paths() -> list[str]:
    script = """
tell application "Finder"
    if (count of selection) is 0 then
        try
            return POSIX path of (target of front window as alias)
        on error
            return ""
        end try
    end if
    set output to ""
    repeat with f in (selection as alias list)
        set output to output & POSIX path of f & linefeed
    end repeat
    return output
end tell
"""
    proc = subprocess.run(
        ["osascript", "-e", script],
        check=False,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        err = (proc.stderr or proc.stdout or "osascript failed").strip()
        raise RuntimeError(err)
    return [line.strip() for line in proc.stdout.splitlines() if line.strip()]


def cmd_finder() -> int:
    try:
        paths = finder_paths()
    except RuntimeError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    if not paths:
        print("error: no Finder selection or front window", file=sys.stderr)
        return 1
    rc = 0
    for path in paths:
        this = run_wrapper(["--classic", path])
        if this != 0:
            rc = this
    return rc


def score_match(query: str, path: str, kind: str) -> int | None:
    q = query.lower().strip()
    if not q:
        return None
    name = Path(path).name.lower()
    stem = Path(path).stem.lower()
    path_l = path.lower()
    if kind == "file" and "." not in q and "/" not in q:
        return None
    if path_l == q or name == q or stem == q:
        return 0
    if name == f"{q}.code-workspace" or stem == q:
        return 0
    if name.startswith(q) or stem.startswith(q):
        return 1
    if q in name or q in stem:
        return 2
    if q in path_l:
        return 3
    return None


def format_item(path: str, kind: str) -> str:
    return f"{kind:9} {path}"


def cmd_list(limit: int, include_files: bool) -> int:
    items = load_recent()
    shown = 0
    for path, kind in items:
        if kind == "file" and not include_files:
            continue
        print(format_item(path, kind))
        shown += 1
        if limit > 0 and shown >= limit:
            break
    if shown == 0:
        print("error: no recent Cursor projects found", file=sys.stderr)
        return 1
    return 0


def cmd_open(query: str | None) -> int:
    if query:
        direct = Path(query).expanduser()
        if direct.exists():
            return run_wrapper(["--classic", str(direct)])

    items = [(p, k) for p, k in load_recent() if k != "file"]
    if not items:
        print("error: no recent Cursor projects found", file=sys.stderr)
        return 1

    if not query or not query.strip():
        print("Recent Cursor projects (workspaces first in history order):")
        print("Re-run with a name fragment, e.g. pet-master")
        print("")
        for path, kind in items[:40]:
            print(format_item(path, kind))
        return 0

    ranked: list[tuple[int, str, str]] = []
    for path, kind in items:
        score = score_match(query, path, kind)
        if score is None:
            continue
        ranked.append((score, path, kind))
    ranked.sort(key=lambda row: (row[0], 0 if row[2] == "workspace" else 1))

    if not ranked:
        print(f"error: no recent project matched {query!r}", file=sys.stderr)
        return 1

    best = ranked[0][0]
    top = [row for row in ranked if row[0] == best]
    workspaces = [row for row in top if row[2] == "workspace"]
    if len(top) == 1 or len(workspaces) == 1:
        path = (workspaces[0] if workspaces else top[0])[1]
        print(f"Opening {path}")
        return run_wrapper(["--classic", path])

    print(f"Multiple matches for {query!r}; be more specific:")
    for _score, path, kind in ranked[:20]:
        print(format_item(path, kind))
    return 2


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="cmd", required=True)

    list_p = sub.add_parser("list", help="print recent workspaces and folders")
    list_p.add_argument("--limit", type=int, default=40)
    list_p.add_argument("--files", action="store_true")

    open_p = sub.add_parser("open", help="open a recent project by name fragment")
    open_p.add_argument("query", nargs="?", default="")

    sub.add_parser("finder", help="open Finder selection (or front window)")
    sub.add_parser("new-window", help="open an empty classic Cursor window")

    args = parser.parse_args()
    if args.cmd == "list":
        return cmd_list(args.limit, args.files)
    if args.cmd == "open":
        return cmd_open(args.query)
    if args.cmd == "finder":
        return cmd_finder()
    if args.cmd == "new-window":
        return cmd_new_window()
    return 2


if __name__ == "__main__":
    raise SystemExit(main())
