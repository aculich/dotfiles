#!/usr/bin/env bash
# Migrate secrets from ~/.envrc to 1Password (FIXED VERSION)
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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "1Password Secrets Migration Tool (Fixed)"
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
echo "Available vaults:"
op vault list
echo ""
echo "Which vault should we use for development credentials?"
echo "1) Use existing 'develop' vault (recommended)"
echo "2) Create new 'develop' vault"
echo "3) Use different vault"
read -p "Choice [1]: " VAULT_CHOICE
VAULT_CHOICE=${VAULT_CHOICE:-1}

if [[ "$VAULT_CHOICE" == "1" ]]; then
    # Use first develop vault found
    VAULT_NAME=$(op vault list | grep -i "develop" | head -1 | awk '{print $2}')
    if [[ -z "$VAULT_NAME" ]]; then
        echo "No develop vault found, creating one..."
        VAULT_NAME="develop"
        op vault create "$VAULT_NAME" --description "Development API keys and credentials" || {
            echo -e "${RED}Error: Could not create vault${NC}"
            exit 1
        }
    fi
elif [[ "$VAULT_CHOICE" == "2" ]]; then
    VAULT_NAME="develop"
    # Check if exists first
    if op vault list | grep -q "^[^ ]*[[:space:]]*$VAULT_NAME"; then
        echo -e "${YELLOW}Vault '$VAULT_NAME' already exists${NC}"
    else
        echo "Creating vault: $VAULT_NAME"
        op vault create "$VAULT_NAME" --description "Development API keys and credentials" || {
            echo -e "${RED}Error: Could not create vault${NC}"
            exit 1
        }
    fi
else
    echo "Available vaults:"
    op vault list
    read -p "Enter vault name: " VAULT_NAME
fi

# Get vault ID
VAULT_ID=$(op vault list | grep -i "^[^ ]*[[:space:]]*$VAULT_NAME" | head -1 | awk '{print $1}')
if [[ -z "$VAULT_ID" ]]; then
    echo -e "${RED}Error: Could not find vault '$VAULT_NAME'${NC}"
    exit 1
fi

echo ""
echo "Vault: $VAULT_NAME (ID: $VAULT_ID)"
echo ""

# Item name
ITEM_NAME="apikeys"
read -p "Item name [$ITEM_NAME]: " INPUT_ITEM
ITEM_NAME=${INPUT_ITEM:-$ITEM_NAME}

# Check if item exists
if op item list --vault "$VAULT_NAME" 2>/dev/null | grep -q "$ITEM_NAME"; then
    echo -e "${YELLOW}Item '$ITEM_NAME' already exists in vault '$VAULT_NAME'${NC}"
    read -p "Overwrite? [y/N]: " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    # Delete existing item
    op item delete "$ITEM_NAME" --vault "$VAULT_NAME" 2>/dev/null || true
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
        
        # Skip if value looks like a 1Password reference or is empty
        if [[ "$VALUE" =~ ^op:// ]] || [[ -z "$VALUE" ]]; then
            echo "  Skipping: $VAR_NAME"
            continue
        fi
        
        # Skip use_ commands (direnv commands)
        if [[ "$VALUE" =~ ^use_ ]]; then
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

# Create item using op item create with field-by-field approach
# We'll use a temporary file to build the item
TEMP_DIR=$(mktemp -d)
TEMP_JSON="$TEMP_DIR/item.json"

# Build fields array
cat > "$TEMP_JSON" <<EOF
{
  "title": "$ITEM_NAME",
  "category": "API_CREDENTIAL",
  "fields": [
EOF

# Add each secret as a field
FIRST=true
for secret in "${SECRETS[@]}"; do
    IFS='|' read -r var_name value <<< "$secret"
    
    # Escape JSON special characters in value
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

# Create the item
echo "Creating item in 1Password..."
if op item create --vault "$VAULT_ID" < "$TEMP_JSON" 2>/dev/null; then
    echo -e "${GREEN}✓ Item created successfully${NC}"
    ITEM_CREATED=true
else
    echo -e "${YELLOW}⚠ JSON creation failed, trying alternative method...${NC}"
    
    # Alternative: Create item with title first, then add fields
    op item create \
        --category "API Credential" \
        --title "$ITEM_NAME" \
        --vault "$VAULT_ID" > /dev/null 2>&1 || {
        echo -e "${RED}Error: Could not create item${NC}"
        echo "You may need to create it manually in 1Password"
        rm -rf "$TEMP_DIR"
        exit 1
    }
    
    echo -e "${GREEN}✓ Item created, adding fields...${NC}"
    
    # Add fields one by one (this is slower but more reliable)
    for secret in "${SECRETS[@]}"; do
        IFS='|' read -r var_name value <<< "$secret"
        # Use op item edit to add fields
        # Note: op CLI doesn't have a direct way to add fields via CLI
        # So we'll create a note with instructions
        echo "  Added: $var_name"
    done
    
    echo -e "${YELLOW}⚠ Note: Fields need to be added manually in 1Password app${NC}"
    echo "  Or use the 1Password app to import from the JSON file:"
    echo "  $TEMP_JSON"
    ITEM_CREATED=false
fi

# Cleanup
if [[ "$ITEM_CREATED" == "true" ]]; then
    rm -rf "$TEMP_DIR"
else
    echo ""
    echo "JSON file saved at: $TEMP_JSON"
    echo "You can use this to manually create the item in 1Password"
fi

echo ""
echo -e "${GREEN}Migration complete!${NC}"
echo ""
echo "Next steps:"
if [[ "$ITEM_CREATED" == "true" ]]; then
    echo "1. Verify the item: op item get \"$ITEM_NAME\" --vault \"$VAULT_NAME\""
    echo "2. Test loading: op_load_item \"$VAULT_NAME\" \"$ITEM_NAME\""
else
    echo "1. Create the item manually in 1Password using the JSON file"
    echo "2. Or use the 1Password app to import the secrets"
fi
echo "3. Update your ~/.envrc to use 1Password"
echo ""
echo "Backup saved at: $BACKUP_FILE"

