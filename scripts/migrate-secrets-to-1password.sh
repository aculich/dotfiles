#!/usr/bin/env bash
# Migrate secrets from ~/.envrc to 1Password
# This script helps migrate hardcoded secrets to 1Password vaults
# Last updated: 2025-11-28

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENVRC_FILE="$HOME/.envrc"
BACKUP_FILE="$HOME/.envrc.backup.$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "1Password Secrets Migration Tool"
echo "=========================================="
echo ""

# Check prerequisites
if ! command -v op &> /dev/null; then
    echo -e "${RED}Error: 1Password CLI (op) not found${NC}"
    echo "Install it with: brew install --cask 1password-cli"
    exit 1
fi

# Check 1Password authentication
if ! op account list &> /dev/null; then
    echo -e "${YELLOW}Warning: Not signed in to 1Password${NC}"
    echo "Please sign in first:"
    echo "  op signin --account aculich@gmail.com"
    exit 1
fi

# Show current account
CURRENT_ACCOUNT=$(op account list | grep '*' | awk '{print $2}' || echo "")
echo "Using 1Password account: ${CURRENT_ACCOUNT:-aculich@gmail.com}"
echo ""

# Check if .envrc exists
if [[ ! -f "$ENVRC_FILE" ]]; then
    echo -e "${RED}Error: $ENVRC_FILE not found${NC}"
    exit 1
fi

# Backup original .envrc
echo "Creating backup: $BACKUP_FILE"
cp "$ENVRC_FILE" "$BACKUP_FILE"
echo -e "${GREEN}✓ Backup created${NC}"
echo ""

# Parse .envrc and extract secrets
echo "Analyzing $ENVRC_FILE..."
echo ""

# Vault selection
echo "Which vault should we use for development credentials?"
echo "1) Create new 'develop' vault (recommended)"
echo "2) Use existing vault"
read -p "Choice [1]: " VAULT_CHOICE
VAULT_CHOICE=${VAULT_CHOICE:-1}

if [[ "$VAULT_CHOICE" == "1" ]]; then
    VAULT_NAME="develop"
    # Check if vault exists, create if not
    if ! op vault list | grep -q "^$VAULT_NAME"; then
        echo "Creating vault: $VAULT_NAME"
        op vault create "$VAULT_NAME" --description "Development API keys and credentials"
        echo -e "${GREEN}✓ Vault created${NC}"
    else
        echo -e "${GREEN}✓ Vault exists${NC}"
    fi
else
    echo "Available vaults:"
    op vault list
    read -p "Enter vault name: " VAULT_NAME
fi

echo ""
echo "Vault: $VAULT_NAME"
echo ""

# Item name
ITEM_NAME="apikeys"
read -p "Item name [$ITEM_NAME]: " INPUT_ITEM
ITEM_NAME=${INPUT_ITEM:-$ITEM_NAME}

# Check if item exists
if op item get "$ITEM_NAME" --vault "$VAULT_NAME" &> /dev/null; then
    echo -e "${YELLOW}Item '$ITEM_NAME' already exists in vault '$VAULT_NAME'${NC}"
    read -p "Overwrite? [y/N]: " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo ""
echo "Extracting secrets from $ENVRC_FILE..."
echo ""

# Extract export statements
SECRETS=()
while IFS= read -r line; do
    # Match: export VAR_NAME=value
    if [[ "$line" =~ ^export[[:space:]]+([A-Z_][A-Z0-9_]*)=(.+)$ ]]; then
        VAR_NAME="${BASH_REMATCH[1]}"
        VALUE="${BASH_REMATCH[2]}"
        # Remove quotes if present
        VALUE="${VALUE#\"}"
        VALUE="${VALUE%\"}"
        VALUE="${VALUE#\'}"
        VALUE="${VALUE%\'}"
        
        # Skip if value looks like a 1Password reference
        if [[ "$VALUE" =~ ^op:// ]]; then
            echo "  Skipping (already 1Password): $VAR_NAME"
            continue
        fi
        
        SECRETS+=("$VAR_NAME|$VALUE")
        echo "  Found: $VAR_NAME"
    fi
done < "$ENVRC_FILE"

if [[ ${#SECRETS[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No secrets found to migrate${NC}"
    exit 0
fi

echo ""
echo "Found ${#SECRETS[@]} secrets to migrate"
echo ""
read -p "Continue with migration? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Creating 1Password item..."

# Build op item create command
OP_FIELDS=()
for secret in "${SECRETS[@]}"; do
    IFS='|' read -r var_name value <<< "$secret"
    # Escape special characters in value
    value_escaped=$(printf '%s' "$value" | sed "s/'/'\"'\"'/g")
    OP_FIELDS+=("${var_name}=${value}")
done

# Create the item using op CLI
# Note: op item create with multiple fields
TEMP_JSON=$(mktemp)
cat > "$TEMP_JSON" <<EOF
{
  "title": "$ITEM_NAME",
  "category": "API_CREDENTIAL",
  "fields": [
$(IFS=$'\n'
  for i in "${!SECRETS[@]}"; do
    IFS='|' read -r var_name value <<< "${SECRETS[$i]}"
    value_json=$(printf '%s' "$value" | jq -Rs .)
    echo "    {"
    echo "      \"id\": \"${var_name,,}\","
    echo "      \"label\": \"$var_name\","
    echo "      \"type\": \"CONCEALED\","
    echo "      \"value\": $value_json"
    if [[ $i -lt $((${#SECRETS[@]} - 1)) ]]; then
      echo "    },"
    else
      echo "    }"
    fi
  done
)
  ]
}
EOF

# Get vault ID (use first develop vault if multiple exist)
VAULT_ID=$(op vault list | grep -i "^[^ ]*[[:space:]]*$VAULT_NAME" | head -1 | awk '{print $1}')
if [[ -z "$VAULT_ID" ]]; then
    echo -e "${RED}Error: Could not find vault '$VAULT_NAME'${NC}"
    rm "$TEMP_JSON"
    exit 1
fi

echo "Using vault ID: $VAULT_ID"

# Create item using vault ID
if op item create --vault "$VAULT_ID" < "$TEMP_JSON" 2>&1; then
    echo -e "${GREEN}✓ Item created successfully${NC}"
    ITEM_CREATED=true
else
    # If creation failed, save JSON for manual import
    echo -e "${YELLOW}⚠ Could not create item automatically${NC}"
    echo "JSON template saved to: $TEMP_JSON"
    echo ""
    echo "You can:"
    echo "1. Create the item manually in 1Password app using this JSON"
    echo "2. Or use: op item create --vault \"$VAULT_ID\" < \"$TEMP_JSON\""
    echo ""
    read -p "Keep JSON file for manual import? [Y/n]: " KEEP_JSON
    if [[ "$KEEP_JSON" =~ ^[Nn]$ ]]; then
        rm "$TEMP_JSON"
    else
        echo "JSON saved at: $TEMP_JSON"
    fi
    ITEM_CREATED=false
fi

if [[ "$ITEM_CREATED" == "true" ]]; then
    rm "$TEMP_JSON"
fi

echo ""
if [[ "$ITEM_CREATED" == "true" ]]; then
    echo -e "${GREEN}Migration complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Verify the item: op item get \"$ITEM_NAME\" --vault \"$VAULT_NAME\""
    echo "2. Test loading secrets: op_load_item \"$VAULT_NAME\" \"$ITEM_NAME\""
else
    echo -e "${YELLOW}Migration partially complete${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Create the item manually in 1Password using the JSON file"
    echo "2. Or import the JSON using: op item create --vault \"$VAULT_ID\" < \"$TEMP_JSON\""
    echo "3. Then test loading: op_load_item \"$VAULT_NAME\" \"$ITEM_NAME\""
fi
echo "4. Update your ~/.envrc to use 1Password (already done if using setup script)"
echo ""
echo "Backup saved at: $BACKUP_FILE"

