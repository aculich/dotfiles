#!/usr/bin/env python3
"""
Discover agent skills across global and project locations.

Writes inventory JSON + markdown under compendium or agent-skills registry:
  - skills-registry/skills-inventory.json  (dotfiles compendium)
  - registry/skills-inventory.json         (agent-skills monorepo, with --registry-root)

Does not install or mirror skills; run snapshot-skills.sh for backups.
"""
from __future__ import annotations

import argparse
import functools
import hashlib
import json
import os
import re
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

try:
    import yaml  # PyYAML, used for provenance-overrides.yaml (optional)
except ImportError:  # pragma: no cover - degrade gracefully if missing
    yaml = None

_START = time.monotonic()


def log(msg: str) -> None:
    """Emit a timestamped progress line to stderr (flushed immediately)."""
    elapsed = time.monotonic() - _START
    print(f"[discover +{elapsed:5.1f}s] {msg}", file=sys.stderr, flush=True)


HOME = Path.home()
CURSOR_DIR = HOME / ".cursor"
CLAUDE_DIR = HOME / ".claude"
CODEX_DIR = HOME / ".codex"
AGENTS_DIR = HOME / ".agents" / "skills"
AGENT_SKILLS_MONOREPO = HOME / "projects" / "agent-skills"

SCAN_ROOTS = [
    HOME / "projects",
    HOME / "tools",
    HOME / "src",
]

GLOBAL_TREES = {
    "cursor-user": CURSOR_DIR / "skills",
    "cursor-managed": CURSOR_DIR / "skills-cursor",
    "claude-user": CLAUDE_DIR / "skills",
    "codex-user": CODEX_DIR / "skills",
    "agents": AGENTS_DIR,
}

# GCP/datacloud vendor pack (from ~/.cursor/skills/.datacloud_skills_manifest)
VENDOR_SKILL_IDS = frozenset(
    {
        "bigquery-data-transfer-service",
        "dataform-bigquery",
        "dbt-bigquery",
        "discovering-gcp-data-assets",
        "gcloud-auth-verification",
        "gcp-composer-troubleshooting",
        "gcp-data-pipelines",
        "gcp-dataflow",
        "gcp-pipeline-orchestration",
        "gcp-pipeline-resource-provisioning",
        "gcp-spark",
        "managing-python-dependencies",
        "ml-best-practices",
        "notebook-guidance",
        "building-data-apps",
        "data-autocleaning",
        "developing-with-bigquery",
    }
)

# Known product-embedded symlinks (canonical home is another repo)
EMBEDDED_SKILL_IDS = frozenset(
    {
        "wip-distill",
        "wip-harvest",
        "wip-publish",
        "cidr-letterhead",
    }
)

# Skills authored in agent-skills monorepo (curated tier)
AUTHORED_SKILL_IDS = frozenset(
    {
        "accidental-data-loss-prevention",
        "adhd-daily-planner",
        "adhdev-engineering-partnership",
        "bootstrap-new-project",
        "bootstrap-tool-config-repo",
        "bootstrap-umbrella-client-project",
        "change-world-critique-quick",
        "change-world-critique-quick-full",
        "cidr-bootstrap-project",
        "compendium-discover-projects",
        "context-engineering",
        "deeplistening-method-synthesis",
        "deeplistening-session-analysis",
        "fireflies-meeting-export",
        "limitless-takeout-search",
        "limitless-takeout-update",
        "luminary-tech-radar",
        "meeting-sync",
        "meeting-sync-and-synthesis",
        "process-umbrella-incoming",
        "project-management-guru-adhd",
        "reflexive-method-authoring-loop",
        "skill-repair",
        "specstory-guard",
        "specstory-link-trail",
        "specstory-organize",
        "specstory-project-stats",
        "specstory-session-summary",
        "specstory-yak",
        "tools-quickstart-bootstrap",
        "op-credentials",
    }
)


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
    return f"path-{hashlib.sha256(digest).hexdigest()[:12]}"


def skill_name(skill_md: Path) -> str:
    return skill_md.parent.name


def load_vendor_manifest() -> set[str]:
    manifest_path = CURSOR_DIR / "skills" / ".datacloud_skills_manifest"
    if not manifest_path.is_file():
        return set(VENDOR_SKILL_IDS)
    try:
        data = json.loads(manifest_path.read_text(encoding="utf-8"))
        skills = set(data.get("skills", {}).keys())
        return skills | VENDOR_SKILL_IDS
    except (json.JSONDecodeError, OSError):
        return set(VENDOR_SKILL_IDS)


def parse_skill_frontmatter(skill_dir: Path) -> dict:
    skill_md = skill_dir / "SKILL.md"
    resolved = skill_dir.resolve()
    if not skill_md.exists():
        skill_md = resolved / "SKILL.md"
    if not skill_md.is_file():
        return {}
    text = skill_md.read_text(encoding="utf-8", errors="replace")
    if not text.startswith("---"):
        return {}
    end = text.find("\n---", 3)
    if end == -1:
        return {}
    block = text[3:end]
    meta: dict = {}
    for line in block.splitlines():
        if ":" not in line:
            continue
        key, _, val = line.partition(":")
        meta[key.strip()] = val.strip().strip('"').strip("'")
    return meta


# ---------------------------------------------------------------------------
# Provenance ("from whence did this skill come?")
#
# Resolves a `source` object per skill from local signals, in priority order:
#   1. registry/provenance-overrides.yaml   (blessed/manual + web-enriched)
#   2. ~/.agents/.skill-lock.json           (CLI install source + folder hash)
#   3. SKILL.md frontmatter (homepage/repository/source/upstream)
#   4. Cursor plugin cache git checkout      (exact repo URL + commit)
#   5. Claude plugin marketplace manifests   (repo + commit)
#   6. authored / vendor classification      (known repos / bundles)
#   7. enclosing local git repo of the resolved path (repo URL + commit)
#   8. unknown                               (candidate for web enrichment)
# ---------------------------------------------------------------------------

CURSOR_PLUGIN_CACHE = CURSOR_DIR / "plugins" / "cache"
CLAUDE_PLUGIN_CACHE = CLAUDE_DIR / "plugins" / "cache"
CLAUDE_MARKETPLACES_JSON = CLAUDE_DIR / "plugins" / "known_marketplaces.json"
CLAUDE_INSTALLED_JSON = CLAUDE_DIR / "plugins" / "installed_plugins.json"
SKILL_LOCK_PATHS = (
    HOME / ".agents" / ".skill-lock.json",
    HOME / ".cursor" / ".skill-lock.json",
    HOME / ".claude" / ".skill-lock.json",
    HOME / ".codex" / ".skill-lock.json",
)

AUTHORED_REPO_URL = "https://github.com/aculich/agent-skills"

OVERRIDE_FILENAMES = (
    "provenance-overrides.yaml",
    "provenance-overrides.yml",
    "provenance-overrides.json",
)


def normalize_git_url(url: str) -> str:
    """Normalize a git remote to a browsable https URL (best effort)."""
    url = url.strip()
    if url.startswith("git@"):
        host, _, path = url[4:].partition(":")
        url = f"https://{host}/{path}"
    elif url.startswith("ssh://"):
        rest = url[len("ssh://"):]
        if rest.startswith("git@"):
            rest = rest[len("git@"):]
        url = "https://" + rest.replace(":", "/", 1)
    if url.endswith(".git"):
        url = url[:-4]
    return url


@functools.lru_cache(maxsize=None)
def git_remote_and_head(repo_dir: str) -> tuple[str | None, str | None]:
    """Return (normalized_origin_url, HEAD_commit) for a git working dir."""
    url = commit = None
    try:
        out = subprocess.run(
            ["git", "-C", repo_dir, "remote", "get-url", "origin"],
            capture_output=True, text=True, timeout=5,
        )
        if out.returncode == 0 and out.stdout.strip():
            url = normalize_git_url(out.stdout.strip())
    except (OSError, subprocess.TimeoutExpired):
        pass
    try:
        out = subprocess.run(
            ["git", "-C", repo_dir, "rev-parse", "HEAD"],
            capture_output=True, text=True, timeout=5,
        )
        if out.returncode == 0 and out.stdout.strip():
            commit = out.stdout.strip()
    except (OSError, subprocess.TimeoutExpired):
        pass
    return url, commit


# Git repos that are NOT skill sources: home + the global agent/config trees.
# A skill living inside one of these (e.g. a dotfiles-tracked ~/.claude) must
# not be attributed to that umbrella repo.
NON_SOURCE_REPO_ROOTS = frozenset(
    {
        HOME,
        HOME / "dotfiles",
        HOME / "dotfiles" / "cursor",
        CURSOR_DIR,
        CLAUDE_DIR,
        CODEX_DIR,
        HOME / ".agents",
        AGENTS_DIR,
    }
)


def find_enclosing_repo(path: Path) -> Path | None:
    """Walk up from `path` to the nearest ancestor git repo that could plausibly
    be a skill's source (skips home and the global agent/config trees)."""
    try:
        cur = path.resolve()
    except OSError:
        return None
    for candidate in [cur, *cur.parents]:
        if candidate == HOME.parent:
            break
        if candidate in NON_SOURCE_REPO_ROOTS:
            continue
        if (candidate / ".git").exists():
            return candidate
    return None


def plugin_source(resolved: Path) -> dict | None:
    """Attribute a path living under the Cursor/Claude plugin caches."""
    try:
        rel = resolved.relative_to(CURSOR_PLUGIN_CACHE)
        marketplace, plugin, sha, *_ = (*rel.parts, "", "", "")
        checkout = CURSOR_PLUGIN_CACHE / marketplace / plugin / sha
        url, commit = git_remote_and_head(str(checkout))
        return {
            "type": "cursor-plugin",
            "marketplace": marketplace,
            "plugin": plugin,
            "url": url,
            "commit": commit or (sha or None),
            "confidence": "high",
            "via": "cursor-plugin-git",
        }
    except ValueError:
        pass
    try:
        rel = resolved.relative_to(CLAUDE_PLUGIN_CACHE)
        marketplace, plugin, version, *_ = (*rel.parts, "", "", "")
        mkts = _load_claude_marketplaces()
        installed = _load_claude_installed()
        repo = mkts.get(marketplace, {}).get("source", {}).get("repo")
        url = f"https://github.com/{repo}" if repo else None
        commit = None
        for rec in installed.get(f"{plugin}@{marketplace}", []):
            if rec.get("version") == version or commit is None:
                commit = rec.get("gitCommitSha") or commit
        return {
            "type": "claude-plugin",
            "marketplace": marketplace,
            "plugin": plugin,
            "url": url,
            "commit": commit,
            "confidence": "high",
            "via": "claude-marketplace-json",
        }
    except ValueError:
        return None


@functools.lru_cache(maxsize=1)
def _load_claude_marketplaces() -> dict:
    try:
        return json.loads(CLAUDE_MARKETPLACES_JSON.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}


@functools.lru_cache(maxsize=1)
def _load_claude_installed() -> dict:
    try:
        data = json.loads(CLAUDE_INSTALLED_JSON.read_text(encoding="utf-8"))
        return data.get("plugins", {})
    except (OSError, json.JSONDecodeError):
        return {}


@functools.lru_cache(maxsize=8)
def load_overrides(registry_dir: str) -> dict:
    """Load provenance overrides keyed by skill id from a registry directory."""
    base = Path(registry_dir)
    for name in OVERRIDE_FILENAMES:
        fp = base / name
        if not fp.is_file():
            continue
        try:
            if fp.suffix == ".json":
                data = json.loads(fp.read_text(encoding="utf-8"))
            elif yaml is not None:
                data = yaml.safe_load(fp.read_text(encoding="utf-8"))
            else:
                continue
        except (OSError, json.JSONDecodeError, Exception):  # noqa: BLE001
            continue
        if isinstance(data, dict):
            # Accept {skills: {id: {...}}} or a bare {id: {...}} mapping.
            return data.get("skills", data)
    return {}


@functools.lru_cache(maxsize=1)
def load_skill_lock() -> dict[str, dict]:
    """Load vercel-labs skills CLI lockfile(s); later paths do not overwrite."""
    out: dict[str, dict] = {}
    for path in SKILL_LOCK_PATHS:
        if not path.is_file():
            continue
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        skills = data.get("skills") if isinstance(data, dict) else None
        if not isinstance(skills, dict):
            continue
        for skill_id, rec in skills.items():
            if skill_id in out or not isinstance(rec, dict):
                continue
            out[skill_id] = rec
    return out


def skill_lock_source(skill_id: str) -> dict | None:
    """Map a skills CLI lock entry into our provenance source object."""
    rec = load_skill_lock().get(skill_id)
    if not rec:
        return None
    source_url = rec.get("sourceUrl") or ""
    install_ref = rec.get("source") or ""
    url = normalize_git_url(source_url) if source_url else None
    if not url and install_ref and "/" in str(install_ref):
        url = f"https://github.com/{install_ref}"
    if not url and not install_ref:
        return None
    out: dict = {
        "type": "skill-lock",
        "url": url,
        "install_source_url": url,
        "install_ref": install_ref or None,
        "source_type": rec.get("sourceType"),
        "folder_hash": rec.get("skillFolderHash"),
        "skill_path": rec.get("skillPath"),
        "installed_at": rec.get("installedAt"),
        "updated_at": rec.get("updatedAt"),
        "confidence": "high",
        "via": "skill-lock",
    }
    return {k: v for k, v in out.items() if v is not None}


FRONTMATTER_SOURCE_KEYS = (
    "homepage",
    "repository",
    "repo",
    "source",
    "upstream",
    "canonical",
    "homepage_url",
    "url",
)


def resolve_source(
    skill_id: str,
    resolved: Path,
    meta: dict,
    is_authored: bool,
    is_vendor: bool,
    overrides: dict,
) -> dict:
    # 1. Blessed / manual overrides win. Low-confidence web guesses do not
    # beat the authoritative CLI lockfile — fall through so skill-lock can win.
    ov = overrides.get(skill_id)
    ov_is_blessed = isinstance(ov, dict) and (
        ov.get("blessed") or ov.get("manual") or ov.get("confidence") == "high"
    )
    if ov_is_blessed and (ov.get("url") or ov.get("type")):
        out = dict(ov)
        out.setdefault("type", "override")
        out.setdefault("confidence", "high")
        out.setdefault("via", "override")
        if out.get("url") and not out.get("install_source_url"):
            out["install_source_url"] = out["url"]
        return out

    # 2. Authoritative CLI lockfile (install source + integrity hash).
    lock = skill_lock_source(skill_id)
    if lock:
        return lock

    # 2b. Low-confidence web / provisional overrides (after lockfile).
    if isinstance(ov, dict) and (ov.get("url") or ov.get("type")):
        out = dict(ov)
        out.setdefault("type", out.get("type") or "override")
        out.setdefault("confidence", "low")
        out.setdefault("via", out.get("via") or "override")
        if out.get("url") and not out.get("install_source_url"):
            out["install_source_url"] = out["url"]
        return out

    # 3. Explicit frontmatter source fields.
    for key in FRONTMATTER_SOURCE_KEYS:
        val = meta.get(key)
        if val and isinstance(val, str) and val.startswith(("http://", "https://", "git@")):
            url = normalize_git_url(val)
            out = {
                "type": "frontmatter",
                "url": url,
                "confidence": "high",
                "via": f"frontmatter:{key}",
            }
            if key in ("upstream", "canonical"):
                out["canonical_upstream_url"] = url
            else:
                out["install_source_url"] = url
            return out

    # 4 + 5. Plugin caches (exact repo + commit).
    ps = plugin_source(resolved)
    if ps and ps.get("url"):
        ps["install_source_url"] = ps["url"]
        return ps

    # 6. Genuinely authored skills only (explicit curated set or monorepo
    # lifecycle) — NOT the classifier's catch-all, which defaults unknown real
    # dirs to "authored" and would wrongly stamp them with the monorepo URL.
    if is_authored:
        return {
            "type": "authored",
            "url": AUTHORED_REPO_URL,
            "install_source_url": AUTHORED_REPO_URL,
            "canonical_upstream_url": AUTHORED_REPO_URL,
            "confidence": "high",
            "via": "authored-registry",
        }
    if is_vendor:
        return {
            "type": "vendor",
            "url": None,
            "confidence": "high",
            "via": "vendor-registry",
            "note": "vendored bundle / cursor-managed; not a public repo",
        }

    # 7. Enclosing local git repo of the resolved (symlink-followed) path.
    # Require a real remote URL; a repo with no remote (or an umbrella config
    # repo) is not a usable provenance signal — fall through to enrichment.
    repo = find_enclosing_repo(resolved)
    if repo is not None:
        url, commit = git_remote_and_head(str(repo))
        if url:
            return {
                "type": "local-repo",
                "url": url,
                "install_source_url": url,
                "commit": commit,
                "local_path": str(repo),
                "confidence": "high",
                "via": "git-remote",
            }

    # 8. Unknown — candidate for web enrichment.
    return {"type": "unknown", "url": None, "confidence": "none", "via": "unresolved"}


def monorepo_lifecycle(skill_id: str, monorepo: Path) -> str | None:
    if not monorepo.is_dir():
        return None
    if (monorepo / "skills" / ".experimental" / skill_id).is_dir():
        return "experimental"
    if (monorepo / "skills" / ".curated" / skill_id).is_dir():
        return "curated"
    if (monorepo / "skills" / skill_id).is_dir():
        return "curated"
    return None


def classify_skill(
    skill_id: str,
    skill_dir: Path,
    tier: str,
    vendor_ids: set[str],
    monorepo: Path,
    overrides: dict | None = None,
) -> dict:
    is_symlink = skill_dir.is_symlink()
    resolved = skill_dir.resolve()
    meta = parse_skill_frontmatter(skill_dir)
    internal = meta.get("metadata", "").find("internal: true") != -1 or (
        "internal: true" in meta.get("description", "")
    )
    # Check YAML metadata.internal properly
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        skill_md = resolved / "SKILL.md"
    if skill_md.is_file():
        raw = skill_md.read_text(encoding="utf-8", errors="replace")
        if "internal: true" in raw.split("---")[1] if raw.startswith("---") else raw:
            internal = True

    lifecycle = monorepo_lifecycle(skill_id, monorepo)

    if skill_id in EMBEDDED_SKILL_IDS or is_symlink:
        classification = "embedded"
    elif skill_id in vendor_ids and skill_id not in AUTHORED_SKILL_IDS:
        classification = "vendor"
    elif lifecycle == "experimental" or internal:
        classification = "experimental"
    elif skill_id in AUTHORED_SKILL_IDS or lifecycle == "curated":
        classification = "authored"
    elif tier == "cursor-managed":
        classification = "vendor"
    else:
        classification = "authored"

    symlink_ok = True
    if is_symlink:
        try:
            symlink_ok = resolved.is_dir() and (resolved / "SKILL.md").exists()
        except OSError:
            symlink_ok = False

    entry = {
        "id": skill_id,
        "classification": classification,
        "lifecycle": lifecycle or ("experimental" if classification == "experimental" else "curated"),
        "tier": tier,
        "path": str(skill_dir),
        "resolved_path": str(resolved),
        "is_symlink": is_symlink,
        "symlink_ok": symlink_ok,
        "version": meta.get("version"),
        "name": meta.get("name", skill_id),
    }
    if is_symlink:
        entry["symlink_target"] = str(skill_dir.readlink())
    # Strict authorship for provenance (independent of the loose classifier,
    # whose catch-all defaults unrecognized real dirs to "authored").
    is_authored = skill_id in AUTHORED_SKILL_IDS or lifecycle in ("curated", "experimental")
    is_vendor = skill_id not in AUTHORED_SKILL_IDS and (
        skill_id in vendor_ids or tier == "cursor-managed"
    )
    entry["source"] = resolve_source(
        skill_id, resolved, meta, is_authored, is_vendor, overrides or {}
    )
    return entry


def classify_global_entry(
    skill_dir: Path, tier: str, vendor_ids: set[str], monorepo: Path, overrides: dict
) -> dict:
    return classify_skill(skill_dir.name, skill_dir, tier, vendor_ids, monorepo, overrides)


def discover_global(monorepo: Path, overrides: dict | None = None) -> dict[str, list[dict]]:
    vendor_ids = load_vendor_manifest()
    overrides = overrides or {}
    out: dict[str, list[dict]] = {}
    log(f"scanning {len(GLOBAL_TREES)} global skill trees…")
    for tier, root in GLOBAL_TREES.items():
        items: list[dict] = []
        if not root.is_dir():
            log(f"  {tier}: (missing) {root}")
            out[tier] = items
            continue
        for child in sorted(root.iterdir()):
            if child.name.startswith("."):
                continue
            if not child.is_dir() and not child.is_symlink():
                continue
            skill_md = child / "SKILL.md"
            resolved_skill = child.resolve() / "SKILL.md"
            if not skill_md.exists() and not resolved_skill.exists():
                continue
            items.append(classify_global_entry(child, tier, vendor_ids, monorepo, overrides))
        log(f"  {tier}: {len(items)} skills")
        out[tier] = items
    return out


# Max directory depth to descend under each scan root (safety net; the prune
# rules below do the real work of keeping the walk fast).
PROJECT_SCAN_MAXDEPTH = 10

# Directory names that never contain first-class skills and are expensive to walk.
PRUNE_DIR_NAMES = frozenset(
    {
        "node_modules",
        ".git",
        ".svn",
        ".hg",
        "__pycache__",
        ".venv",
        "venv",
        ".tox",
        ".mypy_cache",
        ".pytest_cache",
        ".ruff_cache",
        ".next",
        ".nuxt",
        "dist",
        "build",
        ".cache",
        ".gradle",
        ".idea",
        "target",
        "upstream",
        "vendor",
        "archive",
        "disabled",
        "Library",
        ".Trash",
        # Project-local .claude skill trees are captured via the global scan;
        # the legacy find excluded them here to avoid double-counting.
        ".claude",
    }
)

# macOS Spotlight / Apple filesystem "skip indexing" markers. A directory that
# contains one of these has been explicitly flagged as junk, so we prune it too.
NEVER_INDEX_MARKERS = (
    ".metadata_never_index",
    ".metadata_never_index_unless_rootfs",
)


def is_pruned_child(name: str, parent_name: str) -> bool:
    """True if a child dir named `name` (under `parent_name`) should be skipped."""
    if name in PRUNE_DIR_NAMES or name.endswith(".noindex"):
        return True
    # ~/.cursor/extensions and ~/.cursor/plugins are large and skill-free.
    if name in ("extensions", "plugins") and parent_name == ".cursor":
        return True
    return False


def find_skill_files(scan_root: Path) -> list[Path]:
    """Pruned BFS walk for `.../skills/<name>/SKILL.md` (covers both the
    `.cursor/skills/*` and project-level `skills/*` layouts).

    Replaces a `find -maxdepth 10` subprocess that timed out on large trees.
    Junk directories are pruned by name, and any directory carrying a macOS
    Spotlight/AFS "never index" marker is skipped too. Marker detection reuses
    the `os.scandir` listing so it costs no extra stat calls per directory.
    """
    started = time.monotonic()
    hits: list[Path] = []
    stack: list[tuple[Path, int]] = [(scan_root, 0)]
    while stack:
        cur, depth = stack.pop()
        try:
            entries = list(os.scandir(cur))
        except OSError:
            continue
        names = {entry.name for entry in entries}
        # Honor Spotlight/AFS skip markers the user planted in junk dirs.
        if any(marker in names for marker in NEVER_INDEX_MARKERS):
            continue
        # A SKILL.md directly under a `skills/` dir is a skill.
        if cur.parent.name == "skills" and "SKILL.md" in names:
            hits.append(cur / "SKILL.md")
        if depth >= PROJECT_SCAN_MAXDEPTH:
            continue
        for entry in entries:
            if is_pruned_child(entry.name, cur.name):
                continue
            try:
                if not entry.is_dir(follow_symlinks=False):
                    continue
            except OSError:
                continue
            stack.append((Path(entry.path), depth + 1))
    took = time.monotonic() - started
    log(f"  {scan_root}: {len(hits)} SKILL.md files ({took:.1f}s)")
    return hits


def discover_project_skills() -> list[dict]:
    found: list[dict] = []
    seen: set[str] = set()
    slug_cache: dict[str, str] = {}

    log(f"scanning {len(SCAN_ROOTS)} project roots for local skills (pruned walk, maxdepth {PROJECT_SCAN_MAXDEPTH})…")
    for scan_root in SCAN_ROOTS:
        if not scan_root.is_dir():
            log(f"  {scan_root}: (missing)")
            continue
        log(f"  {scan_root}: walking…")
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
                    "classification": "embedded",
                }
            )
    return sorted(found, key=lambda x: (x["project_root"], x["skill"]))


def build_summary(global_data: dict[str, list[dict]]) -> dict:
    by_class: dict[str, int] = {}
    by_source: dict[str, int] = {}
    broken_symlinks: list[str] = []
    unknown_source: list[str] = []
    for items in global_data.values():
        for item in items:
            cls = item.get("classification", "unknown")
            by_class[cls] = by_class.get(cls, 0) + 1
            if item.get("is_symlink") and not item.get("symlink_ok", True):
                broken_symlinks.append(item["id"])
            src = item.get("source") or {}
            stype = src.get("type", "unknown")
            by_source[stype] = by_source.get(stype, 0) + 1
            if stype == "unknown":
                unknown_source.append(item["id"])
    return {
        "by_classification": by_class,
        "by_source_type": by_source,
        "broken_symlinks": broken_symlinks,
        "unknown_source": sorted(set(unknown_source)),
    }


def write_markdown(path: Path, payload: dict) -> None:
    summary = payload.get("summary", {})
    lines = [
        "# Skills inventory (generated)",
        "",
        f"Generated: {payload['generated']}",
        "",
        "## Summary",
        "",
    ]
    for cls, count in sorted(summary.get("by_classification", {}).items()):
        lines.append(f"- **{cls}**: {count}")
    broken = summary.get("broken_symlinks", [])
    if broken:
        lines.append(f"- **broken symlinks**: {', '.join(broken)}")
    by_source = summary.get("by_source_type", {})
    if by_source:
        lines.extend(["", "### Provenance (by source type)", ""])
        for stype, count in sorted(by_source.items(), key=lambda x: -x[1]):
            lines.append(f"- **{stype}**: {count}")
        unknown = summary.get("unknown_source", [])
        if unknown:
            lines.append(
                f"- **unresolved** ({len(unknown)}): {', '.join(unknown)} "
                "— run `scripts/enrich-provenance.py` to attempt web lookup"
            )
    lines.extend(["", "## Global", ""])

    for tier, items in payload["global"].items():
        lines.append(f"### {tier} ({len(items)})")
        lines.append("")
        for item in items:
            flags = []
            if item.get("is_symlink"):
                flags.append("symlink")
            if not item.get("symlink_ok", True):
                flags.append("BROKEN")
            flag_s = f" ({', '.join(flags)})" if flags else ""
            cls = item.get("classification", "?")
            src = item.get("source") or {}
            url = src.get("url")
            conf = src.get("confidence", "")
            conf_flag = " ⚠low" if conf == "low" else (" ⚠?" if src.get("type") == "unknown" else "")
            src_s = f" — source: {url}" if url else f" — source: {src.get('type', '?')}"
            lines.append(f"- `{item['id']}` [{cls}]{flag_s}{conf_flag}{src_s}")
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
            lines.append(
                f"- `{row['skill']}` ({row['layout']}) — `{row['relative_path']}`"
            )
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
    parser.add_argument(
        "--registry-root",
        default="",
        help="Also write registry/skills-inventory.json under this path (e.g. agent-skills monorepo)",
    )
    parser.add_argument(
        "--monorepo",
        default=str(AGENT_SKILLS_MONOREPO),
        help="Path to agent-skills monorepo for lifecycle detection",
    )
    args = parser.parse_args()

    root = (
        Path(args.compendium_root)
        if args.compendium_root
        else Path(args.dotfiles_cursor) / "compendium"
    )
    registry = root / "skills-registry"
    registry.mkdir(parents=True, exist_ok=True)

    monorepo = Path(args.monorepo)
    # Provenance overrides: prefer the monorepo registry, else the registry-root arg.
    override_dir = str((monorepo / "registry") if monorepo.is_dir() else registry)
    if args.registry_root:
        override_dir = str(Path(args.registry_root) / "registry")
    overrides = load_overrides(override_dir)
    if overrides:
        log(f"loaded {len(overrides)} provenance override(s) from {override_dir}")
    lock = load_skill_lock()
    if lock:
        log(f"loaded {len(lock)} skill-lock entries from ~/.agents/.skill-lock.json (+ peers)")
    global_data = discover_global(monorepo, overrides)
    project_data = discover_project_skills()
    log("writing inventory files…")

    payload = {
        "generated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "compendium_root": str(root),
        "monorepo_root": str(monorepo) if monorepo.is_dir() else None,
        "global": global_data,
        "project": project_data,
        "summary": build_summary(global_data),
    }

    json_path = registry / "skills-inventory.json"
    md_path = registry / "skills-inventory.md"
    json_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    write_markdown(md_path, payload)

    if args.registry_root:
        reg_root = Path(args.registry_root)
        reg_dir = reg_root / "registry"
        reg_dir.mkdir(parents=True, exist_ok=True)
        reg_json = reg_dir / "skills-inventory.json"
        reg_md = reg_dir / "skills-inventory.md"
        reg_json.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        write_markdown(reg_md, payload)
        print(f"Also wrote {reg_json}", file=sys.stderr)

    g = sum(len(v) for v in payload["global"].values())
    p = len(payload["project"])
    by_source = payload["summary"].get("by_source_type", {})
    n_unknown = len(payload["summary"].get("unknown_source", []))
    log(f"done: {g} global, {p} project-local skills; sources {dict(sorted(by_source.items()))}")
    if n_unknown:
        log(f"{n_unknown} skills have unresolved source — run scripts/enrich-provenance.py")
    print(f"Wrote {json_path} ({g} global, {p} project-local skills)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
