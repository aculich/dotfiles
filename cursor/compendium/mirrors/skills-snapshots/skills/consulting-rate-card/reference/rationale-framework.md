# Rate-card rationale framework

Internal worksheet. The client never sees this document. Prices in YAML must be traceable to these seven steps.

## 1. Cost floor

Compute a **minimum sustainable hourly** before any market or value conversation.

Inputs:

- Target take-home (after tax)
- Self-employment tax, health insurance, liability, tools, contractors
- Non-billable load (sales, admin, delivery overhead) — realistic billable hours/year, not 2,000
- Buffer for scope creep on packaged work (packages absorb more hours than the estimate)

```
fully_loaded_annual_need / realistic_billable_hours = min_hourly
```

Rules:

- Never publish a from-price whose implied hours × min_hourly exceed the price (you would lose money at the floor).
- Advertised sticker and internal fully loaded cost are **two different numbers**. AI/leverage widens the gap; do not give that gap away as a default discount.

## 2. Market band

Collect **evidence**, do not invent comps:

- Own closed work (invoices, CMAS lists, partner rate cards)
- Sector bands the practice already uses (e.g. corporate vs nonprofit vs government)
- Procurement ceilings when they apply (GSA/CMAS: at or below base schedule)

Write the band as a range with sources. If evidence conflicts, pick a canonical number and record the rejected one.

## 3. Value ceiling

Price against **outcome worth**, not hours inside the package.

Ask (and record answers, even if qualitative):

- What is the number-one priority this work serves?
- What is the cost of not solving it this year?
- What does success look like in measurable terms?
- How much is that outcome worth to the organization?

The public from-price sits between floor and ceiling. The SOW quote may move up with scope; it should not move below floor.

## 4. Engagement-model mix

Rank models by default (best → worst for the practice):

1. **Productized / project (fixed scope, fixed price)** — named offerings with includes/excludes
2. **Value / outcome-based** — only when impact is measurable and the buyer has budget authority
3. **Advisory retainer** — access and judgment, not a bucket of execution hours
4. **Prepaid hour blocks** — efficiency discount for committed volume, still scoped
5. **Time & materials** — discovery, troubleshooting, evolving scope
6. **Emergency / on-call** — separate premium; never the default rate

Do not lead the public card with an hourly ladder. Hourly exists for T&M, change orders, and the full client PDF.

Retainers fail when they are disguised staff-aug. If the client needs execution, sell a project or a block with a change-order rule.

## 5. Sector tiers and discount stack

Start from **sticker**. Discounts are named, stacked, and written down — never silent.

Typical stack (apply in order, each optional):

1. Partner / channel
2. First engagement with this buyer
3. Mission / community / nonprofit
4. Reusability (prior templates, prior county, prior curriculum)

**Floor rule:** name a never-below for new-client work with fixed setup cost (stakeholder load does not shrink with scope). Bounded productized SKUs (short docs, half-day assessments) may sit under that floor if listed as `cost_floor.exceptions`.

Government / CMAS: discounts cannot violate the published catalog or most-favored rules. Prefer packaging (basic vs customized) over ad-hoc cuts.

## 6. Package design

3–7 named offerings. Each has:

- Outcome in one sentence
- Includes / excludes (excludes prevent scope creep)
- `from_price` public anchor
- Optional Good / Better / Best tiers (three, not five)
- Duration or effort hint (weeks, not fake-precise hours on the public page)

Name the package after the result, not the labor category.

Public web: **From $X**. Full quote lives in the SOW. Hourly ladder stays off the website unless `publish.show_hourly` is true.

## 7. Terms

Decide once; copy into YAML `terms`:

- Deposit (fixed-price)
- Net terms
- Late fee
- Travel / expenses
- Retainer rollover (default: unused hours do not roll)
- Change-order trigger
- Emergency definition (outside business hours, critical incident)

## Anti-patterns

- Reverse-engineering hours from a start price (“$50k ÷ $300/hr = 167 hours”) and calling it rationale
- Wide hourly ranges ($125–$250) as the hero of the card — they invite negotiation to the bottom
- Conflicting tabs left unresolved
- Mixing a training/CMAS catalog with an AI/data consulting catalog
- Publishing “starts at” without includes/excludes
- Placeholder copy (`[Your LLC Name]`, emoji checkmarks) in client artifacts
