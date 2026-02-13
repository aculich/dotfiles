#!/bin/bash
set -e

# Script to automatically detect .env files and sync with 1Password Environments
# This script can be called from Cursor agent or manually

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPERS_FILE="$SCRIPT_DIR/env_helpers.sh"

# Source helper functions
if [ -f "$HELPERS_FILE" ]; then
  source "$HELPERS_FILE"
else
  echo "Error: env_helpers.sh not found at $HELPERS_FILE" >&2
  exit 1
fi

# Default to current directory
PROJECT_ROOT="${1:-$(pwd)}"

echo "=========================================="
echo "1Password Environment Sync"
echo "=========================================="
echo ""
echo "Project root: $PROJECT_ROOT"
echo ""

# Run sync
if sync_env_to_1password "$PROJECT_ROOT"; then
  echo ""
  echo "=========================================="
  echo "Sync Complete"
  echo "=========================================="
  echo ""
  echo "Next steps:"
  echo "1. Follow the setup instructions generated above"
  echo "2. Create the 1Password Environment in the desktop app"
  echo "3. Import the .env file into the environment"
  echo "4. Enable the environment"
  echo ""
  exit 0
else
  echo ""
  echo "=========================================="
  echo "Sync Failed"
  echo "=========================================="
  echo ""
  exit 1
fi

