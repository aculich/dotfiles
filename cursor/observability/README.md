# Observability

- **`perf/`** — process logs, status captures, and ad-hoc diagnostics (moved from top-level `cursor-perf/`).
- **`inventories/`** — JSON output from [scripts/cursor-home-inventory.sh](../scripts/cursor-home-inventory.sh). Files are **gitignored** by default; add a baseline with `git add -f observability/inventories/<file>.json`.

See [docs/cursor-home-and-plans.md](../docs/cursor-home-and-plans.md).
