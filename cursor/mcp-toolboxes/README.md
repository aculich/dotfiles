# MCP Toolbox System

Project-specific MCP (Model Context Protocol) configuration toolboxes for Cursor. These are preassembled "kits" that provide exactly the tools you need for specific types of work, avoiding the performance issues that come from having too many MCPs enabled globally.

## Quick Start

```bash
cd /path/to/your/project
activate-mcp-toolbox web-dev
```

This creates `.cursor/mcp.json` in your project with the appropriate MCP servers enabled. **Restart Cursor** for changes to take effect.

## Available Toolboxes

### `minimal`
**Use when:** You need basic utilities that work everywhere
- `context7` - Documentation lookup
- `repomix` - Codebase analysis

**Best for:** Quick tasks, minimal overhead

### `web-dev`
**Use when:** Building web applications, frontend/backend development
- `context7` - Documentation lookup
- `repomix` - Codebase analysis
- `chrome-devtools` - Browser debugging

**Best for:** React, Vue, Next.js, web frameworks

### `cloud-infra`
**Use when:** Working with cloud infrastructure, deployments, DevOps
- `gcloud` - Google Cloud Platform operations
- `github` - GitHub repository management
- `repomix` - Codebase analysis

**Best for:** Terraform, Kubernetes, CI/CD, cloud deployments

### `ai-research`
**Use when:** AI/ML research, model exploration, data science
- `context7` - Documentation lookup
- `Hugging Face` - Model hub access
- `hf-mcp-server` - Hugging Face integration
- `Limitless` - AI research tools
- `repomix` - Codebase analysis

**Best for:** ML projects, model training, research papers

### `full-stack`
**Use when:** Complex projects requiring multiple integrations
- `github` - Version control and collaboration
- `Notion` - Documentation and knowledge management
- `repomix` - Codebase analysis
- `context7` - Documentation lookup
- `gcloud` - Cloud operations

**Best for:** Large projects, team collaboration, production systems

### `browser-automation`
**Use when:** Web scraping, browser testing, automation
- `Nanobrowser` - Lightweight browser automation
- `Browser Use` - Browser interaction tools
- `chrome-devtools` - Chrome debugging
- `repomix` - Codebase analysis

**Best for:** E2E testing, web scraping, browser automation

## How It Works

1. **Global Config** (`~/.cursor/mcp.json`): Minimal, always-on utilities (context7, repomix)
2. **Project Config** (`.cursor/mcp.json`): Project-specific toolboxes activated as needed
3. **Toolbox Library**: Pre-configured bundles in `cursor/mcp-toolboxes/`

Cursor prioritizes project-specific configs over global configs, so you get exactly what you need per project.

## Usage Patterns

### Starting a New Project
```bash
cd new-project
activate-mcp-toolbox web-dev
# Restart Cursor
```

### Switching Context
```bash
# Working on cloud infrastructure now
activate-mcp-toolbox cloud-infra
# Restart Cursor
```

### Creating Custom Toolboxes
1. Copy an existing toolbox: `cp web-dev.json my-custom.json`
2. Edit `my-custom.json` to add/remove MCPs
3. Use it: `activate-mcp-toolbox my-custom`

## Troubleshooting

**Toolbox not found?**
- Check available toolboxes: `activate-mcp-toolbox` (no args)
- Toolboxes are in: `cursor/mcp-toolboxes/*.json`

**MCPs not working after activation?**
- Restart Cursor completely
- Check `.cursor/mcp.json` exists in your project
- Verify JSON syntax is valid

**Want to disable MCPs for a project?**
- Delete `.cursor/mcp.json` in the project
- Or create an empty one: `echo '{"mcpServers":{}}' > .cursor/mcp.json`

## Architecture

```
~/.cursor/mcp.json              # Global (minimal)
  └─ context7, repomix

.cursor/mcp.json                # Project-specific (toolbox)
  └─ Selected MCPs from toolbox

cursor/mcp-toolboxes/           # Toolbox definitions
  ├─ web-dev.json
  ├─ cloud-infra.json
  └─ ...
```

## Best Practices

1. **Start minimal**: Use `minimal` toolbox unless you need specific tools
2. **One toolbox per project**: Don't mix toolboxes
3. **Restart after changes**: Cursor needs a restart to pick up MCP changes
4. **Version control**: Commit `.cursor/mcp.json` to share toolbox choice with team
5. **Custom toolboxes**: Create project-specific toolboxes for unique needs

## Adding New Toolboxes

1. Create a new JSON file in `cursor/mcp-toolboxes/`
2. Follow the structure of existing toolboxes
3. Document it in this README
4. Test with `activate-mcp-toolbox <name>`

## See Also

- [MCP Documentation](https://modelcontextprotocol.info)
- [Cursor MCP Setup](../README-mcp.md)
- [SLOW Landscape Tracking](../../../tools/toolchain-2026/mcp-landscape/)
