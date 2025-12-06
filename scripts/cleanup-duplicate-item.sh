#!/usr/bin/env bash
# Clean up the duplicate "Untitled APICredential" item

set -euo pipefail

VAULT_ID="y5l42cppvgu22o2obesu4ctla4"

echo "=========================================="
echo "Cleaning Up Duplicate Items"
echo "=========================================="
echo ""

# Find both items
DEVELOPMENT_ITEM=$(op item list --vault "$VAULT_ID" --format json | jq -r '.[] | select(.title == "apikeys") | .id' | head -1)
UNTITLED_ITEM=$(op item list --vault "$VAULT_ID" --format json | jq -r '.[] | select(.title == "Untitled APICredential") | .id' | head -1)

if [[ -z "$DEVELOPMENT_ITEM" ]]; then
    echo "Error: 'apikeys' item not found!"
    exit 1
fi

echo "Found items:"
echo "  ✓ apikeys: $DEVELOPMENT_ITEM"

if [[ -n "$UNTITLED_ITEM" ]]; then
    echo "  ⚠ Untitled APICredential: $UNTITLED_ITEM"
    echo ""
    
    # Check field counts
    DEV_COUNT=$(op item get "$DEVELOPMENT_ITEM" --vault "$VAULT_ID" --format json 2>/dev/null | jq '.fields | length' || echo "0")
    UNTITLED_COUNT=$(op item get "$UNTITLED_ITEM" --vault "$VAULT_ID" --format json 2>/dev/null | jq '.fields | length' || echo "0")
    
    echo "Field counts:"
    echo "  apikeys: $DEV_COUNT fields"
    echo "  Untitled APICredential: $UNTITLED_COUNT fields"
    echo ""
    
    if [[ "$UNTITLED_COUNT" -lt 10 ]]; then
        echo "The 'Untitled APICredential' item appears to be empty or nearly empty."
        echo "This was likely created during an earlier migration attempt."
        echo ""
        read -p "Delete the duplicate 'Untitled APICredential' item? [y/N]: " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            if op item delete "$UNTITLED_ITEM" --vault "$VAULT_ID" 2>&1; then
                echo "✓ Deleted duplicate item"
            else
                echo "✗ Failed to delete (you may need to delete it manually in 1Password app)"
            fi
        else
            echo "Skipped deletion"
        fi
    else
        echo "⚠ Warning: Untitled item has $UNTITLED_COUNT fields - might contain data!"
        echo "Review it in 1Password app before deleting."
    fi
else
    echo "  ✓ No duplicate found - all clean!"
fi

echo ""
echo "Final status:"
op item list --vault "$VAULT_ID" --format json | jq -r '.[] | "  - \(.title) (Fields: \(.fields | length))"'

