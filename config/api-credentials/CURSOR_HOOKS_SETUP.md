# Cursor Hooks Setup for 1Password Environments

This guide explains how to set up Cursor hooks for validating local .env files from 1Password Environments at the project level.

## Overview

The 1Password Cursor hook validates that local .env files mounted from 1Password Environments are properly configured before allowing Cursor to execute shell commands. This prevents the Cursor Agent from running when required environment files are missing or invalid.

## User-Level Setup (Already Configured)

The hook has been set up at the user level (`~/.cursor/hooks/`), which means it will work for all projects by default. The hook will automatically discover and validate .env files configured in 1Password Environments.

## Project-Level Setup (Optional)

For more control, you can configure the hook at the project level. This allows you to specify exactly which .env files should be validated for each project.

### Step 1: Copy Hook to Project

Copy the 1password hook to your project:

```bash
mkdir -p .cursor/hooks
cp -r ~/.cursor/hooks/1password .cursor/hooks/
```

Or create a symlink:

```bash
mkdir -p .cursor/hooks
ln -s ~/.cursor/hooks/1password .cursor/hooks/1password
```

### Step 2: Create Project-Level hooks.json

Create `.cursor/hooks.json` in your project root:

```json
{
  "version": 1,
  "hooks": {
    "beforeShellExecution": [
      {
        "command": ".cursor/hooks/1password/validate-mounted-env-files.sh"
      }
    ]
  }
}
```

**Note:** Project-level hooks take precedence over user-level hooks.

### Step 3: Configure Environment Files (Optional)

Create `.1password/environments.toml` in your project root to specify which .env files should be validated:

```toml
# .1password/environments.toml
mount_paths = [".env"]
```

**Options:**

- **Single file:** `mount_paths = [".env"]` - Only validates `.env`
- **Multiple files:** `mount_paths = [".env", "billing.env", "database.env"]` - Validates all specified files
- **No validation:** `mount_paths = []` - Disables validation for this project
- **No file:** If the file doesn't exist, the hook uses default mode (discovers all .env files in the project)

## Validation Modes

### Configured Mode

When `.1password/environments.toml` exists and contains a `mount_paths` field:

- **Only** the files specified in `mount_paths` are validated
- Other .env files in the project are ignored
- Provides explicit control over which files are required

### Default Mode

When no `.1password/environments.toml` file exists:

- The hook automatically discovers all .env files configured in 1Password Environments
- Validates files that are within the project directory
- Works automatically without configuration

## How It Works

1. **Before Command Execution:** When Cursor attempts to run a shell command, the hook runs first
2. **Discovery:** The hook queries 1Password for configured local .env files
3. **Validation:** For each discovered file, it checks:
   - The file is enabled in 1Password
   - The file exists as a valid FIFO (named pipe)
4. **Decision:**
   - **Allow:** All required files are valid → Command executes
   - **Deny:** One or more files are missing/invalid → Command blocked with error message

## Requirements

- **1Password Desktop App:** Must be installed and running
- **sqlite3:** Required for querying 1Password database
  - Install on macOS: `brew install sqlite3`
  - Install on Linux: `sudo apt-get install sqlite3` (or equivalent)
- **1Password Environment:** Must have a local .env file configured

## Troubleshooting

### Hook Not Running

1. Check Cursor's execution log: **Settings > Hooks > Execution Log**
2. Verify `hooks.json` is in the correct location (project or user level)
3. Ensure the hook script is executable: `chmod +x .cursor/hooks/1password/validate-mounted-env-files.sh`

### Validation Failing

1. **File Not Found:** Ensure the .env file is configured in 1Password Environment settings
2. **File Not Enabled:** Enable the local .env file in 1Password desktop app
3. **Not a FIFO:** The file must be a named pipe (FIFO), not a regular file. 1Password creates this automatically when the environment is enabled.

### sqlite3 Not Found

The hook will log a warning and allow execution to proceed (fail-open). To fix:

```bash
# macOS
brew install sqlite3

# Linux (Debian/Ubuntu)
sudo apt-get install sqlite3

# Verify installation
sqlite3 --version
```

### Debug Mode

Run the hook manually with debug output:

```bash
DEBUG=1 echo '{"command": "echo test", "workspace_roots": ["/path/to/project"]}' | ./.cursor/hooks/1password/validate-mounted-env-files.sh
```

### Logs

Check the hook log file for detailed information:

```bash
cat /tmp/1password-cursor-hooks.log
```

## Examples

### Example 1: Simple Project with Single .env

```toml
# .1password/environments.toml
mount_paths = [".env"]
```

### Example 2: Multi-Environment Project

```toml
# .1password/environments.toml
mount_paths = [".env", "staging.env", "production.env"]
```

### Example 3: Disable Validation for Project

```toml
# .1password/environments.toml
mount_paths = []
```

### Example 4: Use Default Mode

Simply don't create `.1password/environments.toml`. The hook will automatically discover and validate all .env files configured in 1Password.

## Integration with 1Password Environments

1. **Create Environment in 1Password:**
   - Open 1Password desktop app
   - Go to **Developer > Environments**
   - Create a new environment or use `default-1234`

2. **Configure Local .env File:**
   - In the environment settings, set the **Local .env file** destination
   - Example: `/path/to/project/.env`

3. **Enable the Environment:**
   - Toggle the environment to enabled
   - 1Password will create the FIFO file at the specified path

4. **Verify in Cursor:**
   - The hook will automatically validate the file
   - Commands will be blocked if the file is missing or disabled

## Next Steps

- See `import_to_environment.md` for importing credentials into 1Password Environments
- See `create_project_environment.sh` for automated project setup
- See `SETUP_GUIDE.md` for complete setup instructions

## References

- [1Password Environments Documentation](https://developer.1password.com/docs/environments)
- [Cursor Hooks Documentation](https://cursor.com/docs/agent/hooks)
- [1Password Cursor Hooks Repository](https://github.com/1Password/cursor-hooks)

