# Values (values pillar)

## Guardrails (hard limits — MUST NOT)

- Commit secrets, API keys, OAuth tokens, or full live `mcp.json` with credentials
- Force-push `main` / `master` or run destructive git unless explicitly requested
- Delete files or large code sections without explicit permission
- Treat `ApplicationSupport` / runtime Cursor dirs as portable sources of truth to commit wholesale
- Publish skills/compendium remotes as public when they may contain private plans or MCP-adjacent data
- Invent model IDs or bypass version-snapshot rules when writing provider code elsewhere

## Guiderails (preferences — SHOULD)

- Prefer `just` recipes for status, skill backup, and remotes checks
- Keep skills authoring in `~/projects/agent-skills`; treat this tree as ops + mirror
- Prefer Oh My Zsh / documented patterns in parent dotfiles over one-off duplicates
- Cite paths and recipes in docs; flag uncertainty when inventory JSON is stale
- Split commits into reviewable chunks when asked to commit
- Use `uv` / venvs for Python; never `pip install --break-system-packages`

## Sensitive framing

- This repo may reference private GitHub remotes, workspace paths, and chat/agent volume metrics — keep summaries operational, not gossip about other projects' contents
