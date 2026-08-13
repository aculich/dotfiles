# consulting-rate-card examples

## New card from scratch

1. Copy `templates/rate-card.example.yaml` to `rate-cards/{brand}/rate-card.yaml`.
2. Walk [reference/rationale-framework.md](reference/rationale-framework.md) and fill `rationale.md`.
3. Render:

```bash
python3 ~/.cursor/skills/consulting-rate-card/scripts/render_rate_card.py \
  rate-cards/{brand}/rate-card.yaml
```

## Existing messy Google Doc

Do not treat the Doc as canonical. Extract offerings, hourly rows, and terms into YAML. Log conflicts in the rationale reconciliation table. Pick one number per field.

## Multi-brand

Separate YAML files. PEEQ-style training catalogs carry `compliance.regime: cmas` (or `gsa`) and must not exceed the named bound. A consulting brand does not inherit those SKUs.

## Stub brand (no rates yet)

Offerings with names and summaries only. Omit `pricing.from_price`. Set `publish.show_from_prices: false`. Renderer still emits a services stub without dollar amounts.
