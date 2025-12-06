# Professional Development Environment Setup Guide

This guide will help you set up a professional, secure, and maintainable development environment using best practices for 2025.

## Overview

This setup provides:
- ✅ Secure secrets management with 1Password CLI
- ✅ Modular, maintainable zsh configuration
- ✅ Proper direnv integration for project-specific environments
- ✅ Cursor IDE shell integration support
- ✅ Version-controlled dotfiles
- ✅ Industry best practices

## Prerequisites

1. **macOS** (this guide is tailored for macOS)
2. **Homebrew** installed
3. **1Password account** (aculich@gmail.com)
4. **Git** for version control

## Step 1: Install Core Tools

```bash
# Install essential tools
brew install direnv git jq
brew install --cask 1password-cli

# Verify installations
direnv --version
op --version
```

## Step 2: Set Up 1Password CLI

```bash
# Sign in to 1Password
op signin --account aculich@gmail.com

# Verify authentication
op account list

# Create a develop vault (if it doesn't exist)
op vault create "develop" --description "Development API keys and credentials"
```

## Step 3: Migrate Existing Secrets

If you have secrets in `~/.envrc`, migrate them to 1Password:

```bash
# Run the migration script
~/dotfiles/scripts/migrate-secrets-to-1password.sh

# Or manually create items in 1Password
# Then use: op item create --vault "develop" --title "apikeys" --category API_CREDENTIAL
```

## Step 4: Install Zsh Configuration

### Option A: Symlink Method (Recommended)

```bash
# Backup existing configs
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)
cp ~/.zshenv ~/.zshenv.backup.$(date +%Y%m%d) 2>/dev/null || true

# Create symlinks
ln -sf ~/dotfiles/zsh/.zshrc.professional ~/.zshrc
ln -sf ~/dotfiles/zsh/.zshenv.professional ~/.zshenv

# Reload shell
exec zsh
```

### Option B: Source Method

Add to your existing `~/.zshrc`:

```zsh
# Source professional config from dotfiles
if [[ -f "$HOME/dotfiles/zsh/.zshrc.professional" ]]; then
    source "$HOME/dotfiles/zsh/.zshrc.professional"
fi
```

## Step 5: Set Up Project .envrc Files

For each project that needs environment variables:

```bash
# Copy the template
cp ~/dotfiles/zsh/.envrc.template .envrc

# Edit to match your 1Password vault/item
# Then allow direnv
direnv allow
```

Example `.envrc`:

```bash
# Load secrets from 1Password
export OP_VAULT="develop"
export OP_ITEM="apikeys"

# Load the secrets
op_load_item "$OP_VAULT" "$OP_ITEM"

# Project-specific non-secret vars
export PROJECT_NAME="my-project"
export NODE_ENV="development"
```

## Step 6: Verify Setup

Run the development environment check:

```bash
dev_check
```

This will verify:
- Shell configuration
- Installed tools
- 1Password authentication
- Direnv status

## Step 7: Cursor IDE Integration

Cursor should automatically detect your zsh configuration. To verify:

1. Open Cursor
2. Open integrated terminal (`` Ctrl+` ``)
3. Check that `$SHELL` is `/bin/zsh`
4. Verify environment variables load correctly

If issues occur:
- Ensure Cursor is using zsh: Check terminal settings
- Restart Cursor completely after config changes
- Check that `~/.zshrc` is properly sourced

## Directory Structure

```
~/dotfiles/
├── zsh/
│   ├── .zshrc.professional      # Main zsh config
│   ├── .zshenv.professional      # Environment setup
│   ├── aliases.zsh              # Shell aliases
│   ├── functions.zsh             # Helper functions
│   ├── .envrc.template          # Direnv template
│   └── site-specific/           # Machine-specific configs
├── scripts/
│   └── migrate-secrets-to-1password.sh
└── SETUP_GUIDE.md               # This file
```

## Best Practices

### Secrets Management

1. **Never commit secrets** to git
2. **Use 1Password** for all API keys, tokens, passwords
3. **Separate vaults** for personal vs. development credentials
4. **Use descriptive item names** in 1Password

### Environment Variables

1. **Project-specific**: Use `.envrc` files in project directories
2. **Global secrets**: Load from 1Password in `~/.envrc` (if needed)
3. **Non-secret configs**: Can be committed to git

### Zsh Configuration

1. **Keep it modular**: Separate aliases, functions, configs
2. **Version control**: All configs in dotfiles repo
3. **Machine-specific**: Use `site-specific/` directory
4. **Document changes**: Comment complex configurations

## Troubleshooting

### 1Password CLI Issues

```bash
# Re-authenticate
op signout
op signin --account aculich@gmail.com

# Check vault/item names
op vault list
op item list --vault develop
```

### Direnv Not Loading

```bash
# Check direnv is allowed
direnv status
direnv allow

# Check .envrc syntax
direnv export zsh
```

### Cursor Terminal Issues

```bash
# Verify shell
echo $SHELL

# Check if config is loaded
echo $ZSH

# Reload config
source ~/.zshrc
```

## Migration from Old Setup

If migrating from an existing setup:

1. **Backup everything**:
   ```bash
   cp ~/.zshrc ~/.zshrc.old
   cp ~/.envrc ~/.envrc.old
   ```

2. **Migrate secrets** using the migration script

3. **Test new config** in a new terminal session

4. **Gradually adopt** - you can keep old configs as backups

## Resources

- [1Password CLI Documentation](https://developer.1password.com/docs/cli)
- [Direnv Documentation](https://direnv.net/)
- [Oh My Zsh Documentation](https://ohmyz.sh/)
- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles)
- [Awesome AI DevTools](https://github.com/jamesmurdza/awesome-ai-devtools)

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the configuration files
3. Run `dev_check` to diagnose issues
4. Check 1Password CLI and direnv documentation

