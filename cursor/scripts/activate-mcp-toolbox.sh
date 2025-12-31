#!/bin/bash

# activate-mcp-toolbox.sh
# Activates a pre-configured MCP toolbox for the current project
#
# Usage: activate-mcp-toolbox <toolbox-name>
# Example: activate-mcp-toolbox web-dev

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLBOX_DIR="$(dirname "$SCRIPT_DIR")/mcp-toolboxes"

# Check if toolbox name was provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Toolbox name required${NC}"
    echo ""
    echo "Usage: activate-mcp-toolbox <toolbox-name>"
    echo ""
    echo "Available toolboxes:"
    ls -1 "$TOOLBOX_DIR"/*.json 2>/dev/null | sed 's|.*/||' | sed 's|\.json$||' | sed 's|^|  - |' || echo "  (none found)"
    exit 1
fi

TOOLBOX_NAME="$1"
TOOLBOX_FILE="$TOOLBOX_DIR/${TOOLBOX_NAME}.json"

# Check if toolbox exists
if [ ! -f "$TOOLBOX_FILE" ]; then
    echo -e "${RED}Error: Toolbox '${TOOLBOX_NAME}' not found${NC}"
    echo ""
    echo "Available toolboxes:"
    ls -1 "$TOOLBOX_DIR"/*.json 2>/dev/null | sed 's|.*/||' | sed 's|\.json$||' | sed 's|^|  - |' || echo "  (none found)"
    exit 1
fi

# Check if we're in a git repository (common indicator of a project)
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${YELLOW}Warning: Not in a git repository. Proceeding anyway...${NC}"
fi

# Create .cursor directory if it doesn't exist
PROJECT_CURSOR_DIR=".cursor"
if [ ! -d "$PROJECT_CURSOR_DIR" ]; then
    mkdir -p "$PROJECT_CURSOR_DIR"
    echo -e "${BLUE}Created .cursor directory${NC}"
fi

# Backup existing mcp.json if it exists
PROJECT_MCP_FILE="$PROJECT_CURSOR_DIR/mcp.json"
if [ -f "$PROJECT_MCP_FILE" ]; then
    BACKUP_FILE="${PROJECT_MCP_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$PROJECT_MCP_FILE" "$BACKUP_FILE"
    echo -e "${BLUE}Backed up existing mcp.json to $(basename "$BACKUP_FILE")${NC}"
fi

# Copy toolbox config to project
cp "$TOOLBOX_FILE" "$PROJECT_MCP_FILE"
echo -e "${GREEN}✓ Activated toolbox: ${TOOLBOX_NAME}${NC}"

# Validate JSON syntax
if command -v jq > /dev/null 2>&1; then
    if jq empty "$PROJECT_MCP_FILE" 2>/dev/null; then
        echo -e "${GREEN}✓ JSON syntax validated${NC}"
    else
        echo -e "${RED}✗ Warning: JSON syntax validation failed${NC}"
        exit 1
    fi
fi

# List activated MCPs
echo ""
echo -e "${BLUE}Activated MCP servers:${NC}"
if command -v jq > /dev/null 2>&1; then
    jq -r '.mcpServers | keys[]' "$PROJECT_MCP_FILE" | sed 's/^/  - /'
else
    grep -o '"[^"]*":' "$PROJECT_MCP_FILE" | sed 's/":$//' | sed 's/^"//' | sed 's/^/  - /'
fi

echo ""
echo -e "${YELLOW}Note: Restart Cursor for changes to take effect${NC}"
