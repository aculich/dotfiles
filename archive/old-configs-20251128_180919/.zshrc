export PATH="$HOME/.local/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"


export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Silence direnv verbose output (don't show all env vars!)
export DIRENV_LOG_FORMAT=""

plugins=(
    aliases
    git
    node npm yarn
    conda
    # direnv  # Disabled - loading manually below
    # zsh-direnv  # Disabled - loading manually below
    zsh-autosuggestions
    zsh-syntax-highlighting
    fast-syntax-highlighting
    # zsh-autocomplete
    fzf
    zsh-git-fzf
)

source $ZSH/oh-my-zsh.sh

# nvm support
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && source "$(brew --prefix nvm)/nvm.sh"

# conda support
if command -v conda &> /dev/null; then
    eval "$(conda shell.zsh hook)"
    conda config --set auto_activate_base false
    # ensure prompt shows current env
    precmd() { PROMPT="$CONDA_PROMPT_MODIFIER $PROMPT"; }
fi

# Enable direnv with silent output
eval "$(direnv hook zsh)"

# # Optional: adjust PATH or load bun
# export PATH="$HOME/.bun/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/me/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
export PATH="$HOME/.local/bin:$PATH"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
export PATH="/Library/TeX/texbin:$PATH"

source ~/.raycast_shell_aliases

# Android Auto Development Environment
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# TRIBE CLI - Added 2025-11-02T01:06:04.558Z
source ~/.tribe/tribe-env.sh
## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/me/.dart-cli-completion/zsh-config.zsh ]] && . /Users/me/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]


# Added by Antigravity
export PATH="/Users/me/.antigravity/antigravity/bin:$PATH"

# bun completions
[ -s "/Users/me/.bun/_bun" ] && source "/Users/me/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
