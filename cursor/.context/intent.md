# Intent (intent pillar)

## Goals

- Keep Cursor **settings/keybindings** versioned and correctly symlinked.
- Keep **skills backup** and remote privacy hygiene trustworthy (`just status` / `just skill-backup`).
- Make **Agents Window** and home-inventory data actionable for cleanup without guessing.
- Keep **docs** accurate for Cloud vs local agents, costs, keybindings, and skills SoT.
- Give agents a durable **`.context/`** + status canvas so ops health is visible without re-discovering the tree.

## Success criteria

- Symlinks for settings and keybindings resolve to this repo.
- Checked remotes stay **private**.
- Skill live vs mirror drift is known and periodically committed (or intentionally deferred).
- A recent Agents Window inventory exists under `observability/inventories/` when hygiene work is underway.
- MCP enable/disable state is intentional and documented (toggle script matches operator intent).

## Audience

- Aaron (owner/operator)
- Coding agents working in this workspace

## Tone

- Precise, operational, path-first
- Prefer recipes (`just …`) over ad-hoc shell

## What “good” looks like

- `just status` is green enough to trust in under a minute
- Canvas overview matches live checks (within one refresh cycle)
- Next actions list is short and owned

## Non-goals

- Not a product app or client delivery umbrella
- Not the skills authoring SoT (that is `~/projects/agent-skills`)
- Not automatic Agents Window Archive All (manual UI only)
- Not committing secrets or live MCP tokens into git
