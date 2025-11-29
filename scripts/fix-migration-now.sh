#!/usr/bin/env bash
# Quick fix: Migrate secrets to 1Password using a simpler approach
# This creates a document item with all secrets, then you can manually create the API Credential item

set -euo pipefail

ENVRC_BACKUP="$HOME/dotfiles-backup-20251128_180919/.envrc"
VAULT_NAME="Development"
VAULT_ID=$(op vault list | grep -i "Development" | head -1 | awk '{print $1}')

if [[ -z "$VAULT_ID" ]]; then
    echo "Error: Could not find Development vault"
    exit 1
fi

echo "Using vault: $VAULT_NAME (ID: $VAULT_ID)"
echo ""

# Extract secrets and create a document item
echo "Creating document item with all secrets..."

# Create a formatted document with all secrets
TEMP_DOC=$(mktemp)
cat > "$TEMP_DOC" <<'EOFDOC'
# Development API Keys

This document contains all API keys and credentials migrated from ~/.envrc.

To use these in your .envrc, create an "API Credential" item in 1Password with the following fields:

EOFDOC

# Extract and format secrets
while IFS= read -r line; do
    if [[ "$line" =~ ^export[[:space:]]+([A-Z_][A-Z0-9_]*)=(.+)$ ]]; then
        VAR_NAME="${BASH_REMATCH[1]}"
        VALUE="${BASH_REMATCH[2]}"
        VALUE="${VALUE#\"}"
        VALUE="${VALUE%\"}"
        VALUE="${VALUE#\'}"
        VALUE="${VALUE%\'}"
        
        if [[ "$VALUE" =~ ^op:// ]] || [[ -z "$VALUE" ]] || [[ "$VALUE" =~ ^use_ ]]; then
            continue
        fi
        
        echo "" >> "$TEMP_DOC"
        echo "## $VAR_NAME" >> "$TEMP_DOC"
        echo "$VALUE" >> "$TEMP_DOC"
    fi
done < "$ENVRC_BACKUP"

# Create document item in 1Password
echo "Creating document item in 1Password..."
op item create \
    --category "Document" \
    --title "Development API Keys - Migration Backup" \
    --vault "$VAULT_ID" \
    "notesPlain=$(cat $TEMP_DOC)" 2>/dev/null && {
    echo "✓ Document item created"
    echo ""
    echo "Next: Create an 'API Credential' item manually in 1Password app"
    echo "  Name: 'Development API Keys'"
    echo "  Vault: Development"
    echo "  Then add each field from the document item"
} || {
    echo "⚠ Could not create document item"
    echo "Saving to file instead..."
    cp "$TEMP_DOC" "$HOME/dotfiles/archive/secrets-backup-$(date +%Y%m%d).md"
    echo "Saved to: $HOME/dotfiles/archive/secrets-backup-$(date +%Y%m%d).md"
}

rm "$TEMP_DOC"

echo ""
echo "For now, your .envrc is set up but pointing to a non-existent item."
echo "You have two options:"
echo "1. Create the item manually in 1Password app (recommended)"
echo "2. Temporarily use the old .envrc: cp $ENVRC_BACKUP ~/.envrc"

