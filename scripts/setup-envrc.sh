#!/usr/bin/env bash
# Setup new .envrc using 1Password
# This script creates a new ~/.envrc that loads secrets from 1Password
# Last updated: 2025-11-28

set -euo pipefail

ENVRC_FILE="$HOME/.envrc"
BACKUP_FILE="$HOME/.envrc.backup.$(date +%Y%m%d_%H%M%S)"
TEMPLATE_FILE="$HOME/dotfiles/zsh/.envrc.template"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "=========================================="
echo "Setup New .envrc with 1Password"
echo "=========================================="
echo ""

# Check prerequisites
if ! command -v op &> /dev/null; then
    echo -e "${RED}Error: 1Password CLI (op) not found${NC}"
    exit 1
fi

# Check 1Password authentication
if ! op account list &> /dev/null; then
    echo -e "${YELLOW}Warning: Not signed in to 1Password${NC}"
    echo "Please sign in first: op signin --account aculich@gmail.com"
    exit 1
fi

# Backup existing .envrc if it exists
if [[ -f "$ENVRC_FILE" ]]; then
    echo "Backing up existing .envrc..."
    cp "$ENVRC_FILE" "$BACKUP_FILE"
    echo -e "${GREEN}✓ Backup created: $BACKUP_FILE${NC}"
    echo ""
fi

# Get vault and item information
echo "1Password Configuration:"
echo ""

# List available vaults
echo "Available vaults:"
op vault list
echo ""

read -p "Vault name [develop]: " VAULT_NAME
VAULT_NAME=${VAULT_NAME:-develop}

# Verify vault exists
if ! op vault list | grep -q "^$VAULT_NAME"; then
    echo -e "${YELLOW}Vault '$VAULT_NAME' not found${NC}"
    read -p "Create it? [y/N]: " CREATE_VAULT
    if [[ "$CREATE_VAULT" =~ ^[Yy]$ ]]; then
        op vault create "$VAULT_NAME" --description "Development API keys and credentials"
        echo -e "${GREEN}✓ Vault created${NC}"
    else
        echo "Aborted."
        exit 1
    fi
fi

echo ""
read -p "Item name [apikeys]: " ITEM_NAME
ITEM_NAME=${ITEM_NAME:-apikeys}

# Verify item exists (optional)
if op item get "$ITEM_NAME" --vault "$VAULT_NAME" &> /dev/null; then
    echo -e "${GREEN}✓ Item found${NC}"
else
    echo -e "${YELLOW}Item '$ITEM_NAME' not found in vault '$VAULT_NAME'${NC}"
    echo "You can create it later in 1Password or use the migration script."
    read -p "Continue? [Y/n]: " CONTINUE
    if [[ "$CONTINUE" =~ ^[Nn]$ ]]; then
        exit 0
    fi
fi

echo ""
echo "Creating new .envrc..."

# Create new .envrc
cat > "$ENVRC_FILE" <<EOF
# .envrc - Global Environment Variables
# This file is loaded by direnv for the home directory
# 
# SECURITY: Uses 1Password CLI to securely load secrets
# Never commit secrets directly to this file!
#
# Setup:
# 1. Ensure you're signed in: op signin --account aculich@gmail.com
# 2. Allow direnv: direnv allow
#
# ============================================================================
# 1PASSWORD CONFIGURATION
# ============================================================================
export OP_VAULT="${VAULT_NAME}"
export OP_ITEM="${ITEM_NAME}"

# ============================================================================
# LOAD SECRETS FROM 1PASSWORD
# ============================================================================
# Load all secrets from the 1Password item
# This requires the op_load_item function from ~/dotfiles/zsh/functions.zsh
if command -v op_load_item &> /dev/null; then
    op_load_item "\$OP_VAULT" "\$OP_ITEM" || {
        echo "Warning: Could not load secrets from 1Password" >&2
        echo "Run: op signin --account aculich@gmail.com" >&2
    }
else
    # Source functions if not already loaded
    if [[ -f "\$HOME/dotfiles/zsh/functions.zsh" ]]; then
        source "\$HOME/dotfiles/zsh/functions.zsh"
        op_load_item "\$OP_VAULT" "\$OP_ITEM" || true
    else
        echo "Warning: op_load_item function not found. Install dotfiles config." >&2
    fi
fi

# ============================================================================
# GLOBAL ENVIRONMENT VARIABLES (Non-secret)
# ============================================================================
# Add global, non-sensitive environment variables here
# Examples:
# export EDITOR="code"
# export LANG="en_US.UTF-8"

# ============================================================================
# TOOL-SPECIFIC CONFIGURATIONS
# ============================================================================
# Example: Google Cloud (if needed globally)
# use_google_cloud "default"
EOF

echo -e "${GREEN}✓ New .envrc created${NC}"
echo ""

# Test direnv
if command -v direnv &> /dev/null; then
    echo "Testing direnv..."
    if direnv allow "$HOME" 2>/dev/null; then
        echo -e "${GREEN}✓ Direnv allowed for home directory${NC}"
    else
        echo -e "${YELLOW}Note: You may need to run 'direnv allow' manually${NC}"
    fi
else
    echo -e "${YELLOW}Warning: direnv not found. Install with: brew install direnv${NC}"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Verify 1Password authentication: op account list"
echo "2. Test loading secrets: cd ~ && direnv allow"
echo "3. Check environment: dev_check"
echo ""
echo "If you have existing secrets to migrate, run:"
echo "  ~/dotfiles/scripts/migrate-secrets-to-1password.sh"
echo ""

