Here is the full picture, what was already in place, and what we wired up today.

## The three skill tiers

| Tier | Live location | Source of truth | Backup |
|------|---------------|-----------------|--------|
| **Cursor-managed** | `~/.cursor/skills-cursor/` | Cursor (don't edit) | `mirrors/skills-snapshots/skills-cursor/` |
| **User global** | `~/.cursor/skills/` | You (often symlinked from a project repo) | `mirrors/skills-snapshots/skills/` |
| **Agents global** | `~/.agents/skills/` | You / upstream installs | `mirrors/skills-snapshots/agents-skills/` |
| **Project-local** | `<project>/.cursor/skills/<name>/` | **The product git repo** | `mirrors/by-project/<slug>/.cursor/skills/` via `snapshot-project.sh` |

Project-local skills were **already designed** to be captured: `snapshot-project.sh` rsyncs the entire `.cursor/` tree, which includes `.cursor/skills/`. The gap was that nobody had been running the compendium snapshots (`project-paths.txt` in the sibling repo was empty).

Discovery found **56 project-local skills** across your projects (e.g. `writing-quality-pipeline`, `proposal-critique`, `cidr-letterhead` in `library__cidrlab`, etc.). Those should live in their **project repos** as canonical copies; the compendium is the cross-project backup.

## What is the compendium?

A **private backup/index repo** for Cursor artifacts scattered across machines and projects:

- Mirrored project `.cursor/` (rules, hooks, **skills**, etc.)
- Global and per-project **plans**
- Optional `.specstory/` snippets
- Global skills snapshots

**When/why created:** May 16, 2026, following your `bootstrap-tool-config-repo` skill. The scaffold landed in dotfiles on **2026-06-12** (`4ef330f`). The live sibling repo is:

- **Path:** `~/src/dotfiles-cursor-compendium`
- **Remote:** `aculich/dotfiles-cursor-compendium` (**PRIVATE**)

`CURSOR_COMPENDIUM_ROOT` should point there. Dotfiles keeps the **canonical scripts**; the sibling is where operational snapshots were meant to land.

## What is skills-registry?

**Inventory manifests only** — not installers. YAML schema for provenance:

- `vendor.yaml` — third-party / marketplace skills
- `authored.yaml` — skills you maintain (with optional dedicated repo)
- `project-index.yaml` — which projects to snapshot

These were scaffolded empty (`[]`) in May 2026 and never filled in. We added **generated** inventory:

- `skills-inventory.json` — machine scan (88 global + 56 project-local)
- `skills-inventory.md` — human-readable index

## Privacy (verified)

Both remotes are **PRIVATE**:

- `aculich/dotfiles`
- `aculich/dotfiles-cursor-compendium`

New script: `cursor/scripts/verify-private-remotes.sh` — run this before any `git push` on skills/compendium data.

**Nothing was pushed** — commits are local only, per your rules.

## What we implemented today

1. **`snapshot-skills.sh`** — now mirrors `~/.cursor/skills`, `skills-cursor`, and `~/.agents/skills` (dereferencing symlinks)
2. **`discover-skills.py`** — scans global + project trees, writes inventory
3. **`snapshot-all-skills.sh`** — one command for globals + inventory + privacy check
4. **`verify-private-remotes.sh`** — blocks push if a remote isn't private
5. **`cursor/docs/SKILLS-MANAGEMENT.md`** — full workflow doc
6. **Committed** in both repos:
   - `dotfiles`: `9e8a8b0`
   - `dotfiles-cursor-compendium`: `ddedcf6`

## Your ongoing workflow

```bash
# Globals + inventory (~3 min for discovery scan)
~/dotfiles/cursor/scripts/snapshot-all-skills.sh
cd ~/dotfiles && git commit -am 'chore: update skills snapshot'

# Project-local backups (includes .cursor/skills per project)
export CURSOR_COMPENDIUM_ROOT=~/src/dotfiles-cursor-compendium
cd "$CURSOR_COMPENDIUM_ROOT"
./scripts/snapshot-all.sh    # discover projects, sync plans, mirror each .cursor/
git commit -am 'chore(compendium): snapshot'

# Before pushing either repo
~/dotfiles/cursor/scripts/verify-private-remotes.sh
git push   # only after verify passes
```

## Architecture note

You now have **two copies** of global skills mirrors:

- `dotfiles/cursor/compendium/mirrors/skills-snapshots/` (committed today)
- `~/src/dotfiles-cursor-compendium/mirrors/skills-snapshots/` (sibling compendium)

That matches the original design: dotfiles = scaffold + scripts; sibling compendium = operational backup repo. Project-local skills still need a `snapshot-all.sh` run to populate `mirrors/by-project/` — that step hasn't been done yet (it will take longer since it walks every discovered project).

If you want, I can run `snapshot-all.sh` against the sibling compendium next to back up all project-local `.cursor/skills/` trees, or push both local commits after another privacy verify.

---

Those background scans finished and mostly confirmed what we already wired up:

- **Privacy check:** both `aculich/dotfiles` and `aculich/dotfiles-cursor-compendium` are **PRIVATE**.
- **Project-local skills:** dozens exist under `~/projects/*/.cursor/skills/` (e.g. `writing-quality`, `cidr-evictionstory-mn`, `proposal-studio`, `storytelling-capsules`).
- **Agents skills:** 17 under `~/.agents/skills/` (google-agents-cli-*, perks, pubmed-database, etc.).
- **False positives:** early scans also hit `upstream/` clones and `.claude/skills/` — that's why `discover-skills.py` now excludes those paths.

The slow discovery runs were killed mid-scan, but the optimized version completed successfully (**88 global + 56 project-local** skills inventoried) and both repos are committed locally.


---

Yes. `tools-quickstart-bootstrap` is backed up.

- **Live:** `~/.cursor/skills/tools-quickstart-bootstrap/SKILL.md`
- **Mirror:** `dotfiles/cursor/compendium/mirrors/skills-snapshots/skills/tools-quickstart-bootstrap/SKILL.md` (same size, 5798 bytes)
- **Git:** committed in `e559c65` (initial skills snapshot), with the inventory updated in `9e8a8b0`
- **Inventory:** listed under global `cursor-user` in `skills-registry/skills-inventory.json`

It’s also mirrored in the sibling compendium repo (`~/src/dotfiles-cursor-compendium/mirrors/skills-snapshots/skills/tools-quickstart-bootstrap/`). Nothing has been pushed to GitHub yet — commits are local only.

```bash
/Users/me/src
➜  src tree -L3 -td
.
├── skill-eval
│   ├── claude-adhd-skills
│   │   ├── examples
│   │   ├── hooks
│   │   └── skills
│   └── some-claude-skills
│       ├── adhd-daily-planner
│       ├── project-management-guru-adhd
│       ├── adhd-design-expert
│       └── tech-entrepreneur-coach-adhd
└── dotfiles-cursor-compendium
    ├── plans
    │   ├── global
    │   └── by-project
    ├── launchd
    ├── scripts
    │   └── __pycache__
    ├── mirrors
    │   ├── skills-snapshots
    │   └── by-project
    └── skills-registry

22 directories
➜  src 
```

---

Done. There's now a `justfile` at `/Users/me/dotfiles/cursor/justfile` and a clear recurring-backup story. Committed as `7f8866c` (plus the snapshot commits from testing).

## How to keep skills backed up regularly

Three composable options (documented in `SKILLS-MANAGEMENT.md`):

1. **Manual/frequent:** `just skill-backup-fast` — mirrors global skills and commits in ~2s. Commits **only when content actually changed** (no-op otherwise, so no noise commits).
2. **Automated daily:** `just install-daily` — installs a launchd agent running `just skill-backup` at 06:15, committing to dotfiles locally.
3. **Project-local + plans:** the existing compendium launchd example runs `snapshot-all.sh` (which now also refreshes the global skills mirror) and commits to the sibling repo.

Nothing is ever auto-pushed — run `just remotes` then `git push` when you want to sync.

## The justfile recipes

```
just              # list recipes
just status       # git status (dotfiles + compendium) + skill counts + remote privacy
just skill-status # live-vs-mirror counts, inventory time, last mirror commit
just skill-drift  # rsync dry-run: exactly which skills changed since last backup
just skill-backup       # full: mirror + inventory scan (~3min) + commit
just skill-backup-fast  # fast: mirror + commit, skips project scan (~2s)
just skill-backup-full  # also mirrors project-local .cursor/skills via compendium
just skill-discover     # regenerate skills-inventory.{json,md}
just remotes            # verify GitHub remotes are private
just config-snapshot    # snapshot mcp/settings/extensions
just install-daily / uninstall-daily / daily-status
```

## Key fixes made while building it

- Added a `SKILL_DISCOVER=0` fast path so quick backups skip the slow 3-min project scan.
- Removed the volatile `generated:` timestamp from `MANIFEST.txt` so backups don't create empty timestamp-only commits — verified a second `skill-backup-fast` run correctly reports "No skill changes to commit."
- `skill-status` now reports the last mirror **git commit** rather than a file timestamp.
- Pinned `skill-backup`/`skill-backup-fast` to the dotfiles mirror so the committed copy is always the one refreshed, regardless of `CURSOR_COMPENDIUM_ROOT`.

All verified working. Recommended daily driver: `just skill-backup-fast`, or `just install-daily` to automate it.
