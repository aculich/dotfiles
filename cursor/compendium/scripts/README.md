# Compendium scripts

Requires **`rsync`**. Set **`CURSOR_COMPENDIUM_ROOT`** to the compendium git root (the copy of this scaffold you made sibling to dotfiles).

## Denylist

All scripts pass `--exclude='mcp.json'` and similar. Edit the `RSYNC_EXCLUDES` variable in each script before mirroring new sensitive patterns.

## Files

| Script | Role |
| --- | --- |
| `discover-skills.py` | **Shim only** — execs `$AGENT_SKILLS_ROOT/scripts/discover-skills.py` (default `~/projects/agent-skills`). Do not fork invent logic here. |
| `discover-project-paths.py` | Merge **Cursor-known** workspace roots with a **disk scan** for `.cursor/`, `.claude/`, `.specstory/` under `~/projects`, `~/tools`, optional roots, and shallow `$HOME`; write `project-paths.txt` + `discover-report.json` (orphans vs stale). |
| `sync-global-plans.sh` | `~/.cursor/plans` → `plans/global/` |
| `snapshot-project.sh` | One project `.cursor/`, `.cursor/plans`, optional `.specstory` rules-only |
| `snapshot-all.sh` | Runs skills invent (unless `SKILL_DISCOVER=0`), project-path discover (unless `COMPENDIUM_AUTO_DISCOVER=0`), then global plans, then each line in `project-paths.txt` |

### skills invent

Prefer from agent-skills: `just invent-compendium`, or from dotfiles/cursor: `just skill-discover` (both call the canonical script with `--compendium-root` = `CURSOR_COMPENDIUM_ROOT`).

Bootstrap once from `project-paths.example.txt` if you need a template; day-to-day, prefer **`discover-project-paths.py`** so paths stay aligned with Cursor and disk. The YAML `project-index.yaml` is for documentation and richer metadata.

### discover-project-paths flags

- `--dry-run` — print JSON summary only; **no writes** (use `--verbose` for full path lists).
- `--compendium-root DIR` — write `project-paths.txt` and `discover-report.json` here (same as `CURSOR_COMPENDIUM_ROOT` for `snapshot-all.sh`).
- `--extra-root PATH` — repeat to scan another top-level tree (unlimited depth like `projects`/`tools`).
- `--home-maxdepth N` — shallow `$HOME` walk depth (default 5); set `0` to skip the home pass.
