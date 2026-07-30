---
name: dwim-justfile
description: >-
  Scaffolds or enriches a repo-root justfile with DWIM defaults (help, status,
  doctor, doit, phase, phases, scaffold-lineages). Prefer tool-quickstart.justfile
  + PHASES.md for *-metarepo trees. Alias: create-justfile.
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
| `doit` / `phase B` | Phase B DWIM |
| `phase C\|D\|E` | Print PHASES.md section |
| `phases` | B then kit hand-off |
| `scaffold-lineages` | Phase D: public + personal + team (`WITHOUT_TEAM=1` skips team) |

Do **not** ship `PHASE_C_PROMPT.md` — use PHASES.md §C.

## Related

- Bootstrap: `bootstrap-tool-quickstart` (default dir `~/tools/<slug>-metarepo`)
