# collab-sync — reference

## just recipes

| Recipe | Role |
|--------|------|
| `just` / `just status` | Quick git + incoming + granola ls |
| `just check` | Deterministic dashboard (`scripts/collab-check.sh`) |
| `just sync` | `check` + fetch companion clone outbox if present |
| `just agent-check` | `cursor-agent --mode plan` + collab-sync read-only |
| `just agent-sync` | `cursor-agent` + collab-sync; apply bottle receive if found (still gated in skill) |

Slash skills are **not** callable from bare `just`. `just agent-*` is the bridge.

## cursor-agent prompts

**agent-check** (plan / read-only):

```text
Follow .cursor/skills/collab-sync/SKILL.md in check mode.
Run just check if available. Use Granola MCP list_meetings for folder EZW only to report gaps.
Do not write files. Emit the Collab dashboard block.
```

**agent-sync**:

```text
Follow .cursor/skills/collab-sync/SKILL.md.
Start with the read-only dashboard. If a peer ack bottle or companion_repo is available, apply message-in-a-bottle receive and update conventions/workspace.
Do not auto-ingest Granola meetings. Whimsy commits if you commit. Emit the Collab dashboard block when done.
```

Always pass `--workspace` = this repo root.

## Shell companion probe

Recommended peer (until ack): `ez-walk/from-ztoa-private`

```bash
gh api "repos/ez-walk/from-ztoa-private" --jq '{full_name,private,pushed_at,default_branch}' || echo "peer: 404"
```

If `companion_repo_https` is set in conventions, prefer that URL’s `owner/repo`.

## Granola gap report

1. Read ids from `granola/EZW/index.json` → `meetings[].id`
2. MCP: `list_meetings` with `folder_id` from conventions (`granola_folder_id`)
3. Report meetings in MCP not in index — do not ingest here

## Dashboard example (pre-ack)

```markdown
### Collab dashboard
- entanglement: offered | companion: pending Ethan ack
- bottles: outbox=1 inbox=0 ack=0 | unanswered_ping: yes
- peer repo: 404 (ez-walk/from-ztoa-private)
- peer outbox new: none
- git: ## main...origin/main
- granola mirrored: 2 | MCP new ids: none
- next: Wait for Ethan Make it so! / ack bottle; re-run /collab-sync or just check
```
