# Prefer classic Cursor IDE for `cursor` launches (not Agents Window / glass).
#
# Cursor 3 has no settings.json default for this. The wrapper injects --classic
# on editor opens. Raycast and other non-interactive shells need the PATH
# install: just install-classic-cli  (see cursor/docs/cursor-classic-ide.md).
#
# Escape: CURSOR_CLASSIC=0 cursor …   or   cursor --glass …

unalias cursor 2>/dev/null || true

cursor() {
  local wrapper="${DOTFILES:-$HOME/dotfiles}/cursor/scripts/cursor-classic-wrapper.sh"
  if [[ -x "$wrapper" ]]; then
    "$wrapper" "$@"
  else
    command cursor "$@"
  fi
}
