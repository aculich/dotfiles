#!/usr/bin/env bash
# Timestamped snapshot of Cursor config before/after tuning changes.
#
# Usage:
#   snapshot-cursor-config.sh              # writes snapshots/config-YYYY-MM-DD_HH-MM-SS/
#   snapshot-cursor-config.sh /path/to/dir # custom output directory

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CURSOR="$(cd "$SCRIPT_DIR/.." && pwd)"
TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
OUT="${1:-$REPO_CURSOR/snapshots/config-$TIMESTAMP}"

CURSOR_DIR="${CURSOR_DIR:-$HOME/.cursor}"
USER_DATA="${CURSOR_USER_DATA:-$HOME/Library/Application Support/Cursor/User}"
STATE_DB="$USER_DATA/globalStorage/state.vscdb"

mkdir -p "$OUT"

printf '%s\n' "$TIMESTAMP" >"$OUT/SNAPSHOT_TIMESTAMP.txt"
printf '%s\n' "$OUT" >"$OUT/SNAPSHOT_PATH.txt"

copy_if() {
  if [[ -f "$1" ]]; then
    cp -p "$1" "$2"
  fi
}

# MCP
copy_if "$CURSOR_DIR/mcp.json" "$OUT/mcp.json"
copy_if "$CURSOR_DIR/mcp.servers.stash.json" "$OUT/mcp.servers.stash.json"
copy_if "$CURSOR_DIR/.mcp-servers-disabled" "$OUT/mcp-servers-disabled.marker"

# User settings (resolve symlink)
if [[ -f "$USER_DATA/settings.json" ]]; then
  cp -Lp "$USER_DATA/settings.json" "$OUT/settings.json.live"
fi
copy_if "$REPO_CURSOR/settings.json" "$OUT/settings.json.dotfiles"

# Extensions (see also: scripts/manage-extensions.sh snapshot for SUMMARY.md + restore)
if command -v cursor >/dev/null 2>&1; then
  cursor --list-extensions --show-versions >"$OUT/extensions-installed.txt" 2>/dev/null || true
  cursor --list-extensions >"$OUT/extensions-installed-ids.txt" 2>/dev/null || true
fi

if [[ -f "$STATE_DB" ]] && command -v sqlite3 >/dev/null 2>&1; then
  sqlite3 "$STATE_DB" "SELECT value FROM ItemTable WHERE key='extensionsIdentifiers/disabled';" \
    >"$OUT/extensions-disabled.json" 2>/dev/null || true

  sqlite3 "$STATE_DB" "SELECT key, value FROM ItemTable WHERE key LIKE 'cursor.plugins.installedIds.%';" \
    >"$OUT/cursor-plugins-installed.raw.txt" 2>/dev/null || true
fi

# Plugin MCP inventory
find "$HOME/.cursor/projects" -path '*/mcps/plugin-*' -maxdepth 3 -type d 2>/dev/null \
  | sed 's|.*/mcps/||' | sort -u >"$OUT/plugin-mcp-server-ids.txt" || true

# Per-workspace disabled MCP (sample all workspaces)
{
  echo '{'
  first=1
  for db in "$USER_DATA/workspaceStorage"/*/state.vscdb; do
    [[ -f "$db" ]] || continue
    ws="$(basename "$(dirname "$db")")"
    val="$(sqlite3 "$db" "SELECT value FROM ItemTable WHERE key='cursor/disabledMcpServers';" 2>/dev/null || true)"
    [[ -n "$val" ]] || continue
    if [[ "$first" -eq 1 ]]; then first=0; else echo ','; fi
    printf '  "%s": %s' "$ws" "$val"
  done
  echo ''
  echo '}'
} >"$OUT/workspace-disabled-mcp-servers.json" 2>/dev/null || true

# Process sample (optional, non-fatal)
ps -axo rss,command 2>/dev/null | grep -i '[Cc]ursor' | grep -v grep \
  | awk '{rss+=$2;n++} END {printf "processes=%d rss_mb=%.0f\n", n+0, rss/1024}' \
  >"$OUT/cursor-process-summary.txt" 2>/dev/null || true

cat >"$OUT/README.txt" <<EOF
Cursor config snapshot: $TIMESTAMP

Restore helpers:
  $REPO_CURSOR/scripts/apply-cursor-resource-tuning.sh restore $OUT

Contents:
  mcp.json, mcp.servers.stash.json, settings, extension lists,
  extensions-disabled.json, plugin MCP ids, per-workspace disabled MCP map.

Extension-only snapshot (readable SUMMARY + restore):
  $REPO_CURSOR/scripts/manage-extensions.sh snapshot
EOF

echo "Snapshot written to: $OUT" >&2
echo "$OUT"
