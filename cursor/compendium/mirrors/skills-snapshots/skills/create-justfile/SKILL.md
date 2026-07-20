---
name: create-justfile
description: >-
  Scaffolds or enriches a repo-root justfile with DWIM defaults (help, status,
  doctor, doit) for any project shape — umbrella/coordination or thin
  operational. Use when the user runs /create-justfile, asks for a justfile,
  just doit, or DWIM task-runner recipes.
disable-model-invocation: true
---

# Create Justfile (DWIM)

## When to apply

User wants a **top-level justfile**, enrichment of an existing one, or `/create-justfile`. Not a full repo bootstrap — for that use `bootstrap-new-project` (which may still call this skill for justfile recipes).

## Minimal defaults (always)

Every root justfile must expose:

| Recipe | Role |
|--------|------|
| `default` / `help` | `@just --list --unsorted` (discoverability) |
| `status` | Read-only snapshot (git + project health) |
| `doctor` | Check required CLIs on `PATH` |
| `doit` | DWIM happy path for *this* project |

## Classify the target

| Class | Heuristic |
|-------|-----------|
| **Greenfield** | No `justfile` / `Justfile` at repo root |
| **Existing** | Root justfile present |
| **Umbrella-with-vendored** | Root justfile **and** `upstream/**/justfile` (or similar) — coordinate at root; **never overwrite** vendored operational justfiles |

## Execution contract

### Pass A — dry-run (required for **Existing**)

1. Read the current justfile; note missing minimal recipes.
2. Emit a **Dry-run report**: planned writes/edits prefixed `[plan]`.
3. End with: `NO FILES WRITTEN — DRY RUN ONLY`.

### Pass B — apply

Write only after the user says **`apply`**, **`overwrite justfile`**, **`create-justfile apply`**, or the same message already included apply intent for greenfield.

**Greenfield:** may write in one shot when the user asked to create a justfile (or `/create-justfile` with no existing file).

## Choose a template

| Flag / situation | Template |
|------------------|----------|
| `--minimal` or unknown / docs-only | [templates/minimal.justfile](templates/minimal.justfile) |
| `--umbrella` or `upstream/` + compose/overlays | [templates/umbrella.justfile](templates/umbrella.justfile) |
| `--operational` or packaging a single app/lib (npm/cargo) **inside** a product dir | [templates/operational.justfile](templates/operational.justfile) |

Default for repo **root**: **minimal**, unless umbrella markers (`upstream/`, `local/compose*.yaml`, pin files) → **umbrella**.

## Shape `doit` by stack

Inspect the repo, then wire `doit` (and optionally `start`/`stop`/`smoke`):

| Signal | `doit` shape |
|--------|----------------|
| `docker-compose*.yml` / `compose.yaml` | ensure-deps → start → wait HTTP → smoke (and `open` if URL known) |
| `package.json` with `dev`/`start` | install if needed → run/dev |
| Docs-only (`README.md`, no app) | `status` then `open README.md` |
| Unknown | Print “fill in happy path” and exit 0 (placeholder body) |

## Hard rules

1. **Never `cd` before nested `just`** — just resolves recipes from cwd; use subshells for compose: `( cd dir && docker compose … )`.
2. **Do not replace** vendored/upstream justfiles when scaffolding the umbrella root.
3. Prefer **list** for `default`/`help` (uinbox discoverability). Keep `status` **read-only**.
4. After write: run `just` (list) and `just doctor`; report results.

## Workflow checklist

```
Task Progress:
- [ ] Classify greenfield / existing / umbrella-with-vendored
- [ ] Dry-run if existing
- [ ] Pick template (minimal | umbrella | operational)
- [ ] Shape doit from stack heuristics
- [ ] Apply (after authorize)
- [ ] just && just doctor
```

## Additional resources

- Umbrella vs operational detail: [reference.md](reference.md)
- Exemplar: `~/tools/universal-inbox-quickstart/justfile`
- TIL: `~/tools/toolchain-2026/learning/til/process/dwim-justfile-status-help-doit.md`
