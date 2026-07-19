---
name: cursor-purification
description: Scans open Cursor workspaces, applies .cursorindexingignore plus files.watcherExclude/search.exclude (and optional .cursorignore for multi-GB dirs), and updates the purification manifest. Use when Cursor is slow, extension hosts use high CPU/RAM, swap pressure is high, or the user asks to purify workspaces, ignore junk from indexing, or re-run cursor-purification.
disable-model-invocation: true
---

# Cursor purification

Keep Cursor extension hosts and file watchers off huge clones, archives, backups, venvs, and other low-value trees. `.gitignore` alone does **not** stop the watcher or TypeScript server.

## Paths (this machine)

| Role | Path |
|------|------|
| Scripts | `~/dotfiles/cursor/scripts/cursor-purification.sh` |
| Logic | `~/dotfiles/cursor/scripts/lib/purify-workspace.py` |
| Path overrides | `~/dotfiles/cursor/scripts/lib/cursor-purification-paths.json` |
| Manifest | `~/dotfiles/cursor/observability/cursor-purification/MANIFEST.json` |
| Runbook | `~/dotfiles/cursor/observability/cursor-purification/README.md` |
| Ignore layers | `~/dotfiles/cursor/docs/IGNORING.md` |
| Perf capture | `~/dotfiles/cursor/scripts/cursor-perf-report.sh` |

## Workflow

Copy and track:

```
Purification:
- [ ] 1. Capture (optional) cursor-perf-report.sh
- [ ] 2. Scan: cursor-purification.sh --scan
- [ ] 3. Review proposed heavy_dirs / extreme dirs
- [ ] 4. Apply: cursor-purification.sh --apply
- [ ] 5. Confirm MANIFEST.json updated
- [ ] 6. Tell user: Reload Window on affected workspaces
```

### 1. Capture (optional but useful)

```bash
cd ~/dotfiles/cursor
./scripts/cursor-perf-report.sh
```

Note extension-host memory and “Large workspace folders” in `observability/perf/run-*/report.md`.

### 2. Scan (dry-run)

```bash
cd ~/dotfiles/cursor
./scripts/cursor-purification.sh --scan
# or reuse a capture:
./scripts/cursor-purification.sh --scan --status-log observability/perf/run-.../cursor-status.log
# single workspace:
./scripts/cursor-purification.sh --scan --workspace rrid
```

Review output: resolved paths, `heavy_dirs`, `extreme (>5G → .cursorignore)`, skips.

### 3. Apply

Only after scan looks right (or user said apply in the same request):

```bash
./scripts/cursor-purification.sh --apply
# or --apply --workspace NAME
```

Idempotent: merges tagged `# cursor-purification` blocks; does not wipe existing ignore rules.

### 4. Manifest

Confirm `observability/cursor-purification/MANIFEST.json` lists each workspace with `last_applied`, `files_touched`, `excludes_added`.

### 5. User action (required)

Tell the user to reload each affected window:

**Cmd+Shift+P → Developer: Reload Window**

Watcher and tsserver settings do not apply until reload. Closing unused Cursor windows remains the fastest structural win when many extension hosts are open.

## What gets applied per workspace

1. **`.cursorindexingignore`** — tagged block: universal junk + heavy dirs (≥100 MB only if known_heavy, junk-named, or gitignored).
2. **`.vscode/settings.json`** — merge `files.watcherExclude` + `search.exclude`; TS quieting when `package.json` or >500 JS/TS files.
3. **`.cursorignore`** — only for extreme dirs ≥5 GB that also qualify as heavy (optional AI context block).

Never delete existing ignore lines. Prefer merge. Do **not** commit foreign repos unless the user asks.

## Path overrides

Repos not under `~/projects/<name>` live in `scripts/lib/cursor-purification-paths.json` (`overrides`, `skip`, `known_heavy`). Add a new override when a workspace resolves as “path not found”.

## Safety

- Do not exclude active project folders solely because they are large; only known_heavy, junk names (`upstream`, `archive`, `venv`, `*_isos`, backups, …), or top-level gitignored dirs.
- Skip list includes tiny non-roots (e.g. `workspaces`).
- Prefer `--scan` before `--apply` on unfamiliar trees.
- Local edits only; `.vscode/` is often gitignored — that is fine.

## Related

- After diagnosis: [scripts/apply-cursor-resource-tuning.sh](file:///Users/me/dotfiles/cursor/scripts/apply-cursor-resource-tuning.sh) for heavy extensions/MCP.
- Layer theory: [docs/IGNORING.md](file:///Users/me/dotfiles/cursor/docs/IGNORING.md).
