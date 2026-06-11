#!/usr/bin/env bash
# Apply or restore Cursor resource-tuning changes (extensions + plugin MCP + settings).
#
# Usage:
#   apply-cursor-resource-tuning.sh snapshot   # snapshot only
#   apply-cursor-resource-tuning.sh apply      # snapshot then apply
#   apply-cursor-resource-tuning.sh restore <snapshot-dir>
#   apply-cursor-resource-tuning.sh status
#
# Restart Cursor after apply or restore.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CURSOR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$REPO_CURSOR/config/resource-tuning.manifest.json"
USER_DATA="${CURSOR_USER_DATA:-$HOME/Library/Application Support/Cursor/User}"
STATE_DB="$USER_DATA/globalStorage/state.vscdb"
SETTINGS_LIVE="$USER_DATA/settings.json"
SETTINGS_DOTFILES="$REPO_CURSOR/settings.json"

# Extensions to disable globally (keep installed; re-enable per workspace when needed).
EXTENSIONS_TO_DISABLE=(
  streetsidesoftware.code-spell-checker
  bradlc.vscode-tailwindcss
  dbaeumer.vscode-eslint
  redhat.vscode-yaml
  anysphere.cursorpyright
  golang.go
  hashicorp.terraform
  run-at-scale.terraform-doc-snippets
  prisma.prisma
  docker.docker
  ms-azuretools.vscode-docker
  ms-azuretools.vscode-containers
  ms-kubernetes-tools.vscode-kubernetes-tools
  anthropic.claude-code
)

# Known plugin MCP server ids (unioned with discovered plugin-* folders on apply).
PLUGIN_MCP_EXTRA=(
  plugin-snyk-secure-development-Snyk
  plugin-cloudflare-cloudflare-bindings
  plugin-cloudflare-cloudflare-builds
  plugin-cloudflare-cloudflare-docs
  plugin-cloudflare-cloudflare-observability
  plugin-context7-plugin-context7
  plugin-compound-engineering-context7
  plugin-vercel-vercel
  plugin-stripe-stripe
  plugin-clerk-clerk
  plugin-figma-figma
  plugin-prisma-Prisma-Remote
  plugin-neon-postgres-neon
  plugin-linear-linear
  plugin-notion-workspace-notion
  plugin-slack-slack
  plugin-supabase-supabase
  plugin-hex-hex
  plugin-browserstack-browserstack
  plugin-deploy-on-aws-awsiac
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo -e "${RED}Required command not found: $1${NC}" >&2
    exit 1
  }
}

collect_plugin_mcp_ids() {
  local f
  if [[ -f "$MANIFEST" ]] && command -v jq >/dev/null 2>&1; then
    jq -r '.pluginMcpServerIds[]?' "$MANIFEST" 2>/dev/null || true
  fi
  printf '%s\n' "${PLUGIN_MCP_EXTRA[@]}"
  find "$HOME/.cursor/projects" -path '*/mcps/plugin-*' -maxdepth 3 -type d 2>/dev/null \
    | sed 's|.*/mcps/||' || true
}

cmd_snapshot() {
  "$SCRIPT_DIR/snapshot-cursor-config.sh" "$@"
}

disable_extensions() {
  need_cmd cursor
  local ext
  for ext in "${EXTENSIONS_TO_DISABLE[@]}"; do
    if cursor --list-extensions 2>/dev/null | grep -qx "$ext"; then
      if cursor --disable-extension "$ext" 2>/dev/null; then
        echo -e "  ${GREEN}disabled (cli)${NC} $ext"
      else
        echo -e "  ${YELLOW}skip/fail (cli)${NC} $ext"
      fi
    else
      echo -e "  ${BLUE}not installed${NC} $ext"
    fi
  done
}

# CLI disable does not always persist while Cursor is running; merge into global state DB.
disable_extensions_in_state_db() {
  need_cmd python3
  python3 - "$STATE_DB" "${EXTENSIONS_TO_DISABLE[@]}" <<'PY'
import json
import sqlite3
import sys
from pathlib import Path

db_path = Path(sys.argv[1])
ext_ids = sys.argv[2:]
ext_root = Path.home() / ".cursor/extensions"

def find_uuid(ext_id: str) -> str | None:
    for d in ext_root.glob(ext_id + "*"):
        pkg = d / "package.json"
        if pkg.is_file():
            data = json.loads(pkg.read_text())
            return data.get("__metadata", {}).get("id")
    return None

con = sqlite3.connect(db_path)
row = con.execute(
    "SELECT value FROM ItemTable WHERE key='extensionsIdentifiers/disabled'"
).fetchone()
existing = json.loads(row[0]) if row and row[0] else []
by_id = {x["id"]: x for x in existing}
added = []
for eid in ext_ids:
    if eid in by_id:
        continue
    uuid = find_uuid(eid)
    if not uuid:
        print(f"  warn: no uuid for {eid}")
        continue
    by_id[eid] = {"id": eid, "uuid": uuid}
    added.append(eid)
merged = list(by_id.values())
con.execute(
    "INSERT OR REPLACE INTO ItemTable (key, value) VALUES (?, ?)",
    ("extensionsIdentifiers/disabled", json.dumps(merged)),
)
con.commit()
con.close()
print(f"  state DB: {len(added)} newly disabled, {len(merged)} total")
PY
}

enable_extensions_from_snapshot() {
  need_cmd cursor
  local snap="$1"
  local list="$snap/extensions-disabled.json"
  [[ -f "$list" ]] || {
    echo -e "${RED}Missing $list${NC}" >&2
    exit 1
  }
  need_cmd jq
  local to_enable
  to_enable="$(jq -r '.[].id' "$list")"
  local ext
  while IFS= read -r ext; do
    [[ -n "$ext" ]] || continue
    if [[ " ${EXTENSIONS_TO_DISABLE[*]} " == *" $ext "* ]]; then
      if cursor --enable-extension "$ext" 2>/dev/null; then
        echo -e "  ${GREEN}enabled${NC} $ext"
      fi
    fi
  done <<<"$to_enable"
}

apply_plugin_mcp_disable() {
  need_cmd python3
  local tmp
  tmp="$(mktemp)"
  collect_plugin_mcp_ids | sort -u >"$tmp"
  python3 - "$USER_DATA/workspaceStorage" "$tmp" <<'PY'
import json
import sqlite3
import sys
from pathlib import Path

ws_root = Path(sys.argv[1])
plugin_ids = [ln.strip() for ln in Path(sys.argv[2]).read_text().splitlines() if ln.strip()]
count = 0
for db in ws_root.glob("*/state.vscdb"):
    con = sqlite3.connect(db)
    row = con.execute(
        "SELECT value FROM ItemTable WHERE key='cursor/disabledMcpServers'"
    ).fetchone()
    existing = json.loads(row[0]) if row and row[0] else []
    merged = sorted(set(existing) | set(plugin_ids))
    con.execute(
        "INSERT OR REPLACE INTO ItemTable (key, value) VALUES (?, ?)",
        ("cursor/disabledMcpServers", json.dumps(merged)),
    )
    con.commit()
    con.close()
    count += 1
print(count)
print(len(merged))
PY
  rm -f "$tmp"
  echo -e "${GREEN}Updated cursor/disabledMcpServers in all workspace state DBs${NC}"
}

restore_plugin_mcp_from_snapshot() {
  local snap="$1"
  local map="$snap/workspace-disabled-mcp-servers.json"
  [[ -f "$map" ]] || {
    echo -e "${YELLOW}No workspace-disabled-mcp-servers.json in snapshot; skipping MCP restore${NC}"
    return 0
  }
  need_cmd python3
  python3 - "$USER_DATA/workspaceStorage" "$map" <<'PY'
import json
import sqlite3
import sys
from pathlib import Path

ws_root = Path(sys.argv[1])
data = json.loads(Path(sys.argv[2]).read_text())
for ws, val in data.items():
    db = ws_root / ws / "state.vscdb"
    if not db.is_file():
        continue
    con = sqlite3.connect(db)
    con.execute(
        "INSERT OR REPLACE INTO ItemTable (key, value) VALUES (?, ?)",
        ("cursor/disabledMcpServers", json.dumps(val)),
    )
    con.commit()
    con.close()
    print(f"  restored workspace {ws}")
PY
}

apply_settings_tweaks() {
  local f="$SETTINGS_DOTFILES"
  [[ -f "$f" ]] || return 0
  if grep -q '"specstory.cloudSync.enabled": "always"' "$f" 2>/dev/null; then
    sed -i '' 's/"specstory.cloudSync.enabled": "always"/"specstory.cloudSync.enabled": "never"/' "$f"
  fi
  if grep -q 'vscode.markdown.preview.editor' "$f" 2>/dev/null; then
    python3 - "$f" <<'PY'
import re
import sys
from pathlib import Path

p = Path(sys.argv[1])
text = p.read_text()
text = re.sub(
    r'\n  "workbench\.editorAssociations": \{\n    "\*\.md": "vscode\.markdown\.preview\.editor"\n  \},?\n',
    '\n',
    text,
    count=1,
)
p.write_text(text)
PY
  fi
  echo -e "${GREEN}Updated $f${NC} (removed md preview default; specstory cloudSync never)"
  if [[ -L "$SETTINGS_LIVE" || -f "$SETTINGS_LIVE" ]]; then
    echo "  Live settings follow dotfiles symlink."
  fi
}

restore_settings_from_snapshot() {
  local snap="$1"
  if [[ -f "$snap/settings.json.dotfiles" ]]; then
    cp -p "$snap/settings.json.dotfiles" "$SETTINGS_DOTFILES"
    echo -e "${GREEN}Restored settings.json from snapshot${NC}"
  fi
}

restore_extensions_full() {
  local snap="$1"
  need_cmd cursor
  need_cmd jq
  local before="$snap/extensions-disabled.json"
  [[ -f "$before" ]] || return 0
  local enabled now
  enabled="$(cursor --list-extensions 2>/dev/null | sort -u || true)"
  local disabled_ids
  disabled_ids="$(jq -r '.[].id' "$before" | sort -u)"
  local ext
  while IFS= read -r ext; do
    [[ -n "$ext" ]] || continue
    if ! grep -qx "$ext" <<<"$disabled_ids"; then
      if cursor --enable-extension "$ext" 2>/dev/null; then
        echo -e "  ${GREEN}enabled${NC} $ext (was not in snapshot disabled list)"
      fi
    fi
  done <<<"$(cursor --list-extensions 2>/dev/null | sort -u)"
}

cmd_apply() {
  echo -e "${BLUE}=== Step 1: snapshot (before apply) ===${NC}"
  local snap
  snap="$("$SCRIPT_DIR/snapshot-cursor-config.sh")"
  mkdir -p "$REPO_CURSOR/config"
  echo "$snap" >"$REPO_CURSOR/config/last-resource-tuning-snapshot.txt"

  echo -e "${BLUE}=== Step 2: ensure global MCP disabled ===${NC}"
  if [[ -x "$SCRIPT_DIR/toggle-global-mcp.sh" ]]; then
    "$SCRIPT_DIR/toggle-global-mcp.sh" disable || true
  fi

  echo -e "${BLUE}=== Step 3: disable extensions globally ===${NC}"
  disable_extensions
  disable_extensions_in_state_db

  echo -e "${BLUE}=== Step 4: disable plugin MCP in all workspace state DBs ===${NC}"
  apply_plugin_mcp_disable

  echo -e "${BLUE}=== Step 5: settings tweaks (dotfiles) ===${NC}"
  apply_settings_tweaks

  echo ""
  echo -e "${YELLOW}Restart Cursor for changes to take effect.${NC}"
  echo "Snapshot for restore: $snap"
}

cmd_restore() {
  local snap="${1:-}"
  if [[ -z "$snap" ]]; then
  if [[ -f "$REPO_CURSOR/config/last-resource-tuning-snapshot.txt" ]]; then
      snap="$(cat "$REPO_CURSOR/config/last-resource-tuning-snapshot.txt")"
    fi
  fi
  [[ -n "$snap" && -d "$snap" ]] || {
    echo -e "${RED}Usage: $0 restore <snapshot-dir>${NC}" >&2
    exit 1
  }
  echo -e "${BLUE}Restoring from $snap${NC}"

  if [[ -f "$snap/mcp.json" ]]; then
    cp -p "$snap/mcp.json" "$HOME/.cursor/mcp.json"
  fi
  if [[ -f "$snap/mcp.servers.stash.json" ]]; then
    cp -p "$snap/mcp.servers.stash.json" "$HOME/.cursor/mcp.servers.stash.json"
  fi

  restore_settings_from_snapshot "$snap"
  restore_plugin_mcp_from_snapshot "$snap"

  if [[ -f "$snap/extensions-disabled.json" ]] && command -v python3 >/dev/null 2>&1; then
    python3 - "$STATE_DB" "$snap/extensions-disabled.json" <<'PY'
import json
import sqlite3
import sys

db, snap = sys.argv[1], sys.argv[2]
raw = open(snap, encoding="utf-8").read()
con = sqlite3.connect(db)
con.execute(
    "INSERT OR REPLACE INTO ItemTable (key, value) VALUES (?, ?)",
    ("extensionsIdentifiers/disabled", raw),
)
con.commit()
con.close()
PY
    echo -e "${GREEN}Restored extensionsIdentifiers/disabled in global state${NC}"
  fi

  restore_extensions_full "$snap"

  echo -e "${YELLOW}Restart Cursor after restore.${NC}"
}

cmd_status() {
  echo "Global MCP:"
  if [[ -x "$SCRIPT_DIR/toggle-global-mcp.sh" ]]; then
    "$SCRIPT_DIR/toggle-global-mcp.sh" status
  fi
  echo ""
  echo "Extensions to disable (manifest):"
  printf '  - %s\n' "${EXTENSIONS_TO_DISABLE[@]}"
  echo ""
  if [[ -f "$REPO_CURSOR/config/last-resource-tuning-snapshot.txt" ]]; then
    echo "Last apply snapshot: $(cat "$REPO_CURSOR/config/last-resource-tuning-snapshot.txt")"
  fi
}

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
}

main() {
  local cmd="${1:-status}"
  case "$cmd" in
    snapshot) shift; cmd_snapshot "$@" ;;
    apply) cmd_apply ;;
    restore) shift; cmd_restore "${1:-}" ;;
    status) cmd_status ;;
    -h|--help|help) usage ;;
    *)
      echo -e "${RED}Unknown command: $cmd${NC}" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
