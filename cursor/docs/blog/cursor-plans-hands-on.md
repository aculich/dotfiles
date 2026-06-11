# Cursor plans with agents: a hands-on walkthrough

*For people who have used Plan Mode once and want to run multi-todo work without burning their API budget.*

**Time:** ~45 minutes reading + one practice plan  
**Prerequisites:** Cursor Pro (or similar), a repo with `.cursor/plans/`  
**Companion:** [cursor-plans-agents-guide.md](../cursor-plans-agents-guide.md)

---

## Act 1 — Why plans feel expensive

You open Plan Mode (`Shift+Tab`), get a crisp todo list, hit **Build**, and watch the meter climb. Maybe you pinned Opus on the Build bar "just to be safe." Maybe Auto ran fine but one todo spawned five retries.

Cursor has **two usage pools** ([Models & Pricing](https://cursor.com/docs/models-and-pricing)):

1. **Auto + Composer** — cheap, generous included usage.
2. **API pool** — every pinned Sonnet, Codex, or Fable 5 token bills at provider rates against your monthly included API allowance (Pro $20, Pro+ $70, Ultra $400).

**The fix is not "never use good models."** It is: **route cheap work to Auto, pin expensive models only where judgment matters**, and **measure after each wave** on the [usage dashboard](https://cursor.com/dashboard?tab=usage).

---

## Act 2 — Open the plan editor

1. Create or open a `.plan.md` file (saved plans live in `.cursor/plans/` — see [cursor-home-and-plans.md](../cursor-home-and-plans.md)).
2. Notice three regions:
   - **Top:** model picker + **Build** (`Cmd+Enter`)
   - **Middle:** todos with status chips and assignment controls
   - **Right/bottom:** **Referenced by N Agents** with **+ New**

![Plan editor with Agents panel](../assets/plan-editor-agents-panel.png)

**Rule of thumb:** Leave **Auto** on the plan-level Build bar. Create **referenced agents** for pinned models.

---

## Act 3 — Add agents and assign todos

### Step 1: Create two agents

| Agent name | Model | Role |
|------------|-------|------|
| `janitor` | Auto | Scripts, mkdir, cross-links |
| `writer` | Composer 2.5 or Sonnet | Docs and synthesis |

Click **+ New** twice; set each agent's model in its own picker.

### Step 2: Assign todos

Use the **assignment chip** on each todo:

- Mechanical work → `janitor`
- Prose / structure → `writer`

The counter updates: **Referenced by 2 Agents**.

### Step 3: Build in waves

Do not Build all thirteen todos at once on your first try.

1. Select todos for wave 1 → **Build selected** (or open `janitor` and run).
2. Mark completed in the plan.
3. Check usage on the dashboard.
4. Start wave 2 with the writer agent.

---

## Act 4 — Budget before Build

Before you spend, annotate your plan (convention in the [reference guide](../cursor-plans-agents-guide.md#6-plan-file-cost-annotations)):

```yaml
est_cost_usd:
  low: 0.5
  typical: 1.2
  high: 2.5
pool: auto
```

Add a **`## Cost budget`** table with Lean / Balanced / Premium columns.

**Quick math:**

```
cost ≈ (input_M × rate_in) + (output_M × rate_out)
```

Example: 100k in + 30k out on Sonnet ($3 / $15 per M) ≈ $0.30 + $0.45 = **$0.75**.

Run locally:

```bash
python3 scripts/estimate-plan-cost.py ~/.cursor/plans/my-plan.plan.md
```

Set a **ceiling** (e.g. `$15 API this session`). If Balanced estimate exceeds it, move more todos to Auto.

### When to use Fable 5

[Fable 5](https://cursor.com/docs/models-and-pricing) costs **$10 / $50 per M tokens** — about **2× Opus**. Use it on **one interpretive todo per plan**, not bulk code.

**Good Fable todo:** "Write a narrative walkthrough explaining tradeoffs to a newcomer."  
**Bad Fable todo:** "Download 50 PDFs and write INDEX.md."

---

## Act 5 — Mini practice plan (3 todos)

Try this in a scratch repo:

```yaml
todos:
  - id: scaffold
    content: Create docs/blog/ and a one-line README stub
    status: pending
  - id: draft
    content: Write 300 words on why Plan Mode beats ad-hoc chat for multi-step work
    status: pending
  - id: link
    content: Add one cross-link from README to the new doc
    status: pending
```

| Todo | Agent | Model | Why |
|------|-------|-------|-----|
| `scaffold` | janitor | Auto | Mechanical |
| `draft` | writer | Fable 5 | Narrative quality |
| `link` | janitor | Auto | One-line edit |

**Expected API spend (Balanced):** ~$1–3 (mostly Fable on `draft`).

**Build order:** scaffold → draft → link → dashboard check.

---

## Act 6 — Measure and reconcile

### Everyone

Open [cursor.com/dashboard?tab=usage](https://cursor.com/dashboard?tab=usage). Compare actual spend to your `## Cost budget` table.

### Teams admins

```bash
export CURSOR_ADMIN_API_KEY=...
scripts/fetch-cursor-usage-events.sh \
  --start 2026-06-10T00:00:00Z \
  --end 2026-06-10T23:59:59Z \
  --email you@example.com
```

Sum `chargedCents` and group by `model`. Details: [reference guide §7](../cursor-plans-agents-guide.md#7-measure-after-execution).

### Third-party helpers

- [cursor-cost-calculator.com](https://cursor-cost-calculator.com/) — quick what-if
- [kingdomseed/cursor-calculator](../upstream/kingdomseed__cursor-calculator/) — CSV import (vendored under `upstream/`)

---

## Cheat sheet

| I want to… | Do this |
|------------|---------|
| Cheap bulk work | Auto agent + Auto on Build bar |
| Reliable code | GPT-5.3 Codex agent, API pool |
| Great prose (once) | Fable 5 on **one** todo |
| Mix models | Referenced agents + per-todo assignment |
| Estimate before Build | Annotate plan + `estimate-plan-cost.py` |
| Verify after Build | Usage dashboard or Teams API |

---

## What to read next

- [cursor-plans-agents-guide.md](../cursor-plans-agents-guide.md) — full reference, appendices for 4- and 13-todo plans
- [MULTIROOT-cursor-lifecycle.md](../MULTIROOT-cursor-lifecycle.md) §3 — plan file locations
- [CURSOR3-worktrees.md](../CURSOR3-worktrees.md) — parallel agents via worktrees

*Last updated: 2026-06-10. Validate UI labels on your Cursor version.*
