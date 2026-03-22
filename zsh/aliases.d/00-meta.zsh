# Meta: alias listing, reload helpers, discovery (loaded first via aliases.d/*.zsh)

# Single source of truth for the version-controlled aliases file (override if dotfiles live elsewhere)
: "${DOTFILES_ALIASES_FILE:=$HOME/dotfiles/zsh/aliases.zsh}"

# Format alias output: GNU column uses -x; BSD/macOS column only supports -t -s
_als_column_table() {
  if command -v gcolumn >/dev/null 2>&1; then
    gcolumn -x -s "$(printf '\x23')" -t
  else
    column -t -s '#'
  fi
}

_als_column_fmt() {
  perl -pe 's/=/\x23/' | _als_column_table
}

_als_term_width() {
  local w="${COLUMNS:-$(tput cols 2>/dev/null)}"
  [[ "$w" == <-> ]] && (( w > 0 )) || w=80
  print -r -- "$w"
}

# Paged, formatted alias list (works on macOS BSD column and GNU)
als() {
  local w
  w="$(_als_term_width)"
  alias | _als_column_fmt | cut -c-"$w" | less -R -F
}

# Fuzzy pick an alias (needs fzf)
al() {
  local w
  w="$(_als_term_width)"
  if ! command -v fzf >/dev/null 2>&1; then
    echo 'fzf not found; use als or ag' >&2
    return 1
  fi
  alias | _als_column_fmt | cut -c-"$w" | fzf
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

# List shell function names (complement to als, which only shows aliases)
funcs() {
  print -l ${(k)functions} | sort -u | less -FRX
}
