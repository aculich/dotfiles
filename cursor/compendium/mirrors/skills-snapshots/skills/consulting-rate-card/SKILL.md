---
name: consulting-rate-card
description: >-
  Builds a consulting rate card from a cost/market/value rationale, a YAML
  catalog, and rendered views (client 1-pager HTML/PDF, Marp deck HTML/PPTX,
  website services stub). Use when the user asks for a rate card, consulting
  rates, pricing rationale, services offered, package pricing, retainer vs
  hourly vs project fees, or to publish services with or without visible rates.
---

# Consulting rate card

Walk a practitioner from **why these numbers** to a **YAML source of truth** to **shareable views**. Never mix the three layers.

| Layer | Audience | Contains |
|-------|----------|----------|
| Rationale | Internal only | Cost floor, market band, value ceiling, sector tiers, discount stack, never-below rules |
| Catalog | Source of truth | `rate-card.yaml` — offerings, packages, models, terms, publish flags |
| Views | Client / web / deck | Filtered projections (rates on/off, hourly on/off) |

Default public web view: **package “from $X” anchors, hide the hourly ladder.** Client PDF/deck may include full rates.

## When to use

- New rate card, or a messy existing one (conflicting tabs, hourly-first, reverse-engineered “rationale”)
- Multi-brand orgs that need one framework and separate catalogs
- 1-pager, agency deck, or website “services offered” stub from the same numbers

## Workflow

Copy this checklist and track it:

```
- [ ] Phase 1 — Intake + rationale worksheet
- [ ] Phase 2 — Write rate-card.yaml
- [ ] Phase 3 — Critique numbers
- [ ] Phase 4 — Render views
- [ ] Phase 5 — Hand off (do not treat Google Docs as canonical after YAML exists)
```

Read [reference/rationale-framework.md](reference/rationale-framework.md) before inventing prices. Read [reference/schema.md](reference/schema.md) before writing YAML.

### Phase 1 — Intake + rationale

Interview the user (do not skip to a rate table). Fill [templates/rationale.md](templates/rationale.md) using the 7 steps in the framework:

1. Cost floor
2. Market band (use evidence; do not invent comps)
3. Value ceiling
4. Engagement-model mix (productized/project first; T&M for discovery; emergency premium separate)
5. Sector + discount stack + explicit floors
6. Package design (3–7 named offerings, fixed scope boundaries)
7. Terms

Save as `{brand}/rationale.md` next to the YAML. Internal only.

### Phase 2 — Catalog

Copy [templates/rate-card.example.yaml](templates/rate-card.example.yaml) to `{brand}/rate-card.yaml`. One file per brand. Do not mix brands in one catalog.

Reconcile conflicts (duplicate tabs, $50k vs $25k, Net 15 vs Net 30) **in YAML**, with a short note in rationale — not by averaging silently.

### Phase 3 — Critique

Run the renderer (it prints a critique report). Fix before sharing:

- No conflicting `from_price` for the same offering
- Public from-price ≥ cost floor; not above a stated value ceiling without a note
- Procurement catalogs (e.g. CMAS) stay at or below the bound named in `compliance`
- Discount stack is documented; sticker is not a silent pre-discount
- Nonprofit/gov paths do not undercut `cost_floor.new_client_project_floor` except for bounded productized SKUs listed in `cost_floor.exceptions`

### Phase 4 — Render

From the skill directory, or with an absolute path to the script:

```bash
python3 ~/.cursor/skills/consulting-rate-card/scripts/render_rate_card.py \
  path/to/rate-card.yaml \
  --out path/to/out
```

If a sibling `rationale.md` exists, it is copied into `out/`. Emits:

| File | Use |
|------|-----|
| `rationale.md` | Internal |
| `critique.md` | Internal consistency report |
| `rate-card-full.md` | Client-shareable full card (hourly on) |
| `one-pager.html` / `one-pager.pdf` | Client 1-pager |
| `deck.md` / `deck.html` / `deck.pptx` | Short agency presentation |
| `services-stub.md` / `services-stub.html` | Website services section |

PDF via WeasyPrint, or Chrome headless if WeasyPrint’s native libs are missing. Deck HTML/PPTX via Marp CLI (`fnm` Node 22 + `npx @marp-team/marp-cli` preferred; Homebrew `marp` on Node 26 is known-broken). Pandoc PPTX is the last fallback.

### Phase 5 — Hand off

YAML is canonical. Optionally export a cleaned Google Doc from `rate-card-full.md`. Do not keep editing the old conflicting doc.

Website publish is a **stub** (paste into CMS / static site). Do not deploy live unless the user asks.

## Anti-patterns

- Hourly-first cards (ranges invite haggling; undervalue packaged work)
- Reverse-engineering hours from a start price and calling it rationale
- Mixing brands or procurement regimes in one file
- Publishing the hourly ladder on the public services page (unless `publish.show_hourly: true`)
- Inventing rates for a brand with no offerings yet — stub names only
- Emoji, “Why work with us” filler, or placeholder `[Your LLC Name]` in client views

## Multi-brand

One rationale **framework**, separate YAML files. Example layout in a project repo:

```
rate-cards/
  aallc/rate-card.yaml
  peeq/rate-card.yaml
  codesculpting/rate-card.yaml   # stub until offerings exist
```

## Utility script

**render_rate_card.py** — validate YAML, critique, render all views. Execute it; do not reimplement in the conversation.
