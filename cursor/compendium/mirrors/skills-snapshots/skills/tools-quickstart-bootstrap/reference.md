# Tools Quickstart Bootstrap Reference

This reference expands the workflow in `SKILL.md`.

## Directory layout template

### New quickstart repo

```text
~/tools/<tool>-quickstart/
├── upstream/
│   └── <org>__<repo>/
├── docs/
│   ├── TECHSTACK.md
│   ├── ARCHITECTURE.md
│   ├── RESEARCH_KEYWORDS.md
│   ├── project-scan-full.json
│   └── parallel-cache/
├── design/
│   ├── LANDSCAPE.md
│   └── USECASES.md
├── EXECSUMMARY.md
├── PRAXIS.md
├── TOOLBOX.md
├── META.md
└── .gitignore
```

### In-place bootstrap (existing `~/tools/<name>/`)

Same files at the **existing repo root**. May also have:

```text
~/tools/chrome-extensions/          # example
├── .agents/skills/                 # project-local skills (npx skills add, no -g)
├── skills-lock.json
├── AgentBoard/                     # subprojects (no single upstream/)
├── tabwrangler/
└── …
```

Do not require `upstream/<org>__<repo>/` at the root unless the repo is single-tool focused; subfolders may already vendor upstream (e.g. `copyallurls-clone/upstream/`).

## Suggested authoring order

1. `.gitignore` and repo hygiene.
2. Install + smoke tests (`--help`, `version`) — or inventory existing subprojects + manifests.
3. `EXECSUMMARY.md` (purpose, audience, where it fits/does not fit).
4. `PRAXIS.md` (daily workflow and commands).
5. `TECHSTACK.md` and `ARCHITECTURE.md`.
6. Keyword matrix and landscape searches.
7. **`npx skills find`** (find-skills): cache JSON → `TOOLBOX.md` (install user-selected skills project-local).
8. `LANDSCAPE.md` and `USECASES.md` (include agent-skills landscape + pointer to `TOOLBOX.md`).
9. `META.md`.
10. Commit.

### TOOLBOX.md template (sections)

1. How skills are installed in this repo (`.agents/skills/`, `skills-lock.json`, no `-g` by default)
2. **Installed (project-local)** — table: skill, source, installs, role, re-install command
3. **Explicitly not installed** — with reason
4. **Recommended (not installed)** — when to add
5. **Relevant skills elsewhere** — `~/.cursor/skills/`, `~/.agents/skills/`, MCP plugins
6. **Non-skill tooling** — CLIs, browser steps
7. **Maintenance** — `npx skills check` / `update`

## Dual-tool orchestrator pattern

When two tools are meant to work together:

1. Create `~/tools/<tool-a>-quickstart/`
2. Create `~/tools/<tool-b>-quickstart/`
3. Create `~/tools/<shared-stack-repo>/` for integration contracts
4. Keep deep tool docs in each quickstart
5. Keep cross-tool contracts and deployment decisions in shared repo

Recommended shared repo layout:

```text
~/tools/<shared-stack-repo>/
├── docs/
│   ├── INTEGRATION_ARCHITECTURE.md
│   ├── SELF_HOSTING_PLAYBOOK.md
│   └── INTEROP_MATRIX.md
├── scripts/
│   ├── make_contract.sh
│   ├── check_contract.sh
│   └── check_output.sh
├── META.md
└── README.md
```

Dual-tool checkpoints:

- Validate each tool independently before linking.
- Define input/output boundaries before writing orchestration scripts.
- Track licensing/deployment posture per tool and for the combined stack.
- Commit each repo independently in logical batches.

## Canonical section checklist

### EXECSUMMARY

- Purpose
- Objective
- Use cases
- Audience
- Expected outcomes
- No-brainer fit
- Not-yet fit
- Bottom line

### PRAXIS

- Install
- Configure
- Core commands
- Workflow loops
- Deployment stance
- Verification notes

### TECHSTACK

- Runtime and package manager
- Dependency graph
- Provider surface
- Practical implications

### ARCHITECTURE

- Mermaid system diagram
- Layer responsibilities
- Data/control flow
- Why this architecture works

### LANDSCAPE

- Concept lens
- Component lens
- Narrative post angles
- Builder post angles
- Sources and raw cache pointers

### USECASES

- Upstream-stated use cases
- Local-context use cases
- Pantheon contribution model
- Reusable template for future case capture

### META

- Narrative of what was done
- Replicable numbered workflow
- Recursive improvement loop
- Anti-patterns to avoid

## Quality bar

- Keep claims factual and cited where external.
- Keep docs concise and navigable.
- Separate observed facts from interpretation.
- Prefer reproducible commands over prose-only guidance.
