# PHASES — tool quickstart metarepo

Single oracle for A–D–R (singleton) and E (landscape). **Standard path is one laptop.** Dual-laptop generate-and-compare is optional (`/bootstrap-regen`).

```bash
just phase B                 # smoke (= just doit; after Phase R, doit → runtime-doit)
just phase C                 # agent brief
just scaffold-lineages       # Phase D machine
just phase D                 # agent brief
just scaffold-runtime        # Phase R machine checklist
just phase R                 # agent brief — write runtime.justfile + runtime-doit
just bootstrap-machine       # lineages then doit (fat after R)
just tag-phase A|B|C|D|R     # annotated tag metarepo/phase-*-done (for optional regen)
```

**Definition of done (non-negotiable):** docs-complete ≠ runnable. Success requires:

1. `runtime.justfile` with `runtime-doit`
2. `just status` forks OK (or `WITHOUT_TEAM=1`)
3. `just doit` installs/launches Upstream on this Mac

**Optional generate-and-compare** (not default): `/bootstrap-regen [stage]` on another laptop forks from `metarepo/phase-<STAGE>-done` — see [SIDEQUEST.md](SIDEQUEST.md).

Just runs machine steps. Agent briefs are paste targets for Cursor (or canvas `newComposerChat` buttons). Briefs are **self-contained** (no legacy `*-quickstart` trees required).

Placeholders filled at Phase A: `{{TOOL_LABEL}}`, `{{UPSTREAM_URL}}`, `{{UPSTREAM_DIR}}`.

---

## Phase A — Envelope (skill: `/bootstrap-quickstart`)

**Trigger:** slash / bootstrap skill. **Not** re-run via `just phase A` after the tree exists.

**Machine:** mkdir `~/tools/<slug>-metarepo`, gitignore, shallow clone upstream, pin, justfile, this PHASES.md, stub META/QUICKSTART/PRAXIS, copy bootstrap canvas templates, commit, `just tag-phase A`.

**Done when:** hand-off printed: open folder → open bootstrap overview canvas → `just doit` (B).

**Do not:** dossier depth, PRD, PLAYBOOK, FORKS, lineage remotes, runtime install.

---

## Phase B — DWIM / smoke (`just doit` or `just phase B`)

**Machine:** If `runtime-doit` exists (Phase R), delegate to it. Else: ensure-upstream → doctor → pin → smoke → checklist → print Phase C brief.

**Done when:** smoke green (thin path) or runtime daily-driver green (after R). Envelope `doit` is never rewritten — Phase R adds `runtime.justfile`. Tag: `just tag-phase B` after first green smoke.
---

## Phase C — Inquiry + per-tool PRD (agent)

**Trigger:** `just phase C`.

**Agent brief:**

```
Flesh out this tool quickstart metarepo Phase C for {{TOOL_LABEL}} ({{UPSTREAM_URL}}):
1. Write EXECSUMMARY.md (exec altitude).
2. Create dossier/ with USECASES.md, LANDSCAPE.md, ARCHITECTURE.md, TECHSTACK.md, SEARCH_KEYWORDS.md
   (new trees use dossier/ only).
3. Write PRD.md for THIS tool only (jobs, non-goals, success criteria).
4. Deepen PRAXIS.md with the one key functional proof (install details wait for Phase R).
5. Do NOT write PLAYBOOK.md / FORKS.md yet (Phase D) unless I ask.
Cite canonical upstreams (gh api fork check). Keep upstream/ gitignored.
```

**Done when:** EXECSUMMARY + dossier set + PRD.md + PRAXIS stub exist.

---

## Phase D — Lineages + PLAYBOOK (machine + agent)

**Default triad:** public GitHub fork + personal private + team private.  
**Lighter:** `WITHOUT_TEAM=1 just scaffold-lineages`.

**Machine:** `just scaffold-lineages` (attach-if-exists).

**Agent brief:**

```
Phase D docs for {{TOOL_LABEL}}:
1. Write FORKS.md (Upstream pin, public GitHub fork, personal/team private paths + remotes).
2. Write thin PLAYBOOK.md (doit, scaffold-lineages, open forks/*). Note Phase R comes next for install.
3. Stub identity matrix rows (Upstream / Personal / Team / Public) — bundle IDs filled in Phase R.
Do not delete GitHub remotes. Attach-if-exists only.
```

**Done when:** `forks/{public,personal,team}` present (team optional if WITHOUT_TEAM); FORKS.md + PLAYBOOK.md written.

---

## Phase R — Runtime (LOCAL_BUILD / brew + flavor identities)

**Goal:** This Mac can install the Upstream track; personal/team private forks get distinct `io.github.aculich.*` identities and install paths.

**Identity matrix (locked):**

| Lineage | Bundle ID | Display name | Install path |
|---------|-----------|--------------|--------------|
| Upstream | upstream’s own ID | Product name | `/Applications/<Product>.app` |
| Personal | `io.github.aculich.<Product>Personal` | `<Product> Personal` | `/Applications/<Product> Personal.app` |
| Team | `io.github.aculich.<Product>Team` | `<Product> Team` | `/Applications/<Product> Team.app` |
| Public | upstream ID | unchanged | no default install |

Flavor: xcconfig (or equivalent) overrides bundle ID + display name; keep `PRODUCT_NAME` without spaces if SPM requires it.

**Detect shape:**

1. `.xcodeproj` / Xcode → LOCAL_BUILD recipes (build, Apple Development codesign, install-local, permissions, quit-all, sync-upstream, build-flavor / install-flavor / dev-personal / dev-team).
2. Homebrew cask documented by upstream → brew install/upgrade/run for Upstream track; **still** add personal/team source flavor builds when it is a macOS app.

**Machine:** `just scaffold-runtime` (checklist + ensure forks).

**Agent brief:**

```
Phase R — Runtime for {{TOOL_LABEL}} ({{UPSTREAM_URL}}, pin at {{UPSTREAM_DIR}}):
1. Inspect upstream: Xcode app vs brew cask vs both.
2. Create runtime.justfile (envelope already has `import? 'runtime.justfile'`). Put install/run/flavor recipes THERE.
   Required recipe name: runtime-doit (daily-driver DWIM). Do NOT rewrite envelope doit — it auto-delegates when
   runtime-doit is listed by `just --summary` (detection: tr ' ' '\\n' | grep -qx — summary is ONE space-separated line).
   Do NOT remove phase / phases / scaffold-lineages / scaffold-runtime from the envelope justfile.
3. Upstream track: install + run for THIS machine (LOCAL_BUILD and/or brew).
4. Personal + team: flavor xcconfigs (or equiv) on forks/personal and forks/team with io.github.aculich.* bundle IDs;
   commit and push those forks; add build-flavor / install-flavor / dev-personal / dev-team in runtime.justfile.
   Branding checklist: bundle ID + CFBundleDisplayName/Name + UI chrome (AppBrand/AppIdentity) + disable Upstream Sparkle
   on private bundles; for LOCAL_BUILD tools add `xcode-ready` and prefer ad-hoc codesign fallback when no Apple Development identity.
5. Deepen PRAXIS.md + PLAYBOOK.md (permissions, quit-all, first functional proof; note shared model caches vs per-bundle prefs if applicable).
6. Run `just doit` on this Mac (must hit runtime-doit); record proof notes in PRAXIS; `just tag-phase R`.
Do not require legacy *-quickstart trees. Optional read of a sibling quickstart is hints only.
```

**Done when:** Upstream app installable via just; personal/team flavors buildable with distinct bundle IDs **and** UI names; `just doit` runs `runtime-doit`; forks present; PRAXIS/PLAYBOOK updated. Markdown-only is not done.
---

## Phase E — Landscape SuperPRD (skip for singleton)

**Trigger:** `/bootstrap-landscape` or multi-tool rollup. Not part of singleton `just phases` / `bootstrap-machine`.

**Done when:** SuperPRD + workspace refresh at constellation altitude.
