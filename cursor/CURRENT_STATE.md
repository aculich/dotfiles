# Current State Documentation

This document maps the current state of Cursor configuration, including existing symlinks, what's working, and what needs attention.

**Last Updated**: 2026-01-11

## Symlink Status

### ✅ Active Symlinks (All Valid)

#### 1. Settings Configuration
- **Source**: `~/dotfiles/cursor/settings.json`
- **Target**: `~/Library/Application Support/Cursor/User/settings.json`
- **Status**: ✅ **ACTIVE** - Valid symlink created Jan 29, 2025
- **Direction**: Live → Dotfiles (live points to dotfiles)
- **Purpose**: Editor settings and preferences
- **Validation**: ✅ Symlink is valid and target exists

#### 2. Keybindings Configuration
- **Source**: `~/dotfiles/cursor/keybindings.json`
- **Target**: `~/Library/Application Support/Cursor/User/keybindings.json`
- **Status**: ✅ **ACTIVE** - Valid symlink created Jan 29, 2025
- **Direction**: Live → Dotfiles (live points to dotfiles)
- **Purpose**: Custom keyboard shortcuts
- **Validation**: ✅ Symlink is valid and target exists
- **Note**: Multiple backup files exist in User directory (`.bak` files)

#### 3. Application Support Directory
- **Source**: `~/dotfiles/cursor/ApplicationSupport`
- **Target**: `~/Library/Application Support/Cursor/User`
- **Status**: ✅ **ACTIVE** - Valid symlink created Jan 27, 2025
- **Direction**: Dotfiles → Live (dotfiles points to live)
- **Purpose**: Convenience access to User configuration directory
- **Validation**: ✅ Symlink is valid and target exists

### ❌ Missing Symlinks (Should Be Created)

#### 1. MCP Configuration
- **Live Location**: `~/.cursor/mcp.json`
- **Dotfiles Location**: None (not tracked)
- **Status**: ❌ **NOT SYMLINKED**
- **Recommendation**: Copy to dotfiles and create symlink
- **Priority**: High - Important configuration

#### 2. Hooks Configuration
- **Live Location**: `~/.cursor/hooks.json`
- **Dotfiles Location**: None (not tracked)
- **Status**: ❌ **NOT SYMLINKED**
- **Recommendation**: Copy to dotfiles and create symlink
- **Priority**: Medium - Automation hooks

#### 3. Hooks Blueplane Directory
- **Live Location**: `~/.cursor/hooks_blueplane/`
- **Dotfiles Location**: None (not tracked)
- **Status**: ❌ **NOT SYMLINKED**
- **Recommendation**: Copy to dotfiles and create symlink
- **Priority**: Medium - Advanced hook system

#### 4. Rules Directory
- **Live Location**: `~/.cursor/rules/`
- **Dotfiles Location**: None (not tracked)
- **Status**: ❌ **NOT SYMLINKED**
- **Recommendation**: Copy to dotfiles and create symlink
- **Priority**: Medium - Cursor rules

#### 5. CLI Configuration
- **Live Location**: `~/.cursor/cli-config.json`
- **Dotfiles Location**: None (not tracked)
- **Status**: ❌ **NOT SYMLINKED**
- **Recommendation**: Copy to dotfiles and create symlink (if user-specific, may skip)
- **Priority**: Low - May be user-specific

## What's Working Well

### ✅ Core Configuration Management
- Settings and keybindings are properly symlinked and working
- Changes to dotfiles immediately reflect in Cursor
- Symlink direction is correct (live points to dotfiles for version control)

### ✅ Snapshot System
- Comprehensive workspace snapshot tools are functional
- Historical snapshots provide valuable context
- Scripts (`dump-cursor-windows.sh`, `view-cursor-snapshots.sh`) work well

### ✅ MCP Toolbox System
- Well-organized MCP toolbox system in dotfiles
- Activation script (`activate-mcp-toolbox.sh`) is functional
- Clear separation between global and project-specific MCP configs

### ✅ Extension Tracking
- Extension lists are tracked in dotfiles
- Historical snapshots show extension evolution
- Installation script exists (`install-extensions.sh`)

## What Needs Attention

### ⚠️ Configuration Gaps

1. **MCP Configuration Not Tracked**
   - Global MCP config (`mcp.json`) is not in dotfiles
   - Should be copied and symlinked for version control
   - Multiple backup versions exist (cleanup opportunity)

2. **Hooks Not Tracked**
   - Both `hooks.json` and `hooks_blueplane/` are not tracked
   - Important automation infrastructure should be versioned
   - Blueplane hooks are a sophisticated system worth preserving

3. **Rules Not Tracked**
   - Cursor rules directory is not in dotfiles
   - Rules are valuable configuration that should be versioned

4. **Extension List Out of Date**
   - Current `extensions.list` may not match installed extensions
   - Should be updated with current extension list (96 extensions)

### ⚠️ Unusual Patterns

1. **Git Repository in Runtime Directory**
   - `~/.cursor/.git/` exists - unusual for a runtime directory
   - Should investigate purpose and whether it's needed
   - May be for local version control of runtime data (not recommended)

2. **Multiple Backup Files**
   - Many `.bak` and timestamped backup files in `~/.cursor`
   - MCP config has 7+ backup/version files
   - Keybindings has 3 backup files in User directory
   - Consider cleanup strategy

3. **Settings Extra File**
   - `settings-extra.json` exists but not used
   - Determine if it should be merged or removed

### ⚠️ Runtime Data Management

1. **Large Runtime Directories**
   - `projects/` has 195 directories
   - `plans/` has 64+ plan files
   - `chats/` contains chat history
   - These should NOT be versioned but may need archival strategy

2. **Snapshot Accumulation**
   - 50+ workspace snapshots under `~/dotfiles/cursor/snapshots/workspace/`
   - Consider archival strategy for old snapshots
   - May want to compress or move to `archives/` (see [README.md](README.md))

## Symlink Strategy Analysis

### Current Pattern
- **Direction**: Live → Dotfiles (live configuration points to dotfiles)
- **Rationale**: Changes in dotfiles immediately affect live config
- **Benefit**: Single source of truth in version control
- **Status**: Working well for settings and keybindings

### Recommended Pattern for New Symlinks
- **Follow existing pattern**: Live → Dotfiles
- **Exception**: ApplicationSupport symlink goes Dotfiles → Live (convenience access)

### Files That Should Be Symlinked

**High Priority**:
1. `~/.cursor/mcp.json` → `~/dotfiles/cursor/mcp.json`
2. `~/.cursor/hooks.json` → `~/dotfiles/cursor/hooks.json`
3. `~/.cursor/rules/` → `~/dotfiles/cursor/rules/`

**Medium Priority**:
4. `~/.cursor/hooks_blueplane/` → `~/dotfiles/cursor/hooks_blueplane/`

**Low Priority** (user-specific, may skip):
5. `~/.cursor/cli-config.json` → `~/dotfiles/cursor/cli-config.json`

### Files That Should NOT Be Symlinked

**Runtime Data** (should never be symlinked):
- `~/.cursor/chats/` - Chat history
- `~/.cursor/projects/` - Project-specific state
- `~/.cursor/plans/` - Runtime plan files
- `~/.cursor/browser-logs/` - Debug logs
- `~/.cursor/ai-tracking/` - Analytics
- `~/.cursor/extensions/` - Installed extension files
- `~/.cursor/.git/` - Local git repository

## Broken or Missing Links

### ✅ No Broken Links Found
All existing symlinks are valid and functional.

## Backup Files

### Keybindings Backups
Located in `~/Library/Application Support/Cursor/User/`:
- `keybindings.json.27c8a83c.bak` (Jun 29, 2025)
- `keybindings.json.503e72a8.bak` (Oct 30, 2025)
- `keybindings.json.bcdf0538.bak` (Jul 7, 2025)

**Recommendation**: These can likely be removed since we have version control in dotfiles.

### MCP Configuration Backups
Located in `~/.cursor/`:
- `mcp.json.bak` (May 6, 2025)
- `mcp.json.2025-05-27` (May 27, 2025)
- `mcp__2025-05-25.json` (May 25, 2025)
- `mcp.json.disabled` (Dec 25, 2025)
- `mcp.json.latest-disabled` (May 25, 2025)
- `mcp.json.minimal` (Dec 25, 2025)

**Recommendation**: After copying `mcp.json` to dotfiles, these backups can be archived or removed.

## Immediate Action Items

### High Priority
1. ✅ Document current state (this document)
2. ⏳ Copy `mcp.json` to dotfiles and create symlink
3. ⏳ Update `extensions.list` with current extensions (96 total)

### Medium Priority
4. ⏳ Copy `hooks.json` to dotfiles and create symlink
5. ⏳ Copy `hooks_blueplane/` to dotfiles and create symlink
6. ⏳ Copy `rules/` to dotfiles and create symlink

### Low Priority
7. ⏳ Clean up backup files (after confirming symlinks work)
8. ⏳ Investigate `~/.cursor/.git/` purpose
9. ⏳ Decide on `settings-extra.json` usage
10. ⏳ Create snapshot archival strategy

## Validation Commands

### Check Symlink Validity
```bash
# Check all symlinks
test -L ~/Library/Application\ Support/Cursor/User/settings.json && echo "VALID" || echo "BROKEN"
test -L ~/Library/Application\ Support/Cursor/User/keybindings.json && echo "VALID" || echo "BROKEN"
test -L ~/dotfiles/cursor/ApplicationSupport && echo "VALID" || echo "BROKEN"
```

### List All Symlinks
```bash
# In User directory
find ~/Library/Application\ Support/Cursor/User -type l -ls

# In dotfiles
find ~/dotfiles/cursor -type l -ls
```

### Verify Symlink Targets
```bash
readlink ~/Library/Application\ Support/Cursor/User/settings.json
readlink ~/Library/Application\ Support/Cursor/User/keybindings.json
readlink ~/dotfiles/cursor/ApplicationSupport
```

## Summary

### Working ✅
- Core configuration (settings, keybindings) properly symlinked
- Snapshot system functional
- MCP toolbox system well-organized
- Extension tracking in place

### Needs Work ⚠️
- MCP, hooks, and rules not tracked
- Extension list needs update
- Backup file cleanup needed
- Runtime data management strategy needed

### Next Steps
1. Create missing symlinks for MCP, hooks, and rules
2. Update extension list
3. Clean up backup files
4. Document symlink creation process
