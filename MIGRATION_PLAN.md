# Migration Plan: Professional Development Environment

This document outlines the step-by-step migration from your current setup to the new professional configuration.

## Current State Analysis

### Issues Identified

1. **🔴 CRITICAL SECURITY ISSUE**: `~/.envrc` contains 94+ lines of hardcoded API keys and secrets
2. **Configuration Fragmentation**: Multiple zsh config files with inconsistent structure
3. **No Secrets Management**: All credentials stored in plaintext
4. **Cursor Integration Issues**: Shell integration problems with current setup
5. **Version Control Gap**: Actual `~/.zshrc` differs from dotfiles repo version

### Current Files

- `~/.zshrc` - Active zsh config (different from dotfiles repo)
- `~/.envrc` - Contains hardcoded secrets (94 lines)
- `~/.zshenv` - Minimal pipx PATH setup
- `~/.zprofile` - Not present
- `~/dotfiles/zsh/.zshrc` - Different version in repo
- `~/dotfiles/zsh/aliases.zsh` - Symlinked to `~/.oh-my-zsh/custom/aliases.zsh`

## Migration Steps

### Phase 1: Preparation (Safe - No Changes)

1. ✅ **Audit Current Setup**
   ```bash
   # Review current configs
   cat ~/.zshrc
   cat ~/.envrc
   
   # Check 1Password setup
   op account list
   op vault list
   ```

2. ✅ **Backup Everything**
   ```bash
   # Create backup directory
   mkdir -p ~/dotfiles-backup-$(date +%Y%m%d)
   cp ~/.zshrc ~/dotfiles-backup-$(date +%Y%m%d)/
   cp ~/.envrc ~/dotfiles-backup-$(date +%Y%m%d)/
   cp ~/.zshenv ~/dotfiles-backup-$(date +%Y%m%d)/ 2>/dev/null || true
   ```

3. ✅ **Install/Verify Tools**
   ```bash
   # Verify 1Password CLI
   op --version
   
   # Verify direnv
   direnv --version
   
   # Sign in to 1Password
   op signin --account aculich@gmail.com
   ```

### Phase 2: Secrets Migration (Critical)

1. **Create 1Password Vault Structure**
   ```bash
   # Create develop vault
   op vault create "develop" --description "Development API keys and credentials"
   
   # Optional: Create separate vaults
   op vault create "Personal" --description "Personal credentials"
   ```

2. **Migrate Secrets**
   
   **Option A: Automated Migration (Recommended)**
   ```bash
   ~/dotfiles/scripts/migrate-secrets-to-1password.sh
   ```
   
   **Option B: Manual Migration**
   - Open 1Password app
   - Create new item: "apikeys"
   - Add each secret as a field
   - Use field labels matching environment variable names

3. **Verify Secrets in 1Password**
   ```bash
   # List items
   op item list --vault develop
   
   # View an item
   op item get "apikeys" --vault develop --format json | jq
   ```

### Phase 3: Configuration Migration

1. **Set Up New .envrc**
   ```bash
   # Run setup script
   ~/dotfiles/scripts/setup-envrc.sh
   
   # Or manually create from template
   cp ~/dotfiles/zsh/.envrc.template ~/.envrc
   # Edit to match your 1Password vault/item names
   ```

2. **Test New .envrc**
   ```bash
   # Allow direnv
   direnv allow ~
   
   # Test loading
   cd ~
   # Should see direnv loading message
   ```

3. **Migrate Zsh Configuration**
   
   **Option A: Replace (Clean Start)**
   ```bash
   # Backup current
   cp ~/.zshrc ~/.zshrc.old
   
   # Create symlink
   ln -sf ~/dotfiles/zsh/.zshrc.professional ~/.zshrc
   
   # Test in new terminal
   exec zsh
   ```
   
   **Option B: Gradual Migration**
   ```bash
   # Add to end of existing ~/.zshrc
   echo "" >> ~/.zshrc
   echo "# Source professional config" >> ~/.zshrc
   echo "[[ -f \"\$HOME/dotfiles/zsh/.zshrc.professional\" ]] && source \"\$HOME/dotfiles/zsh/.zshrc.professional\"" >> ~/.zshrc
   ```

4. **Set Up .zshenv**
   ```bash
   # Create symlink
   ln -sf ~/dotfiles/zsh/.zshenv.professional ~/.zshenv
   ```

### Phase 4: Verification & Testing

1. **Test New Configuration**
   ```bash
   # Open new terminal session
   # Run environment check
   dev_check
   ```

2. **Verify Secrets Loading**
   ```bash
   # Check if secrets are loaded
   echo $OPENAI_API_KEY  # Should show value from 1Password
   echo $GITHUB_TOKEN     # Should show value from 1Password
   ```

3. **Test Cursor Integration**
   - Open Cursor
   - Open integrated terminal
   - Verify `$SHELL` is `/bin/zsh`
   - Check that environment variables are loaded
   - Test running commands that need API keys

4. **Test Project-Specific .envrc**
   ```bash
   # Create test project
   mkdir -p ~/test-project
   cd ~/test-project
   
   # Create .envrc
   cp ~/dotfiles/zsh/.envrc.template .envrc
   # Edit to use different vault/item if needed
   
   # Allow direnv
   direnv allow
   
   # Verify it loads
   cd ~/test-project
   ```

### Phase 5: Cleanup (After Verification)

1. **Remove Old Secrets from .envrc**
   ```bash
   # The new .envrc should only have 1Password references
   # Old secrets are now in 1Password
   ```

2. **Update Git Configuration**
   ```bash
   # Ensure .envrc is in .gitignore if it contains any secrets
   # Add to .gitignore if needed:
   echo ".envrc" >> ~/.gitignore  # For projects
   ```

3. **Document Project-Specific Setups**
   - For each project, create `.envrc` using template
   - Document which 1Password vault/item to use
   - Add to project README if needed

## Rollback Plan

If something goes wrong:

1. **Restore Backups**
   ```bash
   cp ~/dotfiles-backup-YYYYMMDD/.zshrc ~/.zshrc
   cp ~/dotfiles-backup-YYYYMMDD/.envrc ~/.envrc
   exec zsh
   ```

2. **Revert Symlinks**
   ```bash
   rm ~/.zshrc ~/.zshenv
   # Restore from backup
   ```

3. **Re-authenticate 1Password**
   ```bash
   op signout
   op signin --account aculich@gmail.com
   ```

## Timeline Recommendation

- **Day 1**: Phase 1 & 2 (Preparation & Secrets Migration)
- **Day 2**: Phase 3 (Configuration Migration)
- **Day 3**: Phase 4 (Verification & Testing)
- **Day 4+**: Phase 5 (Cleanup & Optimization)

## Success Criteria

✅ All secrets migrated to 1Password  
✅ No hardcoded secrets in `~/.envrc`  
✅ New zsh config loads correctly  
✅ Cursor terminal integration works  
✅ Environment variables load from 1Password  
✅ Project-specific `.envrc` files work  
✅ `dev_check` passes all checks  

## Support Resources

- Setup Guide: `~/dotfiles/SETUP_GUIDE.md`
- Functions: `~/dotfiles/zsh/functions.zsh`
- Migration Script: `~/dotfiles/scripts/migrate-secrets-to-1password.sh`
- 1Password CLI Docs: https://developer.1password.com/docs/cli
- Direnv Docs: https://direnv.net/

