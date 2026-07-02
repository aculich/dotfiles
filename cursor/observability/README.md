# Observability

- **`perf/`** — process logs, status captures, and ad-hoc diagnostics (formerly top-level `cursor-perf/`).
- **`inventories/`** — JSON output from [scripts/cursor-home-inventory.sh](../scripts/cursor-home-inventory.sh). Files are **gitignored** by default; add a baseline with `git add -f observability/inventories/<file>.json`.

See [docs/cursor-home-and-plans.md](../docs/cursor-home-and-plans.md).

## Performance snapshot and report

Run while Cursor is open (ideally when you want to diagnose idle CPU/RAM):

```bash
cd ~/dotfiles/cursor
./scripts/cursor-perf-report.sh
```

This writes a timestamped directory under **`observability/perf/run-<UTC-ts>/`** containing:

| File | Purpose |
|------|---------|
| `cursor-status.log` | Full output of `cursor -s` (process tree, workspace stats) |
| `cursor-status.err` | stderr from `cursor -s` (usually empty) |
| `ps-top.txt` | Top Cursor-related processes from `ps` |
| `report.md` | Parsed summary: top CPU/RAM, counts, duplicate MCP/LSP, action hints |

Optional Process Explorer history (JSONL export):

```bash
./scripts/cursor-perf-report.sh --jsonl observability/perf/cursor-process-history-2026-04-12T19-11-52-740Z.jsonl
```

Re-summarize an existing capture without re-running `cursor -s`:

```bash
./scripts/cursor-perf-report.sh --no-capture observability/perf/run-2026-04-12T12-00-00Z
```

### Compare two runs

```bash
diff -u observability/perf/run-OLD/report.md observability/perf/run-NEW/report.md
diff -u observability/perf/cursor-status-2.log observability/perf/run-NEW/cursor-status.log
```

### Prior manual captures (reference)

Committed examples from earlier investigation:

- [perf/cursor-status.log](perf/cursor-status.log), [perf/cursor-status-2.log](perf/cursor-status-2.log) — `cursor -s` snapshots
- [perf/cursor-process-history-*.jsonl](perf/) — Process Explorer time series
- [perf/console-logs-chrome.js](perf/console-logs-chrome.js) — DevTools console (PluginsProviderService, OTLP errors)
- [perf/extension-host-logging.log](perf/extension-host-logging.log) — extension host attach (mostly source-map noise)

### Squelch after diagnosis

1. **User settings** — [settings.json](../settings.json) includes global `files.watcherExclude` and `search.exclude` (see [docs/IGNORING.md](../docs/IGNORING.md)).
2. **Per-repo** — `.cursorignore`, `.cursorindexingignore`, `.vscode/settings.json` for large trees.
3. **Extensions / MCP** — [scripts/apply-cursor-resource-tuning.sh](../scripts/apply-cursor-resource-tuning.sh) (`snapshot` then `apply`; restart Cursor).
