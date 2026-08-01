# Conventions (machine-oriented)

## Repo

- **project_slug:** `cursor-ops`
- **repo_root:** `/Users/me/dotfiles/cursor`
- **dotfiles_root:** `/Users/me/dotfiles`
- **task_runner:** `just` — default recipe lists help; **`just status`** is read-only health; **`just doit`** is DWIM (status + resource forensics, diagnose-only)
- **status_canvas:** `/Users/me/.cursor/projects/Users-me-dotfiles-cursor/canvases/cursor-ops-status.canvas.tsx`
- **resource_snapshot:** `just resource-snapshot` → `observability/perf/resource-*/` (pointer: `observability/perf/last-resource-snapshot.txt`)
- **macos_cli_landscape:** `~/tools/macosx-tools/research/macos-system-info/CLI-RESOURCE-TOOLS.md`

## Key paths

- **settings:** `settings.json` (live → this file via symlink)
- **keybindings:** `keybindings.json` (live → this file via symlink)
- **docs:** `docs/`
- **scripts:** `scripts/`
- **config_manifests:** `config/`
- **mcp_toolboxes:** `mcp-toolboxes/`
- **compendium_scaffold:** `compendium/`
- **observability:** `observability/`
- **snapshots:** `snapshots/`
- **upstream_cost_tools:** `upstream/`
- **workspace_rules:** `.cursor/rules/`

## Skills and compendium

- **skills_sot:** `/Users/me/projects/agent-skills` (authoring SoT — not this tree)
- **live_skills:** `~/.cursor/skills`, `~/.cursor/skills-cursor`, `~/.agents/skills`
- **mirror_in_dotfiles:** `compendium/mirrors/skills-snapshots/`
- **CURSOR_COMPENDIUM_ROOT:** `/Users/me/ops/dotfiles-cursor-compendium` (live private sibling)
- **skill_backup:** `just skill-backup` / `just skill-backup-fast`

## MCP

- **global_mcp:** `~/.cursor/mcp.json` (not symlinked into this repo)
- **toggle_script:** `scripts/toggle-global-mcp.sh` (`status|disable|enable`)
- **toolboxes:** `mcp-toolboxes/*.json`

## Observability

- **perf_report:** `scripts/cursor-perf-report.sh` → `observability/perf/run-*/`
- **agents_inventory:** `scripts/cursor-agents-inventory.sh` → `observability/inventories/`
- **agents_hygiene_doc:** `docs/agents-window-hygiene.md`

## Granola / Zoom / Notes

Not primary ingest for this ops repo. Use product docs under `docs/` and inventories under `observability/` instead of meeting-sync mirrors.

## Git upstream

- **lfs_skip_smudge:** `GIT_LFS_SKIP_SMUDGE=1 git pull`
- **upstream_paths:**
  - `upstream/` (cursor cost calculator / explorer clones)

## Cadence

- **health_check:** `just status` (on demand / daily)
- **skill_backup:** launchd via `just install-daily` (06:15) or manual `just skill-backup`
- **agents_inventory:** after large Agents Window cleanup sessions
- **resource_tuning_snapshot:** before/after extension or MCP mass changes

## Canonical docs (human)

- **readme:** `README.md`
- **current_state:** `CURRENT_STATE.md`
- **config_inventory:** `CONFIG_INVENTORY.md`
- **compendium:** `docs/COMPENDIUM.md`
- **skills_management:** `docs/SKILLS-MANAGEMENT.md`
- **cloud_vs_local:** `docs/cursor-cloud-agents-vs-local.md`
- **keybindings_guide:** `docs/keybindings-guide.md`
- **agents_window_hygiene:** `docs/agents-window-hygiene.md`
- **cursor_architecture:** `docs/cursor-architecture.md`
- **cursor_storage_map:** `docs/cursor-storage-map.md`
- **cursor_settings_guide:** `docs/cursor-settings-guide.md`
- **cursor_canvases:** `docs/cursor-canvases.md`
- **cursor_tools_superprd:** `docs/cursor-tools-superprd.md`
- **cursor_tools_ontology:** `docs/cursor-tools-ontology.md`
- **cursor_internals_version:** `docs/cursor-internals-VERSION.md`
- **tool_clusters:** `docs/tools/`
