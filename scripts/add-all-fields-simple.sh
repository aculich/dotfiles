#!/usr/bin/env bash
# Simple script to add all remaining fields one by one

set -euo pipefail

ENVRC_BACKUP="$HOME/dotfiles/archive/old-configs-20251128_180919/.envrc"
VAULT_ID="y5l42cppvgu22o2obesu4ctla4"
ITEM_ID="yshcei6tjnutzbow46mx5ypu3y"

echo "Adding all fields from backup..."
echo ""

# Get existing fields
EXISTING=$(op item get "$ITEM_ID" --vault "$VAULT_ID" --format json 2>/dev/null | \
    jq -r '.fields[]? | select(.section?.label == "custom" or (.label | test("^[A-Z_]+$"))) | .label' 2>/dev/null || echo "")

# Process backup file
ADDED=0
FAILED=0

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
        
        # Skip if already exists
        if echo "$EXISTING" | grep -q "^${VAR_NAME}$"; then
            continue
        fi
        
        echo -n "Adding $VAR_NAME... "
        
        # Escape value properly
        value_escaped=$(printf '%q' "$VALUE")
        
        # Add field
        if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.${VAR_NAME}[CONCEALED]=${value_escaped}" > /dev/null 2>&1; then
            echo "✓"
            ADDED=$((ADDED + 1))
            # Update existing list
            EXISTING="$EXISTING"$'\n'"$VAR_NAME"
        else
            echo "✗"
            FAILED=$((FAILED + 1))
        fi
        
        # Small delay
        sleep 0.2
    fi
done < "$ENVRC_BACKUP"

echo ""
echo "Summary:"
echo "  Added: $ADDED"
echo "  Failed: $FAILED"
echo ""
echo "Final field count:"
op item get "$ITEM_ID" --vault "$VAULT_ID" --format json 2>/dev/null | jq '.fields | length' || echo "Error getting count"

