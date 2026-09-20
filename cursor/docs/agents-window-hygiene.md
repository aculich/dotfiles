# Agents Window hygiene (listing, Archive All, automation)

**Date:** 2026-07-23  
**Status:** Field notes + inventory tooling for the Cursor 3 Agents Window sidebar.

Prefer official docs when product behavior drifts: [Agents Window](https://cursor.com/docs/agent/agents-window.md) · [Cloud Agents API](https://cursor.com/docs/cloud-agent/api/endpoints) · [Automations](https://cursor.com/docs/cloud-agent/automations.md).

---

## 1. What the sidebar is (and is not)

The Agents Window left rail lists **workspaces** (repos / folders) with agent chats under them. That listing is **local UI state**, not the same thing as:

| Surface | What it is | How to list / archive |
| --- | --- | --- |
| Agents Window workspaces + chats | Local Composer/agent sessions grouped by workspace | UI: per-workspace **Archive All**, **Remove from Sidebar**; inventory script below |
| Cloud Agents | Remote VM runs (`bc_*` / API agents) | [Cloud Agents API](https://cursor.com/docs/cloud-agent/api/endpoints): `GET /v1/agents`, `POST /v1/agents/{id}/archive` |
| Automations | Scheduled / event-triggered **Cloud Agents** | [Automations](https://cursor.com/docs/cloud-agent/automations.md) — **cannot** clear the sidebar |

**Automations are the wrong tool for clean-slate.** They run always-on cloud workflows (PR review, Slack digests, docs gen). They do not expose “Archive All chats in Agents Window.”

There is **no** supported global “Archive All across every workspace” and **no** official agent/MCP hook to archive sidebar chats ([forum thread](https://forum.cursor.com/t/agents-sidebar-archive-only-no-delete-need-permanent-cleanup/163637)).

---

## 2. Built-in UI actions (manual clean slate)

| Goal | Action | Notes |
| --- | --- | --- |
| Archive every chat in one workspace | Workspace context menu → **Archive All** | Soft hide; undo toast / restore from Archived filter |
| Hide a workspace row | **Remove from Sidebar** | Does not delete the git repo on disk |
| See archived chats | Workspaces filter → **Archived** (or Customize → show Archived) | Restore via hover / right-click |
| Archive current chat | `Cmd+Shift+E` in Agents Window | Conflicts with Explorer in classic editor; file tree in Agents Window is often `Cmd+G` |

Archive ≠ delete. Data stays in local SQLite (`state.vscdb`). Permanent bulk delete remains a product gap.

---

## 3. Current-state inventory (this repo)

### Snapshot (2026-07-23)

Captured while starting a manual Archive All sweep. Numbers move as you archive (re-run the script after Cursor flushes).

| Metric | Count |
| --- | ---: |
| Composer headers | 2553 |
| Active (not archived) | 2441 |
| Already archived | 112 |
| Workspaces with active chats | 279 |
| `workspaceStorage` folders | 793 |
| `~/.cursor/projects` with agent-transcripts | 201 (855 transcripts) |
| Cloud Agents API | skipped (`CURSOR_API_KEY` unset) |

Heaviest active workspaces at capture time (top of checklist): `umpire-empire` (257), `continuous-ai` (98), `switchdimension-community` (72), `google-workspace-tools` (65), `openpaper` (59), …

**Full checklist + JSON/CSV:** [observability/inventories/agents-window-2026-07-23/](../observability/inventories/agents-window-2026-07-23/) — start with `README.md` or `chats-by-workspace.csv`.

### Re-run inventory

Read-only against Cursor Application Support (SQLite `mode=ro` + `PRAGMA query_only`). Outputs land only under this repo’s `observability/inventories/` — never writes Cursor-owned DBs or settings.

```bash
cd ~/dotfiles/cursor
./scripts/cursor-agents-inventory.sh
# optional Cloud Agents dump (GET only; does not archive):
# CURSOR_API_KEY=… ./scripts/cursor-agents-inventory.sh
```

Writes `observability/inventories/agents-window-YYYY-MM-DD/` (JSON/CSV gitignored by default; `README.md` is fine to commit as a baseline).

**Caveats**

- Read-only against Application Support DBs. Do not hand-edit `state.vscdb` while Cursor is open — in-memory state can rewrite the DB on quit.
- Sidebar “which workspaces appear” can be a subset of all `workspaceStorage` entries; the inventory maps **chats → workspaceId → path**.
- `agent-transcripts/` under `~/.cursor/projects` are logs for agents; deleting them does not clear the Agents Window list.

---

## 4. Recommended clean-slate workflow

1. Run `./scripts/cursor-agents-inventory.sh` and keep the dated folder as a before-snapshot.
2. In Agents Window, walk the rail: **Archive All** per workspace (use the CSV/README as a checklist).
3. For repos you are not actively agenting: **Remove from Sidebar**.
4. Confirm with filter **Archived** off; restore anything you still need.
5. Re-run the inventory to measure progress (`active` should drop; `archived` should rise).
6. Optional: with `CURSOR_API_KEY`, archive old **Cloud** agents via API (separate from sidebar chats).

Going forward: prefer fewer long-lived chats per active workspace; archive finished work early; remove dead workspace rows from the sidebar so the rail stays a working set.

---

## 5. Related docs in this tree

- [cursor-classic-ide.md](cursor-classic-ide.md) — make `cursor` open the classic IDE (`--classic` wrapper)
- [cursor-cloud-agents-vs-local.md](cursor-cloud-agents-vs-local.md) — Cloud vs local Agent
- [cursor-home-and-plans.md](cursor-home-and-plans.md) — `~/.cursor` inventory patterns
- [MULTIROOT-cursor-lifecycle.md](MULTIROOT-cursor-lifecycle.md) — chat history / export community tools
- [observability/README.md](../observability/README.md) — where inventory outputs live
