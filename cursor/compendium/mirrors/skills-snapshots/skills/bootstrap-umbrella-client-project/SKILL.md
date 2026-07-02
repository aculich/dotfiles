---
name: bootstrap-umbrella-client-project
description: Normalizes a long-lived client umbrella repo (engagements/, .context/, incoming/ triage, justfile + docs/AUTOMATION.md) and folds nested git via subtree. Existing repos: dry-run first; apply only after umbrella bootstrap apply / explicit approve. Pairs with context-engineering, meeting-sync, process-umbrella-incoming.
disable-model-invocation: true
---

# Bootstrap umbrella client project

## When to use

- One **client relationship** spans **multiple** solicitations, mini-RFPs, or years of work.
- You need **throughline** memory (people, norms, drafting rules) at client tier plus **solicitation-specific** detail per engagement.
- The repo has **accidental nested `.git`** or broken gitlinks — fold into one umbrella with subtree merge.
- Prefer this over generic **`bootstrap-new-project`** when `engagements/` or multi-stream mirrors are expected.

## 0. Execution contract — dry-run, then apply (existing repos)

**Same gate as `bootstrap-new-project` §0**, with umbrella-specific stakes (subtree merges, `git mv` of whole workstreams, `incoming/` policy).

### Pass A — dry-run (required for **Existing**)

1. Read **`.context/engagements.md`**, **`ARCHITECTURE.md`**, **`AGENTS.md`**, nested **`.git` / gitlinks**, and any ADR drafts.
2. Emit a **Dry-run report**: every **`git subtree`**, **`git rm` gitlink**, **`git mv` legacy → `engagements/`**, **`.gitignore`**, **`justfile` + `docs/AUTOMATION.md`**, **`README` workspace activity**, **`incoming/ROUTING-LOG`** migration rows, and **remote** operations. Prefix with **`[plan]`**.
3. End with **`NO FILES WRITTEN — DRY RUN ONLY`**.

### Pass B — apply

Proceed with writes **only** when the user authorizes **`umbrella bootstrap apply`**, **`approve bootstrap`**, **`execute the umbrella plan`**, or the **same** message included **apply** / **execute** / **go ahead** with the bootstrap request. **Greenfield** empty umbrella skeletons may use **`greenfield apply`** in one message; otherwise default to dry-run first.

**On apply, also run the `process-umbrella-incoming` checklist** (same agent session): repo-root **`incoming/`** + **`incoming/opportunities/`** triage, **`git mv`** of confirmed opportunity stubs → **`engagements/<slug>/`** (preserve git history), **`incoming/ROUTING-LOG.md`** rows, root **`README.md`** `## Workspace activity`, **`decisions.md`** / **`next-actions.md`** when opening a slug. Orphan root-only folders → **`client-shared/archive/<descriptive-name>/`** with a one-screen **`README.md`** map unless they clearly belong under **`procurement/`** / **`programs/`**.

### `just` + `docs/AUTOMATION.md` (required for umbrella scaffolds)

Treat **`justfile`** + **`docs/AUTOMATION.md`** as **part of the standard umbrella kit** (not optional): default **`just`** = read-only `status`, optional **Glow** paging, **`just doctor`**, `PEEQ_JUST_PLAIN` / `GLOW_WIDTH` — copy from a **reference** repo (e.g. **`peeq-carb`**). Set **`task_runner: just`** in **`.context/conventions.md`** when that file is created or updated.

## Topology default

**Umbrella monorepo** (single `.git`): `engagements/YYYY-MM-<client>-<descriptor>/` each with optional `.context/`, `granola/`, `zoom_transcripts/`, `notes/`, `incoming/`, `communications/`, `STATUS.md`.

Separate GitHub repos per engagement only when access control or legal separation requires it — document in `ARCHITECTURE.md` + ADR.

## Directory skeleton

```
.context/engagements.md
.context/backfill-status.md
.context/relationship-timeline.md   # optional
incoming/README.md
incoming/ROUTING-LOG.md
incoming/opportunities/README.md
incoming/_review/README.md
justfile                           # required: `just` => read-only status; Glow width; see docs/AUTOMATION.md
docs/AUTOMATION.md                 # required: just vs Cursor slash vs cursor-agent / claude + manual Claude app
engagements/<slug>/README.md
engagements/<slug>/.context/        # optional engagement tier
procurement/ programs/ partners/ compliance/ client-shared/ tools/
```

## Engagement slug

Pattern: `YYYY-MM-<client>-<short-descriptor>` (e.g. `2026-03-carb-rfp-25msc005`). Register every slug in **`.context/engagements.md`** with paths for Granola, Zoom, incoming, communications, status file.

## Fold nested git (history-preserving)

1. Inner nested repo first (e.g. `catalog` under `DGS`): `git rm --cached` gitlink → `git subtree add --prefix=catalog <path-to-nested.git> main`.
2. Outer repo into umbrella: remove parent gitlink → `git subtree add --prefix=procurement/<name> <path-to-outer.git> main`.
3. Verify: `find . -name .git -type d` only shows repo root `.git`.

## Migration checklist

- [ ] **§0:** Dry-run report for **Existing** repos; wait for **`umbrella bootstrap apply`** (or equivalent) before writes
- [ ] ADR or `decisions.md` entry (slug table, DGS policy)
- [ ] Root `README.md`, `AGENTS.md`, `ARCHITECTURE.md`, `.gitignore` (`*.p12`, umbrella `incoming/**` exceptions)
- [ ] Root **`README.md`** includes **`## Workspace activity`** (merge **`context-engineering` / `scaffold/root-readme-workspace-activity.fragment.md`**) with rows from **`engagements.md`** + thresholds from **`conventions.md`**
- [ ] `git mv` legacy folders → `engagements/` / `procurement/` / etc.
- [ ] Path sweep (`rg` old names); fix Granola double-prefix if any
- [ ] Per-engagement `incoming/README`, `communications/`, `STATUS.md`
- [ ] Append **`incoming/ROUTING-LOG.md`** for migrated `.eml` / loose files / opportunity **`git mv`** promotions
- [ ] **`justfile` + `docs/AUTOMATION.md` + `task_runner`** per **§0**; run **`just doctor`**
- [ ] Update **`meeting-sync`** paths via `conventions.md` + `engagements.md`

## See also

- **`process-umbrella-incoming`** — triage repo-root inbox before Phase 1b.
- **`context-engineering`** — client vs engagement context promotion rules.
- Generic **`bootstrap-new-project`** — single-product greenfield default.
