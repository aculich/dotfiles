# Professional Dotfiles Configuration

A professional, secure, and maintainable development environment setup following industry best practices for 2025.

## Features

- ✅ **Secure Secrets Management** - 1Password CLI integration for all API keys and credentials
- ✅ **Modular Zsh Configuration** - Clean, organized, and maintainable shell setup
- ✅ **Direnv Integration** - Project-specific environment variables
- ✅ **Cursor IDE Support** - Optimized for Cursor shell integration
- ✅ **Version Controlled** - All configs tracked in git (secrets excluded)
- ✅ **Best Practices** - Follows industry standards for professional development

## Quick Start

1. **Install prerequisites**:
   ```bash
   brew install direnv git jq
   brew install --cask 1password-cli
   ```

2. **Set up 1Password**:
   ```bash
   op signin --account aculich@gmail.com
   op vault create "develop" --description "Development API keys"
   ```

3. **Migrate existing secrets** (if you have them):
   ```bash
   ~/dotfiles/scripts/migrate-secrets-to-1password.sh
   ```

4. **Install configuration**:
   ```bash
   # Backup existing configs
   cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)
   cp ~/.envrc ~/.envrc.backup.$(date +%Y%m%d) 2>/dev/null || true
   
   # Create symlinks
   ln -sf ~/dotfiles/zsh/.zshrc.professional ~/.zshrc
   ln -sf ~/dotfiles/zsh/.zshenv.professional ~/.zshenv
   
   # Set up new .envrc
   ~/dotfiles/scripts/setup-envrc.sh
   
   # Reload shell
   exec zsh
   ```

5. **Verify setup**:
   ```bash
   dev_check
   ```

## Documentation

- **[Setup Guide](SETUP_GUIDE.md)** - Comprehensive setup instructions
- **[Migration Plan](MIGRATION_PLAN.md)** - Step-by-step migration from old setup
- **[Quick Reference](QUICK_REFERENCE.md)** - Common commands and troubleshooting
- **[GitHub Trending Setup](GITHUB_TRENDING_SETUP.md)** - Install and use `gh trending` and `ghtrend` on this machine or another
- **[FZF, jq, and friends](FZF_JQ_SETUP.md)** - fzf keybindings, jq/jqless/jqrepl, up, yq, glow, yt-x, and upstream clones

## Directory Structure

```
dotfiles/
├── zsh/
│   ├── .zshrc.professional      # Main zsh configuration
│   ├── .zshenv.professional      # Environment setup (non-interactive)
│   ├── aliases.zsh               # Shell aliases
│   ├── functions.zsh             # Helper functions (1Password, etc.)
│   ├── .envrc.template           # Template for project .envrc files
│   └── site-specific/            # Machine-specific configurations
├── scripts/
│   ├── migrate-secrets-to-1password.sh  # Migrate secrets to 1Password
│   └── setup-envrc.sh                   # Setup new .envrc
├── SETUP_GUIDE.md                # Detailed setup guide
├── MIGRATION_PLAN.md             # Migration instructions
├── QUICK_REFERENCE.md            # Quick reference guide
├── GITHUB_TRENDING_SETUP.md      # GitHub trending (ghtrend / gh trending) setup
├── FZF_JQ_SETUP.md               # FZF, jq, yq, glow, up, yt-x setup and upstream clones
└── README.md                      # This file
```

## Key Components

### Zsh Configuration

- **Modular design** - Separated into logical files
- **Performance optimized** - Fast startup time
- **Oh My Zsh integration** - Uses Oh My Zsh with curated plugins
- **Cursor IDE support** - Optimized for Cursor terminal integration

### Secrets Management

- **1Password CLI** - All secrets stored in 1Password
- **Direnv integration** - Automatic loading via `.envrc` files
- **Helper functions** - Easy-to-use functions for loading secrets
- **No hardcoded secrets** - All credentials loaded dynamically

### Project Environments

- **Project-specific .envrc** - Each project can have its own environment
- **Template provided** - Easy setup for new projects
- **Version controlled** - `.envrc.template` in git, actual `.envrc` files ignored

## Best Practices

1. **Secrets**: Never commit secrets to git. Use 1Password for all API keys.
2. **Configuration**: Keep configs modular and well-documented.
3. **Version Control**: Track all dotfiles in git, exclude secrets.
4. **Testing**: Always test config changes in a new terminal session.
5. **Documentation**: Document any custom configurations you add.

## Troubleshooting

See [QUICK_REFERENCE.md](QUICK_REFERENCE.md) for common troubleshooting steps.

## Resources

- [1Password CLI Documentation](https://developer.1password.com/docs/cli)
- [Direnv Documentation](https://direnv.net/)
- [Oh My Zsh Documentation](https://ohmyz.sh/)
- [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles)

## License

Personal dotfiles - use as you wish.

