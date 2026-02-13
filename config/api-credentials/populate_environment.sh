#!/bin/bash
set -e

unset OP_ACCOUNT
VAULT="develop"
ENV_FILE="${1:-/tmp/default-1234.env}"

echo "Exporting API credentials to .env format..."
echo "Output file: $ENV_FILE"
echo ""

# Get all credentials with the migrated-from-apikeys tag
credentials=$(op item list --vault "$VAULT" --tags "migrated-from-apikeys" --format json)

count=0
skipped=0

# Create/clear the output file
> "$ENV_FILE"

# Use process substitution to avoid subshell issues
while IFS= read -r title; do
  # Get the credential value
  item_json=$(op item get "$title" --vault "$VAULT" --reveal --format json 2>/dev/null)
  value=$(echo "$item_json" | jq -r '.fields[] | select(.label == "credential") | .value' 2>/dev/null)
  
  if [ -z "$value" ] || [ "$value" = "null" ]; then
    echo "Warning: No credential value found for $title" >&2
    ((skipped++))
    continue
  fi
  
  # Strip leading/trailing single quotes if present
  if [[ "$value" == \'*\' ]]; then
    value="${value:1:${#value}-2}"
  fi
  
  # For .env files, we need to handle special characters
  # If value contains spaces, quotes, or other special chars, wrap in quotes
  if [[ "$value" =~ [[:space:]\"\$\`] ]]; then
    # Escape backslashes and quotes, then wrap in double quotes
    value=$(echo "$value" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
    value="\"$value\""
  fi
  
  # Write to .env file
  echo "${title}=${value}" >> "$ENV_FILE"
  ((count++))
done < <(echo "$credentials" | jq -r '.[].title')

echo ""
echo "Export complete!"
echo "  Credentials exported: $count"
echo "  Skipped: $skipped"
echo "  Output file: $ENV_FILE"
echo ""
echo "Next steps:"
echo "1. Open 1Password desktop app"
echo "2. Go to Developer > Environments > default-1234"
echo "3. Click 'Import .env file'"
echo "4. Select: $ENV_FILE"
echo ""
echo "Or use the import instructions in: import_to_environment.md"
