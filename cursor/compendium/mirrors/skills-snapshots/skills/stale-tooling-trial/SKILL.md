---
name: stale-tooling-trial
description: >-
  Assesses abandoned tool clones under umbrellas (fork/commits/secrets/SpecStory),
  preserves intent metadata, marks for mark-and-sweep, bootstraps a fresh
  ~/tools/*-quickstart, elects credential rotation, then just doit. Use when
  chaos-containment finds a stale tooling trial, or the user says stale tool,
  deaccession, mark-and-sweep tooling test, or abandoned clone under macosx-tools.
disable-model-invocation: true
---

# Stale tooling trial

Deaccession a stale “clone → configure → abandon” tool trial: preserve context, mark old tree, bootstrap fresh in `~/tools/`.

## Checklist

```text
Stale tooling trial:
- [ ] 0. hot-livewires-preflight (mandatory)
- [ ] 1. Assess remotes/fork/commits/dirty/size/intent metadata
- [ ] 2. Brief classification
- [ ] 3. Preserve (PDV SpecStory; heritage non-secret; chaos already for creds)
- [ ] 4. MARK-AND-SWEEP.md (no hard-delete unless user applies sweep)
- [ ] 5. tools-quickstart-bootstrap → ~/tools/<tool>-quickstart/
- [ ] 6. Rotation election (recommend rotate before doit)
- [ ] 7. just doit only after election resolves
```

## Step 0 — Livewires

Follow [`hot-livewires-preflight`](file:///Users/me/.cursor/skills/hot-livewires-preflight/SKILL.md). Halt on `verified-live` until chaos items + `ROTATION-PLAN.md` exist.

## Step 1 — Assess

For each nested `.git`:

- `git remote -v`, `gh` fork check for user
- Commits ahead of `origin/main` (or master)
- `git status --porcelain`
- `du -sh` (note `target`/`.devbox` bloat)
- SpecStory, chatstory, Cursor project paths

Classify: `clean-abandoned` | `abandoned-with-config` | `fork-or-product`

See [assessment-checklist.md](assessment-checklist.md).

## Step 2–4 — Brief, preserve, mark

- PDV: contaminated SpecStory + redacted briefing ([capsule-layout.md](capsule-layout.md))
- Heritage: non-secret wrapper docs → later quickstart `background/heritage/`
- Write `MARK-AND-SWEEP.md` at old root pointing at capsule + new quickstart path
- Optional reclaim: delete `target/` / `.devbox/` **only after user confirm**

## Step 5 — Bootstrap

Invoke [`tools-quickstart-bootstrap`](file:///Users/me/.claude/skills/tools-quickstart-bootstrap/SKILL.md):

- New repo at `~/tools/<tool>-quickstart/`
- Fresh upstream clones (not the dirty trial tree)
- Include `just doit` and `just rotate-status` from bootstrap reference

## Step 6 — Rotation election

Structured ask after bootstrap:

- **Recommended:** rotate now (provider URLs in `ROTATION-PLAN.md`) → new secrets in `develop` → then doit
- **Alternate:** skip for this smoke only; use chaos legacy; still document election in `ROTATION-PLAN.md`

Do not run `just doit` until election is recorded.

## Step 7 — doit

`just doit` (docker-first when possible). Open browser. Smoke. Commit quickstart without secrets.
