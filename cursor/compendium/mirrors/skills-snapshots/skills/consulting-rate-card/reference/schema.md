# rate-card.yaml schema

One file per brand. `schema_version: 1`.

## Required

| Field | Notes |
|-------|--------|
| `schema_version` | Integer `1` |
| `brand.id` | Lowercase slug (`aallc`, `peeq`) |
| `brand.name` | Legal or trading name |
| `brand.entity` | Contracting entity |
| `brand.tagline` | One line; used on 1-pager and deck |
| `brand.website` / `brand.email` | Contact |
| `effective_date` | ISO date |
| `who_we_help` | One or two sentences |
| `problems` | List of short problem statements (deck slide 2) |
| `engagement_models` | List of `{id, name, summary}` — `project`, `retainer`, `tm`, `hybrid` |
| `offerings` | List (may be empty only for an explicit stub brand) |
| `terms` | Deposit, net, late fee, travel, rollover |
| `publish.show_from_prices` | Web stub shows From $X when true |
| `publish.show_hourly` | Web stub shows hourly ladder when true (default false) |
| `publish.show_hourly_client` | Full card / 1-pager / deck appendix |

## `brand` extras

```yaml
brand:
  id: aallc
  name: Asemic Arche LLC
  short_name: AALLC
  tagline: AI and data systems consulting
  entity: Asemic Arche LLC
  website: https://asemicarche.com
  email: aaron@asemicarche.com
  voice: Direct, technical, outcome-first. No emoji.
  colors:
    ink: "#1c1917"
    paper: "#eef2f1"
    accent: "#0f766e"
    muted: "#57534e"
  fonts:
    display: "Fraunces"
    body: "Figtree"
```

## `offerings[]`

```yaml
- id: cloud-review
  name: Cloud architecture and security review
  category: infrastructure
  summary: Time-boxed review with a written findings memo and prioritized fixes.
  outcomes:
    - Named risks ranked by severity
    - 90-day remediation sequence
  includes:
    - Architecture interview and diagram review
    - Written memo
  excludes:
    - Implementation of remediations
    - 24/7 on-call
  duration: 3–5 weeks
  pricing:
    model: project          # project | retainer | tm | package | hourly
    from_price: 25000
    currency: USD
    tiers:                  # optional Good/Better/Best
      - name: Core
        price: 25000
        note: Review and memo
  sector_overrides:         # optional
    - sector: nonprofit
      from_price: 20000
  public: true              # false = omit from web stub
```

`from_price` is the public anchor. Omit it for stub offerings with no rates yet.

## `hourly_ladder[]` / `retainers[]`

Internal + client-full views. Omitted from the web stub when `publish.show_hourly` is false.

```yaml
hourly_ladder:
  - id: strategic
    name: Strategic consulting
    rate_low: 300
    rate_high: 450
    unit: hour
    description: High-impact AI/ML and informatics.
    public_client: true

retainers:
  - id: standard
    name: Standard retainer
    min_hours_month: 10
    rate: 275
    notes: Priority scheduling. Unused hours do not roll over.
```

## `cost_floor` / `discount_policy` / `compliance`

Used by critique and internal rationale; not printed on the public stub.

```yaml
cost_floor:
  min_hourly: 200
  new_client_project_floor: 20000
  exceptions:
    - tech-docs
  notes: Setup and stakeholder cost on new-client work.

discount_policy:
  stack:
    - partner
    - first_engagement
    - mission
    - reusability
  notes: Start from sticker. Name every cut.

sector_tiers:
  - id: corporate
    label: Corporate
    hourly_sticker: 350
  - id: nonprofit
    label: Nonprofit / research
    hourly_sticker: 200

compliance:
  regime: none            # none | cmas | gsa | other
  notes: ""
```

## `terms`

```yaml
terms:
  net_days: 15
  late_fee_pct: 5
  late_fee_after_days: 30
  deposit_pct_fixed_price: 50
  travel: Billed separately at cost for on-site work.
  retainer_rollover: Unused hours do not roll over unless the SOW says otherwise.
  change_orders: Work outside includes[] is a written change order.
```

## Views (renderer)

| Flag | Web stub | Client 1-pager | Full markdown | Deck body | Deck appendix |
|------|----------|----------------|---------------|-----------|---------------|
| `show_from_prices` | From $X | From $X | yes | From $X | full table |
| `show_hourly` | ladder | no | no | no | no |
| `show_hourly_client` | no | optional compact | yes | no | yes |

Stub brands: `offerings` may lack `pricing.from_price`. Renderer still emits a services stub without dollar amounts.
