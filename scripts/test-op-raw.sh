#!/usr/bin/env bash
# Raw 1Password CLI test script
# This uses only raw `op` commands to debug what works
# Run this to see what actually works, then we'll fix the scripts accordingly

set -e

echo "=========================================="
echo "Raw 1Password CLI Test"
echo "=========================================="
echo ""

# Check if op is installed
if ! command -v op &> /dev/null; then
    echo "Error: 1Password CLI (op) not found"
    exit 1
fi

echo "1. Listing all accounts:"
echo "------------------------"
op account list
echo ""

# Get account UUID for aculich@gmail.com
echo "2. Getting account UUID for aculich@gmail.com:"
echo "-----------------------------------------------"
ACCOUNT_UUID=$(op account list --format json 2>/dev/null | jq -r '.[] | select(.email == "aculich@gmail.com") | .account_uuid' 2>/dev/null || \
    op account list 2>/dev/null | grep -i "aculich@gmail.com" | awk '{print $3}' | head -1)

if [[ -z "$ACCOUNT_UUID" ]]; then
    echo "Error: Could not find account UUID for aculich@gmail.com"
    exit 1
fi

echo "Account UUID: $ACCOUNT_UUID"
echo ""

# Check if signed in
echo "3. Checking if signed in:"
echo "-------------------------"
if op account list --account "$ACCOUNT_UUID" &> /dev/null; then
    echo "✓ Signed in to aculich@gmail.com"
else
    echo "✗ Not signed in. Attempting to sign in..."
    op signin --account "$ACCOUNT_UUID" || {
        echo "Error: Failed to sign in"
        exit 1
    }
fi
echo ""

# List vaults
echo "4. Listing vaults:"
echo "------------------"
op vault list --account "$ACCOUNT_UUID"
echo ""

# List items in develop vault
echo "5. Listing items in 'develop' vault:"
echo "-------------------------------------"
op item list --vault "develop" --account "$ACCOUNT_UUID"
echo ""

# Get apikeys item details
echo "6. Getting 'apikeys' item details (JSON):"
echo "------------------------------------------"
ITEM_JSON=$(op item get "apikeys" --vault "develop" --account "$ACCOUNT_UUID" --format json 2>/dev/null)

if [[ -z "$ITEM_JSON" ]]; then
    echo "Error: Could not retrieve item 'apikeys' from vault 'develop'"
    exit 1
fi

echo "$ITEM_JSON" | jq '.' 2>/dev/null || echo "$ITEM_JSON"
echo ""

# Extract field names
echo "7. Extracting field names:"
echo "--------------------------"
if command -v jq &> /dev/null; then
    echo "Field names (labels):"
    echo "$ITEM_JSON" | jq -r '.fields[]? | select(.label) | .label' 2>/dev/null | sort
    echo ""
    echo "All fields with types:"
    echo "$ITEM_JSON" | jq -r '.fields[]? | "\(.label // .id) [\(.type // "unknown")]"' 2>/dev/null | sort
else
    echo "Install jq for better output: brew install jq"
    echo "$ITEM_JSON"
fi
echo ""

# Test reading a specific field
echo "8. Testing field reads:"
echo "----------------------"
if command -v jq &> /dev/null; then
    FIRST_FIELD=$(echo "$ITEM_JSON" | jq -r '.fields[]? | select(.label) | .label' 2>/dev/null | head -1)
    if [[ -n "$FIRST_FIELD" ]]; then
        echo "Reading field: $FIRST_FIELD"
        op read "op://develop/apikeys/$FIRST_FIELD" --account "$ACCOUNT_UUID" 2>/dev/null | head -c 20
        echo "..."
        echo ""
    fi
fi

# Test op inject
echo "9. Testing op inject:"
echo "---------------------"
cat > /tmp/test-env.1password <<EOF
# Test template
TEST_FIELD=op://develop/apikeys/OPENAI_API_KEY
EOF

echo "Template file:"
cat /tmp/test-env.1password
echo ""

echo "Running: op inject -i /tmp/test-env.1password"
if op inject -i /tmp/test-env.1password --account "$ACCOUNT_UUID" 2>&1; then
    echo "✓ op inject succeeded"
else
    echo "✗ op inject failed"
fi

rm -f /tmp/test-env.1password
echo ""

echo "=========================================="
echo "Test Complete"
echo "=========================================="

