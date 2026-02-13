# Cursor Configuration Inventory

This document provides a comprehensive inventory of all configuration files and directories in both the live Cursor configuration (`~/.cursor`) and the dotfiles repository (`~/dotfiles/cursor`).

**Last Updated**: 2026-01-11

## Directory Overview

### Live Configuration: `~/.cursor`
**Purpose**: Runtime directory where Cursor reads active configuration. This is the **source of truth** for the running Cursor instance.

**Location**: `/Users/me/.cursor`

### Dotfiles Repository: `~/dotfiles/cursor`
**Purpose**: Version-controlled configuration tracking. Contains tracked configs, scripts, and historical snapshots.

**Location**: `/Users/me/dotfiles/cursor`

---

## Configuration Files Inventory

### Core User Configuration Files

#### Settings (`settings.json`)
- **Live Location**: `~/Library/Application Support/Cursor/User/settings.json` (symlinked)
- **Dotfiles Location**: `~/dotfiles/cursor/settings.json`
- **Sync Strategy**: ✅ **SYMLINKED** - Live points to dotfiles
- **Purpose**: Editor settings, preferences, extension configurations
- **Status**: Active symlink confirmed

#### Keybindings (`keybindings.json`)
- **Live Location**: `~/Library/Application Support/Cursor/User/keybindings.json` (symlinked)
- **Dotfiles Location**: `~/dotfiles/cursor/keybindings.json`
- **Sync Strategy**: ✅ **SYMLINKED** - Live points to dotfiles
- **Purpose**: Custom keyboard shortcuts and key mappings
- **Status**: Active symlink confirmed

#### Settings Extra (`settings-extra.json`)
- **Location**: `~/dotfiles/cursor/settings-extra.json`
- **Sync Strategy**: ⚠️ **NOT SYMLINKED** - Not currently in use
- **Purpose**: Additional settings (possibly for merging or reference)

### MCP Configuration

#### Global MCP Config (`mcp.json`)
- **Live Location**: `~/.cursor/mcp.json`
- **Dotfiles Location**: None (not tracked)
- **Sync Strategy**: ⚠️ **NOT SYMLINKED** - Should be tracked
- **Purpose**: Global MCP server configurations
- **Current Content**: context7, repomix servers
- **Status**: Active, minimal configuration

#### MCP Backup Files
- `~/.cursor/mcp.json.bak` - Backup from May 2025
- `~/.cursor/mcp.json.2025-05-27` - Historical snapshot
- `~/.cursor/mcp__2025-05-25.json` - Historical snapshot
- `~/.cursor/mcp.json.disabled` - Disabled configuration
- `~/.cursor/mcp.json.latest-disabled` - Latest disabled version
- `~/.cursor/mcp.json.minimal` - Minimal configuration template
- `~/.cursor/mcp.json.lock` - Lock file (empty)

#### MCP Toolboxes
- **Location**: `~/dotfiles/cursor/mcp-toolboxes/`
- **Sync Strategy**: ✅ **VERSION CONTROLLED** - Project-specific MCP configs
- **Purpose**: Pre-configured MCP server bundles for different use cases
- **Toolboxes**:
  - `minimal.json` - Minimal MCP setup
  - `web-dev.json` - Web development tools
  - `full-stack.json` - Full-stack development
  - `cloud-infra.json` - Cloud infrastructure
  - `browser-automation.json` - Browser automation
  - `ai-research.json` - AI research tools
- **Activation**: Via `scripts/activate-mcp-toolbox.sh`

### Hooks Configuration

#### Hooks (`hooks.json`)
- **Live Location**: `~/.cursor/hooks.json`
- **Dotfiles Location**: None (not tracked)
- **Sync Strategy**: ⚠️ **NOT SYMLINKED** - Should be tracked
- **Purpose**: Cursor hooks for automation (beforeShellExecution, etc.)
- **Current Content**: 1Password validation hook

#### Hooks Blueplane (`hooks_blueplane/`)
- **Live Location**: `~/.cursor/hooks_blueplane/`
- **Dotfiles Location**: None (not tracked)
- **Sync Strategy**: ⚠️ **NOT SYMLINKED** - Advanced hook system
- **Purpose**: Python-based hook system with multiple hook points
- **Files**:
  - `after_agent_response.py`
  - `after_file_edit.py`
  - `after_mcp_execution.py`
  - `after_shell_execution.py`
  - `before_mcp_execution.py`
  - `before_read_file.py`
  - `before_shell_execution.py`
  - `before_submit_prompt.py`
  - `hook_base.py`
  - `send_session_event.py`
  - `stop.py`
  - `beforePromptSubmit.sh`

#### Hooks Backup
- `~/.cursor/hooks.json.blueplane` - Blueplane hooks configuration

### Rules Configuration

#### Rules Directory (`rules/`)
- **Live Location**: `~/.cursor/rules/`
- **Dotfiles Location**: None (not tracked)
- **Sync Strategy**: ⚠️ **NOT SYMLINKED** - Should be tracked
- **Purpose**: Cursor rules and patterns
- **Files**:
  - `01-version-snapshot.mdc` - Version snapshot rule
  - `shell-commands.mdc` - Shell command rules

### Extensions Management

#### Extension Lists
- **Current Extensions**: 96 installed (as of 2026-01-11)
- **Tracked Lists**:
  - `~/dotfiles/cursor/extensions.list` - Current/active list
  - `~/dotfiles/cursor/extensions.list-2025-10-02` - Snapshot from Oct 2, 2025 (127 extensions)
  - `~/dotfiles/cursor/extensions.list-2025-10-29` - Snapshot from Oct 29, 2025
- **Sync Strategy**: ✅ **VERSION CONTROLLED** - Manual updates
- **Installation Script**: `~/dotfiles/cursor/install-extensions.sh`

#### Extension Analysis
- **Changes since Oct 2025**: 
  - Removed: `anysphere.remote-ssh`, `bradlc.vscode-tailwindcss`, `codeandstuff.vscode-navigate-edit-history`, `docker.docker`, `expo.vscode-expo-tools`, `goodfoot.compare-branch`
  - Added: `akhaled.key-bindings-to-md`, `alexzheng111.kb-shortcut-learner`, `bodil.file-browser`, `bognaum.emmet-commands-and-keybindings`, `bpruitt-goddard.mermaid-markdown-syntax-highlighting`, `danielnichols.slurm-dashboard`, `donebd.vscode-keypromoter`, `eamodio.gitlens`, `esbenp.prettier-vscode`, `github.remotehub`

#### Extension Management Files (in `~/.cursor`)
- `extensions/` - Directory containing installed extensions
- `extensions/extensions.json` - Extension metadata
- `extensions-disabled-2025-11-22-01-20.md` - Disabled extensions log
- `extensions-removed-2025-11-22.md` - Removed extensions log
- `extensions-to-disable-settings.json` - Settings for disabling extensions

### CLI Configuration

#### CLI Config (`cli-config.json`)
- **Live Location**: `~/.cursor/cli-config.json`
- **Dotfiles Location**: None (not tracked)
- **Sync Strategy**: ⚠️ **NOT SYMLINKED** - Should be tracked
- **Purpose**: Cursor CLI configuration

#### Argv Config (`argv.json`)
- **Live Location**: `~/.cursor/argv.json`
- **Dotfiles Location**: None (not tracked)
- **Sync Strategy**: ⚠️ **NOT SYMLINKED** - Runtime configuration
- **Purpose**: Command-line arguments configuration

### Runtime Data (Should NOT be versioned)

#### Chats (`chats/`)
- **Live Location**: `~/.cursor/chats/`
- **Sync Strategy**: ❌ **DO NOT SYNC** - Runtime chat history
- **Purpose**: Chat conversation history
- **Contains**: Multiple chat session directories with databases

#### Projects (`projects/`)
- **Live Location**: `~/.cursor/projects/`
- **Sync Strategy**: ❌ **DO NOT SYNC** - Project-specific runtime data
- **Purpose**: Per-project Cursor state and configurations
- **Contains**: 195 project directories

#### Plans (`plans/`)
- **Live Location**: `~/.cursor/plans/`
- **Sync Strategy**: ⚠️ **OPTIONAL** - Could archive important plans
- **Purpose**: Cursor plan files (`.plan.md` files)
- **Contains**: 64+ plan files from various projects
- **Note**: Some plans might be valuable to archive, but most are runtime

#### Browser Logs (`browser-logs/`)
- **Live Location**: `~/.cursor/browser-logs/`
- **Sync Strategy**: ❌ **DO NOT SYNC** - Debug logs
- **Purpose**: Browser automation logs
- **Contains**: Timestamped snapshot logs

#### AI Tracking (`ai-tracking/`)
- **Live Location**: `~/.cursor/ai-tracking/`
- **Sync Strategy**: ❌ **DO NOT SYNC** - Analytics data
- **Purpose**: AI code tracking database
- **Contains**: `ai-code-tracking.db`

#### Worktrees (`worktrees/`)
- **Live Location**: `~/.cursor/worktrees/`
- **Sync Strategy**: ❌ **DO NOT SYNC** - Git worktree metadata
- **Purpose**: Git worktree management

#### Workers (`workers/`)
- **Live Location**: `~/.cursor/workers/`
- **Sync Strategy**: ❌ **DO NOT SYNC** - Runtime worker processes
- **Purpose**: Background worker processes

#### IDE State (`ide_state.json`)
- **Live Location**: `~/.cursor/ide_state.json`
- **Sync Strategy**: ❌ **DO NOT SYNC** - Runtime state
- **Purpose**: Current IDE state snapshot

#### Prompt History (`prompt_history.json`)
- **Live Location**: `~/.cursor/prompt_history.json`
- **Sync Strategy**: ❌ **DO NOT SYNC** - Runtime history
- **Purpose**: Prompt history tracking

### Application Support Symlink

#### ApplicationSupport
- **Location**: `~/dotfiles/cursor/ApplicationSupport` (symlink)
- **Target**: `~/Library/Application Support/Cursor/User`
- **Sync Strategy**: ✅ **SYMLINKED** - Provides access to User directory
- **Purpose**: Convenience symlink to User configuration directory
- **Status**: Active symlink confirmed

### Snapshot System

#### Workspace Snapshots
- **Location**: `~/dotfiles/cursor/cursor-workspace-*.{txt,json,extensions.txt}`
- **Sync Strategy**: ✅ **VERSION CONTROLLED** - Historical snapshots
- **Purpose**: Timestamped workspace state snapshots
- **Count**: 50+ snapshot sets (Oct 2025 - Jan 2026)
- **Scripts**:
  - `dump-cursor-windows.sh` - Create snapshots
  - `view-cursor-snapshots.sh` - View and compare snapshots

#### Snapshot Contents
Each snapshot includes:
- `.txt` - Full `cursor --status` output
- `.json` - Structured workspace data
- `-extensions.txt` - Extension list at time of snapshot

### Scripts

#### Management Scripts (`scripts/`)
- **Location**: `~/dotfiles/cursor/scripts/`
- **Sync Strategy**: ✅ **VERSION CONTROLLED**
- **Scripts**:
  - `activate-mcp-toolbox.sh` - Activate MCP toolbox for project

#### Root Scripts
- `dump-cursor-windows.sh` - Create workspace snapshot
- `view-cursor-snapshots.sh` - View snapshots
- `install-extensions.sh` - Install extensions from list
- `backup-cursor.sh` (in `~/.cursor/`) - Backup script

### Documentation

#### README Files
- `README.md` - Workspace snapshot tools documentation
- `README-cursor.md` - Cursor extension documentation
- `README-mcp.md` - MCP setup documentation

#### Analysis Documents
- `cursor-file-locations-analysis-2025-11-22.md` (in `~/.cursor/`) - File location analysis
- `missing.list` - Missing extensions list

### Git Repository

#### `.cursor/.git/`
- **Location**: `~/.cursor/.git/`
- **Sync Strategy**: ❌ **DO NOT SYNC** - Local git repo in runtime directory
- **Purpose**: Local version control for `~/.cursor` directory
- **Note**: This is unusual - runtime directory has its own git repo

---

## Configuration Categories Summary

### ✅ Should Be Version Controlled (Symlinked or Copied)

1. **Core Configs** (Already symlinked):
   - `settings.json` ✅
   - `keybindings.json` ✅

2. **MCP Configs** (Should be tracked):
   - `mcp.json` (global) ⚠️
   - `mcp-toolboxes/*.json` ✅

3. **Hooks** (Should be tracked):
   - `hooks.json` ⚠️
   - `hooks_blueplane/` ⚠️

4. **Rules** (Should be tracked):
   - `rules/*.mdc` ⚠️

5. **Extensions** (Already tracked):
   - `extensions.list*` ✅

6. **Scripts** (Already tracked):
   - All management scripts ✅

7. **Documentation** (Already tracked):
   - README files ✅

### ❌ Should NOT Be Version Controlled

1. **Runtime Data**:
   - `chats/` - Chat history
   - `projects/` - Project-specific state
   - `plans/` - Runtime plan files (maybe archive important ones)
   - `browser-logs/` - Debug logs
   - `ai-tracking/` - Analytics
   - `worktrees/` - Git metadata
   - `workers/` - Worker processes
   - `ide_state.json` - Current state
   - `prompt_history.json` - History

2. **Extensions Directory**:
   - `extensions/` - Installed extension files

3. **Git Repository**:
   - `.cursor/.git/` - Local git repo

### ⚠️ Needs Decision

1. **CLI Config**: `cli-config.json` - Might be user-specific
2. **Argv Config**: `argv.json` - Runtime configuration
3. **Plans**: Some plans might be valuable to archive

---

## Sync Strategy Recommendations

### Immediate Actions

1. **Track MCP Config**: Copy `~/.cursor/mcp.json` to dotfiles and symlink
2. **Track Hooks**: Copy `~/.cursor/hooks.json` and `hooks_blueplane/` to dotfiles
3. **Track Rules**: Copy `~/.cursor/rules/` to dotfiles
4. **Update Extensions List**: Update `extensions.list` with current extensions

### Future Enhancements

1. **Create Sync Script**: Automate syncing of tracked configs
2. **Create Backup Script**: Backup runtime data before changes
3. **Extension Profiles**: Organize extensions into base + optional sets
4. **Validate Symlinks**: Script to check and repair symlinks

---

## File Count Summary

- **Live Config Files** (`~/.cursor`): 100+ files
- **Dotfiles Config Files** (`~/dotfiles/cursor`): 200+ files (including snapshots)
- **Workspace Snapshots**: 50+ sets
- **MCP Toolboxes**: 6 toolboxes
- **Plans**: 64+ plan files
- **Projects**: 195 project directories
- **Extensions**: 96 currently installed

---

## Notes

- The `~/.cursor` directory has its own `.git/` repository, which is unusual for a runtime directory
- Some configuration files have multiple backup versions (especially MCP configs)
- The snapshot system is comprehensive and valuable for tracking workspace state over time
- Extension count has decreased from 127 (Oct 2025) to 96 (Jan 2026), indicating cleanup
- MCP toolbox system provides good separation between global and project-specific configs
