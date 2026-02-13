# Complete Setup Guide: 1Password Environments with Cursor

This guide provides step-by-step instructions for setting up 1Password Environments integration with Cursor validation hooks.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Populate default-1234 Environment](#populate-default-1234-environment)
4. [Configure Cursor Hooks](#configure-cursor-hooks)
5. [Project-Specific Setup](#project-specific-setup)
6. [Automatic Environment Detection](#automatic-environment-detection)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

1. **1Password Desktop App**
   - Download from [1password.com](https://1password.com/downloads/)
   - Sign in to your account
   - Ensure you have access to the `develop` vault

2. **1Password CLI**
   - Install: `brew install 1password-cli` (macOS) or see [1Password CLI docs](https://developer.1password.com/docs/cli)
   - Sign in: `op signin`
   - Verify: `op account list`

3. **Additional Tools**
   - `jq` - JSON processor: `brew install jq`
   - `sqlite3` - For Cursor hook validation: `brew install sqlite3`
   - `bash` 4.0+ (usually pre-installed)

### Verify Installation

```bash
# Check 1Password CLI
op --version

# Check jq
jq --version

# Check sqlite3
sqlite3 --version

# Check 1Password sign-in
op account list
```

## Initial Setup

### Step 1: Verify Credentials

Ensure all 81 API credentials exist in the `develop` vault with the `migrated-from-apikeys` tag:

```bash
unset OP_ACCOUNT
op item list --vault "develop" --tags "migrated-from-apikeys" --format json | jq 'length'
# Should output: 81
```

### Step 2: Update URLs

Update all credentials with platform URLs:

```bash
~/dotfiles/config/api-credentials/update_1password_urls.sh
```

Expected output:
- Processed: 81
- Updated: 77
- Skipped: 4

### Step 3: Create default-1234 Environment

1. Open **1Password Desktop App**
2. Go to **Developer > Environments**
3. Click **+** or **New Environment**
4. Name it: **default-1234**
5. Leave it disabled for now (we'll enable it after importing)

## Populate default-1234 Environment

### Step 1: Export Credentials

Run the populate script:

```bash
~/dotfiles/config/api-credentials/populate_environment.sh
```

This creates `/tmp/default-1234.env` with all 81 credentials.

### Step 2: Import into 1Password

1. In 1Password Desktop App, go to **Developer > Environments**
2. Select **default-1234**
3. Click **Import** or **Import .env file**
4. Select `/tmp/default-1234.env`
5. Review the imported variables
6. Confirm the import

### Step 3: Configure Local .env File

1. In the environment settings, find **Local .env file** or **Destination**
2. Set the path (e.g., `~/dotfiles/.env` or `~/.env`)
3. Save the configuration

### Step 4: Enable Environment

1. Toggle the environment to **Enabled**
2. 1Password will create the FIFO file at the specified path
3. Verify the file exists: `ls -l ~/.env` (or your configured path)
4. It should be a FIFO (named pipe), not a regular file

### Step 5: Verify Import

```bash
# Check file exists and is a FIFO
ls -l ~/.env
# Should show: prw-r--r-- ... (the 'p' indicates a pipe)

# Test reading (should show environment variables)
head -5 ~/.env
```

## Configure Cursor Hooks

### User-Level Setup (Already Done)

The hooks have been set up at `~/.cursor/hooks/`. This applies to all projects by default.

Verify setup:

```bash
ls -la ~/.cursor/hooks/1password/
cat ~/.cursor/hooks.json
```

### Project-Level Setup (Optional)

For project-specific configuration:

1. **Copy hook to project:**
   ```bash
   mkdir -p .cursor/hooks
   cp -r ~/.cursor/hooks/1password .cursor/hooks/
   ```

2. **Create `.cursor/hooks.json`:**
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

3. **Create `.1password/environments.toml`:**
   ```toml
   mount_paths = [".env"]
   ```

See `CURSOR_HOOKS_SETUP.md` for detailed instructions.

## Project-Specific Setup

### For New Projects

When starting a new project that will use 1Password Environments:

```bash
cd /path/to/project
~/dotfiles/config/api-credentials/create_project_environment.sh --project-name myproject
```

This will:
- Create `.1password/environments.toml`
- Set up Cursor hooks
- Generate setup instructions

### For Existing Projects with .env Files

If you have an existing project with a `.env` file:

```bash
cd /path/to/project
~/dotfiles/config/api-credentials/sync_env_to_1password.sh
```

This will:
- Detect the `.env` file
- Check if 1Password Environment exists
- Generate setup instructions if missing
- Help you import the credentials

## Automatic Environment Detection

### Cursor Agent Integration

The Cursor Agent can automatically detect `.env` files and help set up 1Password Environments.

**How it works:**
1. Agent detects `.env` file in project
2. Checks if 1Password Environment exists
3. If missing, runs `sync_env_to_1password.sh`
4. Generates setup instructions
5. Guides you through the setup process

**To enable:**
- The scripts are already set up and ready to use
- When working in a project with a `.env` file, ask the agent: "Set up 1Password Environment for this project"
- Or manually run: `~/dotfiles/config/api-credentials/sync_env_to_1password.sh`

See `cursor_env_sync.md` for detailed integration guide.

## Troubleshooting

### Hook Not Running

**Symptoms:** Cursor commands execute without validation

**Solutions:**
1. Check Cursor execution log: **Settings > Hooks > Execution Log**
2. Verify `~/.cursor/hooks.json` exists and is valid JSON
3. Check hook script is executable: `chmod +x ~/.cursor/hooks/1password/validate-mounted-env-files.sh`
4. Verify sqlite3 is installed: `sqlite3 --version`

### Environment File Not Found

**Symptoms:** Hook blocks commands, reports file not found

**Solutions:**
1. Ensure environment is enabled in 1Password desktop app
2. Check the mount path in environment settings
3. Verify the file exists: `ls -l /path/to/.env`
4. Ensure it's a FIFO: `file /path/to/.env` should show "FIFO"

### sqlite3 Not Found

**Symptoms:** Hook logs warning about sqlite3

**Solutions:**
```bash
# macOS
brew install sqlite3

# Linux
sudo apt-get install sqlite3

# Verify
sqlite3 --version
```

### Import Fails

**Symptoms:** Cannot import .env file into 1Password

**Solutions:**
1. Check .env file format (KEY=value, one per line)
2. Ensure file is readable: `cat /path/to/.env | head -5`
3. Check 1Password desktop app is up to date
4. Try importing a smaller subset first

### Credentials Not Appearing

**Symptoms:** Imported credentials don't show in environment

**Solutions:**
1. Refresh the environment view in 1Password
2. Check the import log for errors
3. Verify credentials have valid values (not null/empty)
4. Re-run the populate script and try importing again

### Script Errors

**Symptoms:** Scripts fail with errors

**Solutions:**
1. Check script permissions: `chmod +x ~/dotfiles/config/api-credentials/*.sh`
2. Verify 1Password CLI is signed in: `op account list`
3. Check vault access: `op item list --vault "develop"`
4. Review script output for specific error messages

### Debug Mode

Enable debug output for troubleshooting:

```bash
# For sync script
DEBUG=1 ~/dotfiles/config/api-credentials/sync_env_to_1password.sh

# For hook validation
DEBUG=1 echo '{"command": "echo test", "workspace_roots": ["/path/to/project"]}' | ~/.cursor/hooks/1password/validate-mounted-env-files.sh
```

### Check Logs

Hook logs are written to:
```bash
cat /tmp/1password-cursor-hooks.log
```

## Testing the Setup

### Test 1: Environment File Access

```bash
# Should show environment variables
head -10 ~/.env
```

### Test 2: Hook Validation

1. Open a project with `.1password/environments.toml`
2. Try running a command in Cursor
3. Check execution log for hook validation
4. Should see "allow" or "deny" decision

### Test 3: Project Setup

```bash
# Create test project
mkdir -p /tmp/test-project
cd /tmp/test-project
echo "TEST_KEY=test_value" > .env

# Run sync
~/dotfiles/config/api-credentials/sync_env_to_1password.sh

# Verify files created
ls -la .1password/
ls -la .cursor/hooks/
```

## Next Steps

- **Customize configuration** - Adjust `.1password/environments.toml` for your needs
- **Set up multiple projects** - Use `create_project_environment.sh` for each project
- **Integrate with CI/CD** - Use 1Password CLI for automated credential management
- **Explore 1Password Environments** - See [1Password Developer Docs](https://developer.1password.com/docs/environments)

## Additional Resources

- **`CURSOR_HOOKS_SETUP.md`** - Detailed hook configuration
- **`cursor_env_sync.md`** - Cursor agent integration
- **`import_to_environment.md`** - Import instructions
- **`README.md`** - Script reference and usage
- [1Password Environments Documentation](https://developer.1password.com/docs/environments)
- [Cursor Hooks Documentation](https://cursor.com/docs/agent/hooks)

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review script output and error messages
3. Check Cursor execution logs
4. Verify all prerequisites are installed
5. Review 1Password and Cursor documentation

