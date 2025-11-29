# Cursor Workspace Snapshot Tools

A comprehensive set of tools to capture and analyze your Cursor editor workspace state.

## Overview

These scripts help you:
- **Snapshot** all open windows, files, folders, and extensions
- **Track** workspace history over time
- **Compare** snapshots to see what changed
- **Restore** context by reviewing past workspace states

## Quick Start

```bash
# Create a snapshot
./dump-cursor-windows.sh

# View available snapshots
./view-cursor-snapshots.sh list

# View windows from latest snapshot
./view-cursor-snapshots.sh windows latest
```

## Installation

```bash
# Optional but recommended for better output
brew install jq
```

## Tools

### `dump-cursor-windows.sh`

Creates a timestamped snapshot of your Cursor workspace.

**Creates 3 files:**
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
diff cursor-workspace-2025-10-01_*-extensions.txt \
     cursor-workspace-2025-10-29_*-extensions.txt
```

## Advanced Usage

### Filtering with jq

```bash
# Get all workspaces
jq -r '.windows[].workspace' cursor-workspace-*.json | sort -u

# Count windows per workspace
jq -r '.windows[] | .workspace' cursor-workspace-*.json | \
  sort | uniq -c | sort -rn

# Find all markdown files
jq -r '.recent_files[] | select(endswith(".md"))' cursor-workspace-*.json

# Get workspaces with most files
jq -r '.workspace_stats | to_entries[] | 
  "\(.key): \(.value)"' cursor-workspace-*.json | \
  grep -o '[0-9]* files' | sort -rn
```

### Automated Backups

```bash
# Archive old snapshots
mkdir -p archives/$(date +%Y-%m)
mv cursor-workspace-*.{txt,json} archives/$(date +%Y-%m)/
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

## File Locations

All snapshots are stored in the same directory as the scripts:
- Default: `~/dotfiles/cursor/`
- Customize by editing `output_dir` in `dump-cursor-windows.sh`
