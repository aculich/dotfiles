#!/usr/bin/env bash
# Install the classic-IDE wrapper over Cursor.app `cursor` CLI symlinks.
#
# Does not replace ~/.local/bin/cursor when that file is Cursor's
# cursor.com/install agent shim (it forwards to the next `cursor` on PATH).
#
# Usage:
#   install-cursor-classic-cli.sh           # wrap writable Homebrew /usr/local bins
#   install-cursor-classic-cli.sh --status  # show what `cursor` resolves to
#   install-cursor-classic-cli.sh --undo    # restore Cursor.app CLI symlinks
#
# See cursor/docs/cursor-classic-ide.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WRAPPER="${SCRIPT_DIR}/cursor-classic-wrapper.sh"
LOCAL_BIN="${HOME}/.local/bin/cursor"
SYSTEM_CANDIDATES=(/opt/homebrew/bin/cursor /usr/local/bin/cursor)

abspath() {
  python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"
}

is_app_cli_path() {
  local dest="$1"
  [[ "$dest" == *"/Contents/Resources/app/bin/cursor" || "$dest" == *"/Contents/Resources/app/bin/code" ]]
}

find_app_cursor() {
  local c
  for c in \
    "/Applications/Cursor.app/Contents/Resources/app/bin/code" \
    "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" \
    "${HOME}/Applications/Cursor.app/Contents/Resources/app/bin/code" \
    "${HOME}/Applications/Cursor.app/Contents/Resources/app/bin/cursor" \
    "/Applications/Cursor Nightly.app/Contents/Resources/app/bin/code" \
    "/Applications/Cursor Nightly.app/Contents/Resources/app/bin/cursor"
  do
    if [[ -x "$c" ]]; then
      printf '%s\n' "$c"
      return 0
    fi
  done
  return 1
}

is_wrapper() {
  [[ -e "$1" || -L "$1" ]] && [[ "$(abspath "$1")" == "$(abspath "$WRAPPER")" ]]
}

is_app_cli() {
  [[ -e "$1" || -L "$1" ]] || return 1
  is_app_cli_path "$(abspath "$1")"
}

is_agent_shim() {
  [[ -f "$1" && ! -L "$1" ]] || return 1
  grep -q 'No Cursor IDE installation found' "$1" 2>/dev/null
}

dir_writable() {
  [[ -w "$(dirname "$1")" ]]
}

print_status() {
  echo "== cursor classic CLI =="
  echo "wrapper: $WRAPPER"
  echo ""
  echo "PATH hits (which -a cursor):"
  if ! which -a cursor >/dev/null 2>&1; then
    echo "  (none)"
  else
    local p
    which -a cursor | while IFS= read -r p; do
      if is_wrapper "$p"; then
        echo "  $p  -> wrapper (classic)"
      elif is_agent_shim "$p"; then
        echo "  $p  -> cursor.com/install agent shim (forwards to next cursor on PATH)"
      elif is_app_cli "$p"; then
        echo "  $p  -> Cursor.app CLI (no default --classic)"
      else
        echo "  $p  -> $(abspath "$p")"
      fi
    done
  fi
  echo ""
  echo "type cursor:"
  type cursor 2>/dev/null || true
  echo ""
  echo "Escape hatches: CURSOR_CLASSIC=0 cursor …   or   cursor --glass …"
  echo "App restore: Cursor Settings → General → Startup → Window Restoration → Last Used Windows"
  echo "Then quit from an Editor window (Cmd+Q) so dock launches restore the IDE."
}

install_link() {
  local dest="$1"
  if is_wrapper "$dest"; then
    echo "already wrapper: $dest"
    return 0
  fi
  if is_agent_shim "$dest"; then
    echo "leave agent shim in place: $dest"
    return 0
  fi
  if ! dir_writable "$dest"; then
    echo "not writable: $dest" >&2
    return 1
  fi
  if [[ -e "$dest" || -L "$dest" ]]; then
    if ! is_app_cli "$dest"; then
      echo "skip (not a Cursor.app CLI symlink): $dest" >&2
      return 1
    fi
  fi
  ln -sf "$WRAPPER" "$dest"
  echo "installed wrapper: $dest"
}

undo_link() {
  local dest="$1"
  local app_cli
  app_cli="$(find_app_cursor)" || {
    echo "error: Cursor.app CLI not found; left $dest alone" >&2
    return 1
  }
  if ! is_wrapper "$dest"; then
    echo "not our wrapper, skip: $dest"
    return 0
  fi
  if ! dir_writable "$dest"; then
    echo "not writable: $dest" >&2
    return 1
  fi
  ln -sf "$app_cli" "$dest"
  echo "restored official CLI: $dest -> $app_cli"
}

MODE="install"
case "${1:-}" in
  -h|--help)
    sed -n '2,14p' "$0"
    exit 0
    ;;
  --status) MODE="status" ;;
  --undo) MODE="undo" ;;
  "") MODE="install" ;;
  *)
    echo "usage: $(basename "$0") [--status|--undo]" >&2
    exit 2
    ;;
esac

if [[ ! -f "$WRAPPER" ]]; then
  echo "error: missing wrapper $WRAPPER" >&2
  exit 1
fi
chmod +x "$WRAPPER"

if [[ "$MODE" == "status" ]]; then
  print_status
  exit 0
fi

if [[ "$MODE" == "undo" ]]; then
  for dest in "${SYSTEM_CANDIDATES[@]}"; do
    undo_link "$dest" || true
  done
  if is_wrapper "$LOCAL_BIN"; then
    echo "note: $LOCAL_BIN is our wrapper; not removing (no automatic restore of agent shim)"
  fi
  print_status
  exit 0
fi

for dest in "${SYSTEM_CANDIDATES[@]}"; do
  if [[ -e "$dest" || -L "$dest" ]]; then
    install_link "$dest" || true
  elif dir_writable "$dest"; then
    install_link "$dest" || true
  fi
done

if is_agent_shim "$LOCAL_BIN"; then
  echo "leave agent shim in place: $LOCAL_BIN (zsh function + Homebrew/usr local wrapper cover launches)"
elif [[ ! -e "$LOCAL_BIN" ]]; then
  mkdir -p "$(dirname "$LOCAL_BIN")"
  ln -sf "$WRAPPER" "$LOCAL_BIN"
  echo "installed wrapper: $LOCAL_BIN"
elif is_wrapper "$LOCAL_BIN"; then
  echo "already wrapper: $LOCAL_BIN"
fi

echo ""
print_status
echo ""
echo "Interactive zsh: function in aliases.d/10-cursor-classic.zsh (already sourced from aliases.zsh)."
echo "Raycast Shell uses PATH: it should hit the Homebrew or /usr/local wrapper."
