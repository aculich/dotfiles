#!/bin/bash
set -e

unset OP_ACCOUNT
SERVICES_JSON="/Users/me/dotfiles/config/api-credentials/services.json"
VAULT="develop"

if [ ! -f "$SERVICES_JSON" ]; then
  echo "Error: services.json not found at $SERVICES_JSON"
  exit 1
fi

# Function to find service for a given env_key
find_service() {
  local env_key="$1"
  jq -r --arg key "$env_key" '
    to_entries[] | 
    select(.value.env_keys[] == $key) | 
    .key
  ' "$SERVICES_JSON" | head -1
}

# Function to get URLs for a service
get_urls() {
  local service="$1"
  jq -r --arg svc "$service" '
    .[$svc] | 
    "\(.platform_url)|\(.docs_url)|\(.key_management_url)"
  ' "$SERVICES_JSON"
}

# Get list of all credentials
echo "Fetching list of API credentials..."
unset OP_ACCOUNT
op item list --vault "$VAULT" --tags "migrated-from-apikeys" --format json | jq -r '.[].title' > /tmp/all_credentials.txt

count=0
updated=0
skipped=0
failed=0

echo "Adding URL fields to 1Password credentials..."
echo "This will add: platform URL, documentation URL, and key management URL"
echo ""

while read -r title; do
  # Find the service for this credential
  service=$(find_service "$title")
  
  if [ -z "$service" ] || [ "$service" = "null" ]; then
    printf "%-50s %s\n" "$title" "SKIPPED (no service mapping)"
    ((skipped++))
    ((count++))
    continue
  fi
  
  # Get URLs
  urls=$(get_urls "$service")
  IFS='|' read -r platform_url docs_url key_mgmt_url <<< "$urls"
  
  printf "%-50s " "$title"
  
  # Build edit command with all three URL fields
  edit_args=()
  fields_added=0
  
  # Add platform URL if available
  if [ "$platform_url" != "null" ] && [ -n "$platform_url" ]; then
    edit_args+=("platform URL[URL]=$platform_url")
    ((fields_added++))
  fi
  
  # Add documentation URL if available
  if [ "$docs_url" != "null" ] && [ -n "$docs_url" ]; then
    edit_args+=("documentation URL[URL]=$docs_url")
    ((fields_added++))
  fi
  
  # Add key management URL if available
  if [ "$key_mgmt_url" != "null" ] && [ -n "$key_mgmt_url" ]; then
    edit_args+=("key management URL[URL]=$key_mgmt_url")
    ((fields_added++))
  fi
  
  if [ ${#edit_args[@]} -eq 0 ]; then
    echo "SKIPPED (no URLs available)"
    ((skipped++))
    ((count++))
    continue
  fi
  
  # Update the item with all URL fields
  if op item edit "$title" --vault "$VAULT" "${edit_args[@]}" > /dev/null 2>&1; then
    echo "✓ ($fields_added URL field(s) added)"
    ((updated++))
  else
    echo "✗ (failed to update)"
    ((failed++))
  fi
  
  ((count++))
  
  # Small delay to avoid rate limiting
  sleep 0.1
done < /tmp/all_credentials.txt

echo ""
echo "Summary:"
echo "  Processed: $count"
echo "  Updated: $updated"
echo "  Skipped: $skipped"
if [ $failed -gt 0 ]; then
  echo "  Failed: $failed"
fi
echo ""
echo "All URL fields have been added to the credentials."
echo "You can now access these URLs directly from 1Password:"
echo "  - Platform URL: Opens the main platform website"
echo "  - Documentation URL: Opens the API documentation"
echo "  - Key Management URL: Opens the key management page (for credential rotation)"

