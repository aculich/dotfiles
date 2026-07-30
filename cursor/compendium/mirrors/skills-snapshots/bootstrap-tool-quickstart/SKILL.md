---
name: bootstrap-tool-quickstart
description: >-
  Phase A factory for a tool quickstart metarepo under ~/tools/<slug>-metarepo.
  Ships PHASES.md + justfile (doit, phase, phases, scaffold-lineages). Aliases:
  tools-quickstart-bootstrap, bootstrap-product-quickstart. Use with
  /bootstrap-quickstart. Does not write dossier/PRD/PLAYBOOK (Phases C/D).
disable-model-invocation: true
---

# Bootstrap Tool Quickstart (Phase A factory)

**Aliases:** `tools-quickstart-bootstrap`, `bootstrap-product-quickstart`.

**Pattern:** tool quickstart metarepo — new trees use directory suffix **`-metarepo`**. Legacy `*-quickstart` baselines remain valid. Exemplar docs: `~/tools/voiceink-quickstart/{INCEPTION,CONSTELLATION,QUICKSTART}.md`.

## Inception UX (locked)

1. Prefer starting the slash from a neutral home (`~/tools/` or `~/projects/workspaces/`), not inside an unrelated quickstart.
2. Phase A writes disk only — **do not** open Cursor mid-clone.
3. After A: tell the user to **open the new directory** and run **`just doit`** (Phase B) — not another bootstrap slash.
4. Phase C+ continues in that new window (`PHASES.md`, `just phase C|D`, `just phases`).

## Inputs

| Input | Required | Notes |
|-------|----------|-------|
| GitHub `owner/repo` | yes | Canonical upstream |
| Product / docs URL | no | Record in META stub |
| Target dir | no | Default **`~/tools/<slug>-metarepo`** |
| `--without-team` | no | Phase D later skips team private fork |
| In-place | no | If “this directory”, write envelope at cwd |

Derive `slug` from repo name (lowercase). Prefer undashed **metarepo** / **multirepo** in prose.

## Phase A checklist (this skill)

```markdown
Phase A Progress:
- [ ] 1. Resolve target path (~/tools/<slug>-metarepo); mkdir; git init if needed
- [ ] 2. Write .gitignore (upstream/, forks/, .venv, *.app, local secrets)
- [ ] 3. Clone shallow upstream → upstream/<owner>__<repo>/
- [ ] 4. Write pin file dossier/UPSTREAM_PIN.txt
- [ ] 5. Install justfile from dwim-justfile templates/tool-quickstart.justfile (fill placeholders)
- [ ] 6. Copy PHASES.md template; substitute TOOL_LABEL / UPSTREAM_* 
- [ ] 7. Stub META.md, QUICKSTART.md, PRAXIS.md (functional-proof checklist stub only)
- [ ] 8. just doctor; just smoke if feasible
- [ ] 9. Commit Phase A artifacts (no secrets; upstream gitignored)
- [ ] 10. Print hand-off: open folder → just doit (B) → just phase C / just phases
```

**Do not in Phase A:** full EXECSUMMARY dossier, LANDSCAPE, PRD, PLAYBOOK, FORKS, TOOLBOX deep research, lineage remotes.

## Placeholders for justfile

| Placeholder | Example |
|-------------|---------|
| `{{TOOL_LABEL}}` | OpenOats |
| `{{UPSTREAM_URL}}` | `https://github.com/yazinsai/OpenOats` (no `.git`) |
| `{{UPSTREAM_DIR}}` | `upstream/yazinsai__OpenOats` |
| `{{PIN_FILE}}` | `dossier/UPSTREAM_PIN.txt` |
| `{{GH_OWNER}}` | `aculich` |
| `{{UPSTREAM_OWNER}}` / `{{UPSTREAM_REPO}}` | yazinsai / OpenOats |
| `{{PUBLIC_FORK_NAME}}` | OpenOats |
| `{{PERSONAL_REPO}}` | `openoats-personal` |
| `{{TEAM_REPO}}` | `openoats-team` |

Also ship [`templates/PHASES.md`](../dwim-justfile/templates/PHASES.md) (substitute label/URL/dir).

## Phase B–E (after A)

| Phase | Trigger | Outputs |
|-------|---------|---------|
| B | `just doit` / `just phase B` | smoke + checklist; prints C brief from PHASES.md |
| C | `just phase C` + agent | EXECSUMMARY, `dossier/*`, **PRD.md**, deepen PRAXIS |
| D | `just scaffold-lineages` + agent | public fork + personal + team (unless WITHOUT_TEAM=1); FORKS + PLAYBOOK |
| E | landscape skill | SuperPRD — skip for singleton |

`just phases` = B then kit hand-off to C/D (agent continues).

**Phase D default:** full triad. Attach-if-exists (`gh repo view` before create/fork).

## Guardrails

- Keep `upstream/` and `forks/` gitignored.
- No “fill in happy path” `doit`.
- Compose with `dwim-justfile` for justfile only; this skill owns the envelope.

## Related

- Landscape: `bootstrap-tool-landscape`
- Justfile: `dwim-justfile`
- Fork lineages: `quickstart-fork-lineage`
