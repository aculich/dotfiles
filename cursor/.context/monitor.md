# Monitor

Routinized **ops watch** for the Cursor hub. Agents may draft status updates; humans approve commits, Archive All, and MCP enable/disable.

## Cadence table

| Topic | Scale | Source / method | Cadence | Default owner | Repo sink | Escalates to |
|-------|-------|-----------------|---------|---------------|------------|--------------|
| Git + skills + remotes | local | `just status` | daily / on demand | Aaron | terminal + status canvas | `next-actions.md` |
| Skill live→mirror drift | local | `just skill-drift` | after skill edits; weekly | Aaron | `compendium/mirrors/` | `outcomes.md` OD3 |
| Skill backup | local | `just skill-backup` or launchd | daily 06:15 if installed | Aaron / launchd | git commit in dotfiles | `intent.md` |
| Remote privacy | GitHub | `just remotes` / `verify-private-remotes.sh` | weekly | Aaron | stdout | `values.md` guardrails |
| Agents Window volume | Cursor UI + DB | `scripts/cursor-agents-inventory.sh` | before/after cleanup | Aaron | `observability/inventories/` | `next-actions.md` |
| MCP toggle state | `~/.cursor` | `scripts/toggle-global-mcp.sh status` | when MCP changes | Aaron | stdout | `outcomes.md` OD5 |
| Resource-tuning age | local | `config/last-*-snapshot.txt` | monthly | Aaron | `snapshots/` | `next-actions.md` |
| Perf / idle CPU | Cursor open | `scripts/cursor-perf-report.sh` | when sluggish | Aaron | `observability/perf/run-*/` | purification docs |

## Draft-comms rule

Status canvas and `.context/` updates are **local drafts**. Do not push remotes or change live MCP without owner confirmation.
