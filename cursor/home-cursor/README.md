# Optional: shadow copies of `~/.cursor` config

Use this folder for **small, intentional** copies of global Cursor config you want in git (e.g. after redacting secrets):

- Suggested files to copy when they stabilize: `mcp.json`, `hooks.json`, `cli-config.json`, and selected `rules/*.mdc` from `~/.cursor/rules/`.
- **Do not** copy `chats/`, `projects/`, `worktrees/`, `extensions/`, or `plans/` wholesale — use [scripts/cursor-home-inventory.sh](../scripts/cursor-home-inventory.sh) and [scripts/catalog-cursor-plans.sh](../scripts/catalog-cursor-plans.sh) for insight.

Rename or document when a file is a snapshot (e.g. `mcp.json` → `mcp.json.example` if you only want shape, not keys).
