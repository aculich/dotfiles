# Project (context pillar)

## Summary

`~/dotfiles/cursor` is the **Cursor editor configuration and ops hub** inside the `dotfiles` repo. It version-controls settings and keybindings, documents Cursor workflows (agents, costs, worktrees, skills), and ships scripts/`just` recipes for workspace snapshots, extension/MCP resource tuning, skills mirroring, performance captures, and Agents Window inventories. A `compendium/` scaffold backs up plans and skills; the live private sibling is typically `CURSOR_COMPENDIUM_ROOT` (`/Users/me/ops/dotfiles-cursor-compendium`). Skills authoring SoT remains `~/projects/agent-skills`, not this tree.

## Status

**As of:** 2026-07-23

- Core symlinks (settings, keybindings) healthy; `ApplicationSupport` convenience link points at live User dir.
- Dotfiles git: `main` ahead of `origin/main` by 5; uncommitted Cursor ops work (agents inventory, hygiene docs, `.context/`).
- Skills: live counts 109 / 19 / 84 vs mirror 109 / 19 / 80; drift present (run `just skill-drift` / `just skill-backup`).
- Global MCP toggle reports **DISABLED** while 15 servers remain listed in active `mcp.json`; stash holds 7.
- Agents Window inventory (2026-07-23): ~2553 composer headers, ~2441 active, 279 workspaces with active chats.
- Resource-tuning / extensions last-apply pointers are from 2026-05-29 (stale relative to current work).

## Canonical docs

| Doc | Purpose |
|-----|---------|
| `README.md` | Snapshot tools, resource tuning, extensions, MCP toggle |
| `CURRENT_STATE.md` | Symlink status and config gaps |
| `CONFIG_INVENTORY.md` | Live vs dotfiles inventory |
| `SYMLINK_STRATEGY.md` | Symlink direction and rationale |
| `docs/COMPENDIUM.md` | Sibling compendium repo + env |
| `docs/SKILLS-MANAGEMENT.md` | Skills tiers and `just` recipes |
| `docs/cursor-cloud-agents-vs-local.md` | Cloud vs local agents |
| `docs/agents-window-hygiene.md` | Agents Window Archive All hygiene |
| `docs/keybindings-guide.md` | Keybinding observability |

## Key paths

- Repo: `/Users/me/dotfiles/cursor`
- Live User config: `~/Library/Application Support/Cursor/User/`
- Live Cursor home: `~/.cursor`
- Status canvas: see `conventions.md` → `status_canvas`
