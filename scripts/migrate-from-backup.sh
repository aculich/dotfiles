#!/usr/bin/env bash
# Migrate secrets from backup .envrc file to 1Password
# This uses the backed-up .envrc that has all the actual secrets

set -euo pipefail

ENVRC_BACKUP="$HOME/dotfiles-backup-20251128_180919/.envrc"
VAULT_NAME="Development"
ITEM_NAME="Development API Keys"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ ! -f "$ENVRC_BACKUP" ]]; then
    echo -e "${RED}Error: Backup file not found: $ENVRC_BACKUP${NC}"
    exit 1
fi

echo "=========================================="
echo "Migrating Secrets from Backup"
echo "=========================================="
echo ""
echo "Source: $ENVRC_BACKUP"
echo ""

# Get vault ID (use first Development vault)
VAULT_ID=$(op vault list | grep -i "Development" | head -1 | awk '{print $1}')
if [[ -z "$VAULT_ID" ]]; then
    echo -e "${RED}Error: Could not find Development vault${NC}"
    exit 1
fi

echo "Using vault: $VAULT_NAME (ID: $VAULT_ID)"
echo ""

# Extract secrets
echo "Extracting secrets..."
SECRETS=()
while IFS= read -r line; do
    if [[ "$line" =~ ^export[[:space:]]+([A-Z_][A-Z0-9_]*)=(.+)$ ]]; then
        VAR_NAME="${BASH_REMATCH[1]}"
        VALUE="${BASH_REMATCH[2]}"
        VALUE="${VALUE#\"}"
        VALUE="${VALUE%\"}"
        VALUE="${VALUE#\'}"
        VALUE="${VALUE%\'}"
        
        # Skip if value looks like a 1Password reference, is empty, or is a direnv command
        if [[ "$VALUE" =~ ^op:// ]] || [[ -z "$VALUE" ]] || [[ "$VALUE" =~ ^use_ ]]; then
            continue
        fi
        
        SECRETS+=("$VAR_NAME|$VALUE")
        echo "  Found: $VAR_NAME"
    fi
done < "$ENVRC_BACKUP"

if [[ ${#SECRETS[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No secrets found to migrate${NC}"
    exit 0
fi

echo ""
echo "Found ${#SECRETS[@]} secrets to migrate"
echo ""
read -p "Continue? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Creating JSON template..."

# Build JSON
TEMP_JSON=$(mktemp)
cat > "$TEMP_JSON" <<EOF
{
  "title": "$ITEM_NAME",
  "category": "API_CREDENTIAL",
  "fields": [
EOF

FIRST=true
for secret in "${SECRETS[@]}"; do
    IFS='|' read -r var_name value <<< "$secret"
    value_json=$(printf '%s' "$value" | jq -Rs .)
    
    if [[ "$FIRST" == "true" ]]; then
        FIRST=false
    else
        echo "," >> "$TEMP_JSON"
    fi
    
    cat >> "$TEMP_JSON" <<FIELDEOF
    {
      "id": "${var_name,,}",
      "label": "$var_name",
      "type": "CONCEALED",
      "value": $value_json
    }
FIELDEOF
done

cat >> "$TEMP_JSON" <<EOF
  ]
}
EOF

echo "Attempting to create item in 1Password..."
echo ""

# Try to create the item with category flag
if op item create --vault "$VAULT_ID" --category "API Credential" < "$TEMP_JSON" 2>&1; then
    echo ""
    echo -e "${GREEN}✓ Item created successfully!${NC}"
    rm "$TEMP_JSON"
    echo ""
    echo "Next steps:"
    echo "1. Verify: op item get \"$ITEM_NAME\" --vault \"$VAULT_NAME\""
    echo "2. Test loading: op_load_item \"$VAULT_NAME\" \"$ITEM_NAME\""
    echo "3. Your .envrc is already configured to use this item"
else
    echo ""
    echo -e "${YELLOW}⚠ Automatic creation failed${NC}"
    echo ""
    echo "JSON template saved to: $TEMP_JSON"
    echo ""
    echo "You can:"
    echo "1. Create the item manually in 1Password app"
    echo "2. Or try: op item create --vault \"$VAULT_ID\" < \"$TEMP_JSON\""
    echo ""
    echo "The JSON contains all ${#SECRETS[@]} secrets in the correct format."
fi

