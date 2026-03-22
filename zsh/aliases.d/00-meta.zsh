# Meta: alias listing, reload helpers, discovery (sourced first via aliases.d/*.zsh)
#
# `als` is normally from Oh My Zsh plugin `aliases` (Python cheatsheet). A fallback is
# defined below if that plugin did not load. Ensure `aliases` is in plugins=() in ~/.zshrc
# and that python3 is available: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/aliases

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

# Same implementation as OMZ plugins/aliases when the plugin did not load
_als_omz_cheatsheet="${ZSH:-$HOME/.oh-my-zsh}/plugins/aliases/cheatsheet.py"
if ! (( $+functions[als] )) && [[ -r "$_als_omz_cheatsheet" ]] && (( $+commands[python3] )); then
  als() {
    alias | python3 "$_als_omz_cheatsheet" "$@"
  }
fi
unset _als_omz_cheatsheet

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

# List shell function names (complement to `als`, which only lists aliases)
funcs() {
  print -l ${(k)functions} | sort -u | less -FRX
}
