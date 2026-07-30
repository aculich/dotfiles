# PHASES — tool quickstart metarepo

Single oracle for A–D–R (singleton) and E (landscape). Generate-and-compare: each laptop uses its own branch.

```bash
just phase B                 # smoke (= just doit until Phase R rewires doit)
just phase C                 # agent brief
just scaffold-lineages       # Phase D machine
just phase D                 # agent brief
just scaffold-runtime        # Phase R machine checklist
just phase R                 # agent brief — LOCAL_BUILD / brew + flavor bundle IDs
just bootstrap-machine       # lineages then doit (fat after R)
```

**Generate-and-compare workflow**

```bash
git pull origin main
git checkout -b regen/<laptop>    # e.g. regen/workhorse or regen/sidequest
# run B → C → D → R; commit; push
# other laptop: same on regen/<other>; then diff branches / fill COMPARE_REGEN.md
```

Just runs machine steps. Agent briefs are paste targets for Cursor. Briefs are **self-contained** (SideQuest must succeed without legacy `*-quickstart` trees).

Placeholders filled at Phase A: `{{TOOL_LABEL}}`, `{{UPSTREAM_URL}}`, `{{UPSTREAM_DIR}}`.

---

## Phase A — Envelope (skill: `/bootstrap-quickstart`)

**Trigger:** slash / bootstrap skill. **Not** re-run via `just phase A` after the tree exists.

**Machine:** mkdir `~/tools/<slug>-metarepo`, gitignore, shallow clone upstream, pin, justfile, this PHASES.md, stub META/QUICKSTART/PRAXIS, commit.

**Done when:** hand-off printed: open folder → `just doit`.

**Do not:** dossier depth, PRD, PLAYBOOK, FORKS, lineage remotes, runtime install.

---

## Phase B — DWIM / smoke (`just doit` or `just phase B`)

**Machine:** doctor → ensure-upstream → pin → smoke → functional-proof checklist → open folder → print Phase C brief.

**Done when:** smoke green. Thin `doit` stays smoke-only until Phase R rewrites it to daily-driver DWIM.

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
1. Inspect upstream: Xcode app vs brew cask vs both. Write self-contained just recipes INTO this metarepo justfile
   (extend; do NOT remove phase / phases / scaffold-lineages / scaffold-runtime).
2. Upstream track: install + run path for THIS machine (LOCAL_BUILD and/or brew). Rewrite `doit` to daily-driver DWIM after install works.
3. Personal + team: add flavor xcconfigs (or equiv) on forks/personal and forks/team with io.github.aculich.* bundle IDs;
   commit and push those forks; add metarepo recipes build-flavor / install-flavor / dev-personal / dev-team.
4. Deepen PRAXIS.md + PLAYBOOK.md (permissions, quit-all, first functional proof).
5. Run install on this Mac; record smoke/proof notes in PRAXIS.
Do not require legacy *-quickstart trees. Optional read of a sibling quickstart is hints only.
```

**Done when:** Upstream app installable via just; personal/team flavors buildable with distinct bundle IDs; `doit` is daily-driver DWIM; PRAXIS/PLAYBOOK updated.

---

## Phase E — Landscape SuperPRD (skip for singleton)

**Trigger:** `/bootstrap-landscape` or multi-tool rollup. Not part of singleton `just phases` / `bootstrap-machine`.

**Done when:** SuperPRD + workspace refresh at constellation altitude.
