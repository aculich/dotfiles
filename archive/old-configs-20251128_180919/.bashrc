#!/usr/bin/env bash

# Add Homebrew to PATH (works for both Intel and Apple Silicon)
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Oh My Zsh has no direct bash equivalent, but bash-it or similar exists.
# If you use bash-it, uncomment the following:
# export BASH_IT="$HOME/.bash_it"
# [ -f "$BASH_IT/bash_it.sh" ] && source "$BASH_IT/bash_it.sh"

# FZF for bash
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Aliases and functions go here

[ -f ~/.path_shared ] && source ~/.path_shared

. "$HOME/.ockam/env"
export PATH="$HOME/.local/bin:$PATH"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path bash)"
