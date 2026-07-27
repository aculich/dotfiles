---
name: compendium-discover-projects
description: >-
  Regenerate Cursor compendium project-paths.txt from Cursor workspace storage
  plus a disk scan for .cursor/.claude/.specstory markers; classify orphans vs
  stale. Use for daily compendium updates, snapshot-all prep, or auditing
  unknown project roots under ~/projects and ~/tools.
metadata:
  source:
    upstream: https://github.com/aculich/agent-skills
    canonical: https://github.com/aculich/agent-skills
---

# Compendium project discovery

## When to use

- Before or as part of **`snapshot-all.sh`** (auto-runs discover when `COMPENDIUM_AUTO_DISCOVER` is not `0`).
- When **`project-paths.txt`** is empty, wrong, or missing repos you expect.
- To list **orphans** (marker dirs on disk that Cursor has never opened) vs **stale** (paths Cursor remembers but no longer have markers or no longer exist).

## Script

Canonical copy lives in dotfiles: **`compendium/scripts/discover-project-paths.py`**. The live compendium repo should keep a synced copy under **`$CURSOR_COMPENDIUM_ROOT/scripts/`**.

```bash
export CURSOR_COMPENDIUM_ROOT=/path/to/dotfiles-cursor-compendium

# Preview counts only (no writes)
python3 "$CURSOR_COMPENDIUM_ROOT/scripts/discover-project-paths.py" --dry-run

# Full paths in stdout JSON (large)
python3 "$CURSOR_COMPENDIUM_ROOT/scripts/discover-project-paths.py" --dry-run --verbose

# Write project-paths.txt + discover-report.json
python3 "$CURSOR_COMPENDIUM_ROOT/scripts/discover-project-paths.py" --compendium-root "$CURSOR_COMPENDIUM_ROOT"
```

## Behavior (short)

- **Cursor-known:** `~/Library/Application Support/Cursor/User/workspaceStorage/*/workspace.json` and `globalStorage/storage.json` (backup workspaces, opened windows, last active).
- **Disk scan:** `~/projects`, `~/tools`, optional `--extra-root`, and shallow `$HOME` walk (`--home-maxdepth`, default 5). Prunes `Library`, `node_modules`, `.git`, etc.
- **Umbrella dirs:** `~/projects` and `~/tools` often have their own `.cursor` for the umbrella repo; the script **still descends** into child folders so each nested project is listed, not only the umbrella root.
- **Outputs:** `project-paths.txt` (known paths first, then orphans with `orphan-…` slugs), `discover-report.json` (`orphans`, `stale_known`, full lists).

## Environment

| Variable | Effect |
| --- | --- |
| `CURSOR_COMPENDIUM_ROOT` | Required for writes; compendium git root. |
| `COMPENDIUM_AUTO_DISCOVER` | If `0`, **`snapshot-all.sh`** skips discover and uses existing `project-paths.txt`. Default: discover runs when the script file exists. |

## Daily flow

```bash
export CURSOR_COMPENDIUM_ROOT=…
cd "$CURSOR_COMPENDIUM_ROOT"
./scripts/snapshot-all.sh   # runs discover first unless COMPENDIUM_AUTO_DISCOVER=0
```

After changing dotfiles scaffold scripts, **`rsync`** or copy into the live compendium repo so launchd and local paths stay aligned.
