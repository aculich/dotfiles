#!/usr/bin/env bash
# Activate New Professional Configuration
# This script safely migrates from old config to new, with full backups
# Last updated: 2025-11-28

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Timestamp for backups
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/dotfiles-backup-$TIMESTAMP"
ARCHIVE_DIR="$HOME/dotfiles-archive"

echo "=========================================="
echo "Activating New Professional Configuration"
echo "=========================================="
echo ""

# Step 1: Create backup directory
echo -e "${BLUE}Step 1: Creating backup directory...${NC}"
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN}✓ Backup directory: $BACKUP_DIR${NC}"
echo ""

# Step 2: Backup all existing config files
echo -e "${BLUE}Step 2: Backing up existing configuration files...${NC}"

BACKUP_FILES=(
    "$HOME/.zshrc"
    "$HOME/.zshenv"
    "$HOME/.zprofile"
    "$HOME/.envrc"
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
)

for file in "${BACKUP_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        cp "$file" "$BACKUP_DIR/$(basename $file)"
        echo -e "  ${GREEN}✓${NC} Backed up $(basename $file)"
    fi
done

# Also backup any existing backups
if [[ -f "$HOME/.envrc.bak" ]]; then
    cp "$HOME/.envrc.bak" "$BACKUP_DIR/.envrc.bak"
    echo -e "  ${GREEN}✓${NC} Backed up .envrc.bak"
fi

if [[ -f "$HOME/.zshrc-2025-11-01" ]]; then
    cp "$HOME/.zshrc-2025-11-01" "$BACKUP_DIR/.zshrc-2025-11-01"
    echo -e "  ${GREEN}✓${NC} Backed up .zshrc-2025-11-01"
fi

echo -e "${GREEN}✓ All files backed up${NC}"
echo ""

# Step 3: Archive old configs to dotfiles repo
echo -e "${BLUE}Step 3: Archiving old configs to dotfiles repo...${NC}"
mkdir -p "$HOME/dotfiles/archive/old-configs-$TIMESTAMP"

# Copy old configs to archive
for file in "${BACKUP_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        cp "$file" "$HOME/dotfiles/archive/old-configs-$TIMESTAMP/$(basename $file)"
    fi
done

echo -e "${GREEN}✓ Configs archived to: dotfiles/archive/old-configs-$TIMESTAMP${NC}"
echo ""

# Step 4: Check 1Password setup
echo -e "${BLUE}Step 4: Checking 1Password setup...${NC}"
if ! command -v op &> /dev/null; then
    echo -e "${YELLOW}⚠ Warning: 1Password CLI not found${NC}"
    echo "  Install with: brew install --cask 1password-cli"
    read -p "  Continue anyway? [y/N]: " CONTINUE
    if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
else
    if op account list &> /dev/null; then
        CURRENT_ACCOUNT=$(op account list | grep '*' | awk '{print $2}' || echo "")
        echo -e "${GREEN}✓ 1Password authenticated${NC} (Account: ${CURRENT_ACCOUNT:-unknown})"
    else
        echo -e "${YELLOW}⚠ 1Password not authenticated${NC}"
        echo "  Sign in with: op signin --account aculich@gmail.com"
        read -p "  Continue anyway? [y/N]: " CONTINUE
        if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    fi
fi
echo ""

# Step 5: Set up new .envrc (if .envrc exists and has secrets)
if [[ -f "$HOME/.envrc" ]]; then
    echo -e "${BLUE}Step 5: Handling .envrc migration...${NC}"
    
    # Check if .envrc has hardcoded secrets
    if grep -q "^export [A-Z_]*=" "$HOME/.envrc" 2>/dev/null; then
        echo -e "${YELLOW}⚠ Found secrets in .envrc${NC}"
        echo "  Options:"
        echo "  1) Migrate secrets to 1Password now (recommended)"
        echo "  2) Keep old .envrc as backup and create new one"
        echo "  3) Skip .envrc setup for now"
        read -p "  Choice [1]: " ENVRC_CHOICE
        ENVRC_CHOICE=${ENVRC_CHOICE:-1}
        
        case "$ENVRC_CHOICE" in
            1)
                echo "  Running migration script..."
                if [[ -f "$HOME/dotfiles/scripts/migrate-secrets-to-1password.sh" ]]; then
                    "$HOME/dotfiles/scripts/migrate-secrets-to-1password.sh" || {
                        echo -e "${YELLOW}⚠ Migration had issues, but continuing...${NC}"
                    }
                else
                    echo -e "${YELLOW}⚠ Migration script not found, skipping...${NC}"
                fi
                ;;
            2)
                echo "  Keeping old .envrc as .envrc.old"
                mv "$HOME/.envrc" "$HOME/.envrc.old"
                ;;
            3)
                echo "  Skipping .envrc setup"
                ;;
        esac
    fi
    
    # Set up new .envrc if old one was migrated or doesn't exist
    if [[ ! -f "$HOME/.envrc" ]] || [[ "$ENVRC_CHOICE" == "1" ]]; then
        echo "  Setting up new .envrc..."
        if [[ -f "$HOME/dotfiles/scripts/setup-envrc.sh" ]]; then
            "$HOME/dotfiles/scripts/setup-envrc.sh" || {
                echo -e "${YELLOW}⚠ Setup script had issues, creating from template...${NC}"
                cp "$HOME/dotfiles/zsh/.envrc.template" "$HOME/.envrc"
            }
        else
            echo "  Creating .envrc from template..."
            cp "$HOME/dotfiles/zsh/.envrc.template" "$HOME/.envrc"
            echo -e "${YELLOW}⚠ You'll need to edit ~/.envrc to set OP_VAULT and OP_ITEM${NC}"
        fi
    fi
else
    echo -e "${BLUE}Step 5: Creating new .envrc...${NC}"
    if [[ -f "$HOME/dotfiles/scripts/setup-envrc.sh" ]]; then
        "$HOME/dotfiles/scripts/setup-envrc.sh" || {
            cp "$HOME/dotfiles/zsh/.envrc.template" "$HOME/.envrc"
        }
    else
        cp "$HOME/dotfiles/zsh/.envrc.template" "$HOME/.envrc"
    fi
fi
echo ""

# Step 6: Install new zsh configuration
echo -e "${BLUE}Step 6: Installing new zsh configuration...${NC}"

# Backup current .zshrc
if [[ -f "$HOME/.zshrc" ]]; then
    echo "  Current .zshrc backed up to: $BACKUP_DIR/.zshrc"
fi

# Create symlink to new config
echo "  Creating symlink to new .zshrc.professional..."
ln -sf "$HOME/dotfiles/zsh/.zshrc.professional" "$HOME/.zshrc"
echo -e "${GREEN}✓ .zshrc symlinked${NC}"

# Set up .zshenv
echo "  Creating symlink to new .zshenv.professional..."
ln -sf "$HOME/dotfiles/zsh/.zshenv.professional" "$HOME/.zshenv"
echo -e "${GREEN}✓ .zshenv symlinked${NC}"

# Ensure functions.zsh is accessible
if [[ ! -f "$HOME/dotfiles/zsh/functions.zsh" ]]; then
    echo -e "${RED}✗ Error: functions.zsh not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ functions.zsh found${NC}"
echo ""

# Step 7: Verify setup
echo -e "${BLUE}Step 7: Verifying setup...${NC}"

# Check symlinks
if [[ -L "$HOME/.zshrc" ]]; then
    LINK_TARGET=$(readlink "$HOME/.zshrc")
    if [[ -f "$LINK_TARGET" ]]; then
        echo -e "${GREEN}✓ .zshrc symlink valid${NC}"
    else
        echo -e "${RED}✗ .zshrc symlink broken!${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ .zshrc is not a symlink!${NC}"
    exit 1
fi

if [[ -L "$HOME/.zshenv" ]]; then
    LINK_TARGET=$(readlink "$HOME/.zshenv")
    if [[ -f "$LINK_TARGET" ]]; then
        echo -e "${GREEN}✓ .zshenv symlink valid${NC}"
    else
        echo -e "${RED}✗ .zshenv symlink broken!${NC}"
        exit 1
    fi
fi

# Check that required files exist
REQUIRED_FILES=(
    "$HOME/dotfiles/zsh/.zshrc.professional"
    "$HOME/dotfiles/zsh/.zshenv.professional"
    "$HOME/dotfiles/zsh/functions.zsh"
    "$HOME/dotfiles/zsh/aliases.zsh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $(basename $file) exists"
    else
        echo -e "${RED}✗${NC} $(basename $file) missing!"
        exit 1
    fi
done

echo ""

# Step 8: Create rollback script
echo -e "${BLUE}Step 8: Creating rollback script...${NC}"
cat > "$BACKUP_DIR/rollback.sh" <<'ROLLBACK_EOF'
#!/usr/bin/env bash
# Rollback script - Restore previous configuration
# Generated: TIMESTAMP_PLACEHOLDER

set -e

BACKUP_DIR="BACKUP_DIR_PLACEHOLDER"

echo "Rolling back to previous configuration..."
echo "Restoring files from: $BACKUP_DIR"

if [[ ! -d "$BACKUP_DIR" ]]; then
    echo "Error: Backup directory not found: $BACKUP_DIR"
    exit 1
fi

# Remove symlinks
[[ -L ~/.zshrc ]] && rm ~/.zshrc
[[ -L ~/.zshenv ]] && rm ~/.zshenv

# Restore files
[[ -f "$BACKUP_DIR/.zshrc" ]] && cp "$BACKUP_DIR/.zshrc" ~/.zshrc
[[ -f "$BACKUP_DIR/.zshenv" ]] && cp "$BACKUP_DIR/.zshenv" ~/.zshenv
[[ -f "$BACKUP_DIR/.zprofile" ]] && cp "$BACKUP_DIR/.zprofile" ~/.zprofile
[[ -f "$BACKUP_DIR/.envrc" ]] && cp "$BACKUP_DIR/.envrc" ~/.envrc
[[ -f "$BACKUP_DIR/.bashrc" ]] && cp "$BACKUP_DIR/.bashrc" ~/.bashrc
[[ -f "$BACKUP_DIR/.bash_profile" ]] && cp "$BACKUP_DIR/.bash_profile" ~/.bash_profile

echo "Rollback complete! Restart your shell to apply changes."
ROLLBACK_EOF

# Replace placeholders
sed -i '' "s/TIMESTAMP_PLACEHOLDER/$TIMESTAMP/g" "$BACKUP_DIR/rollback.sh"
sed -i '' "s|BACKUP_DIR_PLACEHOLDER|$BACKUP_DIR|g" "$BACKUP_DIR/rollback.sh"
chmod +x "$BACKUP_DIR/rollback.sh"

echo -e "${GREEN}✓ Rollback script created: $BACKUP_DIR/rollback.sh${NC}"
echo ""

# Step 9: Summary
echo "=========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Backup location: $BACKUP_DIR"
echo "Archive location: $HOME/dotfiles/archive/old-configs-$TIMESTAMP"
echo ""
echo "To rollback, run: $BACKUP_DIR/rollback.sh"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Restart your shell or run: exec zsh"
echo "2. Test the new config: dev_check"
echo "3. If .envrc needs setup, edit ~/.envrc and run: direnv allow"
echo ""
echo -e "${BLUE}The new configuration is now active!${NC}"
echo ""

