# Cursor Configuration Integration Plan

This document outlines how Cursor configuration management integrates with the toolchain-2026 project patterns and architecture.

**Last Updated**: 2026-01-11

## Overview

The goal is to align Cursor configuration management with toolchain-2026's layered, reproducible approach while maintaining Cursor as the central development tool ("chef's knife").

## Toolchain-2026 Patterns

### Layered Architecture

Toolchain-2026 uses a **Spacemacs-style layered approach**:

```
Layer 0: Base (Core CLI tools, shell, mise, 1Password)
Layer 1: AI (Cursor, Warp, Ollama, MCP servers)
Layer 2: Web (uv, Node.js, browsers, databases)
Layer 3: Data (Pixi, R, Jupyter)
Layer 4: Cloud (Docker, GCP, Kubernetes, Terraform)
Layer 5: Mobile (Xcode, Android Studio, Flutter)
```

### Key Principles

1. **Layered Installation**: Start minimal, add what you need
2. **Reproducible**: Brewfiles + lockfiles everywhere
3. **Secure**: 1Password references, never plaintext secrets
4. **Learnable**: Upstream repos for best practices
5. **Future-ready**: Nix/Devbox paths preserved

## Cursor Integration Points

### 1. Bootstrap Integration

**Current**: Cursor is installed in Layer 1 (AI layer) via `Brewfile.ai`

**Integration**:
- Cursor installation is already part of toolchain-2026 bootstrap
- After bootstrap, Cursor config should be automatically set up
- Symlinks should be created as part of post-bootstrap configuration

**Proposed Script**: `toolchain-2026/scripts/setup-cursor-config.sh`

```bash
#!/bin/bash
# Setup Cursor configuration after bootstrap
# Part of Layer 1 (AI) installation

# Clone or link dotfiles if not already done
# Create symlinks for Cursor config
# Install base extensions
# Setup MCP configuration
```

### 2. MCP Configuration Alignment

**Current State**:
- Global MCP config: `~/.cursor/mcp.json` (minimal: context7, repomix)
- Project MCP configs: `.cursor/mcp.json` (via toolboxes)
- MCP toolboxes: `~/dotfiles/cursor/mcp-toolboxes/`

**Toolchain-2026 MCP Pattern**:
- MCP servers organized by layer
- Base Layer: Core MCP dependencies
- AI Layer: Cursor-specific MCP servers
- Use-case layers: Specialized MCP servers

**Integration Strategy**:

1. **Align MCP Installation**:
   - Use toolchain-2026's `install-mcp-servers.sh` for MCP server installation
   - Integrate with `Brewfile.mcp-base` and `Brewfile.ai`

2. **Unify MCP Configuration**:
   - Global config: `~/.cursor/mcp.json` (minimal, always-on)
   - Project configs: `.cursor/mcp.json` (toolbox-based)
   - Toolbox definitions: Share between `dotfiles/cursor/mcp-toolboxes/` and `toolchain-2026/mcp/`

3. **MCP Management Scripts**:
   - Leverage `toolchain-2026/scripts/mcp-manager.sh`
   - Use `toolchain-2026/scripts/mcp-health-check.sh`
   - Integrate `activate-mcp-toolbox.sh` with toolchain scripts

### 3. Extension Management Alignment

**Current State**:
- Extension list: `~/dotfiles/cursor/extensions.list`
- Installation script: `~/dotfiles/cursor/install-extensions.sh`
- Extension profiles: Proposed (base + optional)

**Toolchain-2026 Pattern**:
- Layered installation approach
- Profile-based package management

**Integration Strategy**:

1. **Extension Profiles**:
   - Base profile: Core extensions (always installed)
   - Layer profiles: Extensions by toolchain layer
     - AI layer: Cursor-specific extensions
     - Web layer: Web development extensions
     - Data layer: Data science extensions
     - Cloud layer: Cloud/DevOps extensions

2. **Extension Installation**:
   - Integrate with `toolchain-2026/scripts/manage-cursor-extensions.sh`
   - Use profile-based installation: `install-extensions.sh --profile base`
   - Align with `install.sh --ai` layer installation

3. **Extension Tracking**:
   - Track extensions in dotfiles
   - Version control extension lists
   - Document extension rationale

### 4. Configuration Sync Strategy

**Current State**:
- Manual symlink creation
- Partial symlink coverage (settings, keybindings)
- Missing: MCP, hooks, rules

**Toolchain-2026 Pattern**:
- Configuration preservation scripts
- Config sync and backup utilities

**Integration Strategy**:

1. **Unified Sync Script**:
   - Create `toolchain-2026/scripts/sync-cursor-config.sh`
   - Integrate with existing `preserve-configs.sh` and `restore-configs.sh`
   - Support both workhorse and sidequest machines

2. **Configuration Backup**:
   - Use `toolchain-2026/scripts/archive-configs.sh` for Cursor configs
   - Backup before symlink creation
   - Archive old snapshots

3. **Cross-Machine Sync**:
   - Dotfiles repository as single source of truth
   - Symlink creation on new machines
   - Validation scripts for consistency

### 5. Script Organization

**Current Scripts** (in `~/dotfiles/cursor/`):
- `dump-cursor-windows.sh` - Workspace snapshots
- `view-cursor-snapshots.sh` - View snapshots
- `install-extensions.sh` - Extension installation
- `scripts/activate-mcp-toolbox.sh` - MCP toolbox activation

**Toolchain-2026 Scripts** (in `toolchain-2026/scripts/`):
- `setup-cursor-mcp.sh` - MCP setup
- `manage-cursor-extensions.sh` - Extension management
- `mcp-manager.sh` - MCP server management
- `preserve-configs.sh` - Config preservation

**Integration Strategy**:

1. **Script Consolidation**:
   - Move Cursor-specific scripts to `toolchain-2026/scripts/`
   - Keep dotfiles scripts minimal (just symlink targets)
   - Create unified Cursor management interface

2. **Script Naming Convention**:
   - `setup-cursor-*.sh` - Initial setup
   - `manage-cursor-*.sh` - Ongoing management
   - `sync-cursor-*.sh` - Synchronization
   - `validate-cursor-*.sh` - Validation

3. **Script Integration**:
   - Cursor scripts callable from toolchain-2026
   - Shared utilities and helpers
   - Consistent error handling and logging

## Implementation Roadmap

### Phase 1: Foundation (Current)

✅ **Completed**:
- Configuration inventory
- Current state documentation
- Extension analysis
- MCP configuration mapping
- Symlink strategy design

### Phase 2: Symlink Creation (Immediate)

⏳ **Next Steps**:
1. Create symlinks for pending configurations:
   - `mcp.json`
   - `hooks.json`
   - `rules/`
   - `hooks_blueplane/`

2. Create symlink management scripts:
   - `sync-cursor-config.sh`
   - `validate-symlinks.sh`

3. Update extension list:
   - Current extensions (96) documented

### Phase 3: Toolchain Integration (Short-term)

⏳ **Planned**:
1. **Script Integration**:
   - Move Cursor scripts to `toolchain-2026/scripts/`
   - Create unified Cursor management interface
   - Integrate with toolchain installation flow

2. **MCP Alignment**:
   - Align MCP installation with toolchain layers
   - Integrate MCP toolbox system
   - Share MCP configuration patterns

3. **Extension Profiles**:
   - Create base extension profile
   - Create layer-based extension profiles
   - Integrate with `install.sh --ai`

### Phase 4: Advanced Features (Medium-term)

📋 **Future**:
1. **Automated Sync**:
   - Automated config sync on toolchain updates
   - Cross-machine configuration sync
   - Conflict resolution strategies

2. **Configuration Templates**:
   - Cursor config templates for different use cases
   - Project-specific config templates
   - Team configuration sharing

3. **Monitoring & Health Checks**:
   - Symlink validation in health checks
   - Extension compatibility monitoring
   - MCP server health integration

## Directory Structure Integration

### Current Structure

```
~/dotfiles/cursor/          # Dotfiles repository
  ├── settings.json         # ✅ Symlinked
  ├── keybindings.json      # ✅ Symlinked
  ├── mcp.json              # ⏳ Pending symlink
  ├── hooks.json             # ⏳ Pending symlink
  ├── rules/                 # ⏳ Pending symlink
  ├── hooks_blueplane/       # ⏳ Pending symlink
  ├── mcp-toolboxes/        # Version controlled
  ├── scripts/               # Management scripts
  └── extensions.list        # Extension inventory

~/.cursor/                  # Live configuration
  ├── mcp.json              # ⏳ Should symlink to dotfiles
  ├── hooks.json             # ⏳ Should symlink to dotfiles
  ├── rules/                 # ⏳ Should symlink to dotfiles
  ├── hooks_blueplane/       # ⏳ Should symlink to dotfiles
  ├── chats/                 # ❌ Runtime data
  ├── projects/              # ❌ Runtime data
  └── plans/                 # ❌ Runtime data

~/tools/toolchain-2026/     # Toolchain project
  ├── scripts/
  │   ├── setup-cursor-mcp.sh
  │   ├── manage-cursor-extensions.sh
  │   └── sync-cursor-config.sh (to be created)
  └── mcp/
      └── mcp-config.json
```

### Proposed Integrated Structure

```
~/dotfiles/cursor/          # Dotfiles (source of truth)
  ├── configs/              # User configurations
  │   ├── settings.json
  │   ├── keybindings.json
  │   ├── mcp.json
  │   ├── hooks.json
  │   └── rules/
  ├── toolboxes/            # MCP toolboxes
  ├── profiles/             # Extension profiles
  │   ├── base.list
  │   ├── web-dev.list
  │   └── cloud.list
  └── scripts/              # Minimal scripts (symlink targets)

~/.cursor/                  # Live (symlinks to dotfiles)
  └── [symlinks to dotfiles/configs/*]

~/tools/toolchain-2026/     # Toolchain (orchestration)
  ├── scripts/
  │   ├── setup-cursor.sh   # Complete Cursor setup
  │   ├── sync-cursor-config.sh
  │   └── validate-cursor.sh
  └── mcp/
      └── [shared MCP configs]
```

## Shared Patterns

### 1. Layered Configuration

**Toolchain Pattern**: Layers 0-5 for different tool categories

**Cursor Application**:
- Base: Core editor config (settings, keybindings)
- Layer 1: AI tools (MCP, extensions)
- Layer 2+: Use-case specific (web, cloud, data)

### 2. Profile-Based Management

**Toolchain Pattern**: Profile-based package installation

**Cursor Application**:
- Base extension profile
- Layer-based extension profiles
- MCP toolbox profiles

### 3. Script-Based Automation

**Toolchain Pattern**: Comprehensive script library

**Cursor Application**:
- Setup scripts
- Management scripts
- Validation scripts
- Sync scripts

### 4. Documentation-Driven

**Toolchain Pattern**: Extensive documentation

**Cursor Application**:
- Configuration inventory
- Current state documentation
- Extension analysis
- Integration plans

## Benefits of Integration

1. **Consistency**: Unified approach across all tooling
2. **Reproducibility**: Same setup on workhorse and sidequest
3. **Maintainability**: Centralized script management
4. **Extensibility**: Easy to add new layers/profiles
5. **Documentation**: Comprehensive docs for all components

## Migration Path

### For Workhorse (Current Machine)

1. Complete symlink creation for pending configs
2. Test symlink validation
3. Integrate scripts with toolchain-2026
4. Document integration

### For Sidequest (Experimental Machine)

1. Clone toolchain-2026
2. Run bootstrap
3. Run Cursor setup script
4. Verify symlinks
5. Test extension profiles

## Success Criteria

✅ **Configuration Management**:
- All user configs symlinked
- Runtime data properly excluded
- Symlinks validated and working

✅ **Toolchain Integration**:
- Cursor setup integrated with bootstrap
- Scripts organized in toolchain-2026
- MCP configuration aligned

✅ **Documentation**:
- Complete configuration inventory
- Clear integration plan
- Usage documentation

✅ **Reproducibility**:
- Same setup on multiple machines
- Automated configuration sync
- Version-controlled configurations

## Next Steps

1. **Immediate** (This week):
   - Create symlinks for pending configs
   - Create symlink management scripts
   - Test validation scripts

2. **Short-term** (This month):
   - Integrate scripts with toolchain-2026
   - Create extension profiles
   - Align MCP configuration

3. **Medium-term** (Next quarter):
   - Advanced sync features
   - Configuration templates
   - Health check integration

## References

- [Toolchain-2026 README](../../tools/toolchain-2026/README.md)
- [MCP Layer Guide](../../tools/toolchain-2026/docs/MCP_LAYER_GUIDE.md)
- [Configuration Inventory](./CONFIG_INVENTORY.md)
- [Current State](./CURRENT_STATE.md)
- [Symlink Strategy](./SYMLINK_STRATEGY.md)
- [Extension Analysis](./EXTENSIONS_ANALYSIS.md)
