# Domain knowledge

Stable facts mechanisms an assistant would not infer from general knowledge.

## Terms

- **Cursor ops hub:** this directory (`~/dotfiles/cursor`) — config + docs + scripts, not an application.
- **Compendium:** private sibling backup/index (`CURSOR_COMPENDIUM_ROOT`, often `/Users/me/ops/dotfiles-cursor-compendium`); scaffold also lives under `compendium/` here.
- **Skills SoT:** `~/projects/agent-skills` — invent/discover scripts and authored skills live there.
- **Resource tuning:** manifests under `config/` + scripts that snapshot then disable heavy extensions/MCP for RAM.
- **Agents Window inventory:** read-only dump from `state.vscdb` / workspaceStorage via `scripts/cursor-agents-inventory.sh`.

## Resource map (what this project owns)

| Category | Paths | Responsibility |
|----------|-------|----------------|
| Core editor config | `settings.json`, `keybindings.json` | Symlinked live User config |
| Convenience runtime link | `ApplicationSupport` → live User | Browse only; not a portable backup |
| Docs | `docs/` | Product learnings, hygiene, costs, worktrees |
| Scripts + just | `scripts/`, `justfile` | Snapshots, tuning, inventories, skill mirror |
| Config manifests | `config/` | Extension keep list, resource-tuning, MCP stash pointer |
| MCP toolboxes | `mcp-toolboxes/` | Named MCP bundles for project activation |
| Compendium / skills mirror | `compendium/` | Scaffold + mirrors + registry under dotfiles |
| Observability | `observability/` | Perf runs, inventories, purification ledger |
| Snapshots | `snapshots/` | Workspace / config / extensions timestamped dumps |
| Upstream | `upstream/` | Vendored cost-tool clones |
| Workspace rules | `.cursor/rules/` | Version snapshot, shell/python practices, warmup/port |
| Agent context | `.context/` | Intent/context/values for agents |
| Research JSON (attic-ish) | root `cursor-*-research.json` | Historical research dumps |
| Optional home copies | `home-cursor/` | Allowlisted global copies only |

## Data / systems

- Live Cursor User: `~/Library/Application Support/Cursor/User/`
- Live Cursor home: `~/.cursor` (`mcp.json`, `skills/`, `projects/`, `plans/`)
- Dotfiles git root: `/Users/me/dotfiles` (this tree is `cursor/` inside it)

## Pitfalls

- `ApplicationSupport` is **huge** runtime; do not git-add it as content.
- Canvas files must live under `~/.cursor/projects/<workspace>/canvases/` — not under this repo — to be detected.
- Global MCP is **not** currently symlinked into this repo; editing live `~/.cursor/mcp.json` does not create a git history here.
- Inventory JSON under `observability/inventories/` may be gitignored; README snapshots can be committed selectively.
- zsh: never put `!` inside double-quoted shell strings (history expansion).
