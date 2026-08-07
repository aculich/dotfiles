Use this as the planning prompt (paste into Cursor Plan / Agent, ask for a plan only — no execution yet):

---

## Planning prompt: Compendium / skills backup UX — signal over noise

### Context (estate as it exists today)

I maintain Cursor ops from `~/dotfiles/cursor` via a `justfile` with two backup layers:

1. **Skills backups** (`skill-backup`, `skill-backup-fast`, etc.) — mirror global skill trees into the **dotfiles** scaffold (`cursor/compendium/mirrors/skills-snapshots`), optionally regenerate inventory, **commit locally, do not push**.
2. **Compendium backup** (`compendium-backup`) — runs the live ops sibling at `$CURSOR_COMPENDIUM_ROOT` (typically `~/ops/dotfiles-cursor-compendium`): skills mirror + invent + project-path discover + global plans + ~850 per-project snapshots, then **`commit-and-push.sh`** to a **private** GitHub remote (opt out with `COMPENDIUM_AUTO_PUSH=0`).

Important distinctions already encoded in the justfile / docs:

- `just doit` is **diagnose-first** (status + resource snapshot + tips). It is **not** a backup and must not become one.
- `skill-backup*` ≠ `compendium-backup` (different repos, push posture, scope).
- Project-local skills ride along in **compendium** project mirrors, not in normal `skill-backup`.
- Authored skills SoT remains `~/projects/agent-skills`; ops/compendium is DR / inventory, not a second edit surface.

### Problem

`just compendium-backup` (and the underlying `scripts/snapshot-all.sh` in the ops tree / scaffold) is **correct but unusable as an interactive tool**:

- Dominated by progress noise: one `Snapshot path -> mirrors/by-project/...` line per project (~800+ lines from `snapshot-project.sh`), plus verbose discover ticks.
- **Signal is missing mid-run**: no clear “skill added/changed,” “project mirror dirty,” “discover orphans/stale moved,” etc.
- **End signal is thin**: `commit-and-push` may say `3 files changed` / `pushed` without listing what changed or characterizing collection health (live vs mirror drift, inventory totals, push/skip, privacy, phase timings).
- Immediate re-run still pays full walk cost; publish *should* be near-noop (`nothing to commit` / already up to date) when the tree is stable, but generated inventory/paths can still churn small commits — treat that as a known tension to acknowledge in the plan (quiet UX first; optional later work on idempotent generated artifacts).

Secondary UX gap (in scope for the plan’s “menu” slice if cheap; otherwise defer explicitly):

- Bare `just` / `just help` lists **every** recipe. I want a **short daily-driver list** by default and a full catalog behind something like `just menu` (or equivalent), without inventing fake recipes that duplicate backup semantics.

Out of band but related (plan should say whether in/out of this change-set):

- There is **no** `just skill-recent` / timeline recipe today; history is recoverable via git on the mirrors. A small `skill-recent` (week/month/top-N) would be valuable but must not block the logging redesign.

### Purpose / intent

Make backup runs **operator-legible**: prove work is happening without drowning in path spam; surface **notable deltas** as they occur; end with a **status characterization** of the collection and publish result so I know whether DR is healthy, drifted, committed, and pushed — without reading 1000 lines of rsync chatter.

This is a **UX / observability** change to existing scripts and just recipes, not a redesign of backup topology, remotes, or SoT.

### Non-goals

- Do not merge `doit` with `compendium-backup`.
- Do not auto-push **dotfiles** skills commits.
- Do not change privacy guarantees (still verify private before push).
- Do not delete/rebuild the ops repo or change slug schemes.
- Do not silently expand scope into skill authoring / provenance enrichment (`enrich-provenance.py`) beyond reporting unresolved counts if already available.
- Do not add heavy new dependencies unless clearly justified; prefer stdlib / existing `rsync`/`git`/`python3`. TTY progress via `\r` is fine; tqdm/rich only if you argue the tradeoff.

### Desired outcomes (acceptance criteria)

**1. Logging model** — introduce a clear three-channel model, gated by something like `COMPENDIUM_LOG=quiet|progress|verbose` (default `progress` on TTY; document env):

| Channel | Behavior |
|---|---|
| Progress | Single rewriting line / bar for long loops (esp. project snapshots; optionally discover walks) |
| Signal | Append-only lines only for notable events |
| Summary | Always print a final structured block |

`verbose` may preserve today’s per-path `Snapshot …` lines for debugging.

**2. Signal events** (emit as you go when non-noop), at least:

- Global skills: `+` / `~` / `-` for skill dirs (or `SKILL.md`) under the three mirrored trees  
- Discover: material changes to path counts / orphans / stale (not every tick)  
- Publish: nothing to commit | committed `<sha>` | pushed | skipped (`COMPENDIUM_AUTO_PUSH=0`) | privacy failure  

Optional if cheap: project mirror “dirty” only when rsync would change bytes — must not recreate the wall of noise (aggregate or sample).

**3. End summary** — always include useful characterization, e.g.:

- Live vs mirror skill counts + drift yes/no (reuse / align with `skill-drift` ideas)
- Inventory totals (global / project-local) + unresolved provenance count if present
- Discover counts: paths, cursor_known, scan_found, orphans, stale
- Phase timings (skills / discover / projects / publish)
- Git: commit sha or no-op; short `--stat` / name-status of what landed; push result
- Pointer tip: `git -C $CURSOR_COMPENDIUM_ROOT show --stat HEAD`

**4. Script surface** — implement in the **canonical scripts** and keep ops sibling + dotfiles scaffold consistent (note which tree is SoT for scripts today and how to sync). Touch points likely include:

- `snapshot-all.sh`, `snapshot-project.sh`, `snapshot-skills.sh` / `snapshot-all-skills.sh`
- `commit-and-push.sh` (richer post-stage reporting)
- discover Python entrypoints’ log verbosity
- `cursor/justfile` docs/comments if recipes gain flags or new helpers

**5. Just UX (small, explicit)**

- Document day-to-day: `doit` (diagnose) vs `compendium-backup` (DR push) vs `skill-backup` / `skill-backup-fast` (dotfiles skills commit).
- Prefer default `just` showing a **curated daily subset**; full list via `just menu` or `just --list` — call out justfile/`[group]` constraints and pick the least-surprising approach.
- Optional stretch: `just skill-recent` (or `skill-timeline`) wrapping the git one-liners for week/month/top-10 — mark P1 vs P2.

**6. Idempotent re-run experience**

- Second immediate `compendium-backup` should feel quiet: progress completes, few/no signals, summary shows no-op publish when tree unchanged.
- Plan may note (but need not fix in v1) that regenerating inventory/`project-paths.txt` can still create tiny commits — recommend measuring and optionally stabilizing later.

### Constraints / quality bar

- Work for both interactive TTY and non-TTY (LaunchAgent logs under `/tmp/cursor-compendium-daily.log`): no broken `\r` spam in log files; progress can degrade to periodic one-liners when not a TTY.
- Keep `set -euo pipefail` / failure modes obvious; never hide privacy-check failures.
- Prefer incremental PR-sized slices in the plan (e.g. (A) silence project echo + progress + git stat summary; (B) skills signal; (C) just menu; (D) skill-recent).
- Update the minimal docs (`docs/COMPENDIUM.md`, `docs/SKILLS-MANAGEMENT.md`, and/or script READMEs) so future-me knows `COMPENDIUM_LOG` and the daily-driver recipes — no drive-by markdown sprawl.
- Follow existing shell rules (e.g. avoid `!` inside double-quoted shell strings in zsh-facing snippets).

### What I want from you (planning only)

Produce a **reviewable implementation plan** (do not execute yet) that includes:

1. **Problem statement** and success metrics (what “done” looks like in a terminal transcript).
2. **Current call graph** of `just compendium-backup` → scripts (ops vs scaffold SoT).
3. **Proposed logging API** (`COMPENDIUM_LOG`, helpers, signal vocabulary).
4. **Phased delivery** with ordered todos, each independently mergeable/testable.
5. **Test / verification plan**: noisy before/after; no-op second run; skill add detection; LaunchAgent/non-TTY; `COMPENDIUM_AUTO_PUSH=0`; privacy failure still loud.
6. **Explicit out-of-scope / follow-ups** (idempotent invent churn, skill-recent, menu split) so we don’t sneak-scope.
7. **Risks**: false “changed” signals from mtimes; progress bars in CI/launchd; scaffold/ops script drift.

After the plan, stop and wait for my review before implementing.

---

### How to use this prompt well

- Paste into **Plan mode** (or Agent with “plan only / no edits”).
- If the planner’s repo root is `dotfiles/cursor` vs ops sibling, add one line: “Scripts may live in both; treat `<path>` as SoT and sync the other.”
- After you get the plan, check that it keeps **`doit` ≠ backup** and that phase A alone would kill the Snapshot wall — if not, send it back.