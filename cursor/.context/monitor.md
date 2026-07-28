# Monitor

Routinized **ops watch** for the Cursor hub. Agents may draft status updates; humans approve commits, Archive All, and MCP enable/disable.

## Cadence table

| Topic | Scale | Source / method | Cadence | Default owner | Repo sink | Escalates to |
|-------|-------|-----------------|---------|---------------|------------|--------------|
| DWIM health + resource snapshot | local | `just doit` | on demand / when sluggish | Aaron | terminal + `observability/perf/resource-*/` + status canvas | `next-actions.md` |
| Git + skills + remotes | local | `just status` | daily / on demand | Aaron | terminal + status canvas | `next-actions.md` |
| Skill live→mirror drift | local | `just skill-drift` | after skill edits; weekly | Aaron | `compendium/mirrors/` | `outcomes.md` OD3 |
| Skill backup | local | `just skill-backup` or launchd | daily 06:15 if installed | Aaron / launchd | git commit in dotfiles | `intent.md` |
| Remote privacy | GitHub | `just remotes` / `verify-private-remotes.sh` | weekly | Aaron | stdout | `values.md` guardrails |
| Agents Window volume | Cursor UI + DB | `scripts/cursor-agents-inventory.sh` | before/after cleanup | Aaron | `observability/inventories/` | `next-actions.md` |
| MCP toggle state | `~/.cursor` | `scripts/toggle-global-mcp.sh status` | when MCP changes | Aaron | stdout | `outcomes.md` OD5 |
| Resource-tuning age | local | `config/last-*-snapshot.txt` | monthly | Aaron | `snapshots/` | `next-actions.md` |
| Cursor + system resource forensics | local | `just resource-snapshot` | when CPU pegged / multi-host hot | Aaron | `observability/perf/resource-*/` | mitigation tips in `report.md` |
| Perf / cursor -s report | Cursor open | `scripts/cursor-perf-report.sh` (opt-in; can hang under load) | ad hoc | Aaron | `observability/perf/run-*/` | purification docs |
| Interactive TUI glance | local | `btop` / optional `macmon` (`just resource-watch`) | live watching | Aaron | — | — |

## Draft-comms rule

Status canvas and `.context/` updates are **local drafts**. Do not push remotes or change live MCP without owner confirmation. `just doit` is diagnose-only (never kills windows/PIDs, never auto-applies tuning).
