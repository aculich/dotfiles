---
name: dwim-justfile
description: >-
  Scaffolds or enriches a repo-root justfile with DWIM defaults (help, status,
  doctor, doit, phase, phases, scaffold-lineages, scaffold-runtime). Prefer
  tool-quickstart.justfile + PHASES.md for *-metarepo trees. Alias: create-justfile.
disable-model-invocation: true
---

# DWIM Justfile

**Alias:** `create-justfile`.

## Templates

| Situation | Template |
|-----------|----------|
| Tool quickstart metarepo | [templates/tool-quickstart.justfile](templates/tool-quickstart.justfile) + [templates/PHASES.md](templates/PHASES.md) |
| Docs-only / unknown | `create-justfile/templates/minimal.justfile` — never “fill in happy path” |

## Recipes (tool-quickstart)

| Recipe | Role |
|--------|------|
| `doit` / `phase B` | Thin smoke **or** delegates to `runtime-doit` when Phase R imported |
| `phase C\|D\|R\|E` | Print PHASES.md section |
| `phases` | B then kit hand-off |
| `scaffold-lineages` | Phase D: public + personal + team (`WITHOUT_TEAM=1` skips team) |
| `scaffold-runtime` | Phase R checklist; agent writes `runtime.justfile` |
| `import? 'runtime.justfile'` | Optional Phase R overlay (always ship the import line) |

Do **not** ship `PHASE_C_PROMPT.md` — use PHASES.md §C.

## Pitfalls (learned WorkHorse regen)

1. **`just --summary` is one space-separated line.** Never `grep '^runtime-doit$'`. Use:
   `just --summary | tr ' ' '\n' | grep -qx 'runtime-doit'`.
2. **Phase R must not rewrite envelope `doit`.** Add `runtime.justfile` with a recipe named **`runtime-doit`**. Envelope already has `import?` + smart `doit`.
3. **Broken multiline inside a shebang recipe** (e.g. a literal newline inside `tr ' ' '…'`) can make later `$0` awk look like just syntax errors — keep the detection on one physical line.
4. **`doctor` must not hard-fail on missing upstream.** Fresh SideQuest clones have no `upstream/` yet; thin `doit` / `runtime-doit` call `ensure-upstream` to clone. Warn only; hard-fail only on missing `git`/`just`. Thin `doit` order: `ensure-upstream` → `doctor` → `pin` → `smoke`.

## Related

- Bootstrap: `bootstrap-tool-quickstart` (default dir `~/tools/<slug>-metarepo`)
- Compare: [templates/COMPARE_REGEN.md](templates/COMPARE_REGEN.md), [templates/SIDEQUEST.md](templates/SIDEQUEST.md)
