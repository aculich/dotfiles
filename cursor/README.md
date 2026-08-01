# Cursor Workspace Snapshot Tools

A comprehensive set of tools to capture and analyze your Cursor editor workspace state.

## Overview

These scripts help you:

- **Snapshot** all open windows, files, folders, and extensions
- **Track** workspace history over time
- **Compare** snapshots to see what changed
- **Restore** context by reviewing past workspace states

## Compendium (Cursor plans, mirrors, skills registry)

For a **sibling private git repo** that backs up global `~/.cursor/plans`, per-project `.cursor/` / `.specstory/` (selective), and tracks **vendor vs authored** skills, see **[docs/COMPENDIUM.md](docs/COMPENDIUM.md)** (live path, `gh` remote, env var, launchd). The scaffold under [`compendium/`](compendium/README.md) matches that layout. Personal Cursor skill: **`bootstrap-tool-config-repo`** in `~/.cursor/skills/bootstrap-tool-config-repo/`.

**Ops status:** agent context lives in [`.context/`](.context/); CLI health is `just status` or DWIM `just doit` (status + resource forensics snapshot); interactive dashboard is the Cursor canvas `cursor-ops-status` (path in `.context/conventions.md`).

## Internals corpus & tool landscape

Version-pinned architecture and tooling research (Cursor **3.13.25** / Nightly):

- **[docs/cursor-architecture.md](docs/cursor-architecture.md)** — top-down mental model
- **[docs/cursor-storage-map.md](docs/cursor-storage-map.md)** — on-disk / SQLite / plans / canvases
- **[docs/cursor-settings-guide.md](docs/cursor-settings-guide.md)** — annotated settings (screenshots in `docs/assets/`)
- **[docs/cursor-canvases.md](docs/cursor-canvases.md)** — managed canvas paths + VCS patterns
- **[docs/cursor-tools-superprd.md](docs/cursor-tools-superprd.md)** — cross-tool SuperPRD matrices
- **[docs/cursor-tools-ontology.md](docs/cursor-tools-ontology.md)** — awesome-list provenance + tiers
- Per-tool clusters: **[docs/tools/](docs/tools/)** · research dumps: **[docs/research/](docs/research/)**

## Quick Start

```bash
# Create a snapshot
./dump-cursor-windows.sh

# View available snapshots
./view-cursor-snapshots.sh list

# View windows from latest snapshot
./view-cursor-snapshots.sh windows latest
```

## Resource tuning (RAM / MCP / LSP)

After auditing many restored windows, use the config snapshot + apply/restore helpers:

```bash
# Snapshot only (timestamped dir under snapshots/)
./scripts/snapshot-cursor-config.sh

# Snapshot, then disable heavy extensions + plugin MCP + tweak settings
./scripts/apply-cursor-resource-tuning.sh apply

# Roll back from a snapshot dir (see snapshots/config-*/README.txt)
./scripts/apply-cursor-resource-tuning.sh restore /path/to/snapshots/config-YYYY-MM-DD_HH-MM-SS

# Global user MCP (~/.cursor/mcp.json) — separate toggle
./scripts/toggle-global-mcp.sh status|disable|enable
```

Manifest: `config/resource-tuning.manifest.json`. Last apply snapshot path: `config/last-resource-tuning-snapshot.txt`. **Restart Cursor** after apply or restore.

### Extensions (snapshot / disable most / restore)

```bash
# Snapshot installed + enabled/disabled state (SUMMARY.md for humans)
./scripts/manage-extensions.sh snapshot

# See counts and path to last snapshot
./scripts/manage-extensions.sh status

# Full lists (what is on vs off right now)
./scripts/manage-extensions.sh list

# What stays enabled on apply (edit config/extensions-keep.manifest.json first)
./scripts/manage-extensions.sh keep

# Preview what apply would disable
./scripts/manage-extensions.sh apply --dry-run

# Snapshot, then disable every installed extension except keepEnabled
./scripts/manage-extensions.sh apply

# Put enable/disable back exactly as at snapshot time
./scripts/manage-extensions.sh restore
./scripts/manage-extensions.sh restore snapshots/extensions-YYYY-MM-DD_HH-MM-SS

# One extension: cursor --enable-extension <publisher.name>
```

Latest snapshot symlink: `snapshots/extensions-latest` (after `apply`, points at the **pre-apply** dir for restore).  
Keep list: `config/extensions-keep.manifest.json` (`keepEnabled` vs `optionalKeep`).

## Installation

```bash
# Optional but recommended for better output
brew install jq
```

## Tools

### `dump-cursor-windows.sh`

Creates a timestamped snapshot of your Cursor workspace.

**Creates 3 files** under `snapshots/workspace/` (or `SNAPSHOT_DIR` if set):
1. `cursor-workspace-YYYY-MM-DD_HH-MM-SS.txt` - Full `cursor --status` output
2. `cursor-workspace-YYYY-MM-DD_HH-MM-SS.json` - Structured data extract
3. `cursor-workspace-YYYY-MM-DD_HH-MM-SS-extensions.txt` - Installed extensions

**Captures:**
- All open windows with their current files
- Workspace folders and paths
- Recent files from menu
- Workspace file statistics (file types, counts)
- Workspace storage mappings
- Extension list with versions

**Usage:**
```bash
./dump-cursor-windows.sh
```

### `view-cursor-snapshots.sh`

Interactive tool to explore and compare snapshots.

**Commands:**

```bash
# List all snapshots
./view-cursor-snapshots.sh list

# View full snapshot data
./view-cursor-snapshots.sh view N

# List all open windows (showing current file + workspace)
./view-cursor-snapshots.sh windows N

# List tracked folders
./view-cursor-snapshots.sh folders N

# List recent files
./view-cursor-snapshots.sh recent N

# Show workspace statistics
./view-cursor-snapshots.sh stats N

# Compare two snapshots
./view-cursor-snapshots.sh diff N1 N2

# View latest snapshot
./view-cursor-snapshots.sh latest
```

## JSON Structure

The `.json` files contain:

```json
{
  "timestamp": "2025-10-29_17-48-12",
  "windows": [
    {
      "window_number": 1,
      "workspace": "traub-umpire-empire",
      "current_file": "officialspay_export_2025-09-29.json"
    }
  ],
  "folders": [
    "/Users/me/projects/traub-umpire-empire",
    "/Users/me/tools/markdown-slides"
  ],
  "recent_files": [
    "/Users/me/projects/dgx-spark/README.md"
  ],
  "workspace_stats": {
    "cursor": "22 files",
    "gcloud-default-1234": "17 files"
  },
  "workspace_files": {
    "cursor": {
      "path": "/Users/me/dotfiles/cursor",
      "storage_id": "ad8316de0edfff49cfd059d4dfd6caf2"
    }
  }
}
```

## Use Cases

### 1. Daily Snapshots
```bash
# Add to your daily routine (e.g., via crontab or Alfred workflow)
cd ~/dotfiles/cursor && ./dump-cursor-windows.sh
```

### 2. Before/After Comparisons
```bash
# Take snapshot before major refactoring
./dump-cursor-windows.sh

# Do your work...

# Take another snapshot
./dump-cursor-windows.sh

# Compare
./view-cursor-snapshots.sh diff 1 2
```

### 3. Context Recovery
```bash
# "What was I working on last Tuesday?"
./view-cursor-snapshots.sh windows 5
```

### 4. Extension Audits
```bash
# Track extension changes over time
cd snapshots/workspace
diff cursor-workspace-2025-10-01_*-extensions.txt \
     cursor-workspace-2025-10-29_*-extensions.txt
```

## Advanced Usage

### Filtering with jq

```bash
# Get all workspaces (from repo root: use snapshots/workspace/)
jq -r '.windows[].workspace' snapshots/workspace/cursor-workspace-*.json | sort -u

# Count windows per workspace
jq -r '.windows[] | .workspace' snapshots/workspace/cursor-workspace-*.json | \
  sort | uniq -c | sort -rn

# Find all markdown files
jq -r '.recent_files[] | select(endswith(".md"))' snapshots/workspace/cursor-workspace-*.json

# Get workspaces with most files
jq -r '.workspace_stats | to_entries[] | 
  "\(.key): \(.value)"' snapshots/workspace/cursor-workspace-*.json | \
  grep -o '[0-9]* files' | sort -rn
```

### Automated Backups

```bash
# Archive old snapshots
mkdir -p archives/$(date +%Y-%m)
mv snapshots/workspace/cursor-workspace-*.{txt,json} archives/$(date +%Y-%m)/
```

## Data Sources

The scripts extract data from:
1. `cursor --status` - Process info, windows, workspace stats
2. `~/Library/Application Support/Cursor/User/globalStorage/storage.json` - Folder list, recent files
3. `~/Library/Application Support/Cursor/User/workspaceStorage/*/workspace.json` - Workspace mappings
4. `cursor --list-extensions` - Extension inventory

## Tips

- Use `jq` for powerful JSON querying
- Snapshots are plain text - they compress well with `gzip`
- Compare `.json` files programmatically for automation
- The `.txt` files contain raw process information useful for debugging

## Troubleshooting

**"No snapshots found"**
- Run `./dump-cursor-windows.sh` first to create a snapshot

**"jq not installed"**
- Install with `brew install jq` for enhanced features
- Scripts work without jq but with limited functionality

**Empty or missing data**
- Ensure Cursor is running when taking snapshot
- Check that paths in script match your system

## File locations

- **Default output:** `~/dotfiles/cursor/snapshots/workspace/`
- **Override:** set `SNAPSHOT_DIR` when running `dump-cursor-windows.sh` or `view-cursor-snapshots.sh` (e.g. `SNAPSHOT_DIR=/path ./dump-cursor-windows.sh`).

**Related:** [docs/cursor-home-and-plans.md](docs/cursor-home-and-plans.md) (tracking `~/.cursor`, plan catalogs, observability).
