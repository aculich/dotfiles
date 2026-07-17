#!/usr/bin/env python3
"""Scan open Cursor workspaces and apply ignore/watcher purification.

Usage:
  purify-workspace.py --scan [--status-log PATH] [--workspace NAME]
  purify-workspace.py --apply [--status-log PATH] [--workspace NAME]
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_CURSOR = SCRIPT_DIR.parent.parent
PATHS_FILE = SCRIPT_DIR / "cursor-purification-paths.json"
MANIFEST_DIR = REPO_CURSOR / "observability" / "cursor-purification"
MANIFEST_FILE = MANIFEST_DIR / "MANIFEST.json"

BLOCK_START = "# cursor-purification"
BLOCK_END = "# end cursor-purification"

UNIVERSAL_INDEXING = [
    ".specstory/**",
    "upstream/",
    "archive/",
    "incoming/",
    "venv/",
    ".venv/",
    "node_modules/",
    "__pycache__/",
    "*.pyc",
    "dist/",
    "build/",
    "*.eml",
    "*.map",
    "*.jsonl",
    "metadata_never_index",
]

BASELINE_WATCHER = {
    "**/.git/objects/**": True,
    "**/node_modules/**": True,
    "**/.venv/**": True,
    "**/venv/**": True,
    "**/.venv-*/**": True,
    "**/__pycache__/**": True,
    "**/.mypy_cache/**": True,
    "**/.pytest_cache/**": True,
    "**/.ruff_cache/**": True,
    "**/.tox/**": True,
    "**/.nox/**": True,
    "**/dist/**": True,
    "**/build/**": True,
    "**/.specstory/**": True,
    "**/upstream/**": True,
}

BASELINE_SEARCH = {
    "**/node_modules": True,
    "**/.venv": True,
    "**/venv": True,
    "**/.venv-*": True,
    "**/__pycache__": True,
    "**/.mypy_cache": True,
    "**/.pytest_cache": True,
    "**/.ruff_cache": True,
    "**/.tox": True,
    "**/.nox": True,
    "**/dist": True,
    "**/build": True,
    "**/.specstory": True,
    "**/upstream": True,
}

TS_QUIET = {
    "typescript.disableAutomaticTypeAcquisition": True,
    "javascript.validate.enable": False,
    "typescript.tsc.autoDetect": "off",
    "npm.autoDetect": "off",
    "git.autoRepositoryDetection": False,
    "typescript.tsserver.maxTsServerMemory": 3072,
}

DU_THRESHOLD_BYTES = 100 * 1024 * 1024  # 100 MB
CURSORIGNORE_THRESHOLD_BYTES = 5 * 1024 * 1024 * 1024  # 5 GB
JS_TS_COUNT_THRESHOLD = 500

# Auto-exclude large dirs only when name matches these (or known_heavy / gitignored)
JUNK_DIR_RE = re.compile(
    r"^(upstream|archive|incoming|venv|\.venv|node_modules|dist|build|"
    r"__pycache__|snapshots|ApplicationSupport|forensics|videos|misc|"
    r"gmail-archive|continuous-data|library|_archive.*|"
    r".*-backup.*|.*-backups|.*_isos|.*-isos)$",
    re.IGNORECASE,
)


def load_paths_config() -> dict[str, Any]:
    with PATHS_FILE.open() as f:
        return json.load(f)


def utc_now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def parse_workspace_names(status_text: str) -> dict[str, dict[str, Any]]:
    """Return {name: {file_count: int|None, from_window: bool}}."""
    result: dict[str, dict[str, Any]] = {}
    if "Workspace Stats:" not in status_text:
        return result
    block = status_text.split("Workspace Stats:", 1)[1]
    window_re = re.compile(r"Window \(.+ — ([^)]+)\)")
    folder_re = re.compile(r"Folder \(([^)]+)\):\s*(?:more than )?(\d+)\s+files?")
    for line in block.splitlines():
        line = line.strip().lstrip("|").strip()
        m = window_re.search(line)
        if m:
            name = m.group(1).strip()
            entry = result.setdefault(name, {"file_count": None, "from_window": False})
            entry["from_window"] = True
            continue
        m = folder_re.search(line)
        if m:
            name = m.group(1).strip()
            count = int(m.group(2))
            entry = result.setdefault(name, {"file_count": None, "from_window": False})
            entry["file_count"] = count
    return result


def resolve_path(name: str, cfg: dict[str, Any]) -> Path | None:
    if name in cfg.get("skip", []):
        return None
    overrides = cfg.get("overrides", {})
    if name in overrides:
        p = Path(overrides[name]).expanduser()
        return p if p.is_dir() else None
    root = Path(cfg.get("defaults", {}).get("projects_root", "/Users/me/projects"))
    p = root / name
    return p if p.is_dir() else None


def du_top_level(root: Path) -> list[tuple[str, int]]:
    """Return [(dirname, size_bytes), ...] for top-level dirs, sorted descending."""
    sizes: list[tuple[str, int]] = []
    try:
        for child in root.iterdir():
            if not child.is_dir() or child.name.startswith("."):
                continue
            try:
                out = subprocess.check_output(
                    ["du", "-sk", str(child)],
                    text=True,
                    timeout=120,
                    stderr=subprocess.DEVNULL,
                )
                kb = int(out.split()[0])
                sizes.append((child.name, kb * 1024))
            except (subprocess.SubprocessError, ValueError, IndexError):
                continue
    except OSError:
        return []
    sizes.sort(key=lambda x: x[1], reverse=True)
    return sizes


def count_js_ts(root: Path) -> int:
    count = 0
    try:
        for dirpath, dirnames, filenames in os.walk(root):
            # Prune common junk
            dirnames[:] = [
                d
                for d in dirnames
                if d not in {".git", "node_modules", ".venv", "venv", "__pycache__", "upstream", "archive"}
            ]
            for fn in filenames:
                if fn.endswith((".js", ".ts", ".tsx", ".jsx", ".mjs", ".cjs")):
                    count += 1
                    if count > JS_TS_COUNT_THRESHOLD:
                        return count
    except OSError:
        pass
    return count


def has_package_json(root: Path) -> bool:
    return (root / "package.json").is_file()


def extract_block_patterns(text: str) -> set[str]:
    if BLOCK_START not in text:
        return set()
    start = text.index(BLOCK_START)
    rest = text[start + len(BLOCK_START) :]
    if BLOCK_END in rest:
        rest = rest[: rest.index(BLOCK_END)]
    patterns = set()
    for line in rest.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        patterns.add(line)
    return patterns


def merge_indexing_ignore(path: Path, patterns: list[str], dry_run: bool) -> tuple[bool, list[str]]:
    """Merge patterns into tagged block. Returns (changed, patterns_added)."""
    existing = path.read_text() if path.is_file() else ""
    already = extract_block_patterns(existing)
    # Also treat any line already present anywhere as present
    all_lines = {ln.strip() for ln in existing.splitlines() if ln.strip() and not ln.strip().startswith("#")}
    to_add = [p for p in patterns if p not in already and p not in all_lines]
    if not to_add and BLOCK_START in existing:
        return False, []

    new_patterns = sorted(already | set(to_add) | set(patterns))
    # Prefer stable order: universal first, then rest alphabetically unique
    ordered: list[str] = []
    seen: set[str] = set()
    for p in patterns:
        if p not in seen:
            ordered.append(p)
            seen.add(p)
    for p in sorted(new_patterns):
        if p not in seen:
            ordered.append(p)
            seen.add(p)

    block = BLOCK_START + "\n" + "\n".join(ordered) + "\n" + BLOCK_END + "\n"

    if BLOCK_START in existing:
        start = existing.index(BLOCK_START)
        end_idx = existing.find(BLOCK_END, start)
        if end_idx >= 0:
            end_idx += len(BLOCK_END)
            # consume trailing newline
            if end_idx < len(existing) and existing[end_idx] == "\n":
                end_idx += 1
            new_text = existing[:start] + block + existing[end_idx:]
        else:
            new_text = existing.rstrip() + "\n\n" + block
        added = [p for p in ordered if p not in already]
    else:
        prefix = existing.rstrip() + "\n\n" if existing.strip() else ""
        new_text = prefix + block
        added = ordered

    if new_text == existing:
        return False, []
    if not dry_run:
        path.write_text(new_text if new_text.endswith("\n") else new_text + "\n")
    return True, added


def merge_settings(
    path: Path,
    heavy_dirs: list[str],
    quiet_ts: bool,
    dry_run: bool,
) -> tuple[bool, list[str]]:
    """Merge watcher/search excludes and optional TS quieting. Returns (changed, notes)."""
    notes: list[str] = []
    if path.is_file():
        try:
            settings = json.loads(path.read_text())
        except json.JSONDecodeError:
            notes.append("settings.json invalid; skipping")
            return False, notes
        if not isinstance(settings, dict):
            notes.append("settings.json not an object; skipping")
            return False, notes
    else:
        settings = {}

    watcher = dict(settings.get("files.watcherExclude") or {})
    search = dict(settings.get("search.exclude") or {})
    changed = False

    for k, v in BASELINE_WATCHER.items():
        if watcher.get(k) != v:
            watcher[k] = v
            changed = True
    for k, v in BASELINE_SEARCH.items():
        if search.get(k) != v:
            search[k] = v
            changed = True

    for d in heavy_dirs:
        wkey = f"{d}/**"
        skey = d
        if watcher.get(wkey) is not True:
            watcher[wkey] = True
            changed = True
            notes.append(f"watcher:{d}")
        if search.get(skey) is not True:
            search[skey] = True
            changed = True

    settings["files.watcherExclude"] = watcher
    settings["search.exclude"] = search

    if quiet_ts:
        for k, v in TS_QUIET.items():
            if settings.get(k) != v:
                settings[k] = v
                changed = True
        notes.append("ts_quiet")

    if not changed:
        return False, notes
    if not dry_run:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(settings, indent=4) + "\n")
    return True, notes


def merge_cursorignore(path: Path, dirs: list[str], dry_run: bool) -> tuple[bool, list[str]]:
    if not dirs:
        return False, []
    existing = path.read_text() if path.is_file() else ""
    already = extract_block_patterns(existing)
    all_lines = {ln.strip() for ln in existing.splitlines() if ln.strip() and not ln.strip().startswith("#")}
    patterns = [f"{d}/" for d in dirs]
    to_add = [p for p in patterns if p not in already and p not in all_lines]
    if not to_add and BLOCK_START in existing:
        return False, []
    return merge_indexing_ignore(path, patterns, dry_run)


def gitignore_top_level_dirs(root: Path) -> set[str]:
    """Top-level dir names that appear as ignored in root .gitignore (best-effort)."""
    gi = root / ".gitignore"
    if not gi.is_file():
        return set()
    ignored: set[str] = set()
    for line in gi.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or line.startswith("!"):
            continue
        # Match patterns like upstream/, /archive/, foo/*/
        m = re.match(r"^/?([A-Za-z0-9_.@+-]+)/?\*?/?$", line)
        if m:
            ignored.add(m.group(1))
            continue
        m = re.match(r"^/?([A-Za-z0-9_.@+-]+)/\*/?$", line)
        if m:
            ignored.add(m.group(1))
    return ignored


def propose_excludes(name: str, root: Path, cfg: dict[str, Any]) -> dict[str, Any]:
    known = list(cfg.get("known_heavy", {}).get(name, []))
    sizes = du_top_level(root)
    gitignored = gitignore_top_level_dirs(root)

    # Large dirs: only if known_heavy, junk-named, or gitignored (avoid excluding real projects)
    heavy_from_du: list[str] = []
    for d, sz in sizes:
        if sz < DU_THRESHOLD_BYTES:
            continue
        if d in known or JUNK_DIR_RE.match(d) or d in gitignored:
            heavy_from_du.append(d)

    extreme = [
        d
        for d, sz in sizes
        if sz >= CURSORIGNORE_THRESHOLD_BYTES
        and (d in known or JUNK_DIR_RE.match(d) or d in gitignored)
    ]

    excludes: list[str] = []
    seen: set[str] = set()
    for d in known + heavy_from_du:
        if d not in seen and (root / d).is_dir():
            excludes.append(d)
            seen.add(d)

    for d, sz in sizes:
        if d.startswith("_archive") and sz >= DU_THRESHOLD_BYTES and d not in seen:
            excludes.append(d)
            seen.add(d)

    js_ts = count_js_ts(root)
    quiet_ts = has_package_json(root) or js_ts > JS_TS_COUNT_THRESHOLD

    indexing_patterns = list(UNIVERSAL_INDEXING)
    for d in excludes:
        indexing_patterns.append(f"{d}/")

    return {
        "workspace": name,
        "resolved_path": str(root),
        "heavy_dirs": excludes,
        "du_top": [(d, sz) for d, sz in sizes[:10]],
        "extreme_dirs": extreme,
        "indexing_patterns": indexing_patterns,
        "quiet_ts": quiet_ts,
        "js_ts_count": js_ts,
        "path_override": name in cfg.get("overrides", {}),
    }


def apply_proposal(proposal: dict[str, Any], dry_run: bool) -> dict[str, Any]:
    root = Path(proposal["resolved_path"])
    files_touched: list[str] = []
    excludes_added: list[str] = []
    notes: list[str] = []

    idx_path = root / ".cursorindexingignore"
    changed, added = merge_indexing_ignore(idx_path, proposal["indexing_patterns"], dry_run)
    if changed:
        files_touched.append(".cursorindexingignore")
        excludes_added.extend(added)

    settings_path = root / ".vscode" / "settings.json"
    schanged, snotes = merge_settings(
        settings_path, proposal["heavy_dirs"], proposal["quiet_ts"], dry_run
    )
    if schanged:
        files_touched.append(".vscode/settings.json")
    notes.extend(snotes)

    extreme = proposal.get("extreme_dirs") or []
    if extreme:
        ci_path = root / ".cursorignore"
        cchanged, cadded = merge_cursorignore(ci_path, extreme, dry_run)
        if cchanged:
            files_touched.append(".cursorignore")
            excludes_added.extend(cadded)
            notes.append(f"cursorignore for {extreme}")

    if proposal.get("path_override"):
        notes.append("path_override")

    # Detect .vscode gitignored
    gitignore = root / ".gitignore"
    if gitignore.is_file():
        gi = gitignore.read_text()
        if re.search(r"(?m)^\.?vscode/?$", gi) or ".vscode/" in gi or ".vscode" in gi.splitlines():
            notes.append(".vscode gitignored locally")

    return {
        "workspace": proposal["workspace"],
        "resolved_path": proposal["resolved_path"],
        "files_touched": files_touched,
        "excludes_added": sorted(set(excludes_added)),
        "heavy_dirs": proposal["heavy_dirs"],
        "quiet_ts": proposal["quiet_ts"],
        "notes": notes,
        "changed": bool(files_touched),
        "dry_run": dry_run,
    }


def load_manifest() -> dict[str, Any]:
    if MANIFEST_FILE.is_file():
        return json.loads(MANIFEST_FILE.read_text())
    return {
        "schema_version": 1,
        "description": "Ledger of cursor-purification interventions applied to workspace roots",
        "runs": [],
        "workspaces": {},
    }


def save_manifest(manifest: dict[str, Any]) -> None:
    MANIFEST_DIR.mkdir(parents=True, exist_ok=True)
    MANIFEST_FILE.write_text(json.dumps(manifest, indent=2) + "\n")


def update_manifest(
    results: list[dict[str, Any]],
    file_counts: dict[str, int | None],
    mode: str,
) -> None:
    manifest = load_manifest()
    now = utc_now()
    run = {
        "timestamp": now,
        "mode": mode,
        "workspaces": [r["workspace"] for r in results],
        "changed": [r["workspace"] for r in results if r.get("changed")],
    }
    manifest["runs"].append(run)

    for r in results:
        name = r["workspace"]
        prev = manifest["workspaces"].get(name, {})
        entry = {
            "workspace": name,
            "resolved_path": r["resolved_path"],
            "first_applied": prev.get("first_applied") or now,
            "last_applied": now,
            "files_touched": r.get("files_touched") or prev.get("files_touched") or [],
            "excludes_added": r.get("heavy_dirs") or prev.get("excludes_added") or [],
            "file_count_at_apply": file_counts.get(name),
            "quiet_ts": r.get("quiet_ts", False),
            "notes": "; ".join(r.get("notes") or []) or prev.get("notes", ""),
        }
        # Preserve first_applied
        if prev.get("first_applied"):
            entry["first_applied"] = prev["first_applied"]
        # Merge files_touched history
        merged_files = list(dict.fromkeys((prev.get("files_touched") or []) + (r.get("files_touched") or [])))
        entry["files_touched"] = merged_files
        manifest["workspaces"][name] = entry

    save_manifest(manifest)


def capture_status() -> str:
    try:
        return subprocess.check_output(["cursor", "-s"], text=True, timeout=60, stderr=subprocess.DEVNULL)
    except (subprocess.SubprocessError, FileNotFoundError) as e:
        print(f"Warning: could not run cursor -s: {e}", file=sys.stderr)
        return ""


def main() -> int:
    ap = argparse.ArgumentParser(description="Cursor workspace purification")
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--scan", action="store_true", help="Dry-run: propose excludes")
    mode.add_argument("--apply", action="store_true", help="Apply purification and update manifest")
    ap.add_argument("--status-log", type=Path, help="Existing cursor-status.log (else capture live)")
    ap.add_argument("--workspace", action="append", dest="workspaces", help="Limit to workspace name(s)")
    ap.add_argument("--all-known", action="store_true", help="Also include known_heavy keys even if not in status")
    args = ap.parse_args()

    cfg = load_paths_config()

    if args.status_log:
        status_text = args.status_log.read_text()
    else:
        status_text = capture_status()

    parsed = parse_workspace_names(status_text) if status_text else {}
    names: list[str] = []
    if args.workspaces:
        names = args.workspaces
    else:
        names = sorted(parsed.keys(), key=lambda n: (not parsed[n].get("from_window"), n))
        if args.all_known:
            for k in cfg.get("known_heavy", {}):
                if k not in names:
                    names.append(k)

    if not names and not args.workspaces:
        # Fallback: known_heavy + overrides
        names = sorted(set(cfg.get("known_heavy", {})) | set(cfg.get("overrides", {})))
        print("No workspace stats; using known_heavy + overrides", file=sys.stderr)

    proposals: list[dict[str, Any]] = []
    skipped: list[tuple[str, str]] = []

    for name in names:
        if name in cfg.get("skip", []):
            skipped.append((name, "in skip list"))
            continue
        root = resolve_path(name, cfg)
        if root is None:
            skipped.append((name, "path not found"))
            continue
        proposals.append(propose_excludes(name, root, cfg))

    print(f"# cursor-purification {'scan' if args.scan else 'apply'}")
    print(f"workspaces: {len(proposals)}  skipped: {len(skipped)}")
    for name, reason in skipped:
        print(f"  skip {name}: {reason}")

    results: list[dict[str, Any]] = []
    for prop in proposals:
        print(f"\n## {prop['workspace']}")
        print(f"  path: {prop['resolved_path']}")
        print(f"  heavy_dirs: {', '.join(prop['heavy_dirs']) or '(baseline only)'}")
        print(f"  quiet_ts: {prop['quiet_ts']} (js/ts~{prop['js_ts_count']})")
        if prop.get("extreme_dirs"):
            print(f"  extreme (>5G → .cursorignore): {', '.join(prop['extreme_dirs'])}")
        if args.scan:
            top = ", ".join(f"{d}={sz // (1024 * 1024)}M" for d, sz in prop["du_top"][:5])
            print(f"  du_top: {top}")
            result = {
                "workspace": prop["workspace"],
                "resolved_path": prop["resolved_path"],
                "files_touched": [],
                "excludes_added": prop["heavy_dirs"],
                "heavy_dirs": prop["heavy_dirs"],
                "quiet_ts": prop["quiet_ts"],
                "notes": ["scan only"],
                "changed": False,
                "dry_run": True,
            }
        else:
            result = apply_proposal(prop, dry_run=False)
            print(f"  changed: {result['changed']}")
            print(f"  files: {', '.join(result['files_touched']) or '(none)'}")
            if result["notes"]:
                print(f"  notes: {'; '.join(result['notes'])}")
        results.append(result)

    if args.apply:
        file_counts = {n: parsed.get(n, {}).get("file_count") for n in [r["workspace"] for r in results]}
        update_manifest(results, file_counts, mode="apply")
        print(f"\nManifest updated: {MANIFEST_FILE}")
        print("Reload affected Cursor windows: Developer: Reload Window")

    return 0


if __name__ == "__main__":
    sys.exit(main())
