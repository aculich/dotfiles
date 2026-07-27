---
name: tools-quickstart-bootstrap
description: Bootstrap a new tool quickstart repository under ~/tools/*-quickstart with vendored upstream source, executable validation, architecture/techstack docs, landscape/use-case synthesis, and reusable process capture. Use when setting up a new quickstart, evaluating a newly discovered developer tool, or standardizing a repeatable onboarding workflow.
disable-model-invocation: true
metadata:
  source:
    upstream: https://github.com/aculich/agent-skills
    canonical: https://github.com/aculich/agent-skills
---

# Tools Quickstart Bootstrap

## Purpose

Create a repeatable quickstart workspace that helps a developer evaluate a new tool in context, not in isolation.

## When to use

Use this skill when:

- a new tool should be explored in `~/tools/<tool>-quickstart/`,
- an **existing** repo under `~/tools/` should receive the same documentation envelope **in place** (no new `*-quickstart` folder),
- the workflow should include vendored `upstream/` source plus local documentation,
- the user wants a practical + strategic assessment (`EXECSUMMARY`, `PRAXIS`, `background/*`, `META`).

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
- [ ] 1a. Create justfile from template (status / update / smoke recipes)
- [ ] 2. Vendor upstream source and install locally; write background/UPSTREAM_PIN.txt
- [ ] 3. Run smoke tests and capture drift
- [ ] 4. Write baseline docs (EXECSUMMARY, PRAXIS, background/TECHSTACK, background/ARCHITECTURE)
- [ ] 5. Build project-fit evidence (scan + report)
- [ ] 6. Run landscape research and write background/LANDSCAPE + background/USECASES
- [ ] 6a. Verify cited repos are canonical upstream (fork/star/recency check)
- [ ] 6b. Run find-skills (`npx skills find …`) and write TOOLBOX.md (installed / skipped / recommended / global)
- [ ] 7. Write META process narrative + replicable instructions
- [ ] 8. Commit only intentional artifacts
- [ ] 9. Offer follow-up bootstraps for high-signal landscape alternatives (tiered)
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
- [ ] 6a. Verify cited repos are canonical upstream
- [ ] 7. Write integration architecture/playbook/matrix in orchestrator
- [ ] 8. Write META in all three repos
- [ ] 9. Commit in structured batches per repo
- [ ] 10. Offer follow-up bootstraps for high-signal alternatives (tiered)
```

## Required outputs

**Repo root:**

- `EXECSUMMARY.md`
- `PRAXIS.md`
- `META.md`
- `TOOLBOX.md` — agent skills inventory (see **Agent skills landscape** below)
- `justfile` — maintenance recipes (see **Ongoing maintenance** below)
- `.gitignore`

**`background/`** (all tool research and peer landscape):

- `background/TECHSTACK.md`
- `background/ARCHITECTURE.md`
- `background/RESEARCH_KEYWORDS.md`
- `background/LANDSCAPE.md`
- `background/USECASES.md`
- `background/UPSTREAM_PIN.txt` — commit hash, version, clone date

Optional but recommended:

- `background/project-scan-full.json`
- `background/<TOOL>_PROJECT_CANDIDATES_REPORT.md`
- `background/parallel-cache/*.json`
- Shared orchestrator repo:
  - `background/INTEGRATION_ARCHITECTURE.md`
  - `background/SELF_HOSTING_PLAYBOOK.md`
  - `background/INTEROP_MATRIX.md`
  - `scripts/*` contract checks

**Layout migration:** quickstarts created before 2026-07 used split `docs/` + `design/` directories. When touching an older quickstart, migrate contents into `background/` and update internal links.

## Canonical upstream verification

Before finalizing `background/LANDSCAPE.md` (and any Sources list elsewhere), verify every cited GitHub repo is the **canonical upstream**, not a fork or stale mirror.

For each external repo in landscape research:

```bash
gh api repos/<owner>/<repo> --jq '{fork, parent: .parent.full_name, stars: .stargazers_count, pushed_at}'
```

If `gh` is unavailable, use web search or the GitHub API via fetch to confirm owner, fork status, and star count.

**Red flags requiring resolution:**

- `fork: true` with a known parent org
- Very low stars vs. a same-name repo under a different owner
- Name collision (e.g. `marco0417/OpenHarness` vs canonical `HKUDS/OpenHarness`)

**Default:** cite the canonical upstream URL in Sources and compatibility matrix.

**Exception — citing a fork intentionally:** allowed only when upstream is stale **and/or** the fork is significantly ahead on commits. Even then:

1. Cite the canonical upstream in Sources.
2. Add the fork with a one-line justification (why the fork is the focus).

Do not cite fork/mirror URLs as if they were upstream.

## Agent skills landscape (find-skills)

After baseline analysis (steps 4–5) and **before** finalizing `background/LANDSCAPE.md`, run the **find-skills** workflow:

1. Derive 2–4 search queries from the tool/domain (e.g. `npx skills find chrome extension`, `npx skills find <tool-name>`).
2. Check [skills.sh](https://skills.sh/) leaderboard when the domain is common (React, extensions, deploy, etc.).
3. Verify install counts (prefer 1K+ for primary recommendations; note sub-100 as experimental).
4. **Inventory what is already installed** for this repo:
   - Project-local: `.agents/skills/`, `skills-lock.json`
   - User-global: `~/.cursor/skills/`, `~/.agents/skills/` (read-only inventory; install project-local unless user asks for `-g`)
5. Install skills the user requested: `npx skills add <owner/repo@skill> -y` (omit `-g` for project-local).
6. Cache raw `npx skills find` output under `background/parallel-cache/skills-find-<slug>-<date>.json`.
7. Write **`TOOLBOX.md`** at repo root with:
   - Installed (project) — table with source, installs, when to use
   - Skipped — and why
   - Recommended (not installed) — with install commands
   - Relevant global / MCP complements (Cursor plugins, etc.)
   - Non-skill tooling (CLI, browser steps) if applicable
8. Reference `TOOLBOX.md` from `background/LANDSCAPE.md` (agent-skills row) and `background/USECASES.md` (discover/install skills use case).

Do not recommend skills from search alone — follow find-skills quality checks (install count, source reputation).

## Ongoing maintenance (justfile)

Every quickstart ships a root **`justfile`** (template in [reference.md](reference.md)). Conventions mirror [awesome-awesome](/Users/me/tools/awesome-awesome/justfile): doc comment per recipe, `default: @just --list --unsorted`, DWIM batch recipe (`just update`).

**Hybrid pattern:** shell recipes gather raw data into `background/parallel-cache/`, then **print a ready-to-paste agent prompt** for synthesis (landscape, TOOLBOX, integrations). Do not auto-edit LANDSCAPE without human/agent review unless the user asks.

| Recipe | Purpose |
| --- | --- |
| `just status` | Git state, upstream pin vs remote HEAD, doc freshness |
| `just update` | Batch: upstream + landscape + skills + integrations + security |
| `just pin` | Write `background/UPSTREAM_PIN.txt` from current upstream HEAD |
| `just update-upstream` | Pull vendored clone, re-pin, diffstat since last pin |
| `just update-landscape` | Re-verify cited repos (`gh api`), cache JSON, print LANDSCAPE refresh prompt |
| `just update-skills` | Re-run `npx skills find`, cache, print TOOLBOX refresh prompt |
| `just update-integrations` | Tiered discovery (see below), cache, print prompt |
| `just update-security` | Advisories + awesome-awesome security lens, print prompt |
| `just verify-sources` | Canonical-upstream check for every GitHub URL in LANDSCAPE |
| `just smoke` | Tool-specific smoke from PRAXIS |

**`update-integrations` tiers:**

1. **Tier 0 (offline):** grep awesome-awesome catalog JSONL (`~/tools/awesome-awesome/data/processed/awesome-catalog.full.jsonl`) — warn if catalog mtime is stale.
2. **Tier 1:** ripgrep `~/tools/awesome-awesome/upstream/` clones; suggest promoting uncloned `awesome-<tool>` lists into `urls.repos.txt` + `just sync-upstream` there.
3. **Tier 2 (live):** `gh search repos` sorted by updated — catches brand-new integrations (e.g. iris) before lists index them.
4. **Ongoing:** grep latest `~/tools/awesome-awesome/docs/reports/awesome-trends-*.md` for the tool name; optionally delegate `just -d ~/tools/awesome-awesome digest`.

**awesome-awesome delegation:** use its justfile as the stable interface — `just -d ~/tools/awesome-awesome --justfile ~/tools/awesome-awesome/justfile <recipe>`. Guard with directory-exists check; no-op with message when absent.

## Sibling skills

This skill composes with sibling repos/skills — never duplicate their pipelines; delegate or read their artifacts.

| Sibling | Location | Used by quickstart recipes |
| --- | --- | --- |
| **awesome-lists** | `~/tools/awesome-awesome/.cursor/skills/awesome-lists/` | Integrations (catalog, clones, adjacency C/D), security/trends lenses |
| **find-skills** | `npx skills find` | TOOLBOX refresh (`update-skills`) |

**awesome-awesome assets recipes lean on:**

- `data/processed/awesome-catalog.full.jsonl` — offline census (~16K repos)
- `upstream/` clones + `manifest.json` + `just sync-upstream`
- `data/processed/entry-events.jsonl` + `just list-diff` — new bullets in followed lists
- `docs/reports/awesome-trends-*.md` — weekly digest (cross-list movers, new entries)
- Per-lens reports via `just lens ai|agent-skills|devtools|security`

Wire future sibling skills the same way: read-only artifact path + optional justfile delegation + graceful no-op.

## Post-bootstrap alternatives follow-up

After step 8 (commit), review `background/LANDSCAPE.md` for high-signal peer tools discovered during research. Use a **structured question** (AskQuestion or equivalent) — do not bury the offer in prose alone.

Group candidates into tiers:

| Tier | Meaning | Example prompt option |
| --- | --- | --- |
| **Tier 1** | Likely better or directly comparable (stars, activity, fit) | Bootstrap now |
| **Tier 2** | Complements — different niche, pairs with bootstrapped tool | Bootstrap if stacking |
| **Tier 3** | Everything else found | Skip / batch later |

Offer: bootstrap selected Tier 1/2 items with this same skill; optionally “all Tier 3” as a separate batch if the user wants exhaustive coverage.

## Guardrails

- Keep `upstream/` and local docs clearly separated.
- Do not claim production readiness without explicit verification.
- Keep AI-generated outputs under human review before merge or publish.
- Prefer citation-backed landscape statements; verify canonical upstream before citing.
- Commit only intentional files; exclude local environments and scratch artifacts.
- Initialize git and commit the quickstart repo as part of the bootstrap (step 8).
- In dual-tool mode, keep integration contracts in orchestrator repo, not duplicated in each quickstart.

## Quick commands

```bash
uv venv .venv
uv pip install -e upstream/<org>__<repo>
.venv/bin/<tool> --help
.venv/bin/<tool> version

# Upstream pin (after clone)
cd upstream/<org>__<repo> && git rev-parse HEAD
```

## Additional reference

- For full step-by-step guidance and templates, read [reference.md](reference.md).
- Pre-2026-07 skill version archived at [archive/SKILL-v1-2026-07-02.md](archive/SKILL-v1-2026-07-02.md).
