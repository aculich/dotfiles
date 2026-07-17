# Cursor skills backup strategy
_Exported on 7/17/2026 at 06:35:21 PDT from Cursor (3.12.17)_

---

**User**

are we keeping snapshot backups of ~/.cursor/skills and version controlling our cursor skills, as well as other skills that we are installing and writing ourselves? Let's make sure we do that in some quick and dirty way right now if we're not already doing it.

---

**Cursor**

I'll investigate the current state of skill backups/version control in your dotfiles setup before making changes.

Let me look at the existing backup infrastructure and whether skills are already tracked.

Let me examine the existing snapshot script and what it captures, plus check if skills are in any snapshot.

Let me look at the existing skills-registry and the sync manifest to understand what's already in place.

Let me check the skills for symlinks, sizes, and any large/junk content before designing the backup.

I now have a clear picture. Here's the situation:

- `~/.cursor/skills/` (54 entries, ~1.1M) and `~/.cursor/skills-cursor/` (~292K) are **not** version-controlled or backed up anywhere. Some skills are symlinks into other repos (`wip-*`, `cidr-letterhead`).
- Your dotfiles repo has a `cursor/compendium/skills-registry/` that was *designed* for this (it even references `mirrors/skills-snapshots/`), but it's empty/unimplemented (`authored.yaml`/`vendor.yaml` are just `[]`, and `mirrors/` has no skills content).

So: no, we're not doing it yet. Let me wire up a quick-and-dirty mirror script that copies both skill trees into the repo (dereferencing symlinks so linked skills get captured too), then run it.

Now let me make it executable and run it.

Let me verify the mirror captured everything (including the symlinked skills' real content) and check git sees it.

Let me confirm nothing important in the mirror is being blocked by `.gitignore`, then show what will be committed.

Done. Here's the setup, and it's staged in the working tree ready to commit.

**What I found:** Skills were *not* backed up or version-controlled anywhere. The `cursor/compendium/skills-registry/` was designed for this but empty/unimplemented.

**What I added:**
- `cursor/scripts/snapshot-skills.sh` — quick-and-dirty mirror script (sits alongside your existing `snapshot-cursor-config.sh`). It `rsync`s both `~/.cursor/skills` and `~/.cursor/skills-cursor` into the repo, **dereferences symlinks** (so `wip-*` and `cidr-letterhead`, which point into other repos, get captured as real content), excludes junk (`.git`, `__pycache__`, `.pyc`, `.DS_Store`, `node_modules`), and writes a `MANIFEST.txt` recording the symlink provenance.
- Ran it: mirrored **52 skills + 19 cursor-managed skills** into `cursor/compendium/mirrors/skills-snapshots/` (~2.5M, ~220 files).

**Verified:** symlinked skills are now real dirs in the mirror; the only files `.gitignore` skips are generated sample outputs (`cidr-letterhead/examples/_out/*.pdf|docx|png`), which is correct — no need to version generated artifacts.

Re-running the script anytime keeps the mirror in sync (`--delete`), so it doubles as both a repeatable snapshot and the version-controlled copy once committed.

One thing to decide, since committing 220 files and how (if at all) to automate ongoing snapshots is your call.

> **Commit the skills mirror + snapshot script now?**
> - Yes, commit now (Recommended) ✔
> - No, leave it staged; I'll commit myself

> **Automate ongoing snapshots?**
> - Keep manual (run script when I remember) (Recommended) ✔
> - Add a daily launchd job (there's an example plist in compendium/launchd)
> - Wire into an existing hook/other script

I'll commit the skills mirror and snapshot script now.

Committed. Your Cursor skills are now backed up and version-controlled.

## Summary

**Before:** Neither `~/.cursor/skills` nor `~/.cursor/skills-cursor` were backed up or tracked. The `skills-registry` scaffolding existed but was empty.

**Now:**
- **New script** `cursor/scripts/snapshot-skills.sh` — re-runnable mirror that keeps the repo copy in sync (`rsync --delete`), dereferences symlinks, excludes junk, and writes a `MANIFEST.txt` with symlink provenance.
- **Committed snapshot** (`e559c65`, 220 files) of all 52 personal skills + 19 Cursor-managed skills into `cursor/compendium/mirrors/skills-snapshots/`, including the real content behind the `wip-*` and `cidr-letterhead` symlinks.

**Ongoing use (manual, per your choice):** whenever you add/edit/install skills, run:

```bash
cursor/scripts/snapshot-skills.sh && git -C ~/dotfiles add cursor/compendium/mirrors/skills-snapshots && git -C ~/dotfiles commit -m "Update skills snapshot"
```

Note: the commit is local only — I didn't push (no push without your say-so). Also, a handful of *generated* sample outputs in `cidr-letterhead/examples/_out/` (PDF/docx/png) are intentionally skipped by `.gitignore`; the skill source and its build scripts are all captured, so those regenerate on demand.

---

**User**

and what about project-local skills? how do we track and manage those if they are not in the top-level HOME ~/.cursor/skills and ~/.cursor/skills-cursor directories?
what is the compendium and what is the skills-registry?
why do they already exist and when/why were they created?
and let's just make sure as we update things we should commit everything and everything we're doing here should have private github repos before we push, making sure it is private
And in any case, I want to make sure all skills whether global, user, or project-local levels are all tracked, versioned, and managed

---

**Cursor**

I'll dig into the compendium/skills-registry history and how project-local skills are handled today, then outline a full tracking plan.


I have the full picture. The compendium scaffold exists but was never fully wired up; I'll implement unified discovery, snapshotting for all skill tiers, and a pre-push privacy check.


The sibling compendium repo is missing the new discover script — I'll fix path resolution and sync the scripts there.


The project scan is slow on a large tree — I'll optimize discovery and re-run it.


The discovery scan was matching `.claude/skills` and `upstream/` paths — I'll tighten the patterns.


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

**User**

<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: success
task_id: 691966
title: Check repo privacy and find project skills
tool_call_id: tool_9e8bab03-06fd-4ba9-8e24-92814ba7480
output_path: /Users/me/.cursor/projects/Users-me-dotfiles-cursor/terminals/691966.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed). If there's no follow-ups needed, don't explicitly say that.</user_query>

<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: success
task_id: 691967
title: Find project-local and agents skills
tool_call_id: tool_af2a88a0-5582-4504-82ff-c9a97fe789c
output_path: /Users/me/.cursor/projects/Users-me-dotfiles-cursor/terminals/691967.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed). If there's no follow-ups needed, don't explicitly say that.</user_query>

<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: aborted
task_id: 691968
title: Sync scripts to sibling and run snapshot for dotfiles compendium
tool_call_id: tool_5c6f2685-43b3-43b3-a932-e46c4e69dd8
output_path: /Users/me/.cursor/projects/Users-me-dotfiles-cursor/terminals/691968.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed). If there's no follow-ups needed, don't explicitly say that.</user_query>

<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: aborted
task_id: 691969
title: Run optimized discover-skills only
tool_call_id: tool_b7c92981-9466-450f-a45f-389d42a2c0a
output_path: /Users/me/.cursor/projects/Users-me-dotfiles-cursor/terminals/691969.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed). If there's no follow-ups needed, don't explicitly say that.</user_query>

<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: aborted
task_id: 691970
title: Run optimized discover-skills
tool_call_id: tool_ff36d7e9-f9c1-4e42-97fe-1cdf69e23b5
output_path: /Users/me/.cursor/projects/Users-me-dotfiles-cursor/terminals/691970.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed). If there's no follow-ups needed, don't explicitly say that.</user_query>

<system_notification>
The following task has finished. If you were already aware, ignore this notification and do not restate prior responses.

<task>
kind: shell
status: success
task_id: 691971
title: Sample find results to see false positives
tool_call_id: tool_70919584-8df1-4e4b-b71f-e53f0ff3cd5
output_path: /Users/me/.cursor/projects/Users-me-dotfiles-cursor/terminals/691971.txt
</task>
</system_notification>
<user_query>Briefly inform the user about the task result and perform any follow-up actions (if needed). If there's no follow-ups needed, don't explicitly say that.</user_query>

---

**Cursor**

I'll quickly check the background task outputs and summarize what they found.


Those background scans finished and mostly confirmed what we already wired up:

- **Privacy check:** both `aculich/dotfiles` and `aculich/dotfiles-cursor-compendium` are **PRIVATE**.
- **Project-local skills:** dozens exist under `~/projects/*/.cursor/skills/` (e.g. `writing-quality`, `cidr-evictionstory-mn`, `proposal-studio`, `storytelling-capsules`).
- **Agents skills:** 17 under `~/.agents/skills/` (google-agents-cli-*, perks, pubmed-database, etc.).
- **False positives:** early scans also hit `upstream/` clones and `.claude/skills/` — that's why `discover-skills.py` now excludes those paths.

The slow discovery runs were killed mid-scan, but the optimized version completed successfully (**88 global + 56 project-local** skills inventoried) and both repos are committed locally.

---

**User**

is this skill backed up now?
/Users/me/.cursor/skills/tools-quickstart-bootstrap/SKILL.md

---

**Cursor**

Yes. `tools-quickstart-bootstrap` is backed up.

- **Live:** `~/.cursor/skills/tools-quickstart-bootstrap/SKILL.md`
- **Mirror:** `dotfiles/cursor/compendium/mirrors/skills-snapshots/skills/tools-quickstart-bootstrap/SKILL.md` (same size, 5798 bytes)
- **Git:** committed in `e559c65` (initial skills snapshot), with the inventory updated in `9e8a8b0`
- **Inventory:** listed under global `cursor-user` in `skills-registry/skills-inventory.json`

It’s also mirrored in the sibling compendium repo (`~/src/dotfiles-cursor-compendium/mirrors/skills-snapshots/skills/tools-quickstart-bootstrap/`). Nothing has been pushed to GitHub yet — commits are local only.

---

**User**

how do we regularly keep snapshots and version control of all our skills now that we've done an initial one?

among other things it would be nice to have a justfile in this  /Users/me/dotfiles/cursor directory that gives us a way to find out the status of the various cursor related things including this skills compendium and to be able to `just skill-backup` or some such other kinds of things

---

**Cursor**

I'll set up a `justfile` for recurring skill snapshots and cursor status. Let me first check what exists and what `just` recipes would map well to the scripts.

`just` is installed (1.55.1), no existing justfile. Let me look at the launchd example and a couple scripts to design good recipes plus the recurring automation.

Everything's in place to build this. `snapshot-all.sh` already calls `snapshot-skills.sh`, so the daily compendium job also refreshes global skills. Let me create the justfile.

Now let me test the key recipes to make sure they parse and run.

`--list` works. Now let me test the read-only status recipes.

Let me re-run `skill-drift` fully to check the section headers render.

The `skill-drift` section headers aren't printing — the compressed one-liner is fragile. Let me rewrite it as a proper shebang recipe.

`skill-drift` now works (showing timestamp-only drift because the last snapshot targeted the sibling repo, not the dotfiles mirror). Let me pin `skill-snapshot`/`skill-backup` to the dotfiles compendium so the committed mirror is always the one refreshed, and keep the env-based sibling only for the full/status recipes.

The backup includes the ~3 min discovery scan. Let me wait for it.

`just skill-backup` works end-to-end (mirrored, inventoried, committed `50de963`). The discovery scan makes it ~3 min, though. Let me add a fast path that skips the slow project scan for quick global backups.

Good — fast backup runs in ~1.5s. But I notice it created a commit for just the MANIFEST timestamp bump, which will produce noise commits even when nothing changed. Let me remove the volatile timestamp from the manifest so commits only happen on real content changes, and switch `skill-status` to use git for timing.

Now update `skill-status` to derive timing from git instead of the removed manifest timestamp.

Now it's a clean no-op on re-run. Let me verify the combined `status` recipe and then update docs.

Everything works. Now let me add a "Regular snapshots" section to the docs referencing the justfile.

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

