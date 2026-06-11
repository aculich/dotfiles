#!/usr/bin/env bash
# Snapshot, inspect, bulk-disable, and restore Cursor extension enable/disable state.
#
# Usage:
#   manage-extensions.sh snapshot              # before any change (recommended)
#   manage-extensions.sh status                # counts + paths to last snapshot
#   manage-extensions.sh list                  # human-readable enabled/disabled lists
#   manage-extensions.sh apply [--dry-run]     # snapshot, then disable all except keepEnabled
#   manage-extensions.sh restore [snapshot-dir]
#   manage-extensions.sh keep                  # show keep + optional lists from manifest
#
# Restart Cursor after apply or restore.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CURSOR="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$REPO_CURSOR/config/extensions-keep.manifest.json"
USER_DATA="${CURSOR_USER_DATA:-$HOME/Library/Application Support/Cursor/User}"
STATE_DB="$USER_DATA/globalStorage/state.vscdb"
SNAPSHOTS_ROOT="$REPO_CURSOR/snapshots"
LAST_SNAP_FILE="$REPO_CURSOR/config/last-extensions-snapshot.txt"
LATEST_LINK="$SNAPSHOTS_ROOT/extensions-latest"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo -e "${RED}Required: $1${NC}" >&2
    exit 1
  }
}

read_keep_list() {
  need_cmd jq
  [[ -f "$MANIFEST" ]] || {
    echo -e "${RED}Missing $MANIFEST${NC}" >&2
    exit 1
  }
  jq -r '.keepEnabled[]?' "$MANIFEST"
}

fetch_installed() {
  need_cmd cursor
  cursor --list-extensions 2>/dev/null | sort -u
}

fetch_disabled_json() {
  if [[ -f "$STATE_DB" ]] && command -v sqlite3 >/dev/null 2>&1; then
    sqlite3 "$STATE_DB" "SELECT value FROM ItemTable WHERE key='extensionsIdentifiers/disabled';" 2>/dev/null || echo '[]'
  else
    echo '[]'
  fi
}

write_snapshot() {
  local out="$1"
  local update_last="${2:-1}"
  mkdir -p "$out"

  local ts
  ts="$(date +%Y-%m-%d_%H-%M-%S)"
  printf '%s\n' "$ts" >"$out/SNAPSHOT_TIMESTAMP.txt"
  printf '%s\n' "$out" >"$out/SNAPSHOT_PATH.txt"
  cp -p "$MANIFEST" "$out/extensions-keep.manifest.json" 2>/dev/null || true

  if command -v cursor >/dev/null 2>&1; then
    cursor --list-extensions --show-versions >"$out/extensions-installed.txt" 2>/dev/null || true
    fetch_installed >"$out/extensions-installed-ids.txt" 2>/dev/null || true
  fi

  fetch_disabled_json >"$out/extensions-disabled.json"

  need_cmd python3
  python3 - "$out" <<'PY'
import json
import sys
from pathlib import Path

out = Path(sys.argv[1])
installed = [
    ln.strip()
    for ln in (out / "extensions-installed-ids.txt").read_text().splitlines()
    if ln.strip()
]
disabled_raw = (out / "extensions-disabled.json").read_text().strip() or "[]"
disabled = json.loads(disabled_raw)
disabled_ids = {x["id"] for x in disabled}
enabled = sorted(set(installed) - disabled_ids)
disabled_sorted = sorted(disabled_ids)

(out / "extensions-enabled-ids.txt").write_text("\n".join(enabled) + ("\n" if enabled else ""))
(out / "extensions-disabled-ids.txt").write_text("\n".join(disabled_sorted) + ("\n" if disabled_sorted else ""))

summary = [
    f"# Extensions snapshot",
    "",
    f"- **Installed:** {len(installed)}",
    f"- **Enabled:** {len(enabled)}",
    f"- **Disabled:** {len(disabled_sorted)}",
    "",
    "## Enabled",
    "",
]
summary += [f"- `{e}`" for e in enabled] or ["- _(none)_"]
summary += ["", "## Disabled", ""]
summary += [f"- `{e}`" for e in disabled_sorted] or ["- _(none)_"]
summary += [
    "",
    "## Restore",
    "",
    f"```bash",
    f"{out.parent.parent}/scripts/manage-extensions.sh restore {out}",
    f"```",
    "",
]
(out / "SUMMARY.md").write_text("\n".join(summary) + "\n")
PY

  cat >"$out/README.txt" <<EOF
Extensions snapshot: $ts

View:  cat $out/SUMMARY.md
Restore: $REPO_CURSOR/scripts/manage-extensions.sh restore $out
EOF

  if [[ "$update_last" -eq 1 ]]; then
    echo "$out" >"$LAST_SNAP_FILE"
    ln -sfn "$out" "$LATEST_LINK"
  fi

  echo -e "${GREEN}Snapshot:${NC} $out"
  echo -e "${GREEN}Summary:${NC}  $out/SUMMARY.md"
  echo -e "${GREEN}Latest:${NC}   $LATEST_LINK -> $(readlink "$LATEST_LINK" 2>/dev/null || echo "$out")"
}

cmd_snapshot() {
  local ts out
  ts="$(date +%Y-%m-%d_%H-%M-%S)"
  out="$SNAPSHOTS_ROOT/extensions-$ts"
  write_snapshot "$out"
}

cmd_status() {
  echo -e "${BLUE}Extension state (live)${NC}"
  if ! command -v cursor >/dev/null 2>&1; then
    echo -e "${YELLOW}cursor CLI not in PATH${NC}"
    return 0
  fi
  local installed disabled enabled
  installed="$(fetch_installed | wc -l | tr -d ' ')"
  disabled="$(fetch_disabled_json | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))')"
  enabled=$((installed - disabled))
  echo "  Installed: $installed"
  echo "  Enabled:   $enabled"
  echo "  Disabled:  $disabled"
  echo ""
  if [[ -f "$LAST_SNAP_FILE" ]]; then
    local snap
    snap="$(cat "$LAST_SNAP_FILE")"
    echo -e "${BLUE}Last snapshot:${NC} $snap"
    if [[ -f "$snap/SUMMARY.md" ]]; then
      echo -e "${BLUE}Quick view:${NC}  cat $snap/SUMMARY.md"
    fi
  else
    echo -e "${YELLOW}No snapshot yet. Run: $0 snapshot${NC}"
  fi
  if [[ -L "$LATEST_LINK" || -d "$LATEST_LINK" ]]; then
    echo -e "${BLUE}Latest link:${NC}  $LATEST_LINK"
  fi
  echo ""
  echo -e "${BLUE}Keep list:${NC} $MANIFEST"
}

cmd_list() {
  cmd_status
  local disabled_json
  disabled_json="$(fetch_disabled_json)"
  echo -e "${BLUE}Enabled now:${NC}"
  fetch_installed | while read -r ext; do
    [[ -n "$ext" ]] || continue
    if ! python3 -c "import json,sys; d={x['id'] for x in json.loads(sys.argv[1])}; sys.exit(0 if sys.argv[2] in d else 1)" "$disabled_json" "$ext" 2>/dev/null; then
      echo "  $ext"
    fi
  done
  echo ""
  echo -e "${BLUE}Disabled now (state DB):${NC}"
  fetch_disabled_json | jq -r '.[].id' 2>/dev/null | sed 's/^/  /' || true
}

cmd_keep() {
  [[ -f "$MANIFEST" ]] || exit 1
  echo -e "${BLUE}keepEnabled (stays on after apply):${NC}"
  jq -r '.keepEnabled[]' "$MANIFEST" | sed 's/^/  /'
  echo ""
  echo -e "${BLUE}optionalKeep (add to keepEnabled in manifest if you want):${NC}"
  jq -r '.optionalKeep[]?' "$MANIFEST" | sed 's/^/  /'
  echo ""
  jq -r '.notes[]?' "$MANIFEST" | sed 's/^/  /'
}

merge_disabled_in_db() {
  local -a ids=("$@")
  need_cmd python3
  python3 - "$STATE_DB" "${ids[@]}" <<'PY'
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
        print(f"  warn: no uuid for {eid}", file=sys.stderr)
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
print(f"  state DB: +{len(added)} disabled, {len(merged)} total in disabled list")
PY
}

cmd_apply() {
  local dry_run=0
  if [[ "${1:-}" == "--dry-run" ]]; then
    dry_run=1
  fi

  echo -e "${BLUE}=== Step 1: snapshot (before apply) ===${NC}"
  local ts snap
  ts="$(date +%Y-%m-%d_%H-%M-%S)"
  snap="$SNAPSHOTS_ROOT/extensions-$ts"
  write_snapshot "$snap"

  mapfile -t keep < <(read_keep_list)
  mapfile -t installed < <(fetch_installed)

  local -a to_disable=()
  local ext k found
  for ext in "${installed[@]}"; do
    [[ -n "$ext" ]] || continue
    found=0
    for k in "${keep[@]}"; do
      if [[ "$ext" == "$k" ]]; then
        found=1
        break
      fi
    done
    if [[ "$found" -eq 0 ]]; then
      to_disable+=("$ext")
    fi
  done

  printf '%s\n' "${to_disable[@]}" >"$snap/extensions-would-disable-on-apply.txt"

  echo -e "${BLUE}=== Step 2: disable ${#to_disable[@]} extensions (keep ${#keep[@]}) ===${NC}"
  if [[ "$dry_run" -eq 1 ]]; then
    echo -e "${YELLOW}Dry run — would disable:${NC}"
    printf '  - %s\n' "${to_disable[@]}"
    echo ""
    echo "List saved: $snap/extensions-would-disable-on-apply.txt"
    return 0
  fi

  need_cmd cursor
  for ext in "${to_disable[@]}"; do
    if cursor --disable-extension "$ext" 2>/dev/null; then
      echo -e "  ${GREEN}disabled (cli)${NC} $ext"
    else
      echo -e "  ${YELLOW}cli skip${NC} $ext"
    fi
  done

  merge_disabled_in_db "${to_disable[@]}"

  write_snapshot "$snap/post-apply" 0
  echo "$snap" >"$LAST_SNAP_FILE"
  ln -sfn "$snap" "$LATEST_LINK"
  echo ""
  echo -e "${YELLOW}Restart Cursor for extension hosts to exit.${NC}"
  echo "Restore pre-apply state: $0 restore $snap"
}

cmd_restore() {
  local snap="${1:-}"
  if [[ -z "$snap" ]]; then
    if [[ -f "$LAST_SNAP_FILE" ]]; then
      snap="$(cat "$LAST_SNAP_FILE")"
    elif [[ -L "$LATEST_LINK" ]]; then
      snap="$SNAPSHOTS_ROOT/$(readlink "$LATEST_LINK")"
    fi
  fi
  [[ -n "$snap" && -d "$snap" ]] || {
    echo -e "${RED}Usage: $0 restore <snapshot-dir>${NC}" >&2
    exit 1
  }

  echo -e "${BLUE}Restoring from $snap${NC}"

  if [[ -f "$snap/extensions-disabled.json" ]] && [[ -f "$STATE_DB" ]]; then
    need_cmd python3
    python3 - "$STATE_DB" "$snap/extensions-disabled.json" <<'PY'
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

  if [[ -f "$snap/extensions-enabled-ids.txt" ]] && command -v cursor >/dev/null 2>&1; then
    need_cmd cursor
    while IFS= read -r ext; do
      [[ -n "$ext" ]] || continue
      if cursor --enable-extension "$ext" 2>/dev/null; then
        echo -e "  ${GREEN}enabled${NC} $ext"
      fi
    done <"$snap/extensions-enabled-ids.txt"
  fi

  echo -e "${YELLOW}Restart Cursor after restore.${NC}"
}

usage() {
  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
}

main() {
  local cmd="${1:-status}"
  case "$cmd" in
    snapshot) cmd_snapshot ;;
    status) cmd_status ;;
    list) cmd_list ;;
    keep) cmd_keep ;;
    apply) shift || true; cmd_apply "$@" ;;
    restore) shift || true; cmd_restore "${1:-}" ;;
    -h|--help|help) usage ;;
    *)
      echo -e "${RED}Unknown: $cmd${NC}" >&2
      usage
      exit 1
      ;;
  esac
}

main "$@"
