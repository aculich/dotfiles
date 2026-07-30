---
name: bootstrap-tool-quickstart
description: >-
  Phase A factory for a tool quickstart metarepo under ~/tools/. Clones upstream,
  pins, installs tool-quickstart justfile with real just doit. Aliases:
  tools-quickstart-bootstrap, bootstrap-product-quickstart. Use with
  /bootstrap-quickstart. Does not write dossier/PRD/PLAYBOOK (Phases C/D).
disable-model-invocation: true
---

# Bootstrap Tool Quickstart (Phase A factory)

**Aliases:** `tools-quickstart-bootstrap`, `bootstrap-product-quickstart`.

**Pattern:** tool quickstart metarepo — see exemplar `~/tools/voiceink-quickstart/{INCEPTION,CONSTELLATION,QUICKSTART}.md`.

## Inception UX (locked)

1. Prefer starting the slash from a neutral home (`~/tools/` or `~/projects/workspaces/`), not inside an unrelated quickstart.
2. Phase A writes disk only — **do not** open Cursor mid-clone.
3. After A: tell the user to **open the new directory** and run **`just doit`** (Phase B) — not another bootstrap slash.
4. Phase C+ continues in that new window.

## Inputs

| Input | Required | Notes |
|-------|----------|-------|
| GitHub `owner/repo` | yes | Canonical upstream |
| Product / docs URL | no | Record in META stub |
| Target dir | no | Default `~/tools/<slug>-quickstart`; greenfield compare may use `…-metarepo` if user asks |
| In-place | no | If “this directory”, write envelope at cwd; do not create sibling folder |

Derive `slug` from repo name (lowercase). Prefer undashed **metarepo** / **multirepo** in prose.

## Phase A checklist (this skill)

```markdown
Phase A Progress:
- [ ] 1. Resolve target path; mkdir; git init if needed
- [ ] 2. Write .gitignore (upstream/, forks/, .venv, *.app, local secrets)
- [ ] 3. Clone shallow upstream → upstream/<owner>__<repo>/
- [ ] 4. Write pin file dossier/UPSTREAM_PIN.txt (or background/ if matching siblings)
- [ ] 5. Install justfile from dwim-justfile templates/tool-quickstart.justfile (fill placeholders) + copy PHASE_C_PROMPT.md
- [ ] 6. Stub META.md, QUICKSTART.md (link pattern), PRAXIS.md (functional-proof checklist stub only)
- [ ] 7. just doctor; just smoke if feasible
- [ ] 8. Commit Phase A artifacts (no secrets; upstream gitignored)
- [ ] 9. Print hand-off: open folder → just doit (Phase B) → Phase C paste prompt after doit
```

**Do not in Phase A:** full EXECSUMMARY dossier, LANDSCAPE, PRD, PLAYBOOK, FORKS, TOOLBOX deep research.

## Placeholders for justfile

Replace in `tool-quickstart.justfile`:

- `{{TOOL_LABEL}}` — human name
- `{{UPSTREAM_URL}}` — `https://github.com/owner/repo` (no `.git` in URL var; template appends)
- `{{UPSTREAM_DIR}}` — `upstream/owner__repo`
- `{{PIN_FILE}}` — `dossier/UPSTREAM_PIN.txt` (new trees)

## Phase B (user / justfile — not this skill)

`just doit` → doctor → ensure-upstream → pin → smoke → functional-proof checklist → open → **prints Phase C paste prompt**.

## Phase C–E (later)

| Phase | Trigger | Outputs |
|-------|---------|---------|
| C | Paste prompt / “flesh out dossier” | EXECSUMMARY, `dossier/*`, **PRD.md**, deepen PRAXIS |
| D | Living with the tool | PLAYBOOK, FORKS, release recipes |
| E | Landscape rollup | SuperPRD (other skill / landscape) |

Legacy name `background/` = alias of `dossier/`. Keywords file: `SEARCH_KEYWORDS.md`. Found papers → `dossier/papers/`.

## In-place bootstrap

When user says bootstrap **this directory**: same Phase A artifacts at cwd; inventory existing tree; optional upstream pin.

## Guardrails

- Keep `upstream/` gitignored; never absorb tool source into the metarepo commits.
- Verify canonical upstream with `gh api repos/owner/repo --jq '{fork,parent:.parent.full_name,stars:.stargazers_count}'` when citing peers later (Phase C).
- No “fill in happy path” `doit`.
- Compose with `dwim-justfile` for justfile only; this skill owns the envelope.

## Related

- Landscape batch: `bootstrap-tool-landscape`
- Justfile: `dwim-justfile`
- Fork lineages (later): `quickstart-fork-lineage`
