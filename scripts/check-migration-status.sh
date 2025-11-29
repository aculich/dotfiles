#!/usr/bin/env bash
# Check which fields were successfully added and which are missing

set -euo pipefail

ENVRC_BACKUP="$HOME/dotfiles/archive/old-configs-20251128_180919/.envrc"
VAULT_ID="y5l42cppvgu22o2obesu4ctla4"
ITEM_ID="yshcei6tjnutzbow46mx5ypu3y"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Migration Status Check"
echo "=========================================="
echo ""

# Get existing fields from 1Password
echo "Reading fields from 1Password item..."
EXISTING_FIELDS=$(op item get "$ITEM_ID" --vault "$VAULT_ID" --format json 2>/dev/null | \
    jq -r '.fields[]? | select(.section?.label == "custom" or (.label | test("^[A-Z_]+$"))) | .label' 2>/dev/null | sort)

# Extract expected fields from backup
echo "Reading expected fields from backup..."
EXPECTED_FIELDS=()
declare -A EXPECTED_VALUES

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
        
        EXPECTED_FIELDS+=("$VAR_NAME")
        EXPECTED_VALUES["$VAR_NAME"]="$VALUE"
    fi
done < "$ENVRC_BACKUP"

# Sort expected fields
IFS=$'\n' EXPECTED_SORTED=($(sort <<<"${EXPECTED_FIELDS[*]}"))
unset IFS

echo ""
echo "=========================================="
echo "Status Summary"
echo "=========================================="
echo ""

# Find missing fields
MISSING=()
PRESENT=()

for var in "${EXPECTED_FIELDS[@]}"; do
    if echo "$EXISTING_FIELDS" | grep -q "^${var}$"; then
        PRESENT+=("$var")
    else
        MISSING+=("$var")
    fi
done

echo -e "${GREEN}✓ Successfully Added: ${#PRESENT[@]}${NC}"
echo -e "${RED}✗ Missing: ${#MISSING[@]}${NC}"
echo ""

# Show missing fields
if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo "=========================================="
    echo -e "${RED}Missing Fields (${#MISSING[@]}):${NC}"
    echo "=========================================="
    for var in "${MISSING[@]}"; do
        echo "  ✗ $var"
    done
    echo ""
fi

# Show successfully added (first 20)
if [[ ${#PRESENT[@]} -gt 0 ]]; then
    echo "=========================================="
    echo -e "${GREEN}Successfully Added (showing first 20 of ${#PRESENT[@]}):${NC}"
    echo "=========================================="
    for i in "${!PRESENT[@]}"; do
        if [[ $i -lt 20 ]]; then
            echo "  ✓ ${PRESENT[$i]}"
        fi
    done
    if [[ ${#PRESENT[@]} -gt 20 ]]; then
        echo "  ... and $(( ${#PRESENT[@]} - 20 )) more"
    fi
    echo ""
fi

# Create retry script for missing fields
if [[ ${#MISSING[@]} -gt 0 ]]; then
    RETRY_SCRIPT="$HOME/dotfiles/scripts/retry-failed-fields.sh"
    cat > "$RETRY_SCRIPT" <<EOF
#!/usr/bin/env bash
# Retry adding failed fields

VAULT_ID="$VAULT_ID"
ITEM_ID="$ITEM_ID"

EOF
    
    for var in "${MISSING[@]}"; do
        value="${EXPECTED_VALUES[$var]}"
        value_escaped=$(printf '%q' "$value")
        cat >> "$RETRY_SCRIPT" <<FIELDEOF
echo -n "Adding $var... "
if op item edit "\$ITEM_ID" --vault "\$VAULT_ID" "custom.${var}[CONCEALED]=${value_escaped}" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

FIELDEOF
    done
    
    chmod +x "$RETRY_SCRIPT"
    echo "=========================================="
    echo "Retry Script Created"
    echo "=========================================="
    echo "Run this to retry failed fields:"
    echo "  $RETRY_SCRIPT"
    echo ""
fi

# Final count
FINAL_COUNT=$(op item get "$ITEM_ID" --vault "$VAULT_ID" --format json 2>/dev/null | jq '.fields | length' 2>/dev/null || echo "0")
echo "Total fields in item: $FINAL_COUNT"
echo "Expected total: $((8 + ${#EXPECTED_FIELDS[@]}))"  # 8 template fields + our secrets

