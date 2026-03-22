# Meta: alias listing helpers, reload, discovery (loaded first via aliases.d/*.zsh)
#
# `als` is provided by Oh My Zsh plugin `aliases` (grouped cheatsheet via Python).
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/aliases
# Add `aliases` to plugins=() and ensure python3 is available.

# Single source of truth for the version-controlled aliases file (override if dotfiles live elsewhere)
: "${DOTFILES_ALIASES_FILE:=$HOME/dotfiles/zsh/aliases.zsh}"

# Plain-text fuzzy pick over `alias` output (optional; does not replace `als`)
al() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo 'fzf not found' >&2
    return 1
  fi
  alias | fzf
}

ag() {
  alias | grep "$@"
}

adump() {
  local dump_dir="${ZSH_CUSTOM:-$HOME/.config/zsh}"
  mkdir -p "$dump_dir"
  alias | tee "$dump_dir/aliases.dump"
  ls -lah "$dump_dir/aliases.dump"
}

zc() {
  cd "${ZSH_CUSTOM:-$HOME/.config/zsh}" || return 1
}

zcc() {
  echo "Sourcing $DOTFILES_ALIASES_FILE"
  # shellcheck disable=SC1090
  source "$DOTFILES_ALIASES_FILE"
}

zca() {
  echo 'Add custom alias: Ctrl-C to cancel, or copy and paste, then Ctrl-D when done.'
  cat >>"$DOTFILES_ALIASES_FILE"
  zcc
}

zcv() {
  vi "$DOTFILES_ALIASES_FILE"
  zcc
  (cd ~/dotfiles/zsh && git add aliases.zsh && gcom)
}

zcvc() {
  cursor "$DOTFILES_ALIASES_FILE"
}

# List shell function names (complement to `als` from OMZ aliases plugin)
funcs() {
  print -l ${(k)functions} | sort -u | less -FRX
}
