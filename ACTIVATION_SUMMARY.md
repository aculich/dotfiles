# Activation Summary - What Will Happen

## Current State

### Files in $HOME (Real Files, Not Symlinks)
- `~/.zshrc` - Current zsh config (2296 bytes)
- `~/.zprofile` - Current zprofile (85 bytes)  
- `~/.envrc` - Contains 94+ hardcoded secrets (5858 bytes) ⚠️
- `~/.bashrc` - Bash config (681 bytes)
- `~/.bash_profile` - Bash profile (if exists)

### Files in dotfiles repo
- `zsh/.zshrc.professional` - New professional zsh config ✅
- `zsh/.zshenv.professional` - New environment setup ✅
- `zsh/functions.zsh` - Helper functions ✅
- `zsh/aliases.zsh` - Already symlinked to ~/.oh-my-zsh/custom/aliases.zsh ✅

## What the Activation Script Will Do

### 1. Create Backups
- **Backup Directory**: `~/dotfiles-backup-YYYYMMDD_HHMMSS/`
  - Copies all current config files
  - Includes rollback script
  - Safe location, won't be deleted

- **Archive Directory**: `~/dotfiles/archive/old-configs-YYYYMMDD_HHMMSS/`
  - Archived versions in git repo
  - For reference and version control

### 2. Handle .envrc Migration
- **Option 1** (Recommended): Migrate secrets to 1Password
  - Runs migration script
  - Creates 1Password item with all secrets
  - Sets up new .envrc using 1Password

- **Option 2**: Keep old .envrc as backup
  - Renames to .envrc.old
  - Creates new .envrc from template

- **Option 3**: Skip for now
  - Keeps old .envrc
  - You can migrate later

### 3. Install New Zsh Config
- Creates symlinks:
  - `~/.zshrc` → `~/dotfiles/zsh/.zshrc.professional`
  - `~/.zshenv` → `~/dotfiles/zsh/.zshenv.professional`
- Old files are backed up first
- Nothing is deleted, only backed up

### 4. Verify Setup
- Checks all symlinks are valid
- Verifies required files exist
- Ensures functions.zsh is accessible

### 5. Create Rollback Script
- Automatic rollback script in backup directory
- Can restore previous config instantly
- Safe and reversible

## What Gets Committed to Git

### New Files (Should Commit)
- `zsh/.zshrc.professional` ✅
- `zsh/.zshenv.professional` ✅
- `zsh/functions.zsh` ✅
- `zsh/.envrc.template` ✅
- `scripts/activate-new-config.sh` ✅
- `scripts/migrate-secrets-to-1password.sh` ✅
- `scripts/setup-envrc.sh` ✅
- All documentation files ✅

### Archive (Should Commit)
- `archive/old-configs-*/` - Historical backups ✅

### Should NOT Commit
- `~/.envrc` (if it contains secrets) ❌
- Any files with hardcoded secrets ❌
- Backup directories outside repo ❌

## After Activation

### Immediate Changes
1. Next shell session will use new config
2. Old configs are safely backed up
3. Rollback available if needed

### Next Steps
1. **Test the new config**: `dev_check`
2. **Set up .envrc** (if not done during activation):
   - Edit `~/.envrc` to set `OP_VAULT` and `OP_ITEM`
   - Run `direnv allow`
3. **Migrate secrets** (if skipped during activation):
   - Run `~/dotfiles/scripts/migrate-secrets-to-1password.sh`
4. **Verify everything works**:
   - Check environment variables load
   - Test Cursor terminal integration
   - Verify tools are accessible

## Safety Features

✅ **Full Backups** - Nothing is deleted, everything is backed up  
✅ **Rollback Script** - Easy to revert if needed  
✅ **Verification** - Script checks everything before completing  
✅ **Non-Destructive** - Old files preserved in multiple locations  
✅ **Reversible** - Can go back to old config anytime  

## Rollback Instructions

If something goes wrong:

```bash
# Run the rollback script
~/dotfiles-backup-YYYYMMDD_HHMMSS/rollback.sh

# Or manually restore
cp ~/dotfiles-backup-YYYYMMDD_HHMMSS/.zshrc ~/.zshrc
rm ~/.zshrc ~/.zshenv  # Remove symlinks
exec zsh
```

## Files That Will Be Active

After activation, these will be your active configs:

| File | Source | Type |
|------|--------|------|
| `~/.zshrc` | `~/dotfiles/zsh/.zshrc.professional` | Symlink |
| `~/.zshenv` | `~/dotfiles/zsh/.zshenv.professional` | Symlink |
| `~/.envrc` | New (1Password-based) or template | Real file |
| `~/.oh-my-zsh/custom/aliases.zsh` | `~/dotfiles/zsh/aliases.zsh` | Symlink (existing) |

## Ready to Activate?

Run:
```bash
~/dotfiles/scripts/activate-new-config.sh
```

The script will guide you through each step safely!

