#!/usr/bin/env python3
"""
Discover Cursor / Agents skills across global and project locations.

Writes under CURSOR_COMPENDIUM_ROOT (or --compendium-root):
  - skills-registry/skills-inventory.json
  - skills-registry/skills-inventory.md

Does not install or mirror skills; run snapshot-skills.sh and snapshot-all.sh for backups.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path

HOME = Path.home()
CURSOR_DIR = HOME / ".cursor"
AGENTS_DIR = HOME / ".agents" / "skills"
SCAN_ROOTS = [
    HOME / "projects",
    HOME / "tools",
    HOME / "src",
]

GLOBAL_TREES = {
    "cursor-user": CURSOR_DIR / "skills",
    "cursor-managed": CURSOR_DIR / "skills-cursor",
    "agents": AGENTS_DIR,
}


def slug_from_path(path: Path) -> str:
    try:
        out = subprocess.run(
            ["git", "-C", str(path), "remote", "get-url", "origin"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if out.returncode == 0 and out.stdout.strip():
            url = out.stdout.strip()
            m = re.search(r"github\.com[:/]([^/]+)/([^/.]+)", url)
            if m:
                return f"github-com-{m.group(1)}-{m.group(2)}"
    except (OSError, subprocess.TimeoutExpired):
        pass
    digest = path.as_posix().encode("utf-8")
    import hashlib

    return f"path-{hashlib.sha256(digest).hexdigest()[:12]}"


def skill_name(skill_md: Path) -> str:
    return skill_md.parent.name


def classify_global_entry(skill_dir: Path) -> dict:
    resolved = skill_dir.resolve()
    is_symlink = skill_dir.is_symlink()
    entry = {
        "id": skill_dir.name,
        "path": str(skill_dir),
        "resolved_path": str(resolved),
        "is_symlink": is_symlink,
    }
    if is_symlink:
        entry["symlink_target"] = str(skill_dir.readlink())
    return entry


def discover_global() -> dict[str, list[dict]]:
    out: dict[str, list[dict]] = {}
    for tier, root in GLOBAL_TREES.items():
        items: list[dict] = []
        if not root.is_dir():
            out[tier] = items
            continue
        for child in sorted(root.iterdir()):
            if not child.is_dir() and not child.is_symlink():
                continue
            skill_md = child / "SKILL.md"
            if not skill_md.exists() and not (child.resolve() / "SKILL.md").exists():
                continue
            items.append(classify_global_entry(child))
        out[tier] = items
    return out


PROJECT_FIND_EXCLUDES = [
    "-not", "-path", "*/node_modules/*",
    "-not", "-path", "*/.git/*",
    "-not", "-path", "*/upstream/*",
    "-not", "-path", "*/.claude/*",
    "-not", "-path", "*/vendor/*",
    "-not", "-path", "*/archive/*",
    "-not", "-path", "*/disabled/*",
]


def find_skill_files(scan_root: Path) -> list[Path]:
    cmd = [
        "find",
        str(scan_root),
        "-maxdepth",
        "10",
        "(",
        "-path",
        "*/.cursor/skills/*/SKILL.md",
        "-o",
        "-path",
        f"{scan_root}/*/skills/*/SKILL.md",
        ")",
        *PROJECT_FIND_EXCLUDES,
    ]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=90)
    except subprocess.TimeoutExpired:
        return []
    if proc.returncode not in (0, 1):
        return []
    return [Path(line.strip()) for line in proc.stdout.splitlines() if line.strip()]


def discover_project_skills() -> list[dict]:
    found: list[dict] = []
    seen: set[str] = set()
    slug_cache: dict[str, str] = {}

    for scan_root in SCAN_ROOTS:
        if not scan_root.is_dir():
            continue
        for skill_md in find_skill_files(scan_root):
            if not skill_md.is_file():
                continue
            root = skill_md.parent
            while root != scan_root and root.parent != root:
                if (root / ".git").exists():
                    break
                if root.name == "skills" and (root.parent / ".cursor").exists():
                    root = root.parent
                    break
                root = root.parent
            if root == scan_root:
                root = skill_md.parents[2] if len(skill_md.parents) > 2 else skill_md.parent

            key = str(skill_md)
            if key in seen:
                continue
            seen.add(key)

            root_s = str(root)
            if root_s not in slug_cache:
                slug_cache[root_s] = slug_from_path(root)

            rel = skill_md.relative_to(root) if skill_md.is_relative_to(root) else skill_md
            found.append(
                {
                    "skill": skill_name(skill_md),
                    "skill_path": str(skill_md),
                    "project_root": root_s,
                    "project_slug": slug_cache[root_s],
                    "relative_path": str(rel),
                    "layout": (
                        "project-cursor"
                        if ".cursor/skills" in str(skill_md)
                        else "project-skills-dir"
                    ),
                }
            )
    return sorted(found, key=lambda x: (x["project_root"], x["skill"]))


def write_markdown(path: Path, payload: dict) -> None:
    lines = [
        "# Skills inventory (generated)",
        "",
        f"Generated: {payload['generated']}",
        "",
        "## Global",
        "",
    ]
    for tier, items in payload["global"].items():
        lines.append(f"### {tier} ({len(items)})")
        lines.append("")
        for item in items:
            flag = " (symlink)" if item.get("is_symlink") else ""
            lines.append(f"- `{item['id']}`{flag} — `{item['path']}`")
        lines.append("")

    lines.append(f"## Project-local ({len(payload['project'])})")
    lines.append("")
    by_project: dict[str, list[dict]] = {}
    for row in payload["project"]:
        by_project.setdefault(row["project_root"], []).append(row)
    for proj, rows in sorted(by_project.items()):
        lines.append(f"### `{proj}`")
        lines.append("")
        for row in rows:
            lines.append(f"- `{row['skill']}` ({row['layout']}) — `{row['relative_path']}`")
        lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Discover skills across global and project trees.")
    parser.add_argument(
        "--compendium-root",
        default=os.environ.get("CURSOR_COMPENDIUM_ROOT", ""),
        help="Compendium git root (default: env CURSOR_COMPENDIUM_ROOT)",
    )
    parser.add_argument(
        "--dotfiles-cursor",
        default=os.environ.get("DOTFILES_CURSOR", str(HOME / "dotfiles" / "cursor")),
        help="Fallback compendium root when CURSOR_COMPENDIUM_ROOT unset",
    )
    args = parser.parse_args()

    root = Path(args.compendium_root) if args.compendium_root else Path(args.dotfiles_cursor) / "compendium"
    registry = root / "skills-registry"
    registry.mkdir(parents=True, exist_ok=True)

    payload = {
        "generated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "compendium_root": str(root),
        "global": discover_global(),
        "project": discover_project_skills(),
    }

    json_path = registry / "skills-inventory.json"
    md_path = registry / "skills-inventory.md"
    json_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    write_markdown(md_path, payload)

    g = sum(len(v) for v in payload["global"].values())
    p = len(payload["project"])
    print(f"Wrote {json_path} ({g} global, {p} project-local skills)", file=__import__("sys").stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
