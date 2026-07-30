# PHASES — tool quickstart metarepo

Single oracle for A–E. Run one phase or the kit:

```bash
just phase B          # machine steps for B (= just doit)
just phase C          # print agent brief for C
just phases           # B then print C brief (hand-off); agent continues C→D
just scaffold-lineages # Phase D machine: public + personal + team (use WITHOUT_TEAM=1 to skip team)
```

Just runs machine steps. Agent briefs below are paste targets for Cursor.

Placeholders in this file are filled at Phase A: `{{TOOL_LABEL}}`, `{{UPSTREAM_URL}}`, `{{UPSTREAM_DIR}}`.

---

## Phase A — Envelope (skill: `/bootstrap-quickstart`)

**Trigger:** slash / bootstrap skill. **Not** re-run via `just phase A` after the tree exists.

**Machine:** mkdir `~/tools/<slug>-metarepo`, gitignore, shallow clone upstream, pin, justfile, this PHASES.md, stub META/QUICKSTART/PRAXIS, commit.

**Done when:** `just doctor` would pass (upstream present); hand-off printed: open folder → `just doit`.

**Do not:** dossier depth, PRD, PLAYBOOK, FORKS, lineage remotes.

---

## Phase B — DWIM / smoke (`just doit` or `just phase B`)

**Machine:** doctor → ensure-upstream → pin → smoke → functional-proof checklist → open folder → print Phase C brief from this file.

**Done when:** smoke green; operator knows the one key function to prove (see PRAXIS.md).

**Agent:** none required unless smoke needs a tool-specific override.

---

## Phase C — Inquiry + per-tool PRD (agent)

**Trigger:** `just phase C` (prints this section) or paste after `doit`.

**Agent brief — paste into chat:**

```
Flesh out this tool quickstart metarepo Phase C for {{TOOL_LABEL}} ({{UPSTREAM_URL}}):
1. Write EXECSUMMARY.md (exec altitude).
2. Create dossier/ with USECASES.md, LANDSCAPE.md, ARCHITECTURE.md, TECHSTACK.md, SEARCH_KEYWORDS.md
   (legacy alias: background/ is OK only if this tree already uses it — new trees use dossier/).
3. Write PRD.md for THIS tool only (jobs, non-goals, success criteria).
4. Deepen PRAXIS.md with the one key functional proof.
5. Do NOT write PLAYBOOK.md / FORKS.md yet (Phase D) unless I ask.
Cite canonical upstreams (gh api fork check). Keep upstream/ gitignored.
```

**Done when:** EXECSUMMARY + dossier set + PRD.md + deepened PRAXIS exist.

---

## Phase D — Lineages + PLAYBOOK (machine + agent)

**Default triad:** public GitHub fork + personal private fork + team private fork.  
**Lighter tools:** `WITHOUT_TEAM=1 just scaffold-lineages`.

**Machine:** `just scaffold-lineages` (attach-if-exists; never recreate blindly).

**Agent brief — after scaffold:**

```
Phase D docs for {{TOOL_LABEL}}:
1. Write FORKS.md (Upstream pin, public GitHub fork, personal private, team private paths + remotes).
2. Write thin PLAYBOOK.md (what do I do next: doit, scaffold, open forks/*).
3. Note bundle/display identity stubs if the tool is a macOS app; skip if N/A.
Do not delete GitHub remotes. Attach-if-exists only.
```

**Done when:** `forks/{public,personal,team}` present (team optional if WITHOUT_TEAM); FORKS.md + PLAYBOOK.md written; remotes pushable.

---

## Phase E — Landscape SuperPRD (skip for singleton)

**Trigger:** `/bootstrap-landscape` or multi-tool rollup ask. Not part of singleton `just phases`.

**Done when:** SuperPRD + workspace refresh exist at constellation altitude.
