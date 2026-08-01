# Cursor local storage map

**Version pin:** [cursor-internals-VERSION.md](cursor-internals-VERSION.md).  
**Probed on this machine:** [research/local-storage-probe-20260730.txt](research/local-storage-probe-20260730.txt) (`confirmed` 2026-07-31).

## Core roots (macOS)

| Root | Role |
|------|------|
| `~/.cursor/` | User home Cursor config, projects, chats, plans, hooks, mcp, skills |
| `~/Library/Application Support/Cursor/User/` | VS Code–style User data (settings, workspaceStorage, globalStorage, History) |
| `<project>/.cursor/` | Project rules, skills, hooks, mcp, optional workspace plans |

Linux: `~/.config/Cursor/User/`. Windows: `%APPDATA%\Cursor\User\`.

## Git-friendly project tree

```
<project>/.cursor/
  rules/*.mdc
  skills/**/SKILL.md
  agents/          # subagents
  hooks.json + hooks/
  mcp.json
  plans/*.plan.md  # when “Save to workspace”
  canvases/        # NOT the managed IDE path; some teams mirror here manually
```

## Orphaned / home stores (not in project git)

| Path | Contents | Status |
|------|----------|--------|
| `~/.cursor/plans/*.plan.md` | Default Plan Mode files | `confirmed` — 1513 plans on this machine |
| `~/.cursor/projects/<id>/canvases/*.canvas.tsx` | Managed canvases | `confirmed` — 280 canvas dirs; catalog via `scripts/catalog-cursor-canvases.sh` |
| `~/.cursor/projects/<id>/agent-transcripts/*.jsonl` | Agent transcripts | `confirmed` — 239 dirs / 1643 jsonl |
| `~/.cursor/chats/**/store.db` | Chat SQLite stores | `confirmed` — 27 store.db |
| `~/Library/Application Support/Cursor/User/workspaceStorage/<hash>/state.vscdb` | Per-workspace ItemTable (composer IDs, UI state) | `confirmed` — 820 workspaces |
| `.../workspaceStorage/<hash>/workspace.json` | `{ "folder": "file://..." }` | `confirmed` |
| `.../globalStorage/state.vscdb` | Global `cursorDiskKV` bubbles / composer payloads | `confirmed` (file present) |
| `~/Library/Application Support/Cursor/User/History/` | Local file history | `suspected` secondary |
| `~/.cursor/ai-tracking/` | AI attribution DB | `suspected` |
| `~/.cursor/prompt_history.json` | Prompt history | `suspected` |

## Association: plans ↔ projects

There is **no** single plans database. Association is by:

1. File location (`~/.cursor/plans` vs `<project>/.cursor/plans`)
2. Editor / workspace context when created
3. Path references inside the plan body
4. Catalog scripts: [catalog-cursor-plans.sh](../scripts/catalog-cursor-plans.sh)

See [cursor-home-and-plans.md](cursor-home-and-plans.md).

## Association: canvases ↔ projects

Managed path: `~/.cursor/projects/<slug>/canvases/`. Slug encodes the workspace folder with `/` → `-` (e.g. `Users-me-dotfiles-cursor`). Catalog: [catalog-cursor-canvases.sh](../scripts/catalog-cursor-canvases.sh). Official docs describe canvases as durable Agents Window artifacts but do **not** document the on-disk managed path ([Canvases docs](https://cursor.com/docs/agent/tools/canvas)); path is community/`confirmed` locally. Forum request to allow in-repo canvases: [feature request](https://forum.cursor.com/t/allow-canvas-tsx-inside-workspace-repo-git-with-optional-sync-to-managed-canvases/159617).

## Chat / composer dual stack (`suspected` / community)

Tools like ChatStory and SpecStory read:

1. Workspace `state.vscdb` → `ItemTable` keys such as `composer.composerData`
2. Global `state.vscdb` → `cursorDiskKV` keys `composerData:*`, `bubbleId:*`
3. Optionally `~/.cursor/chats/*/store.db` and agent-transcripts

Schema is **not** published by Cursor; treat as version-sensitive (`confirmed` that DBs exist; key names `suspected` until re-queried after upgrades).

## Settings locations

| What | Where |
|------|-------|
| User `settings.json` | App Support `User/settings.json` (this machine: symlinked from [settings.json](../settings.json)) |
| Keybindings | [keybindings.json](../keybindings.json) |
| Agents UI toggles | Often reactive storage inside `state.vscdb` / app persistent storage — not all mirrored in `settings.json` |

## Inventory commands

```bash
scripts/cursor-home-inventory.sh          # sizes/mtimes under ~/.cursor
scripts/catalog-cursor-plans.sh
scripts/catalog-cursor-canvases.sh
INCLUDE_WS=1 scripts/catalog-cursor-canvases.sh
```
