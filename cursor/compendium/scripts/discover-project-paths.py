#!/usr/bin/env python3
"""
Discover project roots for the Cursor compendium:

  - Cursor-known roots: workspaceStorage/workspace.json, globalStorage/storage.json
    (backupWorkspaces + openedWindows + lastActiveWindow).
  - Filesystem scan: directories under $HOME/projects, $HOME/tools, and optional
    shallow $HOME pass that contain .cursor/, .claude/, or .specstory/.

Writes under CURSOR_COMPENDIUM_ROOT (required unless --dry-run without --report-dir):
  - project-paths.txt       tab-separated slug<TAB>path (known + orphans)
  - discover-report.json    structured cursor_known, scan_roots, orphans, stale_known

Orphans = scan-found project roots with markers that are not in Cursor's known set.
Stale    = Cursor-known paths that no longer exist or no longer have any marker dir.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

MARKERS = (".cursor", ".claude", ".specstory")
HOME = Path.home()
CURSOR_USER = HOME / "Library/Application Support/Cursor/User"
WORKSPACE_STORAGE = CURSOR_USER / "workspaceStorage"
GLOBAL_STORAGE = CURSOR_USER / "globalStorage" / "storage.json"

# When walking $HOME, prune these top-level names (plus Library subtree noise).
HOME_PRUNE_TOP = frozenset(
    {
        "Library",
        "Movies",
        "Music",
        "Pictures",
        "Public",
        "Applications",
        "Parallels",
        ".Trash",
        ".npm",
        ".yarn",
        "go",
        "miniconda3",
        "anaconda3",
        ".cargo/registry",
        # Operational sibling repos (not product workspaces); see ~/ops/README.md
        "ops",
        "src",  # legacy name for ~/ops
    }
)


def file_uri_to_path(uri: str) -> str | None:
    if not uri or not isinstance(uri, str):
        return None
    if uri.startswith("file://"):
        parsed = urlparse(uri)
        path = unquote(parsed.path)
        # macOS file:///Users/... vs file:/Users
        if path.startswith("/") and len(path) > 2 and path[2] == ":":
            path = path[1:]  # rare Windows-style
        return path
    return None


def parse_code_workspace_file(ws_file: Path) -> list[str]:
    out: list[str] = []
    try:
        data = json.loads(ws_file.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return out
    base = ws_file.parent
    for entry in data.get("folders") or []:
        p = entry.get("path")
        if not p:
            continue
        fp = Path(p)
        if fp.is_absolute():
            out.append(str(fp.resolve()))
        else:
            out.append(str((base / p).resolve()))
    return out


def collect_cursor_known_paths() -> set[str]:
    known: set[str] = set()

    if WORKSPACE_STORAGE.is_dir():
        for child in WORKSPACE_STORAGE.iterdir():
            if not child.is_dir():
                continue
            wj = child / "workspace.json"
            if not wj.is_file():
                continue
            try:
                data = json.loads(wj.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError):
                continue
            if "folder" in data:
                p = file_uri_to_path(data["folder"])
                if p:
                    known.add(str(Path(p).resolve()))
            if "workspace" in data:
                wu = file_uri_to_path(data["workspace"])
                if wu:
                    wpath = Path(wu)
                    if wpath.suffix == ".code-workspace" and wpath.is_file():
                        for rp in parse_code_workspace_file(wpath):
                            known.add(str(Path(rp).resolve()))

    if GLOBAL_STORAGE.is_file():
        try:
            root = json.loads(GLOBAL_STORAGE.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            root = {}
        bw = root.get("backupWorkspaces") or {}
        for folder in bw.get("folders") or []:
            uri = folder.get("folderUri")
            p = file_uri_to_path(uri) if uri else None
            if p:
                known.add(str(Path(p).resolve()))
        ws_state = root.get("windowsState") or {}
        for key in ("openedWindows",):
            for win in ws_state.get(key) or []:
                for k in ("folder", "workspace"):
                    if k not in win:
                        continue
                    p = file_uri_to_path(win[k])
                    if not p:
                        continue
                    pp = Path(p)
                    if k == "workspace" and pp.suffix == ".code-workspace" and pp.is_file():
                        for rp in parse_code_workspace_file(pp):
                            known.add(str(Path(rp).resolve()))
                    else:
                        known.add(str(pp.resolve()))
        lw = ws_state.get("lastActiveWindow")
        if isinstance(lw, dict):
            for k in ("folder", "workspace"):
                if k not in lw:
                    continue
                p = file_uri_to_path(lw[k])
                if not p:
                    continue
                pp = Path(p)
                if k == "workspace" and pp.suffix == ".code-workspace" and pp.is_file():
                    for rp in parse_code_workspace_file(pp):
                        known.add(str(Path(rp).resolve()))
                else:
                    known.add(str(pp.resolve()))

    return known


def has_marker(root: Path) -> bool:
    return any((root / m).is_dir() for m in MARKERS)


def is_aggregate_projects_or_tools(p: Path) -> bool:
    """~/projects and ~/tools are often umbrella dirs with their own .cursor; still scan children."""
    try:
        rp = p.resolve()
        return rp in {(HOME / "projects").resolve(), (HOME / "tools").resolve()}
    except OSError:
        return False


def should_skip_scan_dir(path: Path) -> bool:
    """Skip heavy or irrelevant subtrees while descending."""
    parts = path.parts
    if "node_modules" in parts or ".git" in parts:
        return True
    if ".cursor" in parts and "extensions" in parts:
        return True
    if ".cursor" in parts and "plugins" in parts:
        return True
    try:
        path.resolve().relative_to(HOME.resolve() / "Library")
        return True
    except ValueError:
        pass
    return False


def scan_tree_for_projects(root: Path, max_depth: int | None) -> set[str]:
    """Return canonical project root paths (dirs that directly contain a marker)."""
    found: set[str] = set()
    if not root.is_dir():
        return found
    root = root.resolve()
    # BFS with depth
    stack: list[tuple[Path, int]] = [(root, 0)]
    while stack:
        cur, depth = stack.pop()
        if should_skip_scan_dir(cur):
            continue
        if has_marker(cur) and not is_aggregate_projects_or_tools(cur):
            found.add(str(cur.resolve()))
            continue
        if max_depth is not None and depth >= max_depth:
            continue
        try:
            for ch in cur.iterdir():
                if not ch.is_dir():
                    continue
                if ch.is_symlink():
                    continue
                if ch.name.startswith("."):
                    # still descend into e.g. .venv? skip hidden except we need to reach .cursor
                    # descend into normal hidden dirs except obvious junk
                    if ch.name in (".git", ".svn", ".hg", "__pycache__"):
                        continue
                stack.append((ch, depth + 1))
        except OSError:
            continue
    return found


def scan_home_shallow(max_depth: int) -> set[str]:
    found: set[str] = set()
    if not HOME.is_dir():
        return found
    stack: list[tuple[Path, int]] = [(HOME, 0)]
    while stack:
        cur, depth = stack.pop()
        if should_skip_scan_dir(cur):
            continue
        if cur != HOME and cur.name in HOME_PRUNE_TOP and cur.parent == HOME:
            continue
        if has_marker(cur) and not is_aggregate_projects_or_tools(cur):
            found.add(str(cur.resolve()))
            continue
        if depth >= max_depth:
            continue
        try:
            for ch in cur.iterdir():
                if not ch.is_dir():
                    continue
                if ch.is_symlink():
                    continue
                if ch.name in HOME_PRUNE_TOP and ch.parent == HOME:
                    continue
                stack.append((ch, depth + 1))
        except OSError:
            continue
    return found


def slug_for_path(project: Path) -> str:
    project = project.resolve()
    git_dir = project / ".git"
    if git_dir.exists():
        try:
            out = subprocess.run(
                ["git", "-C", str(project), "remote", "get-url", "origin"],
                capture_output=True,
                text=True,
                timeout=5,
            )
            if out.returncode == 0 and out.stdout.strip():
                url = out.stdout.strip()
                m = re.search(r"[:/]([^/]+)/([^/.]+?)(?:\.git)?$", url)
                if m:
                    host = m.group(1).replace("@", "-").replace(".", "-")
                    repo = m.group(2)
                    return re.sub(r"[^a-zA-Z0-9._-]+", "-", f"github-{host}-{repo}".lower())[:80]
        except (OSError, subprocess.TimeoutExpired):
            pass
    h = hashlib.sha256(str(project).encode()).hexdigest()[:12]
    safe = re.sub(r"[^a-zA-Z0-9._-]+", "-", project.name.lower()).strip("-")[:40]
    return f"path-{safe}-{h}"


def slug_orphan(project: Path) -> str:
    h = hashlib.sha256(str(project.resolve()).encode()).hexdigest()[:10]
    safe = re.sub(r"[^a-zA-Z0-9._-]+", "-", project.name.lower()).strip("-")[:30]
    return f"orphan-{safe}-{h}"


def merge_slugs(existing_lines: list[str], path: str, new_slug: str) -> str:
    """Reuse slug if an existing line already maps to this path."""
    for line in existing_lines:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split("\t")
        if len(parts) >= 2 and parts[1].strip() == path:
            return parts[0].strip()
    return new_slug


def main() -> int:
    ap = argparse.ArgumentParser(description="Discover compendium project paths.")
    ap.add_argument(
        "--compendium-root",
        default=os.environ.get("CURSOR_COMPENDIUM_ROOT", ""),
        help="Compendium git root (default: env CURSOR_COMPENDIUM_ROOT)",
    )
    ap.add_argument("--dry-run", action="store_true", help="Print counts to stdout; do not write project-paths.txt.")
    ap.add_argument(
        "--verbose",
        action="store_true",
        help="With --dry-run, also print full path lists (large).",
    )
    ap.add_argument(
        "--home-maxdepth",
        type=int,
        default=5,
        help="Max directory depth under $HOME for orphan scan (default 5). Use 0 to skip $HOME scan.",
    )
    ap.add_argument(
        "--extra-root",
        action="append",
        default=[],
        help="Additional absolute directory to scan (repeatable).",
    )
    args = ap.parse_args()

    cursor_known = collect_cursor_known_paths()

    scan_roots: list[Path] = []
    for rel in ("projects", "tools"):
        p = HOME / rel
        if p.is_dir():
            scan_roots.append(p)
    for extra in args.extra_root:
        if extra and Path(extra).is_dir():
            scan_roots.append(Path(extra).resolve())

    scan_found: set[str] = set()
    for r in scan_roots:
        scan_found |= scan_tree_for_projects(r, max_depth=None)

    if args.home_maxdepth > 0:
        scan_found |= scan_home_shallow(args.home_maxdepth)

    def is_forbidden_project_root(path_str: str) -> bool:
        """Never treat $HOME (or global ~/.cursor) as a snapshot project."""
        try:
            rp = Path(path_str).resolve()
        except OSError:
            return True
        home = HOME.resolve()
        if rp == home or rp == (home / ".cursor"):
            return True
        return False

    # Drop global ~/.cursor and $HOME itself (Cursor sometimes lists $HOME as a workspace)
    scan_found = {
        p
        for p in scan_found
        if Path(p).exists() and not is_forbidden_project_root(p)
    }
    scan_found.discard(str((HOME / ".cursor").resolve()))

    cursor_existing = {
        p
        for p in cursor_known
        if Path(p).exists() and not is_forbidden_project_root(p)
    }
    orphans = scan_found - cursor_existing
    stale = cursor_existing - scan_found

    report = {
        "cursor_known_count": len(cursor_known),
        "cursor_existing_count": len(cursor_existing),
        "scan_found_count": len(scan_found),
        "orphans_count": len(orphans),
        "stale_known_count": len(stale),
        "cursor_known": sorted(cursor_known),
        "scan_found": sorted(scan_found),
        "orphans": sorted(orphans),
        "stale_known": sorted(stale),
    }

    root = args.compendium_root.strip()

    if args.dry_run:
        counts = {k: report[k] for k in report if k.endswith("_count")}
        print(json.dumps(counts, indent=2))
        if args.verbose:
            slim = {k: v for k, v in report.items() if isinstance(v, list)}
            print(json.dumps(slim, indent=2))
        return 0

    if not root:
        print("Set CURSOR_COMPENDIUM_ROOT or pass --compendium-root", file=sys.stderr)
        return 2

    comp = Path(root).resolve()
    comp.mkdir(parents=True, exist_ok=True)

    existing_lines: list[str] = []
    pp = comp / "project-paths.txt"
    if pp.is_file():
        existing_lines = pp.read_text(encoding="utf-8").splitlines()

    lines_out: list[str] = [
        "# Generated by discover-project-paths.py — edit slugs carefully; paths are tab-separated.",
        "# Orphans use slug prefix orphan-; Cursor-known use git-derived slug when possible.",
    ]
    written: set[str] = set()

    def add_line(path_str: str, slug_fn) -> None:
        if path_str in written:
            return
        p = Path(path_str)
        if not p.is_dir():
            return
        slug = merge_slugs(existing_lines, path_str, slug_fn(p))
        lines_out.append(f"{slug}\t{path_str}")
        written.add(path_str)

    for pth in sorted(cursor_existing):
        add_line(pth, slug_for_path)
    for pth in sorted(orphans):
        add_line(pth, slug_orphan)

    text = "\n".join(lines_out) + "\n"
    pp.write_text(text, encoding="utf-8")
    (comp / "discover-report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(f"Wrote {pp} ({len(written)} paths) and discover-report.json")
    print(
        f"counts: cursor_known={report['cursor_known_count']} "
        f"scan_found={report['scan_found_count']} orphans={report['orphans_count']} stale={report['stale_known_count']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
