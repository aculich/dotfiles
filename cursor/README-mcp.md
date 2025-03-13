# Anthropic Model Context Protocol (MCP) for Cursor

This document describes the Model Context Protocol setup for Cursor, which enables Claude to interact with external tools like GitHub.

## What is MCP?

The Model Context Protocol (MCP) is Anthropic's protocol for connecting Claude with external tools and services. It allows Claude to:

- Access and manipulate external data sources
- Execute code and commands in controlled environments
- Integrate with APIs and services
- Work with files and repositories

## GitHub MCP Server

The GitHub MCP server enables Claude to interact with GitHub repositories, providing capabilities like:

- Creating or updating files in repositories
- Pushing multiple files in a single commit
- Searching repositories, code, issues, and users
- Creating and managing issues and pull requests
- Accessing file contents and repository information

## Setup Instructions

1. Make sure the MCP configuration is enabled in Cursor's settings.json:
   ```json
   "cursor.experimental.anthropic.claude.modelContextProtocol": true,
   "cursor.experimental.anthropic.claude.modelContextProtocolPath": "~/Library/Application Support/Cursor/User/mcp/config.json"
   ```

2. Create a GitHub Personal Access Token (PAT) with appropriate permissions.

3. Update the MCP configuration file with your token:
   ```
   ~/Library/Application Support/Cursor/User/mcp/config.json
   ```
   
   Replace `YOUR_GITHUB_TOKEN` with your actual GitHub Personal Access Token.

4. Keep the MCP server package updated by running:
   ```
   ./scripts/update-mcp.sh
   ```

## Usage

When you chat with Claude in Cursor, it can now access the GitHub MCP server to perform operations on GitHub repositories.

Example commands:
- "Create a new file in my repository"
- "Search for issues related to X"
- "Update the README with new documentation"
- "Create a pull request for these changes"

## Troubleshooting

- If Claude can't access GitHub, check that your token has the necessary permissions.
- Make sure the NPM package is installed: `npm list -g @modelcontextprotocol/server-github`
- Check Cursor's logs for any MCP-related errors.

## References

- [Anthropic Model Context Protocol](https://modelcontextprotocol.io/)
- [MCP GitHub Server Repository](https://github.com/modelcontextprotocol/servers/tree/main/src/github) 