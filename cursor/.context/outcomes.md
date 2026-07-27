# Outcomes

Link to **`intent.md`** for direction. Ops indicators for this Cursor hub.

## Desired outcomes

| ID | Outcome | Indicator | Evidence / sink | Review | Impact voice |
|----|---------|-----------|-----------------|--------|----------------|
| OD1 | Config integrity | Settings + keybindings symlinks resolve to this repo | `readlink` / `CURRENT_STATE.md` | weekly | Aaron |
| OD2 | Privacy posture | Dotfiles + compendium remotes PRIVATE | `just remotes` | weekly | Aaron |
| OD3 | Skills backup currency | Live≈mirror counts; drift empty or freshly committed | `just skill-status` / `skill-drift` | after skill edits | Aaron |
| OD4 | Agents hygiene visibility | Inventory <14d old when cleanup is active | `observability/inventories/*/README.md` | per cleanup sprint | Aaron |
| OD5 | MCP intentionality | Toggle state matches operator intent | `scripts/toggle-global-mcp.sh status` | when changing MCP | Aaron |

## Expected outcomes (under constraints)

| ID | Outcome | Indicator | Evidence / sink | Review | Impact voice |
|----|---------|-----------|-----------------|--------|----------------|
| OE1 | Partial skill drift between backups | Counts close; known new skills listed in drift | `just skill-drift` | daily/weekly | Aaron |
| OE2 | High Agents Window volume until Archive All | Active headers remain high until manual UI cleanup | inventory README | ongoing | Aaron |
| OE3 | Global MCP not in git | Live `mcp.json` exists; not symlinked | `CONFIG_INVENTORY.md` | backlog | Aaron |

## Divergence triggers

- Symlink broken → stop and fix before other config work
- Remotes not private → escalate immediately
- MCP toggle DISABLED while heavy work needs tools → revisit stash/enable
- Skill drift grows for >1 week without backup → run `just skill-backup`
- Inventory older than 30 days and hygiene claimed “done” → re-run inventory
