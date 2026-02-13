#!/bin/bash
set -e

unset OP_ACCOUNT
SERVICES_JSON="/Users/me/dotfiles/config/api-credentials/services.json"

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
op item list --vault "develop" --tags "migrated-from-apikeys" --format json | jq -r '.[].title' > /tmp/all_credentials.txt

count=0
updated=0
skipped=0
failed=0

echo "Updating 1Password entries with URLs..."
echo ""

while read -r title; do
  # Find the service for this credential
  service=$(find_service "$title")
  
  if [ -z "$service" ] || [ "$service" = "null" ]; then
    printf "%-50s %s\n" "$title" "SKIPPED (no service mapping)"
    ((skipped++))
    continue
  fi
  
  # Get URLs
  urls=$(get_urls "$service")
  IFS='|' read -r platform_url docs_url key_mgmt_url <<< "$urls"
  
  printf "%-50s " "$title"
  
  # Update hostname field with platform URL if available
  if [ "$platform_url" != "null" ] && [ -n "$platform_url" ]; then
    if op item edit "$title" --vault "develop" "hostname=$platform_url" > /dev/null 2>&1; then
      echo "✓ (platform: $platform_url)"
      ((updated++))
    else
      echo "✗ (failed to update)"
      ((failed++))
    fi
  else
    echo "SKIPPED (no platform URL)"
    ((skipped++))
  fi
  
  ((count++))
done < /tmp/all_credentials.txt

echo ""
echo "Summary:"
echo "  Processed: $count"
echo "  Updated: $updated"
echo "  Skipped: $skipped"
if [ $failed -gt 0 ]; then
  echo "  Failed: $failed"
fi
