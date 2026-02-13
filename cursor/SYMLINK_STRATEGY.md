# Symlink Strategy for Cursor Configuration

This document defines the symlink strategy for managing Cursor configuration files between the live configuration directory (`~/.cursor`) and the dotfiles repository (`~/dotfiles/cursor`).

**Last Updated**: 2026-01-11

## Principles

### 1. Single Source of Truth
- **Dotfiles repository** is the authoritative source for version-controlled configurations
- **Live configuration** points to dotfiles via symlinks
- Changes in dotfiles immediately affect live configuration

### 2. Direction: Live → Dotfiles
- Symlinks are created from live locations to dotfiles
- Pattern: `~/.cursor/config.json` → `~/dotfiles/cursor/config.json`
- Exception: `ApplicationSupport` symlink goes Dotfiles → Live (convenience access)

### 3. Separation of Concerns
- **Version-controlled**: User configurations, scripts, toolboxes
- **Runtime data**: Chats, projects, plans, logs (never symlinked)
- **Installed extensions**: Extension files (never symlinked)

## Symlink Categories

### ✅ Category 1: Core User Configuration (Symlink)

**Always symlinked - essential user preferences**

| File/Directory | Live Location | Dotfiles Location | Status | Priority |
|---------------|---------------|-------------------|--------|----------|
| `settings.json` | `~/Library/Application Support/Cursor/User/settings.json` | `~/dotfiles/cursor/settings.json` | ✅ Active | High |
| `keybindings.json` | `~/Library/Application Support/Cursor/User/keybindings.json` | `~/dotfiles/cursor/keybindings.json` | ✅ Active | High |
| `mcp.json` | `~/.cursor/mcp.json` | `~/dotfiles/cursor/mcp.json` | ⏳ Pending | High |
| `hooks.json` | `~/.cursor/hooks.json` | `~/dotfiles/cursor/hooks.json` | ⏳ Pending | Medium |
| `rules/` | `~/.cursor/rules/` | `~/dotfiles/cursor/.cursor/rules/` | ✅ Active | Medium |
| `hooks_blueplane/` | `~/.cursor/hooks_blueplane/` | `~/dotfiles/cursor/hooks_blueplane/` | ⏳ Pending | Medium |
| `cli-config.json` | `~/.cursor/cli-config.json` | `~/dotfiles/cursor/cli-config.json` | ⏳ Pending | Low |

**Rationale**: These are user-defined configurations that should be version-controlled and shared across machines.

### ✅ Category 2: Convenience Symlinks (Symlink)

**Symlinks for easier access**

| File/Directory | Source | Target | Status | Purpose |
|---------------|--------|--------|--------|---------|
| `ApplicationSupport` | `~/dotfiles/cursor/ApplicationSupport` | `~/Library/Application Support/Cursor/User` | ✅ Active | Convenience access |

**Rationale**: Provides easy access to User directory from dotfiles.

### ❌ Category 3: Runtime Data (Never Symlink)

**Never symlinked - machine-specific runtime data**

| Directory/File | Location | Reason |
|---------------|----------|--------|
| `chats/` | `~/.cursor/chats/` | Chat history is machine-specific |
| `projects/` | `~/.cursor/projects/` | Project state is machine-specific |
| `plans/` | `~/.cursor/plans/` | Runtime plan files (may archive important ones) |
| `browser-logs/` | `~/.cursor/browser-logs/` | Debug logs |
| `ai-tracking/` | `~/.cursor/ai-tracking/` | Analytics data |
| `worktrees/` | `~/.cursor/worktrees/` | Git worktree metadata |
| `workers/` | `~/.cursor/workers/` | Worker processes |
| `ide_state.json` | `~/.cursor/ide_state.json` | Current IDE state |
| `prompt_history.json` | `~/.cursor/prompt_history.json` | Prompt history |
| `extensions/` | `~/.cursor/extensions/` | Installed extension files |
| `.git/` | `~/.cursor/.git/` | Local git repository |

**Rationale**: These contain machine-specific, runtime, or generated data that should not be version-controlled.

### 📋 Category 4: Version Controlled (Copy, Not Symlink)

**Files tracked in dotfiles but not symlinked**

| File/Directory | Dotfiles Location | Purpose |
|---------------|-------------------|---------|
| `extensions.list*` | `~/dotfiles/cursor/extensions.list*` | Extension inventory |
| `mcp-toolboxes/` | `~/dotfiles/cursor/mcp-toolboxes/` | MCP toolbox definitions |
| `scripts/` | `~/dotfiles/cursor/scripts/` | Management scripts |
| `cursor-workspace-*.{txt,json}` | `~/dotfiles/cursor/` | Historical snapshots |
| `README*.md` | `~/dotfiles/cursor/` | Documentation |

**Rationale**: These are reference files, templates, or historical data that don't need to be symlinked.

## Symlink Creation Process

### Step 1: Backup Existing Files

Before creating symlinks, backup any existing files:

```bash
# Backup mcp.json
if [ -f ~/.cursor/mcp.json ]; then
    cp ~/.cursor/mcp.json ~/.cursor/mcp.json.backup.$(date +%Y%m%d)
fi
```

### Step 2: Copy to Dotfiles

Copy configuration files to dotfiles repository:

```bash
# Copy mcp.json to dotfiles
cp ~/.cursor/mcp.json ~/dotfiles/cursor/mcp.json

# Copy hooks.json
cp ~/.cursor/hooks.json ~/dotfiles/cursor/hooks.json

# Copy rules directory
cp -r ~/.cursor/rules ~/dotfiles/cursor/rules

# Copy hooks_blueplane directory
cp -r ~/.cursor/hooks_blueplane ~/dotfiles/cursor/hooks_blueplane
```

### Step 3: Create Symlinks

Create symlinks from live to dotfiles:

```bash
# Remove original file/directory
rm ~/.cursor/mcp.json
rm ~/.cursor/hooks.json
rm -r ~/.cursor/rules
rm -r ~/.cursor/hooks_blueplane

# Create symlinks
ln -s ~/dotfiles/cursor/mcp.json ~/.cursor/mcp.json
ln -s ~/dotfiles/cursor/hooks.json ~/.cursor/hooks.json
ln -s ~/dotfiles/cursor/rules ~/.cursor/rules
ln -s ~/dotfiles/cursor/hooks_blueplane ~/.cursor/hooks_blueplane
```

### Step 4: Verify Symlinks

Verify symlinks are valid:

```bash
# Check symlink validity
test -L ~/.cursor/mcp.json && echo "VALID" || echo "BROKEN"
readlink ~/.cursor/mcp.json

# Verify target exists
test -f ~/dotfiles/cursor/mcp.json && echo "TARGET EXISTS" || echo "TARGET MISSING"
```

## Symlink Management Script

### Recommended Script Structure

```bash
#!/bin/bash
# sync-cursor-config.sh
# Syncs Cursor configuration files between live and dotfiles

set -e

DOTFILES_DIR="$HOME/dotfiles/cursor"
LIVE_CURSOR_DIR="$HOME/.cursor"
USER_DIR="$HOME/Library/Application Support/Cursor/User"

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"
    
    echo "Creating symlink: $description"
    
    # Backup if exists
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "  Backing up existing file..."
        mv "$target" "${target}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Remove if exists (broken symlink)
    [ -L "$target" ] && rm "$target"
    
    # Create symlink
    ln -s "$source" "$target"
    echo "  ✓ Created: $target -> $source"
}

# Create symlinks
create_symlink "$DOTFILES_DIR/mcp.json" "$LIVE_CURSOR_DIR/mcp.json" "MCP configuration"
create_symlink "$DOTFILES_DIR/hooks.json" "$LIVE_CURSOR_DIR/hooks.json" "Hooks configuration"
create_symlink "$DOTFILES_DIR/rules" "$LIVE_CURSOR_DIR/rules" "Rules directory"
create_symlink "$DOTFILES_DIR/hooks_blueplane" "$LIVE_CURSOR_DIR/hooks_blueplane" "Hooks Blueplane"

echo "✓ All symlinks created successfully"
```

## Validation Script

### Check All Symlinks

```bash
#!/bin/bash
# validate-symlinks.sh
# Validates all Cursor configuration symlinks

check_symlink() {
    local path="$1"
    local description="$2"
    
    if [ -L "$path" ]; then
        if [ -e "$path" ]; then
            echo "✅ $description: VALID"
            echo "   -> $(readlink "$path")"
        else
            echo "❌ $description: BROKEN (target missing)"
            echo "   -> $(readlink "$path")"
        fi
    elif [ -e "$path" ]; then
        echo "⚠️  $description: NOT SYMLINKED (regular file/directory)"
    else
        echo "❌ $description: MISSING"
    fi
}

echo "Checking Cursor configuration symlinks..."
echo ""

check_symlink "$HOME/Library/Application Support/Cursor/User/settings.json" "Settings"
check_symlink "$HOME/Library/Application Support/Cursor/User/keybindings.json" "Keybindings"
check_symlink "$HOME/.cursor/mcp.json" "MCP Config"
check_symlink "$HOME/.cursor/hooks.json" "Hooks"
check_symlink "$HOME/.cursor/rules" "Rules"
check_symlink "$HOME/.cursor/hooks_blueplane" "Hooks Blueplane"
check_symlink "$HOME/dotfiles/cursor/ApplicationSupport" "ApplicationSupport"
```

## Symlink Maintenance

### Regular Tasks

1. **Monthly Validation**: Run validation script to check for broken symlinks
2. **After Updates**: Verify symlinks after Cursor updates
3. **Before Changes**: Backup before modifying symlink strategy
4. **Cross-Machine Sync**: Ensure dotfiles are synced before creating symlinks on new machine

### Troubleshooting

#### Broken Symlink

**Symptom**: Symlink exists but target is missing

**Solution**:
```bash
# Remove broken symlink
rm ~/.cursor/mcp.json

# Recreate if file exists in dotfiles
ln -s ~/dotfiles/cursor/mcp.json ~/.cursor/mcp.json
```

#### File Exists (Not Symlink)

**Symptom**: File exists but is not a symlink

**Solution**:
```bash
# Backup existing file
cp ~/.cursor/mcp.json ~/.cursor/mcp.json.backup

# Remove and create symlink
rm ~/.cursor/mcp.json
ln -s ~/dotfiles/cursor/mcp.json ~/.cursor/mcp.json
```

#### Target Missing

**Symptom**: Symlink points to non-existent file

**Solution**:
```bash
# Check if file exists in dotfiles
ls -la ~/dotfiles/cursor/mcp.json

# If missing, copy from live (if exists)
if [ -f ~/.cursor/mcp.json ] && [ ! -f ~/dotfiles/cursor/mcp.json ]; then
    cp ~/.cursor/mcp.json ~/dotfiles/cursor/mcp.json
    git add ~/dotfiles/cursor/mcp.json
fi
```

## Integration with Dotfile Managers

### GNU Stow

If using GNU Stow for dotfile management:

```bash
# Stow cursor configs
stow -d ~/dotfiles -t ~ cursor

# This would create symlinks for all files in ~/dotfiles/cursor
```

### Manual Management

Current approach uses manual symlink creation, which provides:
- Explicit control over what gets symlinked
- Clear documentation of symlink strategy
- Easy troubleshooting

## Best Practices

1. **Always Backup**: Backup existing files before creating symlinks
2. **Verify Targets**: Ensure dotfiles exist before creating symlinks
3. **Document Changes**: Update this document when adding new symlinks
4. **Test After Changes**: Validate symlinks after any changes
5. **Version Control**: Commit symlink strategy changes to git

## Summary

### Current Status

✅ **Active Symlinks**:
- `settings.json` → dotfiles
- `keybindings.json` → dotfiles
- `rules/` → dotfiles (includes shell-commands.mdc and 02-shell-python-best-practices.mdc)
- `ApplicationSupport` → User directory

⏳ **Pending Symlinks**:
- `mcp.json` (High priority)
- `hooks.json` (Medium priority)
- `hooks_blueplane/` (Medium priority)
- `cli-config.json` (Low priority)

❌ **Never Symlink**:
- Runtime data (chats, projects, plans, logs)
- Installed extensions
- Local git repository

### Next Steps

1. Create symlink management script
2. Create symlinks for pending configurations
3. Set up validation script
4. Document in dotfiles repository
5. Test on secondary machine (sidequest)
