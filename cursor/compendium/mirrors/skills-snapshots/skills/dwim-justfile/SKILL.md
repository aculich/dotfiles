---
name: dwim-justfile
description: >-
  Scaffolds or enriches a repo-root justfile with DWIM defaults (help, status,
  doctor, doit). Prefer tool-quickstart.justfile for *-quickstart metarepos.
  Alias: create-justfile. Use for /dwim-justfile, /create-justfile, just doit.
disable-model-invocation: true
---

# DWIM Justfile

**Alias:** `create-justfile` (same skill; prefer this name going forward).

## When to apply

User wants a root justfile, enrichment of an existing one, `/dwim-justfile`, or `/create-justfile`. Not a full Phase A envelope — that is `bootstrap-tool-quickstart`.

## Minimal defaults (always)

| Recipe | Role |
|--------|------|
| `default` / `help` | `@just --list --unsorted` |
| `status` | Read-only snapshot |
| `doctor` | Check required CLIs |
| `doit` | DWIM happy path for *this* project |

## Templates

| Situation | Template |
|-----------|----------|
| Tool quickstart metarepo (`*-quickstart`, `upstream/`, pin) | [templates/tool-quickstart.justfile](templates/tool-quickstart.justfile) + [templates/PHASE_C_PROMPT.md](templates/PHASE_C_PROMPT.md) |
| Docs-only / unknown (non-quickstart) | Prefer shaping `doit` from stack; fall back to thin stub that runs `doctor` + `status` + opens README — **never** print “fill in happy path” |
| Umbrella / operational | Still available under `~/.cursor/skills/create-justfile/templates/` until migrated |

Default for `~/tools/*-quickstart`: **tool-quickstart**.

## Shape `doit` (no placeholder exit)

| Signal | `doit` shape |
|--------|----------------|
| Tool quickstart | `doctor` → ensure pin/upstream → `smoke` → print functional-proof checklist → open folder → print Phase C paste prompt |
| `docker-compose` / `compose.yaml` | ensure-deps → start → wait HTTP → smoke |
| `package.json` with `dev`/`start` | install if needed → run/dev |
| Docs-only | `status` → open README |
| Unknown | `doctor` + `status` + echo next-step guesses from tree (README/Makefile/package.json); exit 0 without a fake “fill in” recipe |

## Execution contract

### Pass A — dry-run (required for **Existing**)

1. Read current justfile; note missing recipes.
2. Emit dry-run report prefixed `[plan]`.
3. End with: `NO FILES WRITTEN — DRY RUN ONLY`.

### Pass B — apply

Write after `apply` / `overwrite justfile` / greenfield create intent.

## Hard rules

1. Never `cd` before nested `just` — use subshells for compose.
2. Do not replace vendored `upstream/**/justfile`.
3. After write: `just` (list) and `just doctor`.

## Related

- Singleton bootstrap: `bootstrap-tool-quickstart`
- Landscape: `bootstrap-tool-landscape`
- Exemplar mature justfile: `~/tools/voiceink-quickstart/justfile`
- TIL: `~/tools/toolchain-2026/learning/til/process/dwim-justfile-status-help-doit.md`
