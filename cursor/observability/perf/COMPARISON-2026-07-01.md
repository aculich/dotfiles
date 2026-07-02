# Comparison: 2026-07-01 live capture vs prior baseline

**New run:** [run-2026-07-01T21-16-48Z](run-2026-07-01T21-16-48Z/report.md)  
**Prior baseline:** [cursor-status-2.log](cursor-status-2.log) (summarized to `/tmp/report-baseline.md` for counts)

## Summary

| Metric | cursor-status-2 (Apr) | run-2026-07-01 (now) |
|--------|----------------------:|---------------------:|
| Free RAM | 1.57 GB | 4.81 GB |
| Load (1/5/15m) | 17 / 19 / 21 | 70 / 119 / 208 |
| Renderer windows | 17 | **33** |
| extensionHost | 81 | 72 |
| fileWatcher | 17 | **33** |
| Cursor version | 3.2.0-pre.6 | 3.9.21 |

## Interpretation

- **Window count doubled** (17 → 33): primary driver of renderer RAM (~983MB–1278MB per hot window) and GPU compositing load.
- **Load averages much higher** despite more free RAM in this snapshot — system still under stress (swap cumulative ~121GB pages in vm_stat).
- **Duplicate MCP/LSP counts are low in this capture** (snyk/repomix/zoom at 0) — resource tuning or fewer per-host MCP children may already be in effect vs April console logs.
- **18 workspace folders** exceed 50k+ files (continuous-ai 109k+). Global `files.watcherExclude` in settings.json helps new sessions; per-repo `.cursorindexingignore` still needed.

## Recommended next steps

1. Restart Cursor after settings.json watcher excludes take effect.
2. Close unused windows (target &lt; 12 renderers).
3. Run `./scripts/apply-cursor-resource-tuning.sh apply` after reviewing [config/resource-tuning.manifest.json](../../config/resource-tuning.manifest.json) — snapshot taken 2026-07-01 via `apply-cursor-resource-tuning.sh snapshot`.
4. Re-run `./scripts/cursor-perf-report.sh` and diff `report.md`.
