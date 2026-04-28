# Tracking `~/.cursor`, plans, and observability

This doc matches the layout under `~/dotfiles/cursor`: [snapshots/workspace/](../snapshots/workspace/), [observability/](../observability/), [home-cursor/](../home-cursor/), and scripts.

## `~/.cursor` without mirroring junk

- **Do not** commit `projects/`, `worktrees/`, `chats/`, `extensions/`, `browser-logs/`, or `ai-tracking/` — high churn, large, or sensitive.
- **Optional copies (allowlist):** use [home-cursor/README.md](../home-cursor/README.md) for small, hand-curated mirrors of `mcp.json`, `hooks.json`, `cli-config.json`, and selected `rules/*.mdc` when you want dotfiles to hold a deliberate snapshot. Runtime files under `~/.cursor` remain authoritative unless you adopt symlinks.
- **Inventory (recommended):** run [scripts/cursor-home-inventory.sh](../scripts/cursor-home-inventory.sh) to write `observability/inventories/cursor-home-<date>.json` (paths, sizes, mtimes). Commit inventories only when you want a baseline; rotate old JSON files to [attic/](../attic/) if needed.
- **Rsync (advanced):** a one-way mirror is possible with a **filter file** that excludes the directories above, `*.log`, and `worktrees/`. Prefer inventory over full mirror unless you need diffable trees. Do not store secrets in git.

## Plans: where they live, association, and catalogs

- **User-level (default):** `~/.cursor/plans/*.plan.md` (flat; filename often includes a short hash).
- **Workspace (Save to workspace):** `<project>/.cursor/plans/*.plan.md` for version control in that repo.
- **No single user-facing “plans database”** that lists every plan for every project. The `.plan.md` files are the source of truth. `ai-code-tracking.db` and similar files are unrelated to a plans index. Association with a project is by **file location**, **editor context** when the plan was created, **recent files** in workspace snapshot JSON, or path references in the plan body.
- **Catalog script:** [scripts/catalog-cursor-plans.sh](../scripts/catalog-cursor-plans.sh) lists `~/.cursor/plans`, optional paths under `~/.cursor/projects`, and optional `PROJECT_ROOTS` (space-separated) to find `.cursor/plans` in your repos.
- **Extensions:** community tools (e.g. [cursor-plan-view](https://github.com/snasa045/cursor-plan-view)) improve **editing and rendering** `*.plan.md` in VS Code/Cursor; use the catalog script for a **flat cross-project file list**, not a built-in global plans dashboard from Cursor.

## Related

- [IGNORING.md](IGNORING.md) — git vs `.cursorignore` / `.cursorindexingignore` vs VS Code watcher and search excludes; monorepo vs subfolder roots.
- [LAYOUT.md](LAYOUT.md) — separating product source, pipeline, artifacts, and vendored research; notes for `storytelling-capsules` and how to generalize.
- [CONFIG_INVENTORY.md](../CONFIG_INVENTORY.md) — full path inventory and symlink notes.
- [README.md](../README.md) — workspace snapshot tools (`SNAPSHOT_DIR`, `snapshots/workspace/`).
