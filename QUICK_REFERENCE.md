# Quick Reference Guide

## Common Tasks

### 1Password Operations

```bash
# Sign in
op signin --account aculich@gmail.com

# List vaults
op vault list

# List items in a vault
op item list --vault develop

# Get a secret
op read "op://develop/apikeys/OPENAI_API_KEY"

# Create a new item
op item create --vault develop --title "New API Keys" --category API_CREDENTIAL
```

### Direnv Operations

```bash
# Allow direnv in current directory
direnv allow

# Check direnv status
direnv status

# View what direnv would load
direnv export zsh

# Deny direnv in a directory
direnv deny
```

### Environment Management

```bash
# Check development environment
dev_check

# Load secrets from 1Password (in zsh)
op_load_item "develop" "apikeys"

# Load a single secret
op_load_secret "develop" "apikeys" "OPENAI_API_KEY" "OPENAI_API_KEY"

# Reload zsh config
reload_zsh
```

### Project Setup

```bash
# Create new .envrc for a project
cp ~/dotfiles/zsh/.envrc.template .envrc
# Edit .envrc to set OP_VAULT and OP_ITEM
direnv allow
```

### GitHub Trending

Requires `gh` and (for full setup) the gh-trending extension. See **[GITHUB_TRENDING_SETUP.md](GITHUB_TRENDING_SETUP.md)** to install on a new machine.

```bash
# Install extension (one-time)
gh extension install gkze/gh-trending

# List trending repos (alias tries API, then gh trending)
ghtrend
ghtrend weekly
ghtrend daily python

# Direct extension (table or JSON)
gh trending
gh trending --web
gh trending -o json

# Clone first N trending repos
ghtrend-clone 3 weekly
```

## File Locations

| File | Purpose | Location |
|------|---------|----------|
| Main zsh config | Interactive shell setup | `~/dotfiles/zsh/.zshrc.professional` → `~/.zshrc` |
| Environment setup | Non-interactive shell | `~/dotfiles/zsh/.zshenv.professional` → `~/.zshenv` |
| Aliases | Shell aliases | `~/dotfiles/zsh/aliases.zsh` |
| Functions | Helper functions | `~/dotfiles/zsh/functions.zsh` |
| Global .envrc | Home directory env vars | `~/.envrc` |
| Project .envrc | Project-specific env vars | `./.envrc` (in project dir) |

## Troubleshooting

### Secrets Not Loading

```bash
# Check 1Password auth
op account list

# Re-authenticate
op signout
op signin --account aculich@gmail.com

# Verify item exists
op item get "apikeys" --vault develop

# Test loading manually
op_load_item "develop" "apikeys"
echo $OPENAI_API_KEY
```

### Direnv Not Working

```bash
# Check if direnv is hooked
echo $precmd_functions | grep direnv

# Re-hook direnv
eval "$(direnv hook zsh)"

# Check .envrc syntax
direnv allow
```

### Cursor Terminal Issues

```bash
# Verify shell
echo $SHELL  # Should be /bin/zsh

# Check if config loaded
echo $ZSH  # Should show Oh My Zsh path

# Reload config
source ~/.zshrc
```

## Migration Commands

```bash
# Migrate secrets to 1Password
~/dotfiles/scripts/migrate-secrets-to-1password.sh

# Setup new .envrc
~/dotfiles/scripts/setup-envrc.sh

# Backup current configs
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)
cp ~/.envrc ~/.envrc.backup.$(date +%Y%m%d)
```

## Best Practices

1. **Never commit secrets** - Use 1Password for all API keys
2. **Use project .envrc** - Each project should have its own `.envrc`
3. **Separate vaults** - Use "develop" for dev, "Personal" for personal
4. **Version control configs** - Keep dotfiles in git, not secrets
5. **Test in new terminal** - Always test config changes in a fresh terminal

