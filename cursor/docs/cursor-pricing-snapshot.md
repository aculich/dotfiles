# Cursor pricing snapshot (plan budgeting)

Dated extract for **pre-build estimates** on plan todos. Not an invoice — rates change; verify on [Models & Pricing](https://cursor.com/docs/models-and-pricing).

**Machine-readable:** [data/cursor-plan-rates.json](../data/cursor-plan-rates.json)  
**Full catalog:** [upstream/kingdomseed__cursor-calculator/src/data/cursor-pricing.json](../upstream/kingdomseed__cursor-calculator/src/data/cursor-pricing.json)  
**Retrieved:** 2026-06-10

---

## Usage pools

| Pool | Models | Included (individual) |
|------|--------|------------------------|
| **Auto + Composer** | Auto, Composer 2.5 | Generous included usage |
| **API** | All pinned named models | Pro $20 / Pro+ $70 / Ultra $400 per month |

Auto on the plan **Build** bar uses the Auto + Composer pool. Per-agent model pins use the API pool (unless Composer/Auto).

---

## Plan-relevant rate card (per 1M tokens)

| Model ID | Input | Output | Pool |
|----------|-------|--------|------|
| Composer 2.5 | $0.50 | $2.50 | Auto + Composer |
| Auto | $1.25 | $6.00 | Auto + Composer |
| Claude 4.5 Haiku | $1.00 | $5.00 | API |
| GPT-5.3 Codex | $1.75 | $14.00 | API |
| Claude 4.6 Sonnet | $3.00 | $15.00 | API |
| Gemini 3.1 Pro | $2.00 | $12.00 | API |
| Claude Opus 4.8 | $5.00 | $25.00 | API |
| Claude Fable 5 | $10.00 | $50.00 | API |

**Fable 5:** ~2× Opus; use on 1–4 interpretive todos per plan, not bulk work.

---

## Estimation formula

```
cost_usd ≈ (input_tokens / 1e6 × rate_in) + (output_tokens / 1e6 × rate_out)
```

Apply **low / typical / high** bands per todo; multiply pessimistic totals by **1.3–2.5×** for retries and long sessions.

**Scripts:**

```bash
# Sum annotated est_cost_usd on a plan
python3 scripts/estimate-plan-cost.py ~/.cursor/plans/my.plan.md

# Compute missing costs from model + token fields
python3 scripts/estimate-plan-cost.py --compute ~/.cursor/plans/my.plan.md

# Refresh data/cursor-plan-rates.json from upstream catalog
scripts/sync-cursor-pricing-snapshot.sh
```

---

## Refresh policy

1. Check [Models & Pricing](https://cursor.com/docs/models-and-pricing) after Cursor changelog mentions billing.
2. Run `scripts/sync-cursor-pricing-snapshot.sh` after pulling `upstream/kingdomseed__cursor-calculator`.
3. Update this file's **Retrieved** date when rates change.

See also [cursor-cost-tooling.md](cursor-cost-tooling.md) for post-execution measurement tools.
