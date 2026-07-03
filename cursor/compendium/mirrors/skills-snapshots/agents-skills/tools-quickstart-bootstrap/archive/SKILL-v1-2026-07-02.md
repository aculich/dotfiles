---
name: tools-quickstart-bootstrap
description: Bootstrap a new tool quickstart repository under ~/tools/*-quickstart with vendored upstream source, executable validation, architecture/techstack docs, landscape/use-case synthesis, and reusable process capture. Use when setting up a new quickstart, evaluating a newly discovered developer tool, or standardizing a repeatable onboarding workflow.
disable-model-invocation: true
---

# Tools Quickstart Bootstrap

## Purpose

Create a repeatable quickstart workspace that helps a developer evaluate a new tool in context, not in isolation.

## When to use

Use this skill when:

- a new tool should be explored in `~/tools/<tool>-quickstart/`,
- an **existing** repo under `~/tools/` should receive the same documentation envelope **in place** (no new `*-quickstart` folder),
- the workflow should include vendored `upstream/` source plus local documentation,
- the user wants a practical + strategic assessment (`EXECSUMMARY`, `PRAXIS`, `TECHSTACK`, `ARCHITECTURE`, `LANDSCAPE`, `USECASES`, `META`).

### In-place bootstrap (existing directory)

When the user says to bootstrap **this directory** or an existing path (e.g. `~/tools/chrome-extensions`):

1. Do **not** create `~/tools/<tool>-quickstart/` unless they ask for a new repo.
2. Write all required outputs at the **current repo root** (same filenames as the quickstart template).
3. Inventory existing subprojects instead of only vendoring a single new upstream.
4. Run the **Agent skills landscape** step (below) and write [`TOOLBOX.md`](TOOLBOX.md) at the repo root.

## Execution workflow

Copy this checklist and update status as you go:

```markdown
Quickstart Bootstrap Progress:
- [ ] 1. Create repo envelope and ignore policy
- [ ] 2. Vendor upstream source and install locally
- [ ] 3. Run smoke tests and capture drift
- [ ] 4. Write baseline docs (EXECSUMMARY, PRAXIS, TECHSTACK, ARCHITECTURE)
- [ ] 5. Build project-fit evidence (scan + report)
- [ ] 6. Run landscape research and write LANDSCAPE/USECASES
- [ ] 6b. Run find-skills (`npx skills find …`) and write TOOLBOX.md (installed / skipped / recommended / global)
- [ ] 7. Write META process narrative + replicable instructions
- [ ] 8. Commit only intentional artifacts
```

**In-place checklist variant:** same steps; step 2 becomes “inventory existing tree + optional upstream pin” instead of “clone new upstream only”.

### Dual-tool + shared-orchestrator mode

Use this variant when bootstrapping two related tools in parallel and linking them with a third repo:

```markdown
Dual Bootstrap Progress:
- [ ] 1. Scaffold tool A quickstart
- [ ] 2. Scaffold tool B quickstart
- [ ] 3. Scaffold shared orchestrator repo
- [ ] 4. Vendor + smoke both upstreams
- [ ] 5. Write core docs for both quickstarts
- [ ] 6. Run shared self-hosting-first landscape synthesis
- [ ] 7. Write integration architecture/playbook/matrix in orchestrator
- [ ] 8. Write META in all three repos
- [ ] 9. Commit in structured batches per repo
```

## Required outputs

- `EXECSUMMARY.md`
- `PRAXIS.md`
- `docs/TECHSTACK.md`
- `docs/ARCHITECTURE.md`
- `docs/RESEARCH_KEYWORDS.md`
- `design/LANDSCAPE.md`
- `design/USECASES.md`
- `META.md`
- `TOOLBOX.md` — agent skills inventory (see **Agent skills landscape** below)

Optional but recommended:

- `docs/project-scan-full.json`
- `docs/<TOOL>_PROJECT_CANDIDATES_REPORT.md`
- `docs/parallel-cache/*.json`
- Shared orchestrator repo:
  - `docs/INTEGRATION_ARCHITECTURE.md`
  - `docs/SELF_HOSTING_PLAYBOOK.md`
  - `docs/INTEROP_MATRIX.md`
  - `scripts/*` contract checks

## Agent skills landscape (find-skills)

After baseline analysis (steps 4–5) and **before** finalizing `design/LANDSCAPE.md`, run the **find-skills** workflow:

1. Derive 2–4 search queries from the tool/domain (e.g. `npx skills find chrome extension`, `npx skills find <tool-name>`).
2. Check [skills.sh](https://skills.sh/) leaderboard when the domain is common (React, extensions, deploy, etc.).
3. Verify install counts (prefer 1K+ for primary recommendations; note sub-100 as experimental).
4. **Inventory what is already installed** for this repo:
   - Project-local: `.agents/skills/`, `skills-lock.json`
   - User-global: `~/.cursor/skills/`, `~/.agents/skills/` (read-only inventory; install project-local unless user asks for `-g`)
5. Install skills the user requested: `npx skills add <owner/repo@skill> -y` (omit `-g` for project-local).
6. Cache raw `npx skills find` output under `docs/parallel-cache/skills-find-<slug>-<date>.json`.
7. Write **`TOOLBOX.md`** at repo root with:
   - Installed (project) — table with source, installs, when to use
   - Skipped — and why
   - Recommended (not installed) — with install commands
   - Relevant global / MCP complements (Cursor plugins, etc.)
   - Non-skill tooling (CLI, browser steps) if applicable
8. Reference `TOOLBOX.md` from `design/LANDSCAPE.md` (agent-skills row) and `design/USECASES.md` (discover/install skills use case).

Do not recommend skills from search alone — follow find-skills quality checks (install count, source reputation).

## Guardrails

- Keep `upstream/` and local docs clearly separated.
- Do not claim production readiness without explicit verification.
- Keep AI-generated outputs under human review before merge or publish.
- Prefer citation-backed landscape statements.
- Commit only intentional files; exclude local environments and scratch artifacts.
- In dual-tool mode, keep integration contracts in orchestrator repo, not duplicated in each quickstart.

## Quick commands

```bash
uv venv .venv
uv pip install -e upstream/<org>__<repo>
.venv/bin/<tool> --help
.venv/bin/<tool> version
```

## Additional reference

- For full step-by-step guidance and templates, read [reference.md](reference.md).
