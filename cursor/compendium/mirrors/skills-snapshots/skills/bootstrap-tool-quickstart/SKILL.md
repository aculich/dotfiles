---
name: bootstrap-tool-quickstart
description: >-
  Phase A factory for a tool quickstart metarepo under ~/tools/<slug>-metarepo.
  Ships PHASES.md + justfile (doit, phase, phases, scaffold-lineages,
  scaffold-runtime, import? runtime.justfile). Aliases: tools-quickstart-bootstrap,
  bootstrap-product-quickstart. Use with /bootstrap-quickstart. Does not write
  dossier/PRD/PLAYBOOK (Phases C/D).
disable-model-invocation: true
---

# Bootstrap Tool Quickstart (Phase A factory)

**Aliases:** `tools-quickstart-bootstrap`, `bootstrap-product-quickstart`.

**Pattern:** tool quickstart metarepo — new trees use directory suffix **`-metarepo`**. Legacy `*-quickstart` baselines remain valid. Exemplar docs: `~/tools/voiceink-quickstart/{INCEPTION,CONSTELLATION,QUICKSTART}.md`.

## Inception UX (locked)

1. Prefer starting the slash from a neutral home (`~/tools/` or `~/projects/workspaces/`), not inside an unrelated quickstart.
2. Phase A writes disk only — **do not** open Cursor mid-clone.
3. After A: tell the user to **open the new directory**, open the **bootstrap overview canvas**, and run **`just doit`** (Phase B) — not another bootstrap slash.
4. Phase C+ continues in that new window (`PHASES.md`, canvas buttons, `just phase C|D|R`).
5. After each phase lands: `just tag-phase A|B|C|D|R` and `git push origin metarepo/phase-*-done` (enables optional `/bootstrap-regen`).
6. Do not claim success until Phase R DoD: `runtime.justfile` + forks + `just doit` runtime path.
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
- [ ] 7b. Copy canvas templates from dwim-justfile/templates/canvases/ into metarepo `canvases/` and note IDE path `~/.cursor/projects/<workspace>/canvases/`
- [ ] 8. just doctor; just smoke if feasible; just tag-phase A
- [ ] 9. Commit Phase A artifacts (no secrets; upstream gitignored)
- [ ] 10. Print hand-off: open folder → bootstrap canvas → just doit (B) → just phase C / just phases
```

**Do not in Phase A:** full EXECSUMMARY dossier, LANDSCAPE, PRD, PLAYBOOK, FORKS, TOOLBOX deep research, lineage remotes, `runtime.justfile`.

**Verify after copy:** envelope justfile has `import? 'runtime.justfile'` and smart `doit` that detects `runtime-doit` via `tr ' ' '\n' | grep -qx` (not `grep '^runtime-doit$'` — `just --summary` is one line).

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
| R | `just scaffold-runtime` + agent | **`runtime.justfile`** with **`runtime-doit`** + flavors; do not rewrite envelope `doit` |
| E | landscape skill | SuperPRD — skip for singleton |

`just phases` = B then kit hand-off to C/D (agent continues).

**Phase D default:** full triad. Attach-if-exists (`gh repo view` before create/fork).

## Guardrails

- Keep `upstream/` and `forks/` gitignored.
- No “fill in happy path” `doit`.
- Compose with `dwim-justfile` for justfile only; this skill owns the envelope.
- Phase R: **add** `runtime.justfile` / `runtime-doit`; **never** replace envelope `doit` detection with a broken `grep '^…$'` on `just --summary`.
- `doctor` must **WARN** (not fail) if `upstream/` is missing — fresh machines rely on `ensure-upstream` inside `doit`.

## Related

- Landscape: `bootstrap-tool-landscape`
- Justfile: `dwim-justfile`
- Fork lineages: `quickstart-fork-lineage`

## After Phase D — Runtime (Phase R)

Singleton metarepos continue with **Phase R** (`just phase R` / `scaffold-runtime`): generate LOCAL_BUILD or brew install recipes into **`runtime.justfile`**, recipe name **`runtime-doit`**, plus `io.github.aculich.*` flavor identities. Envelope `doit` already delegates when that recipe exists.

Multi-laptop: push PHASES + envelope justfile on `main`, then `regen/<laptop>` branches for generate-and-compare (see SIDEQUEST.md / COMPARE_REGEN.md). Do not bulk-copy legacy quickstart justfiles as the primary path.
