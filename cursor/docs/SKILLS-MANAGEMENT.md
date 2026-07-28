# Skills management (global, project-local, agents)

How Cursor skills are tracked across tiers, and how backups relate to the **compendium**.

## Skill tiers

| Tier | Live path | Canonical source of truth | Compendium backup |
| --- | --- | --- | --- |
| **Cursor-managed** | `~/.cursor/skills-cursor/` | Cursor (do not edit) | `mirrors/skills-snapshots/skills-cursor/` |
| **User global** | `~/.cursor/skills/` | You (often symlink into a project repo) | `mirrors/skills-snapshots/skills/` |
| **Agents global** | `~/.agents/skills/` | You / upstream installs | `mirrors/skills-snapshots/agents-skills/` |
| **Project-local** | `<project>/.cursor/skills/<name>/` | **Product git repo** (preferred) | `mirrors/by-project/<slug>/.cursor/skills/` via `snapshot-project.sh` |
| **Project skills dir** | `<project>/skills/<name>/` (non-standard) | Product repo | Same project mirror when under a discovered root |

**Project-local skills** should be committed in the **project repo** when possible. The compendium mirror is a **backup and cross-machine index**, not a second edit surface.

## Compendium vs skills-registry

### Compendium (`cursor/compendium/`)

A **private backup repo scaffold** for cross-project Cursor artifacts:

- Mirrored project `.cursor/` (rules, hooks, **skills**, etc.)
- Global and per-project **plans**
- Optional `.specstory/` (rules-only by default)
- **Global skills snapshots** under `mirrors/skills-snapshots/`

**Created:** May 2026, following the `bootstrap-tool-config-repo` skill pattern (dotfiles scaffold commit `4ef330f`, 2026-06-12). **Live sibling repo:** `/Users/me/ops/dotfiles-cursor-compendium` → private GitHub `aculich/dotfiles-cursor-compendium`. The dotfiles tree keeps the **canonical scripts**; copy or sync scaffold changes into the sibling when you change layout.

Set in shell profile:

```bash
export CURSOR_COMPENDIUM_ROOT=/Users/me/ops/dotfiles-cursor-compendium
```

### skills-registry (`compendium/skills-registry/`)

**Inventory manifests only** — YAML schema for provenance, not installation:

| File | Purpose |
| --- | --- |
| `vendor.yaml` | Third-party / marketplace / cached skills |
| `authored.yaml` | Skills you maintain (global paths, optional dedicated repo) |
| `project-index.yaml` | Projects to snapshot and metadata |
| `skills-inventory.json` | **Generated** full scan (global + project-local) |
| `skills-inventory.md` | Human-readable generated index |

Fill `vendor.yaml` / `authored.yaml` manually for important pins; run discovery for the full machine picture.

## justfile recipes (recommended entry point)

From `cursor/`, run `just` to see all recipes. Common ones:

| Recipe | What it does |
| --- | --- |
| `just status` | Git status (dotfiles + compendium), skill counts, remote privacy |
| `just skill-status` | Live-vs-mirror counts, inventory time, last mirror commit |
| `just skill-drift` | rsync dry-run of live skills vs mirror (what changed) |
| `just skill-backup-fast` | Mirror global skills + commit (skips slow project scan; ~2s) |
| `just skill-backup` | Full: mirror + regenerate inventory (project scan ~3min) + commit |
| `just skill-backup-full` | Also mirror project-local `.cursor/skills` via the compendium |
| `just skill-discover` | Regenerate `skills-inventory.{json,md}` only |
| `just remotes` | Verify GitHub remotes are private |
| `just config-snapshot` | Snapshot mcp/settings/extensions into `snapshots/` |
| `just install-daily` | launchd agent running `just skill-backup` daily at 06:15 |
| `just uninstall-daily` / `just daily-status` | Manage the daily agent |

## Keeping regular snapshots

Pick one (they compose):

1. **Manual, frequent:** `just skill-backup-fast` after adding/editing skills (commits only when content changed — no-op otherwise).
2. **Automated daily (global skills):** `just install-daily` — launchd runs `just skill-backup` at 06:15, commits to dotfiles (local; not pushed).
3. **Automated daily (project-local + plans):** the compendium launchd example (`compendium/launchd/`) runs `snapshot-all.sh` and commits to the sibling repo. `snapshot-all.sh` now also refreshes the global skills mirror.

Commits are never pushed automatically. Run `just remotes` then `git push` when you want to sync.

## Day-to-day workflow

```bash
# 1. Verify remotes are private before any push
~/dotfiles/cursor/scripts/verify-private-remotes.sh

# 2. Mirror global + agents skills and regenerate inventory
~/dotfiles/cursor/scripts/snapshot-all-skills.sh

# 3. Mirror project .cursor/ trees (includes project-local skills)
export CURSOR_COMPENDIUM_ROOT=/Users/me/ops/dotfiles-cursor-compendium
cd "$CURSOR_COMPENDIUM_ROOT"
./scripts/snapshot-all.sh    # discover projects, sync plans, snapshot each project

# 4. Commit in dotfiles (global skills mirror) and/or compendium (project mirrors)
cd ~/dotfiles && git add cursor/compendium/mirrors/skills-snapshots cursor/compendium/skills-registry
cd "$CURSOR_COMPENDIUM_ROOT" && git add -A
```

Or one shot for globals only:

```bash
~/dotfiles/cursor/scripts/snapshot-all-skills.sh
cd ~/dotfiles && git commit -am 'chore(cursor): update skills snapshot'
```

## Privacy

Skills may contain internal methodology, client context, or MCP hints. **Only push to private GitHub repos.**

Verified remotes (as of setup):

- `aculich/dotfiles` — **PRIVATE**
- `aculich/dotfiles-cursor-compendium` — **PRIVATE**

Run `verify-private-remotes.sh` before `git push`.

## Related

- [COMPENDIUM.md](COMPENDIUM.md) — sibling repo bootstrap and launchd
- `compendium/skills-registry/README.md` — YAML schema
- `~/.cursor/skills/bootstrap-tool-config-repo/SKILL.md` — original three-class provenance model
