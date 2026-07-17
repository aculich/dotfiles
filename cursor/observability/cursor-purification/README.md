# Cursor purification

Track and re-apply the three-layer ignore treatment that keeps Cursor extension hosts and file watchers off huge clones, archives, venvs, and backups.

## Why

`.gitignore` alone does **not** stop Cursor's file watcher or TypeScript language server. Without `.cursorindexingignore` and `files.watcherExclude`, extension hosts still scan git-ignored trees (see [docs/IGNORING.md](../../docs/IGNORING.md)).

## Manifest

[`MANIFEST.json`](MANIFEST.json) is the ledger of every workspace that received purification.

| Field | Meaning |
|-------|---------|
| `runs[]` | Each scan/apply invocation (timestamp, mode, workspaces touched) |
| `workspaces.<name>` | Latest state: path, files touched, heavy dirs excluded, file count, notes |

## Run

```bash
cd ~/dotfiles/cursor

# Dry-run: list open windows, resolve paths, propose excludes
./scripts/cursor-purification.sh --scan

# Apply merges + update this manifest
./scripts/cursor-purification.sh --apply

# One workspace
./scripts/cursor-purification.sh --apply --workspace rrid

# Reuse an existing cursor -s capture
./scripts/cursor-purification.sh --scan --status-log observability/perf/run-.../cursor-status.log
```

Path overrides (repos not under `~/projects/`): [`scripts/lib/cursor-purification-paths.json`](../../scripts/lib/cursor-purification-paths.json).

## After apply

Reload each affected Cursor window: **Cmd+Shift+P → Developer: Reload Window**.

Watcher and tsserver settings do not take effect until reload.

## Skill

Personal skill: `~/.cursor/skills/cursor-purification/SKILL.md` (invoke with `/cursor-purification` or ask to purify workspaces).

## Verification note (2026-07-17)

| Metric | Before (run-2026-07-16T17-52-03Z) | After apply (run-2026-07-17T05-30-18Z) |
|--------|-----------------------------------|----------------------------------------|
| Free RAM | 0.63 GB | 30.64 GB (machine quieter / windows changed) |
| Swap used | ~12.7 GB | ~15.9 GB (still elevated) |
| extensionHost count | 18 | 26 (more windows open) |
| continuous-ai file count | >109803 | >109805 (index count until reload) |

Purification edits are on disk for **24** workspaces in `MANIFEST.json`. **Reload Window** is required before watcher/tsserver memory drops. Closing unused windows remains the largest immediate win when extensionHost count is high.
