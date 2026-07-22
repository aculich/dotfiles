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

See **[GITHUB_TRENDING_SETUP.md](GITHUB_TRENDING_SETUP.md)**. Official page scrape via `ghtrend` (huchen API is dead; `gkze/gh-trending` is broken).

```bash
# List trending (daily|weekly|monthly)
ghtrend
ghtrend weekly
ghtrend daily python

# JSON for scripts / agents
~/tools/github-gh-cli/scripts/gh-trending-page.sh weekly --format json | jq 'length'

# Clone first N
ghtrend-clone 3 weekly

# Separate: topic/star velocity (NOT the Trending page)
ghta 20
```

### FZF, jq, markdown

See **[FZF_JQ_SETUP.md](FZF_JQ_SETUP.md)** for full setup (plugins, keybindings, upstream clones).

```bash
# Fzf: Ctrl+T (files), Ctrl+R (history), Alt+C (cd); Esc+z / Esc+p / Esc+d (zz, pz, zd)
# jq: Alt+J on a JSON-producing command; jqrepl file.json; jqless file.json
# Markdown: mdr [dir]   # fuzzy find .md, render with glow
# Pipes: cmd | up      # Ultimate Plumber
# YouTube: yt-x
```

### SQLite and DuckDB

See **[DATABASE_CLI.md](DATABASE_CLI.md)** for brew packages and details.

```bash
sqpick [dir]      # fzf a .db/.sqlite file, open litecli (or sqlite3)
duckpick [dir]    # fzf a .duckdb file, open duckdb
vdpick [dir]      # fzf a DB file, open VisiData
sqschema FILE     # print SQLite schema
duckschema FILE   # SHOW TABLES in DuckDB
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

