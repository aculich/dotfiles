# Justfile styles — umbrella vs operational

## Umbrella / coordination (repo root)

**Exemplar:** `~/tools/universal-inbox-quickstart/justfile`

Owns the **eval / stewardship** surface for agents and humans:

- Variables: `tool`, `upstream_dir`, `compose`, `ui_url`, pin paths
- `status` — git, upstream dirty check, pin file, rotation gate, compose `ps`
- `doit` — DWIM: gates → ensure-deps → start → wait HTTP → open → smoke
- Lifecycle: `start` / `stop` / `ps` / `logs` / `smoke` / `open`
- Stewardship: `pin`, `update-upstream`, `upstream-reset`, git-exclude helpers

`default` / `help` list recipes (`@just --list --unsorted`). Agents learn the menu from bare `just`; humans and agents run `just doit` when they want the happy path.

### Nested `just` gotcha

`just` resolves the justfile from the **current working directory**. If a recipe `cd`s into `upstream/.../docker` and then calls `just ps`, it looks for a justfile *there* and fails or hits the wrong file. Pattern:

```bash
( cd {{docker_dir}} && {{compose}} up -d )
just ps   # still from repo root
```

## Vendored / operational (product subdirs)

**Exemplars:**

- `upstream/universal-inbox__universal-inbox-extension/justfile` — npm install/run/build/lint; `default: @just --choose`
- `upstream/universal-inbox__universal-inbox-raycast/justfile` — same thin style
- `…/rmcp-actix-web/justfile` — specialized (`dev-shell`), not DWIM umbrella

These wrap **day-to-day build/run** for a single package. They are **not** the coordination surface. When scaffolding an umbrella root, leave them alone.

## Minimal defaults (any project)

Even a docs-only or non-software repo gets:

```
default / help → list
status         → read-only orientation
doctor         → PATH tools
doit           → project-shaped happy path (or honest placeholder)
```

## Related skills

- `bootstrap-new-project` — full repo layout; inlines a minimal justfile; prefer **this** skill for justfile-only or DWIM/`doit` enrichment
- `bootstrap-umbrella-client-project` — umbrella kit including justfile; may invoke create-justfile for DWIM recipes
