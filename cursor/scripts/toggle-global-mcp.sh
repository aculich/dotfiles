#!/usr/bin/env bash
# Toggle global Cursor MCP servers in ~/.cursor/mcp.json
#
# Disabled servers are preserved in ~/.cursor/mcp.servers.stash.json
#
# Usage:
#   toggle-global-mcp.sh disable   # empty mcp.json (stash current servers first)
#   toggle-global-mcp.sh enable    # restore from stash
#   toggle-global-mcp.sh status    # show enabled vs disabled + server names
#   toggle-global-mcp.sh list      # list stashed server names
#
# Restart Cursor (or reload MCP) after changing.

set -euo pipefail

CURSOR_DIR="${CURSOR_DIR:-$HOME/.cursor}"
MCP_JSON="$CURSOR_DIR/mcp.json"
STASH="$CURSOR_DIR/mcp.servers.stash.json"
MARKER="$CURSOR_DIR/.mcp-servers-disabled"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

need_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo -e "${RED}jq is required${NC}" >&2
    exit 1
  fi
}

server_count() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo 0
    return
  fi
  jq '.mcpServers // {} | length' "$file" 2>/dev/null || echo 0
}

list_servers() {
  local file="$1"
  jq -r '.mcpServers // {} | keys[]' "$file" 2>/dev/null | sort || true
}

is_disabled() {
  [[ -f "$MARKER" ]] || [[ "$(server_count "$MCP_JSON")" -eq 0 ]]
}

cmd_disable() {
  need_jq
  mkdir -p "$CURSOR_DIR"
  local active_count
  active_count="$(server_count "$MCP_JSON")"

  if [[ "$active_count" -gt 0 ]]; then
    cp "$MCP_JSON" "$STASH"
    echo -e "${BLUE}Stashed ${active_count} server(s) to $(basename "$STASH")${NC}"
    list_servers "$STASH" | sed 's/^/  - /'
  elif [[ ! -f "$STASH" ]]; then
    echo -e "${RED}Nothing to stash: mcp.json is empty and no stash file exists${NC}" >&2
    exit 1
  else
    echo -e "${YELLOW}mcp.json already empty; keeping existing stash ($(server_count "$STASH") server(s))${NC}"
  fi

  jq -n '{ mcpServers: {} }' >"$MCP_JSON"
  date -u +"%Y-%m-%dT%H:%M:%SZ" >"$MARKER"
  echo -e "${GREEN}Global MCP disabled${NC} ($(basename "$MCP_JSON") has no servers)"
  echo -e "${YELLOW}Restart Cursor for changes to take effect${NC}"
}

cmd_enable() {
  need_jq
  if [[ ! -f "$STASH" ]]; then
    echo -e "${RED}No stash at $STASH — cannot enable${NC}" >&2
    exit 1
  fi
  local stash_count
  stash_count="$(server_count "$STASH")"
  if [[ "$stash_count" -eq 0 ]]; then
    echo -e "${RED}Stash file has no servers${NC}" >&2
    exit 1
  fi

  cp "$STASH" "$MCP_JSON"
  rm -f "$MARKER"
  echo -e "${GREEN}Restored ${stash_count} global MCP server(s)${NC}"
  list_servers "$MCP_JSON" | sed 's/^/  - /'
  echo -e "${YELLOW}Restart Cursor for changes to take effect${NC}"
}

cmd_status() {
  need_jq
  echo "Cursor dir: $CURSOR_DIR"
  echo "Active:     $MCP_JSON ($(server_count "$MCP_JSON") server(s))"
  echo "Stash:      $STASH ($(server_count "$STASH") server(s))"
  if is_disabled; then
    echo -e "State:      ${YELLOW}DISABLED${NC}"
  else
    echo -e "State:      ${GREEN}ENABLED${NC}"
  fi
  echo ""
  if [[ "$(server_count "$MCP_JSON")" -gt 0 ]]; then
    echo "Active servers:"
    list_servers "$MCP_JSON" | sed 's/^/  - /'
  fi
  if [[ -f "$STASH" ]] && [[ "$(server_count "$STASH")" -gt 0 ]]; then
    echo "Stashed (restore with: $(basename "$0") enable):"
    list_servers "$STASH" | sed 's/^/  - /'
  fi
}

cmd_list() {
  need_jq
  if [[ ! -f "$STASH" ]]; then
    echo "No stash file."
    exit 0
  fi
  list_servers "$STASH" | sed 's/^/  - /'
}

usage() {
  sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
  echo ""
  echo "Commands: disable | enable | status | list"
}

main() {
  local cmd="${1:-status}"
  case "$cmd" in
    disable) cmd_disable ;;
    enable) cmd_enable ;;
    status) cmd_status ;;
    list) cmd_list ;;
    -h|--help|help) usage ;;
    *)
      echo -e "${RED}Unknown command: $cmd${NC}" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
