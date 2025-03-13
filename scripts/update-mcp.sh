#!/bin/bash

# Update GitHub MCP server package
echo "Updating GitHub MCP server package..."
npm install -g @modelcontextprotocol/server-github

# Check if the GitHub token is set
if [ -z "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
    echo "Warning: GITHUB_PERSONAL_ACCESS_TOKEN environment variable is not set"
    echo "You need to set this in your environment or update the config file at:"
    echo "~/Library/Application Support/Cursor/User/mcp/config.json"
fi

echo "GitHub MCP server has been updated"
echo "To use it with Cursor, make sure you've updated your settings.json with:"
echo "\"cursor.experimental.anthropic.claude.modelContextProtocol\": true"
echo "\"cursor.experimental.anthropic.claude.modelContextProtocolPath\": \"~/Library/Application Support/Cursor/User/mcp/config.json\"" 