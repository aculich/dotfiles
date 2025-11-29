# gcommit, gcom, gcoma, and gcop: Reproducible Setup

## What these commands do

- **gcom**: Wrapper that runs `git gcommit`.
- **gcoma**: Wrapper that runs `git ac` (stage all + commit).
- **git gcommit**: A git alias that delegates to `gcop commit` for AI-assisted commit messages.
- **gcop**: External tool providing AI-powered commit messages and helpers.

## Where they are defined

- Zsh aliases (wrappers):

```350:355:zsh/aliases.zsh
# Git Shortcuts
alias gi='git init'
alias gcom='git gcommit'  # Custom git commit
alias gcoma='git ac'      # Git add and commit
alias ged='git diff HEAD~1 | llm -m 4o-mini -s "explain changes from last commit"'
alias gp='(git push --dry-run; echo; git log --oneline --decorate @{push}..HEAD) | less -R -F'
```

- Git aliases (global):

```4:17:/Users/me/.gitconfig
[alias]
  p = push
  pf = push --force
  undo = reset --soft HEAD^
  gcommit = !gcop commit
  c = !gcop commit
  ac = !git add . && gcop commit
  acp = !git add . && gcop commit && git push
  cp = !gcop commit && git push
  info = !gcop info
  gconfig = !gcop config
  ghelp = !gcop help
  amend = commit --amend
```

## Source for `gcop`

- Referenced in setup script:

```17:27:setup.sh
# Clone and install gcop from GitHub
GCOP_DIR="$HOME/tools/gcop"
if [ ! -d "$GCOP_DIR" ]; then
    echo "Installing gcop from GitHub..."
    mkdir -p "$HOME/tools"
    git clone https://github.com/Undertone0809/gcop.git "$GCOP_DIR"
    #(cd "$GCOP_DIR" && make install)  # Update if gcop has specific installation steps
    pip install gcop
else
    echo "gcop is already installed at $GCOP_DIR"
fi
```

## Optional: prepare-commit-msg hook example

- A sample hook exists that pre-fills AI messages:

```1:20:.git/hooks/prepare-commit-msg
#!/usr/bin/env python3
"""
GCOP Prepare Commit Message Hook

This script can be used as a Git prepare-commit-msg hook to automatically
generate commit messages using GCOP's AI capabilities and write them to
the .git/COMMIT_EDITMSG file.
"""
# ... see file for full details ...
```

## Reproducible setup (new machine)

1. Install prerequisites

```bash
# macOS
xcode-select --install || true
brew install git python@3.11
python3 -m pip install --upgrade pip
```

1. Install `gcop`

```bash
# From PyPI (preferred if available)
python3 -m pip install --upgrade gcop

# Or clone the repo for reference
mkdir -p "$HOME/tools"
[ -d "$HOME/tools/gcop" ] || git clone https://github.com/Undertone0809/gcop.git "$HOME/tools/gcop"
```

1. Configure global git aliases

```bash
# Append (idempotent-safe by using git config)
git config --global alias.gcommit "!gcop commit"
git config --global alias.c "!gcop commit"
git config --global alias.ac "!git add . && gcop commit"
git config --global alias.acp "!git add . && gcop commit && git push"
git config --global alias.cp "!gcop commit && git push"
git config --global alias.info "!gcop info"
git config --global alias.gconfig "!gcop config"
git config --global alias.ghelp "!gcop help"
```

1. Add zsh aliases

```bash
# In ~/.zshrc or sourced aliases file
alias gcom='git gcommit'
alias gcoma='git ac'
```

Then reload shell: `source ~/.zshrc`.

1. (Optional) Configure gcop

```bash
gcop config
# Follow prompts to set API keys, models, conventions, etc.
```

1. (Optional) Enable commit hook in repos

```bash
# From repo root
echo "Installing GCOP commit hook..."
HOOK=.git/hooks/prepare-commit-msg
cat > "$HOOK" <<'PY'
#!/usr/bin/env python3
# See template in this repo at .git/hooks/prepare-commit-msg
print("GCOP hook placeholder. Copy full script from dotfiles if needed.")
PY
chmod +x "$HOOK"
```

## Usage

- Stage and AI-commit: `gcoma` (stages all and runs gcop commit)
- AI-commit current index: `gcom` (runs `git gcommit` -> `gcop commit`)
- AI-commit and push: `git cp` or `git acp`

## Notes

- If `gcop` isn’t found, ensure your Python user base bin is on PATH. For example:

```bash
# For Homebrew Python 3.11
export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"
# Or ensure ~/.local/bin or ~/Library/Python/3.11/bin is in PATH
```

- This repo’s `.git/COMMIT_EDITMSG` may be auto-populated with a header:

```1:3:.git/COMMIT_EDITMSG
# AI-generated commit message by GCOP
# Edit as needed, save and close to commit
```

## Verification

```bash
which gcop && gcop --help | head -n 5
which git && git --version
which zsh && echo $SHELL
# In a git repo
gcoma   # should stage all and open your editor with an AI commit message
```
