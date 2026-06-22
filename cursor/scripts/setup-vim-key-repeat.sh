#!/usr/bin/env bash
# macOS keyboard + Cursor settings for VSCodeVim key repeat (hjkl hold-to-repeat).
#
# Prerequisite (not automated here): Vim extension installed and Vim mode enabled.
# If status bar shows "-- VIM: DISABLED --", use Cmd+Shift+P → "Vim: Toggle Vim Mode"
# or click the status bar indicator before testing hold-to-repeat in the editor.
#
# Usage:
#   setup-vim-key-repeat.sh                 # Cursor per-app press-and-hold off
#   setup-vim-key-repeat.sh --global-repeat # system repeat (NSGlobalDomain + Accessibility)
#   setup-vim-key-repeat.sh --fast            # Cursor press-and-hold + fast system repeat
#   setup-vim-key-repeat.sh --reset           # remove overrides (restore macOS defaults)
#   reset-vim-key-repeat.sh                   # same as --reset (convenience wrapper)
#   setup-vim-key-repeat.sh --all-editors   # press-and-hold off for VS Code family apps
#   setup-vim-key-repeat.sh --verify          # print current values
#   setup-vim-key-repeat.sh --restart-cursor  # quit and reopen Cursor
#   setup-vim-key-repeat.sh --apply-session   # killall loginwindow (keyboard defaults)
#
# Recipe also documented in cursor/keybindings.json (NOTES section).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CURSOR="$(cd "$SCRIPT_DIR/.." && pwd)"
SETTINGS_JSON="${CURSOR_SETTINGS_JSON:-$REPO_CURSOR/settings.json}"

CURSOR_BUNDLE_ID="${CURSOR_BUNDLE_ID:-com.todesktop.230313mzl4w4u92}"
KEY_REPEAT="${KEY_REPEAT:-1}"
INITIAL_KEY_REPEAT="${INITIAL_KEY_REPEAT:-10}"
# Modern macOS (Apple Silicon / Sequoia+) also stores repeat in Accessibility domain.
ACCESSIBILITY_KEY_REPEAT_INTERVAL="${ACCESSIBILITY_KEY_REPEAT_INTERVAL:-0.016666666}"
ACCESSIBILITY_KEY_REPEAT_DELAY="${ACCESSIBILITY_KEY_REPEAT_DELAY:-0.05}"

OTHER_EDITOR_BUNDLES=(
  com.microsoft.VSCode
  com.microsoft.VSCodeInsiders
  com.vscodium
  com.microsoft.VSCodeExploration
  com.exafunction.windsurf
)

usage() {
  sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
}

resolve_cursor_bundle_id() {
  if [[ -d /Applications/Cursor.app ]]; then
    defaults read /Applications/Cursor.app/Contents/Info.plist CFBundleIdentifier 2>/dev/null || true
  fi
  if command -v osascript >/dev/null 2>&1; then
    osascript -e 'id of app "Cursor"' 2>/dev/null || true
  fi
}

disable_press_and_hold() {
  local bundle_id="$1"
  defaults write "$bundle_id" ApplePressAndHoldEnabled -bool false
  printf 'set ApplePressAndHoldEnabled=false for %s\n' "$bundle_id"
}

apply_cursor_press_and_hold() {
  local detected
  detected="$(resolve_cursor_bundle_id | head -1)"
  if [[ -n "$detected" && "$detected" != "$CURSOR_BUNDLE_ID" ]]; then
    printf 'note: detected Cursor bundle %s (using %s from env/default)\n' "$detected" "$CURSOR_BUNDLE_ID"
  fi
  disable_press_and_hold "$CURSOR_BUNDLE_ID"
}

apply_global_repeat() {
  defaults write -g KeyRepeat -int "$KEY_REPEAT"
  defaults write -g InitialKeyRepeat -int "$INITIAL_KEY_REPEAT"
  defaults write -g ApplePressAndHoldEnabled -bool false
  defaults write com.apple.Accessibility KeyRepeatEnabled -bool true
  defaults write com.apple.Accessibility KeyRepeatInterval -float "$ACCESSIBILITY_KEY_REPEAT_INTERVAL"
  defaults write com.apple.Accessibility KeyRepeatDelay -float "$ACCESSIBILITY_KEY_REPEAT_DELAY"
  printf 'set global KeyRepeat=%s InitialKeyRepeat=%s\n' "$KEY_REPEAT" "$INITIAL_KEY_REPEAT"
  printf 'set Accessibility KeyRepeatInterval=%s KeyRepeatDelay=%s\n' \
    "$ACCESSIBILITY_KEY_REPEAT_INTERVAL" "$ACCESSIBILITY_KEY_REPEAT_DELAY"
}

apply_all_editors() {
  apply_cursor_press_and_hold
  local bundle_id
  for bundle_id in "${OTHER_EDITOR_BUNDLES[@]}"; do
    disable_press_and_hold "$bundle_id"
  done
}

delete_default() {
  local domain="$1"
  local key="$2"
  if defaults read "$domain" "$key" >/dev/null 2>&1; then
    defaults delete "$domain" "$key"
    printf 'deleted %s %s\n' "$domain" "$key"
  fi
}

reset_press_and_hold() {
  local bundle_id="$1"
  delete_default "$bundle_id" ApplePressAndHoldEnabled
}

reset_global_repeat() {
  delete_default -g KeyRepeat
  delete_default -g InitialKeyRepeat
  delete_default -g ApplePressAndHoldEnabled
  delete_default com.apple.Accessibility KeyRepeatInterval
  delete_default com.apple.Accessibility KeyRepeatDelay
  delete_default com.apple.Accessibility KeyRepeatEnabled
  printf 'removed keyboard repeat overrides (macOS defaults apply after login session restart)\n'
}

reset_all() {
  reset_press_and_hold "$CURSOR_BUNDLE_ID"
  local bundle_id
  for bundle_id in "${OTHER_EDITOR_BUNDLES[@]}"; do
    reset_press_and_hold "$bundle_id"
  done
  reset_global_repeat
}

read_default() {
  local domain="$1"
  local key="$2"
  defaults read "$domain" "$key" 2>/dev/null || printf '(unset)\n'
}

verify_settings() {
  printf 'Cursor bundle: %s\n' "$CURSOR_BUNDLE_ID"
  printf '  ApplePressAndHoldEnabled: %s\n' "$(read_default "$CURSOR_BUNDLE_ID" ApplePressAndHoldEnabled)"
  printf 'global KeyRepeat: %s\n' "$(read_default -g KeyRepeat)"
  printf 'global InitialKeyRepeat: %s\n' "$(read_default -g InitialKeyRepeat)"
  printf 'global ApplePressAndHoldEnabled: %s\n' "$(read_default -g ApplePressAndHoldEnabled)"
  printf 'Accessibility KeyRepeatInterval: %s\n' "$(read_default com.apple.Accessibility KeyRepeatInterval)"
  printf 'Accessibility KeyRepeatDelay: %s\n' "$(read_default com.apple.Accessibility KeyRepeatDelay)"
  if [[ -f "$SETTINGS_JSON" ]]; then
    if grep -q '"vim.disableExtension"[[:space:]]*:[[:space:]]*true' "$SETTINGS_JSON"; then
      printf 'vim.disableExtension: true (Vim mode OFF — toggle in Cursor UI)\n'
    elif grep -q '"vim.disableExtension"' "$SETTINGS_JSON"; then
      printf 'vim.disableExtension: false (Vim mode should be ON)\n'
    else
      printf 'vim.disableExtension: unset (Vim mode should be ON)\n'
    fi
  else
    printf 'settings.json not found at %s\n' "$SETTINGS_JSON"
  fi
}

restart_cursor() {
  if ! osascript -e 'quit app "Cursor"' 2>/dev/null; then
    printf 'Cursor is not running (or could not quit via osascript)\n'
  else
    sleep 1
  fi
  open -a Cursor
  printf 'restarted Cursor\n'
}

apply_session() {
  killall loginwindow
  printf 'restarted loginwindow — keyboard defaults should now be active\n'
}

do_cursor=true
do_global=false
do_all_editors=false
do_verify=false
do_restart=false
do_session=false
do_reset=false

if [[ $# -eq 0 ]]; then
  :
else
  do_cursor=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      --cursor)
        do_cursor=true
        ;;
      --global-repeat)
        do_global=true
        do_cursor=true
        ;;
      --fast)
        do_global=true
        do_cursor=true
        ;;
      --reset)
        do_reset=true
        do_cursor=false
        ;;
      --all-editors)
        do_all_editors=true
        do_cursor=false
        ;;
      --verify)
        do_verify=true
        ;;
      --restart-cursor)
        do_restart=true
        ;;
      --apply-session)
        do_session=true
        ;;
      *)
        printf 'unknown option: %s\n' "$1" >&2
        usage >&2
        exit 1
        ;;
    esac
    shift
  done
fi

if $do_verify; then
  verify_settings
  exit 0
fi

if $do_reset; then
  reset_all
  if $do_restart; then
    restart_cursor
  fi
  if $do_session; then
    apply_session
  fi
  printf '\nReset complete. Verify with: %s --verify\n' "$(basename "$0")"
  printf 'Run %s --apply-session (or log out/in) for changes to take effect.\n' "$(basename "$0")"
  exit 0
fi

if $do_all_editors; then
  apply_all_editors
elif $do_cursor; then
  apply_cursor_press_and_hold
fi

if $do_global; then
  apply_global_repeat
fi

if $do_restart; then
  restart_cursor
fi

if $do_session; then
  apply_session
fi

if ! $do_all_editors && ! $do_cursor && ! $do_global && ! $do_restart && ! $do_session; then
  apply_cursor_press_and_hold
fi

printf '\nDone. Verify with: %s --verify\n' "$(basename "$0")"
printf 'Prerequisite: Vim mode enabled in Cursor (not just the extension installed).\n'
printf '  Cmd+Shift+P → "Vim: Toggle Vim Mode" or click "-- VIM: DISABLED --" in the status bar.\n'
printf 'Global keyboard changes need a new login session: %s --apply-session (or log out/in).\n' "$(basename "$0")"
printf 'Also check System Settings → Accessibility → Keyboard → Slow Keys is OFF.\n'
