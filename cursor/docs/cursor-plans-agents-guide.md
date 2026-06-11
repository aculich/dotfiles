# Cursor plan agents: reference guide

Companion to [MULTIROOT-cursor-lifecycle.md](MULTIROOT-cursor-lifecycle.md) §3 (where plans live) and [cursor-home-and-plans.md](cursor-home-and-plans.md) (paths and catalogs). This page covers the **plan editor UI**: Build, Auto, referenced agents, per-todo assignment, **cost-aware execution**, and post-run reconciliation.

**Disclaimer:** Cursor behavior changes across versions. Prefer [official docs](https://cursor.com/docs/agent/plan-mode) and [changelog](https://cursor.com/changelog); treat forum threads and app-bundle inference as corroboration.

---

## 1. Prerequisites

- **Plan Mode:** `Shift+Tab` in the agent input ([Plan Mode](https://cursor.com/docs/agent/plan-mode)).
- **Save to workspace:** moves plans to `<project>/.cursor/plans/` ([agent best practices](https://cursor.com/blog/agent-best-practices)).
- **Default location:** unsaved plans often live under `~/.cursor/plans/*.plan.md` until saved ([cursor-home-and-plans.md](cursor-home-and-plans.md)).

---

## 2. Plan editor anatomy

When a plan is ready to build, the editor typically shows:

| UI element | Purpose |
|------------|---------|
| **Model picker + Build** (`Cmd+Enter`) | Default model for plan execution; **Auto** uses the Auto + Composer usage pool |
| **To-dos** | Checklist with statuses (`pending`, `in_progress`, `completed`, `cancelled`) |
| **Assignment chip** | Per-todo link to one or more referenced agents (`Assigned to N agent(s)`) |
| **Referenced by N Agents** | Agents panel; **+ New** creates a sub-composer bound to the plan |

On-disk `.plan.md` frontmatter stores `name`, `overview`, and `todos[]` (`id`, `content`, `status`). **Agent assignments and models are not persisted in YAML today** — they live in Cursor's plan registry/UI. Use the [annotation convention](#6-plan-file-cost-annotations) below for git-backed budgeting.

### Build paths (common confusion)

- **Build from the plan editor** vs **Build from chat** can behave differently; if the agent says it does not see the plan, use Build from the plan UI ([forum](https://forum.cursor.com/t/what-happens-when-plan-file-is-saved/135261)).
- **Build all** runs the full todo set in one agent session.
- **Build selected todos** / **build in new agent** spawns work for a subset with plan context.
- Open an **assigned referenced agent** and run with that agent's model picker.

---

## 3. Auto and usage pools

Cursor individual plans have two usage pools ([Models & Pricing](https://cursor.com/docs/models-and-pricing), [Usage and limits](https://cursor.com/help/models-and-usage/usage-limits)):

| Pool | When it applies | Included usage |
|------|-----------------|----------------|
| **Auto + Composer** | Model = **Auto** or **Composer 2.5** | Generous; designed for everyday agentic work |
| **API** | Any **pinned** named model | Pro $20 / Pro+ $70 / Ultra $400 per month at provider API rates |

**Plan Build bar "Auto"** draws from the cheap pool. **Per-agent model pickers** that pin Sonnet, Codex, Fable 5, etc. bill against the **API pool** for those runs.

### Slim API rate card (per 1M tokens)

| Model | Input | Output | Pool |
|-------|-------|--------|------|
| Composer 2.5 | $0.50 | $2.50 | Auto + Composer |
| Auto (blended) | $1.25 | $6.00 | Auto + Composer |
| Claude 4.5 Haiku | $1.00 | $5.00 | API |
| GPT-5.3 Codex | $1.75 | $14.00 | API |
| Claude 4.6 Sonnet | $3.00 | $15.00 | API |
| Gemini 3.1 Pro | $2.00 | $12.00 | API |
| Claude Opus 4.8 | $5.00 | $25.00 | API |
| Claude Fable 5 | $10.00 | $50.00 | API |

Full table: [Models & Pricing](https://cursor.com/docs/models-and-pricing). **Fable 5:** ~2× Opus cost; privacy/retention constraints; guardrail trips may route to Opus.

### Budgeting heuristic

**Pin API models only where mistake cost > token cost.** Use Auto/Composer for scripts, cross-links, and mechanical wiring. Reserve Fable 5 for 1–2 interpretive or narrative todos per plan.

**Max Mode** bills at the model's API rate and burns context faster ([Usage and limits](https://cursor.com/help/models-and-usage/usage-limits)).

**Teams:** non-Auto agent requests may include the Cursor Token Rate ($0.25/M tokens) on top of model API pricing ([Models & Pricing](https://cursor.com/docs/models-and-pricing)).

---

## 4. Referenced agents and todo assignment

1. Click **+ New** in the Agents panel → creates a **referenced plan agent** (sub-composer linked to the plan).
2. Each agent has its **own model picker** — this is how you mix economical and premium models.
3. Use the **assignment chip** on each todo to assign work to specific agents.
4. Counter shows **Referenced by N Agents**.

Recommended agent roles:

| Agent role | Default model | Pool |
|------------|---------------|------|
| Bulk / janitor | Auto | Auto + Composer |
| Reference / spec | Composer 2.5 or Sonnet | Composer or API |
| Code | GPT-5.3 Codex | API |
| Narrative / critical prose | Fable 5 (sparingly) | API |

**Never pin Fable 5 on the plan-level Build bar** for a whole mixed plan.

Related escape hatches (not duplicated here):

- [CURSOR3-worktrees.md](CURSOR3-worktrees.md) — `/worktree`, `/best-of-n`
- [Subagents](https://cursor.com/docs/context/subagents) — `model:` in `.cursor/agents/*.md`
- `/multitask` in Agents Window ([forum](https://forum.cursor.com/t/multitask-in-agents-window/158955))
- [Cloud agents + plans](https://cursor.com/blog/cloud-agents)

---

## 5. Cost-aware plan execution

### Estimation formula

```
cost_usd ≈ (input_tokens / 1e6 × rate_in) + (output_tokens / 1e6 × rate_out)
```

Use **low / typical / high** bands per todo; multiply by **1.3–2.5×** for pessimistic (retries, long sessions). Estimates are order-of-magnitude, not invoices.

### Task archetypes

| Archetype | Typical input | Typical output |
|-----------|---------------|----------------|
| `script` | 30k–80k | 5k–15k |
| `doc-draft` | 80k–200k | 15k–40k |
| `doc-synthesis` | 150k–400k | 25k–60k |
| `code-feature` | 100k–300k | 20k–80k |
| `code-debug` | 150k–500k+ | 30k–100k+ |
| `cross-link` | 10k–40k | 1k–3k |

### Rollup scenarios

| Scenario | Model strategy | When |
|----------|----------------|------|
| **Lean** | Auto / Composer on non-critical todos | Tight API budget |
| **Balanced** | Auto bulk + 1–4 pinned API todos | Default |
| **Premium** | Opus / Fable / Codex on most todos | Deadline > cost |

### Planning workflow (before Build)

1. Plan Mode produces todos.
2. Annotate each todo: archetype → tokens → model/pool → cost band ([§6](#6-plan-file-cost-annotations)).
3. Sum Lean / Balanced / Premium; set a **spend ceiling** (e.g. `$25 API`).
4. Assign referenced agents + models.
5. Build **wave-by-wave**; reconcile on the [usage dashboard](https://cursor.com/dashboard?tab=usage) after each wave.

**Local helpers:** [scripts/estimate-plan-cost.py](../scripts/estimate-plan-cost.py) sums or computes `est_cost_usd`; [cursor-cost-tooling.md](cursor-cost-tooling.md) indexes CSV analyzers, extensions, and reconcile scripts.

---

## 6. Plan-file cost annotations

Convention for humans and planning agents — **not read by Cursor Build UI yet**.

```yaml
todos:
  - id: write-blog-post
    content: Write docs/blog/cursor-plans-hands-on.md ...
    status: pending
    model: claude-fable-5
    pool: api
    archetype: doc-draft
    auto_likely: null
    auto_confidence: null
    est_tokens_in: 120000
    est_tokens_out: 35000
    est_cost_usd:
      low: 1.8
      typical: 2.8
      high: 4.5
    agent: blog
```

Add a **`## Cost budget`** section in the plan body:

```markdown
## Cost budget
- Scenario: Balanced | Ceiling: $25 API
- plan_started_at: 2026-06-10T14:00:00Z
- plan_completed_at: (fill when done)

| Scenario | Est API $ | Actual $ | Delta |
|----------|-----------|----------|-------|
| Lean | | | |
| Balanced | | | |
| Premium | | | |
```

### Auto `auto_likely` heuristics (not guarantees)

Official Auto [balances intelligence, cost, and reliability](https://cursor.com/docs/models-and-pricing). Routing is opaque.

| Todo signal | `auto_likely` | Confidence |
|-------------|---------------|------------|
| Shell scripts, downloads, cross-links | `composer-2.5` | medium |
| Single-file doc from template | `composer-2.5` | medium |
| Multi-file code feature | `codex-tier` | low |
| Long interpretive synthesis | `sonnet-tier` or `frontier` | low |
| Architecture / spec | `sonnet-tier` | low |
| Guaranteed model needed | *pin explicitly* | — |

Verify actual routing on the usage dashboard after runs.

---

## 7. Measure after execution

### Usage dashboard (all users)

| Resource | URL |
|----------|-----|
| Usage | [cursor.com/dashboard?tab=usage](https://cursor.com/dashboard?tab=usage) |
| Billing | [cursor.com/dashboard?tab=billing](https://cursor.com/dashboard?tab=billing) |
| Help | [Usage and limits](https://cursor.com/help/models-and-usage/usage-limits) |

Enable usage in the editor status bar via Cursor Settings ([forum](https://forum.cursor.com/t/where-can-i-find-usage-limits/127834)). Token breakdowns are shown per [Understanding LLM Token Usage](https://forum.cursor.com/t/understanding-llm-token-usage/120673).

**Individual Pro:** no official personal usage API found. Reconcile manually on the dashboard or via CSV import tools ([kingdomseed/cursor-calculator](https://github.com/kingdomseed/cursor-calculator)).

### Teams Admin API (programmatic)

| Endpoint | Use |
|----------|-----|
| `POST /teams/filtered-usage-events` | **Primary.** Per-event `model`, `tokenUsage`, `chargedCents` |
| `POST /teams/spend` | Billing-cycle totals |
| `POST /teams/daily-usage-data` | Aggregates (not sufficient alone for billing) |

Docs: [Admin API](https://cursor.com/docs/account/teams/admin-api). Auth: Basic auth with admin API key from [team settings](https://cursor.com/settings).

**Reconciliation workflow:**

1. Record `plan_started_at` / `plan_completed_at` in `## Cost budget`.
2. After each wave, fetch events for your email and time window.
3. Sum `chargedCents`; compare to `est_cost_usd` bands.
4. Group by `model` to validate routing.

**Helper:** [scripts/fetch-cursor-usage-events.sh](../scripts/fetch-cursor-usage-events.sh)

Enterprise-only: [Analytics API](https://cursor.com/docs/account/teams/analytics-api), [AI Code Tracking API](https://cursor.com/docs/account/teams/ai-code-tracking-api) (lines of AI code, not dollar ledger).

### Third-party tools

**Pre-build estimates:**

| Tool | Notes |
|------|-------|
| [cursor-cost-calculator.com](https://cursor-cost-calculator.com/) | Web; 29 models; [forum](https://forum.cursor.com/t/simple-price-calculator-to-help-me-understand-my-usage/154793) |
| [kingdomseed/cursor-calculator](../upstream/kingdomseed__cursor-calculator/) | Clone under `upstream/`; CSV import |
| `scripts/estimate-plan-cost.py` | Parse annotated `.plan.md` |

**Monitoring (may break when billing changes):**

| Tool | Notes |
|------|-------|
| [Dwtexe/cursor-stats](https://github.com/Dwtexe/cursor-stats) | Archived Mar 2026 |
| [Tendo33/cursor-usage-tracker](https://github.com/Tendo33/cursor-usage-tracker) | Status bar |
| [Ittipong/cursor-price-tracking](https://github.com/Ittipong/cursor-price-tracking) | Per-model breakdown |
| [cli-cursor-usage-tracker](https://github.com/g-guerzoni/cli-cursor-usage-tracker) | CLI |

---

## 8. Known gaps

- One **Build** click does not fully automate overnight multi-agent orchestration ([forum](https://forum.cursor.com/t/telling-the-plan-agent-to-use-multi-agents/151771)).
- Todo/agent assignment metadata is **not** in committed `.plan.md` YAML by default.
- **Auto** routing is not published per task type.
- Validate all UI behavior on your Cursor build.

---

## Appendix A: Docs plan (4 todos) — cost playbook

| Todo | Agent | Model | Pool |
|------|-------|-------|------|
| `write-reference-guide` | Reference | Composer 2.5 or Sonnet 4.6 | Composer / API |
| `write-blog-post` | Blog | Fable 5 | API |
| `cross-link-existing` | Janitor | Auto | Auto + Composer |
| `create-blog-dir` | Blog | Auto | Auto + Composer |

| Scenario | Est. API spend |
|----------|----------------|
| Lean | ~$1–3 |
| Balanced | ~$3–6 |
| Premium | ~$5–10 |

Build order: reference guide → blog → cross-links.

---

## Appendix B: Lens plan (13 todos) — cost playbook

| Wave | Todos | Model |
|------|-------|-------|
| Corpus | `pdf-extract`, `paper-harvest`, `lit-search` | Auto |
| Scholar | `deep-read`, `methods-landscape`, `lens-vocabulary` | Fable 5 |
| Catalog | `frameworks-extend` | Composer 2.5 |
| Builder | `report-mode` | GPT-5.3 Codex |
| Builder | `classic-lenses` | Auto |
| Verify | `verify-e2e` | Auto → Codex if stuck |
| Director | `lens-walkthrough` | Fable 5 |
| Director | `workbench-prd` | Composer 2.5 |
| Director | `workbench-spec` | Sonnet |

| Scenario | Est. API spend |
|----------|----------------|
| Lean | ~$5–12 |
| Balanced | ~$18–35 |
| Premium | ~$50–100+ |

Fable count (Balanced): 4 todos. Run scholar wave sequentially with fresh sessions.

---

## Sources

- [Plan Mode](https://cursor.com/docs/agent/plan-mode)
- [Introducing Plan Mode](https://cursor.com/blog/plan-mode)
- [Best practices for coding with agents](https://cursor.com/blog/agent-best-practices)
- [Models & Pricing](https://cursor.com/docs/models-and-pricing)
- [Usage and limits](https://cursor.com/help/models-and-usage/usage-limits)
- [Agents Window](https://cursor.com/docs/agent/agents-window)
- [Subagents](https://cursor.com/docs/context/subagents)
- [Admin API](https://cursor.com/docs/account/teams/admin-api)
- [Teams Dashboard](https://cursor.com/docs/account/teams/dashboard)
- [Cloud agents](https://cursor.com/blog/cloud-agents)
- [Cursor 3 changelog](https://cursor.com/changelog/3-0)
- Research JSON: [cursor-plan-agents-research.json](../cursor-plan-agents-research.json), [cursor-usage-dashboard-api-research.json](../cursor-usage-dashboard-api-research.json), [cursor-cost-calculator-tools-research.json](../cursor-cost-calculator-tools-research.json)

Hands-on walkthrough: [blog/cursor-plans-hands-on.md](blog/cursor-plans-hands-on.md)
