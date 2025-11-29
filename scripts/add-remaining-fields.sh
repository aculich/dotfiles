#!/usr/bin/env bash
# Add remaining fields to 1Password item in smaller batches

set -euo pipefail

ENVRC_BACKUP="$HOME/dotfiles/archive/old-configs-20251128_180919/.envrc"
VAULT_ID="y5l42cppvgu22o2obesu4ctla4"
ITEM_ID="yshcei6tjnutzbow46mx5ypu3y"

# Get already added fields
EXISTING_FIELDS=$(op item get "$ITEM_ID" --vault "$VAULT_ID" --format json 2>/dev/null | \
    jq -r '.fields[]? | select(.section != null or (.label | startswith("OPENAI") | not)) | .label' 2>/dev/null || echo "")

# Extract all secrets
declare -A ALL_SECRETS
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
        
        ALL_SECRETS["$VAR_NAME"]="$VALUE"
    fi
done < "$ENVRC_BACKUP"

# Find missing fields
MISSING=()
for var in "${!ALL_SECRETS[@]}"; do
    if ! echo "$EXISTING_FIELDS" | grep -q "^${var}$"; then
        MISSING+=("$var")
    fi
done

echo "Found ${#MISSING[@]} fields still to add"
echo ""

# Add in batches of 5 (smaller batches for reliability)
BATCH_SIZE=5
BATCH_NUM=0

for ((i=0; i<${#MISSING[@]}; i+=BATCH_SIZE)); do
    BATCH_NUM=$((BATCH_NUM + 1))
    BATCH_VARS=("${MISSING[@]:$i:$BATCH_SIZE}")
    
    echo -n "Batch $BATCH_NUM: Adding ${#BATCH_VARS[@]} fields ("
    for var in "${BATCH_VARS[@]}"; do
        echo -n "$var "
    done
    echo -n ")... "
    
    # Build edit command
    EDIT_CMD="op item edit \"$ITEM_ID\" --vault \"$VAULT_ID\""
    for var in "${BATCH_VARS[@]}"; do
        value="${ALL_SECRETS[$var]}"
        # Escape for shell
        value_escaped=$(printf '%s' "$value" | sed "s/'/'\"'\"'/g")
        EDIT_CMD="$EDIT_CMD \"custom.${var}[CONCEALED]='${value_escaped}'\""
    done
    
    # Execute
    if eval "$EDIT_CMD" > /dev/null 2>&1; then
        echo "✓"
    else
        echo "✗"
        echo "Failed batch, trying individually..."
        for var in "${BATCH_VARS[@]}"; do
            value="${ALL_SECRETS[$var]}"
            value_escaped=$(printf '%s' "$value" | sed "s/'/'\"'\"'/g")
            if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.${var}[CONCEALED]='${value_escaped}'" > /dev/null 2>&1; then
                echo "  ✓ $var"
            else
                echo "  ✗ $var"
            fi
        done
    fi
    
    # Small delay to avoid rate limiting
    sleep 0.5
done

echo ""
echo "Final count:"
FINAL_COUNT=$(op item get "$ITEM_ID" --vault "$VAULT_ID" --format json 2>/dev/null | jq '.fields | length' 2>/dev/null || echo "0")
echo "Total fields: $FINAL_COUNT"

