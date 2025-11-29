#!/usr/bin/env bash
# Populate 1Password item with secrets from backup .envrc
# This script adds all fields to the existing "Development API Keys" item

set -euo pipefail

ENVRC_BACKUP="$HOME/dotfiles/archive/old-configs-20251128_180919/.envrc"
VAULT_ID="y5l42cppvgu22o2obesu4ctla4"
ITEM_ID="yshcei6tjnutzbow46mx5ypu3y"
ITEM_NAME="Development API Keys"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [[ ! -f "$ENVRC_BACKUP" ]]; then
    echo -e "${RED}Error: Backup file not found: $ENVRC_BACKUP${NC}"
    exit 1
fi

echo "=========================================="
echo "Populating 1Password Item with Secrets"
echo "=========================================="
echo ""
echo "Item: $ITEM_NAME"
echo "Vault ID: $VAULT_ID"
echo "Source: $ENVRC_BACKUP"
echo ""

# Extract secrets
echo "Extracting secrets from backup..."
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
    fi
done < "$ENVRC_BACKUP"

if [[ ${#SECRETS[@]} -eq 0 ]]; then
    echo -e "${RED}No secrets found to migrate${NC}"
    exit 1
fi

echo "Found ${#SECRETS[@]} secrets to add"
echo ""

# Method 1: Try using op item edit with field assignments
# The op CLI supports: op item edit <item> --vault <vault> "section.field[fieldType]=value"

echo "Attempting to add fields using op item edit..."
echo "This may take a moment..."

# Build the edit command with all fields
# Note: op item edit can take multiple field assignments
EDIT_ARGS=()
for secret in "${SECRETS[@]}"; do
    IFS='|' read -r var_name value <<< "$secret"
    # Use custom field format: "sectionName.fieldName[CONCEALED]=value"
    # For API Credentials, we can use custom fields
    EDIT_ARGS+=("custom.${var_name}[CONCEALED]=${value}")
done

# op item edit has a limit on command line length, so we'll do it in batches
BATCH_SIZE=10
BATCH_NUM=0
TOTAL_BATCHES=$(( (${#SECRETS[@]} + BATCH_SIZE - 1) / BATCH_SIZE ))

echo "Adding fields in batches of $BATCH_SIZE ($TOTAL_BATCHES batches total)..."
echo ""

for ((i=0; i<${#SECRETS[@]}; i+=BATCH_SIZE)); do
    BATCH_NUM=$((BATCH_NUM + 1))
    BATCH_SECRETS=("${SECRETS[@]:$i:$BATCH_SIZE}")
    
    echo -n "Batch $BATCH_NUM/$TOTAL_BATCHES: Adding ${#BATCH_SECRETS[@]} fields... "
    
    # Build edit command for this batch
    BATCH_ARGS=()
    for secret in "${BATCH_SECRETS[@]}"; do
        IFS='|' read -r var_name value <<< "$secret"
        # Escape special characters in value for shell
        value_escaped=$(printf '%s' "$value" | sed "s/'/'\"'\"'/g")
        BATCH_ARGS+=("custom.${var_name}[CONCEALED]='${value_escaped}'")
    done
    
    # Try to edit the item with this batch
    if op item edit "$ITEM_ID" --vault "$VAULT_ID" "${BATCH_ARGS[@]}" 2>&1 | grep -v "^ID:" | grep -v "^Title:" | grep -v "^Vault:" | grep -v "^Updated:" | grep -v "^Favorite:" | grep -v "^Version:" | grep -v "^Category:" | grep -v "^Fields:" | grep -v "^[[:space:]]*valid from:" | grep -v "^[[:space:]]*expires:"; then
        echo -e "${RED}✗ Failed${NC}"
        echo "Trying alternative method..."
        break
    else
        echo -e "${GREEN}✓${NC}"
    fi
done

echo ""
echo "Verifying fields were added..."
FIELD_COUNT=$(op item get "$ITEM_ID" --vault "$VAULT_ID" --format json 2>/dev/null | jq '.fields | length' 2>/dev/null || echo "0")
echo "Current field count: $FIELD_COUNT"

if [[ "$FIELD_COUNT" -lt ${#SECRETS[@]} ]]; then
    echo ""
    echo -e "${YELLOW}⚠ Not all fields were added${NC}"
    echo "Trying alternative method: Creating JSON and using op item edit..."
    
    # Alternative: Create a complete JSON and use op item edit
    TEMP_JSON=$(mktemp)
    
    # Get current item structure
    op item get "$ITEM_ID" --vault "$VAULT_ID" --format json > "$TEMP_JSON.current" 2>/dev/null || true
    
    # Build new JSON with all fields
    cat > "$TEMP_JSON" <<EOF
{
  "title": "$ITEM_NAME",
  "category": "API_CREDENTIAL",
  "fields": [
EOF

    # Add template fields first (username, credential, etc.)
    op item get "$ITEM_ID" --vault "$VAULT_ID" --format json 2>/dev/null | \
        jq -r '.fields[]? | select(.id == "username" or .id == "credential" or .id == "notesPlain") | "    \(.),"' >> "$TEMP_JSON" 2>/dev/null || true
    
    # Add all custom fields
    FIRST_CUSTOM=true
    for secret in "${SECRETS[@]}"; do
        IFS='|' read -r var_name value <<< "$secret"
        value_json=$(printf '%s' "$value" | jq -Rs .)
        
        if [[ "$FIRST_CUSTOM" == "true" ]]; then
            FIRST_CUSTOM=false
            # Add comma if we had template fields
            if op item get "$ITEM_ID" --vault "$VAULT_ID" --format json 2>/dev/null | jq -e '.fields[]? | select(.id == "username")' > /dev/null 2>&1; then
                echo "," >> "$TEMP_JSON"
            fi
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
    
    echo "Updating item with complete JSON..."
    if op item edit "$ITEM_ID" --vault "$VAULT_ID" < "$TEMP_JSON" 2>&1; then
        echo -e "${GREEN}✓ Item updated with JSON method${NC}"
        rm "$TEMP_JSON" "$TEMP_JSON.current" 2>/dev/null || true
    else
        echo -e "${YELLOW}⚠ JSON method also failed${NC}"
        echo "JSON saved to: $TEMP_JSON"
        echo ""
        echo "You may need to use the 1Password app to import this JSON,"
        echo "or manually add fields using the app."
    fi
else
    echo -e "${GREEN}✓ All fields added successfully!${NC}"
fi

echo ""
echo "Final verification..."
FINAL_COUNT=$(op item get "$ITEM_ID" --vault "$VAULT_ID" --format json 2>/dev/null | jq '.fields | length' 2>/dev/null || echo "0")
echo "Total fields in item: $FINAL_COUNT"
echo "Expected: $((8 + ${#SECRETS[@]}))"  # 8 template fields + our secrets

if [[ "$FINAL_COUNT" -ge $((8 + ${#SECRETS[@]} - 5)) ]]; then
    echo -e "${GREEN}✓ Migration appears successful!${NC}"
    echo ""
    echo "Test loading secrets:"
    echo "  source ~/dotfiles/zsh/functions.zsh"
    echo "  op_load_item \"Development\" \"Development API Keys\" \"$VAULT_ID\""
else
    echo -e "${YELLOW}⚠ Some fields may be missing${NC}"
    echo "Check the item in 1Password app to verify."
fi

