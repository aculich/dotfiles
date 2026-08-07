## Planning prompt: Compendium / skills backup UX — signal over noise

**Mode:** Plan only. Do not execute or edit code until I review the plan.

**Workspace / env:** Work from `~/dotfiles/cursor` with
`CURSOR_COMPENDIUM_ROOT=/Users/me/ops/dotfiles-cursor-compendium`.
Do not point push automation at the scaffold under `dotfiles/cursor/compendium`
unless I explicitly opt in.

### Context (estate as it exists today)

I maintain Cursor ops from `~/dotfiles/cursor` via a `justfile` with two backup layers:

1. **Skills backups** (`skill-backup`, `skill-backup-fast`, etc.) — mirror global skill trees into the **dotfiles** scaffold (`cursor/compendium/mirrors/skills-snapshots`), optionally regenerate inventory, **commit locally, do not push**.
2. **Compendium backup** (`compendium-backup`) — runs the live ops sibling at `$CURSOR_COMPENDIUM_ROOT` (typically `~/ops/dotfiles-cursor-compendium`): skills mirror + invent + project-path discover + global plans + ~850 per-project snapshots, then **`commit-and-push.sh`** to a **private** GitHub remote (opt out with `COMPENDIUM_AUTO_PUSH=0`).

Important distinctions already encoded in the justfile / docs:

- `just doit` is **diagnose-first** (status + resource snapshot + tips). It is **not** a backup and must not become one.
- `skill-backup*` ≠ `compendium-backup` (different repos, push posture, scope).
- Project-local skills ride along in **compendium** project mirrors, not in normal `skill-backup`.
- Authored skills SoT remains `~/projects/agent-skills`; ops/compendium is DR / inventory, not a second edit surface.

**Script SoT (hard requirement):**

- Implement logging/UX changes in the **dotfiles canonical scripts**:
  - `~/dotfiles/cursor/compendium/scripts/` (snapshot-all, snapshot-project, commit-and-push, discover shims, etc.)
  - `~/dotfiles/cursor/scripts/` (skill helpers: `snapshot-skills.sh`, `snapshot-all-skills.sh`, …)
- Then **sync/copy into** `$CURSOR_COMPENDIUM_ROOT/scripts/` so `just compendium-backup` (which execs the **ops** tree’s `snapshot-all.sh`) actually picks up the changes.
- The plan must include that sync step. LaunchAgent calls ops `snapshot-all.sh` directly (not via `just`), so logging must work without the justfile.

### Problem

`just compendium-backup` (and the underlying `scripts/snapshot-all.sh` in the ops tree / scaffold) is **correct but unusable as an interactive tool**:

- Dominated by progress noise: one `Snapshot path -> mirrors/by-project/...` line per project (~800+ lines from `snapshot-project.sh`), plus verbose discover ticks.
- **Signal is missing mid-run**: no clear “skill added/changed,” “project mirror dirty,” “discover orphans/stale moved,” etc.
- **End signal is thin**: `commit-and-push` may say `3 files changed` / `pushed` without listing what changed or characterizing collection health (live vs mirror drift, inventory totals, push/skip, privacy, phase timings).
- Immediate re-run still pays full walk cost; publish *should* be near-noop (`nothing to commit` / already up to date) when the tree is stable, but generated inventory/paths can still churn small commits — treat that as a known tension to acknowledge in the plan (quiet UX first; optional later work on idempotent generated artifacts).

### Purpose / intent

Make backup runs **operator-legible**: prove work is happening without drowning in path spam; surface **notable deltas** as they occur; end with a **status characterization** of the collection and publish result so I know whether DR is healthy, drifted, committed, and pushed — without reading 1000 lines of rsync chatter.

This is a **UX / observability** change to existing scripts and just recipes, not a redesign of backup topology, remotes, or SoT.

### Priority (do not waffle)

| Priority | Scope |
|---|---|
| **P0 (v1 must ship)** | Three-channel logging + progress + signal + end summary for the **`compendium-backup` / `snapshot-all.sh` path** (phases A–B below) |
| **P1** | Curated daily-driver `just` list; full catalog via `just menu` (or equivalent) |
| **P2 / follow-up** | `just skill-recent` (week/month/top-N via git on mirrors); idempotent invent/`project-paths.txt` churn |

**Logging scope for v1:** apply to the **`snapshot-all.sh` / compendium-backup path** (and shared helpers it calls: skills mirror, discover, project snapshot, commit-and-push). `skill-backup` / `skill-backup-fast` may stay as-is in v1 unless a shared helper makes quieting them free; if so, note it as a small bonus, not a blocker.

### Non-goals

- Do not merge `doit` with `compendium-backup`.
- Do not auto-push **dotfiles** skills commits.
- Do not change privacy guarantees (still verify private before push).
- Do not delete/rebuild the ops repo or change slug schemes.
- Do not silently expand scope into skill authoring / provenance enrichment (`enrich-provenance.py`) beyond reporting unresolved counts if already available.
- Do not add heavy new dependencies unless clearly justified; prefer stdlib / existing `rsync`/`git`/`python3`. TTY progress via `\r` is fine; tqdm/rich only if you argue the tradeoff.
- Do not treat P1/P2 as required for v1 merge.

### Desired outcomes (acceptance criteria)

**1. Logging model** — three channels, gated by something like `COMPENDIUM_LOG=quiet|progress|verbose` (default `progress` on TTY; document env):

| Channel | Behavior |
|---|---|
| Progress | Single rewriting line / bar for long loops (esp. project snapshots; optionally discover walks) |
| Signal | Append-only lines only for notable events |
| Summary | Always print a final structured block |

`verbose` may preserve today’s per-path `Snapshot …` lines for debugging.

**Hard gate for phase A:** removing or gating the per-project `echo "Snapshot …"` in `snapshot-project.sh` alone must eliminate the ~800-line wall. If a plan’s phase A does not do that, reject it.

**2. Signal events** (emit as you go when non-noop), at least:

- Global skills: `+` / `~` / `-` for skill dirs (or `SKILL.md`) under the three mirrored trees
- Discover: material changes to path counts / orphans / stale (not every tick)
- Publish: nothing to commit | committed `<sha>` | pushed | skipped (`COMPENDIUM_AUTO_PUSH=0`) | privacy failure

Optional if cheap: project mirror “dirty” only when rsync would change bytes — must not recreate the wall of noise (aggregate or sample).

**Volume cap:** if skill (or project-dirty) deltas exceed ~20 lines, summarize (`skills +N ~M -K`) and show only the first ~10 names.

**3. End summary** — always include useful characterization, e.g.:

- Live vs mirror skill counts + drift yes/no (reuse / align with `skill-drift` ideas)
- Inventory totals (global / project-local) + unresolved provenance count if present
- Discover counts: paths, cursor_known, scan_found, orphans, stale
- Phase timings (skills / discover / projects / publish)
- Git: commit sha or no-op; short `--stat` / name-status of what landed; push result
- Pointer tip: `git -C $CURSOR_COMPENDIUM_ROOT show --stat HEAD`

**4. “Done” looks like** (success metric — approximate transcript):

```text
======== compendium-backup ========
skills mirrored (3 trees)
discover 23.5s  paths=853 orphans=53 stale=465
projects  853/853  (100%)  elapsed 3m10s
skills + chatstory-preserve
skills ~ chaos-containment
publish commit e0d7f42
  3 files changed, 22 insertions(+), 22 deletions(-)
  skills-registry/skills-inventory.json
  project-paths.txt
  discover-report.json
publish pushed origin/main

======== summary ========
skills live/mirror: 119/119  20/20  91/91   drift: none
inventory: 344 global, 1176 project-local   unresolved: 19
projects: 853   known=825 scan=388 orphans=53 stale=465
duration: 3m41s   skills 2s | discover 24s | projects 3m10s | publish 5s
git: e0d7f42  |  pushed origin/main  |  remote PRIVATE ok
tip: git -C $CURSOR_COMPENDIUM_ROOT show --stat HEAD
===================================
```

No-op second run should be short: progress completes, few/no signals, summary shows `nothing to commit` / already up to date (when the tree is actually unchanged).

**5. Script surface** — touch points likely include:

- `compendium/scripts/snapshot-all.sh`, `snapshot-project.sh`, `commit-and-push.sh`
- `cursor/scripts/snapshot-skills.sh` / `snapshot-all-skills.sh` (as called from snapshot-all)
- discover Python entrypoints’ log verbosity
- sync into `$CURSOR_COMPENDIUM_ROOT/scripts/`
- `cursor/justfile` docs/comments if recipes gain flags or new helpers (P1 for menu)

**6. Just UX**

- **P0:** Document day-to-day in the minimal docs: `doit` (diagnose) vs `compendium-backup` (DR push) vs `skill-backup` / `skill-backup-fast` (dotfiles skills commit). Document `COMPENDIUM_LOG`.
- **P1:** Prefer default `just` showing a **curated daily subset**; full list via `just menu` or `just --list` — call out justfile/`[group]` constraints and pick the least-surprising approach. Do not invent fake recipes that duplicate backup semantics.
- **P2:** `just skill-recent` (or `skill-timeline`) wrapping git one-liners for week/month/top-10.

**7. Idempotent re-run experience**

- Second immediate `compendium-backup` should feel quiet: progress completes, few/no signals, summary shows no-op publish when tree unchanged.
- Plan may note (but need not fix in v1) that regenerating inventory/`project-paths.txt` can still create tiny commits — recommend measuring and optionally stabilizing later (P2).

### Constraints / quality bar

- Work for both interactive TTY and non-TTY (LaunchAgent logs under `/tmp/cursor-compendium-daily.log`): no broken `\r` spam in log files; progress can degrade to periodic one-liners when not a TTY.
- Keep `set -euo pipefail` / failure modes obvious; never hide privacy-check failures.
- Prefer incremental PR-sized slices in the plan, e.g.:
  - **(A)** silence project echo + progress counter + richer `commit-and-push` `--stat` + summary skeleton + sync to ops
  - **(B)** skills/discover signal events + volume cap
  - **(C)** just menu (P1)
  - **(D)** skill-recent (P2)
- Update the minimal docs (`docs/COMPENDIUM.md`, `docs/SKILLS-MANAGEMENT.md`, and/or script READMEs) so future-me knows `COMPENDIUM_LOG` and the daily-driver recipes — no drive-by markdown sprawl.
- Follow existing shell rules (e.g. avoid `!` inside double-quoted shell strings in zsh-facing snippets).

### What I want from you (planning only)

Produce a **reviewable implementation plan** (do not execute yet) that includes:

1. **Problem statement** and success metrics (use the sample transcript above as the bar).
2. **Current call graph** of `just compendium-backup` → scripts (ops vs scaffold SoT + sync).
3. **Proposed logging API** (`COMPENDIUM_LOG`, helpers, signal vocabulary, TTY vs non-TTY).
4. **Phased delivery** with ordered todos, each independently mergeable/testable; mark P0/P1/P2.
5. **Test / verification plan**: noisy before/after; no-op second run; skill add detection; LaunchAgent/non-TTY; `COMPENDIUM_AUTO_PUSH=0`; privacy failure still loud; ops tree actually updated after sync.
6. **Explicit out-of-scope / follow-ups** (idempotent invent churn, skill-recent, menu if deferred) so we don’t sneak-scope.
7. **Risks**: false “changed” signals from mtimes; progress bars in CI/launchd; scaffold/ops script drift.

After the plan, stop and wait for my review before implementing.
