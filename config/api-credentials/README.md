# API Credentials Configuration

This directory contains configuration and scripts for managing API credentials in 1Password, including integration with 1Password Environments and Cursor validation hooks.

## Files

### Core Configuration
- `services.json` - Mapping of API service names to their platform, documentation, and key management URLs
- `dollar_sign_references.md` - Report of credentials with variable references (dollar-sign values)

### 1Password Management Scripts
- `update_1password_urls.sh` - Script to update 1Password entries with platform URLs in the hostname field
- `add_url_fields_to_credentials.sh` - Add platform URL, documentation URL, and key management URL as custom fields to all credentials
- `populate_environment.sh` - Export all 81 API credentials to .env format for importing into 1Password Environments
- `import_to_environment.md` - Instructions for importing .env files into 1Password Environments

### Project Setup Scripts
- `create_project_environment.sh` - Create 1Password Environment setup for a project (generates config files and instructions)
- `sync_env_to_1password.sh` - Automatically detect .env files and sync with 1Password Environments
- `env_helpers.sh` - Helper functions for detecting and syncing .env files

### Documentation
- `CURSOR_HOOKS_SETUP.md` - Guide for setting up Cursor hooks for .env file validation
- `cursor_env_sync.md` - Cursor agent integration guide for automatic environment detection
- `SETUP_GUIDE.md` - Comprehensive setup guide (see below)

## Quick Start

### 1. Add URL Fields to All Credentials

Run the script to add three URL fields (platform, documentation, and key management) to all API Credential entries:

```bash
~/dotfiles/config/api-credentials/add_url_fields_to_credentials.sh
```

This adds clickable URL fields directly in 1Password, making it easy to:
- Open the platform website
- Access API documentation
- Navigate to key management pages for credential rotation

Alternatively, to only update the hostname field with platform URLs:

```bash
~/dotfiles/config/api-credentials/update_1password_urls.sh
```

### 2. Populate default-1234 Environment

Export all credentials to .env format:

```bash
~/dotfiles/config/api-credentials/populate_environment.sh
```

Then follow the instructions in `import_to_environment.md` to import into the `default-1234` environment.

### 3. Set Up Cursor Hooks

Cursor hooks are already set up at the user level (`~/.cursor/hooks/`). For project-specific setup, see `CURSOR_HOOKS_SETUP.md`.

### 4. Create Project Environment

For a new project with an existing .env file:

```bash
~/dotfiles/config/api-credentials/sync_env_to_1password.sh /path/to/project
```

Or manually:

```bash
~/dotfiles/config/api-credentials/create_project_environment.sh --project-name myproject
```

## Usage

### Adding URL Fields to Credentials

Add three URL fields (platform, documentation, and key management) to all credentials:

```bash
~/dotfiles/config/api-credentials/add_url_fields_to_credentials.sh
```

This script:
- Reads all 81 API credentials from the `develop` vault
- Matches them with entries in `services.json`
- Adds three custom URL fields to each credential:
  - **Platform URL** - Main platform website
  - **Documentation URL** - API documentation
  - **Key Management URL** - Key management page (for credential rotation)
- Reports which credentials were updated and which were skipped

These URL fields are clickable in 1Password, making it easy to access documentation and rotate credentials.

### Updating Hostname Field Only

To only update the `hostname` field with platform URLs (without adding custom fields):

```bash
~/dotfiles/config/api-credentials/update_1password_urls.sh
```

This script:
- Reads all 81 API credentials from the `develop` vault
- Matches them with entries in `services.json`
- Updates the `hostname` field with platform URLs
- Reports which credentials were updated and which were skipped

### Exporting Credentials to .env Format

```bash
# Default output: /tmp/default-1234.env
~/dotfiles/config/api-credentials/populate_environment.sh

# Custom output file
~/dotfiles/config/api-credentials/populate_environment.sh /path/to/output.env
```

The script:
- Extracts all 81 API credentials
- Formats them as KEY=value pairs
- Handles special characters and quotes
- Preserves dollar-sign variable references

### Creating Project Environment

```bash
# Auto-detect project name
~/dotfiles/config/api-credentials/create_project_environment.sh --project-name myproject

# With custom options
~/dotfiles/config/api-credentials/create_project_environment.sh \
  --project-name myproject \
  --env-name myproject-dev \
  --mount-path .env.local \
  --project-root /path/to/project
```

This script:
- Creates `.1password/environments.toml` configuration
- Sets up Cursor hooks in the project
- Generates step-by-step setup instructions
- Prepares the project for 1Password Environment integration

### Syncing Existing .env Files

```bash
# From project root
~/dotfiles/config/api-credentials/sync_env_to_1password.sh

# Specify project path
~/dotfiles/config/api-credentials/sync_env_to_1password.sh /path/to/project
```

This script:
- Detects `.env` files in the project
- Checks if 1Password Environment exists
- Generates setup instructions if missing
- Parses .env file for import reference

## Services JSON Structure

The `services.json` file maps environment variable names to service information:

```json
{
  "service_name": {
    "env_keys": ["ENV_VAR_1", "ENV_VAR_2"],
    "platform_url": "https://platform.example.com",
    "docs_url": "https://docs.example.com",
    "key_management_url": "https://platform.example.com/settings/keys"
  }
}
```

## Cursor Integration

### Automatic Environment Detection

When working in a project with a `.env` file, the Cursor Agent can automatically:
1. Detect the `.env` file
2. Check if a 1Password Environment exists
3. Generate setup instructions if missing
4. Help import credentials into 1Password

See `cursor_env_sync.md` for detailed integration guide.

### Hook Validation

Cursor hooks validate that local .env files from 1Password Environments are properly mounted before allowing command execution. This prevents the Agent from running when required environment files are missing.

See `CURSOR_HOOKS_SETUP.md` for setup instructions.

## Migration Summary

- **Total credentials**: 81
- **Updated with dates**: 81 (Jan 1, 2026 - Dec 31, 2026)
- **Updated with URLs**: 77 (4 skipped - no platform URL available)
- **Dollar-sign references**: 5 (documented in `dollar_sign_references.md`)

## Documentation

- **`SETUP_GUIDE.md`** - Complete step-by-step setup guide
- **`CURSOR_HOOKS_SETUP.md`** - Cursor hooks configuration guide
- **`cursor_env_sync.md`** - Cursor agent integration guide
- **`import_to_environment.md`** - Instructions for importing into 1Password Environments

## Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `add_url_fields_to_credentials.sh` | Add URL fields to credentials | `./add_url_fields_to_credentials.sh` |
| `update_1password_urls.sh` | Update hostname field only | `./update_1password_urls.sh` |
| `populate_environment.sh` | Export to .env format | `./populate_environment.sh [output_file]` |
| `create_project_environment.sh` | Create project setup | `./create_project_environment.sh --project-name NAME` |
| `sync_env_to_1password.sh` | Auto-detect and sync .env | `./sync_env_to_1password.sh [project_root]` |

## Requirements

- **1Password CLI** (`op`) - For managing credentials
- **1Password Desktop App** - For Environment management (no CLI support yet)
- **jq** - For JSON parsing
- **sqlite3** - For Cursor hook validation (install separately)
- **bash** - All scripts require bash 4.0+

## Troubleshooting

### Scripts Not Executable

```bash
chmod +x ~/dotfiles/config/api-credentials/*.sh
```

### 1Password CLI Not Found

Ensure 1Password CLI is installed and in your PATH:
```bash
op --version
```

### sqlite3 Not Found

Install sqlite3 for Cursor hook validation:
```bash
# macOS
brew install sqlite3

# Linux
sudo apt-get install sqlite3
```

### Environment Not Found

1Password Environments must be created and configured via the desktop app. The scripts generate instructions but cannot create environments directly.

## Related Documentation

- [1Password Environments](https://developer.1password.com/docs/environments)
- [Cursor Hooks](https://cursor.com/docs/agent/hooks)
- [1Password Cursor Hooks Repository](https://github.com/1Password/cursor-hooks)
