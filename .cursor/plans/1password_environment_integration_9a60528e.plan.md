---
name: 1Password Environment Integration
overview: "Set up 1Password Environments integration with Cursor validation: populate default-1234 environment with all API credentials, configure Cursor hooks for .env validation, and create a script for future per-project environment setup."
todos:
  - id: complete-url-updates
    content: Fix and complete update_1password_urls.sh script to update all credentials with URLs from services.json
    status: completed
  - id: populate-script
    content: Create populate_environment.sh script to export all 81 API credentials to .env format
    status: completed
  - id: import-instructions
    content: Create import_to_environment.md with instructions for importing into default-1234
    status: completed
    dependencies:
      - populate-script
  - id: clone-hooks
    content: Clone 1Password cursor-hooks repository and extract 1password hook
    status: completed
  - id: user-hooks
    content: Set up Cursor hooks at user level (~/.cursor/hooks/)
    status: completed
    dependencies:
      - clone-hooks
  - id: hook-docs
    content: Create CURSOR_HOOKS_SETUP.md with project-level setup instructions
    status: completed
    dependencies:
      - user-hooks
  - id: project-script
    content: Create create_project_environment.sh for per-project environment setup
    status: completed
    dependencies:
      - hook-docs
  - id: auto-env-detection
    content: Create Cursor agent integration to automatically detect .env files and create 1Password environments
    status: completed
    dependencies:
      - project-script
  - id: update-readme
    content: Update README.md with new scripts and setup instructions
    status: completed
    dependencies:
      - project-script
  - id: setup-guide
    content: Create comprehensive SETUP_GUIDE.md
    status: completed
    dependencies:
      - update-readme
---

#1Password Environment Integration Plan

## Summary

This plan sets up 1Password Environments integration with Cursor validation hooks. It includes:

1. Completing URL updates for all 81 API credentials
2. Populating the `default-1234` environment with all 81 API credentials
3. Setting up Cursor hooks for validating local .env files
4. Creating a reusable script for per-project environment creation
5. Creating automatic environment detection and setup from existing .env files

---

## Task 0: Complete URL Updates

### 0.1 Fix Existing URL Update Script

**File:** `~/dotfiles/config/api-credentials/update_1password_urls.sh`**Issues to fix:**

- Fix typo on line 73 ("Updateupdated" → "Updated")
- Verify script completes successfully for all 81 credentials
- Add support for updating multiple URL fields (platform, docs, key_management) if 1Password API supports it
- Add verification step to confirm URLs were added

**Enhancements:**

- Add option to update all three URL types (platform_url, docs_url, key_management_url) as custom fields
- Create summary report of which credentials were updated and which were skipped

### 0.2 Run URL Updates

- Execute the fixed script to ensure all credentials have platform URLs
- Verify results match services.json mappings
- Document any credentials that couldn't be mapped

---

## Task 1: Populate default-1234 Environment

### 1.1 Create Script to Export Credentials

**File:** `~/dotfiles/config/api-credentials/populate_environment.sh`

- Extract all 81 API Credentials from the `develop` vault
- Format as key-value pairs (KEY=value)
- Handle dollar-sign variable references (keep as-is)
- Output to a temporary .env file

**Script logic:**

```bash
# For each credential with tag "migrated-from-apikeys":
#   - Get credential name (title)
#   - Get credential value (from credential field)
#   - Format as: KEY=value
#   - Handle special characters and quotes
```



### 1.2 Import into 1Password Environment

**Note:** 1Password Environments must be configured via the desktop app. The script will:

- Generate the .env file with all credentials
- Provide instructions for importing into `default-1234` environment
- Optionally use AppleScript/automation if available

**File:** `~/dotfiles/config/api-credentials/import_to_environment.md` (instructions)---

## Task 2: Set Up Cursor Hooks

### 2.1 Clone 1Password Cursor Hooks Repository

**Location:** `~/dotfiles/config/cursor-hooks/` (temporary)

- Clone from `https://github.com/1Password/cursor-hooks`
- Extract the `1password` hook folder

### 2.2 User-Level Hook Setup

**Location:** `~/.cursor/hooks/`

- Copy `1password` folder to `~/.cursor/hooks/1password/`
- Create or update `~/.cursor/hooks.json`:
```json
{
  "version": 1,
  "hooks": {
    "beforeShellExecution": [
      {
        "command": "~/.cursor/hooks/1password/validate-mounted-env-files.sh"
      }
    ]
  }
}
```




### 2.3 Project-Level Hook Documentation

**File:** `~/dotfiles/config/api-credentials/CURSOR_HOOKS_SETUP.md`

- Document how to set up hooks at project level
- Include `.cursor/hooks.json` template
- Include `.1password/environments.toml` template for configured mode

### 2.4 Configure default-1234 Environment Destination

**Note:** Must be done via 1Password desktop app

- Configure local .env file destination for `default-1234`
- Set mount path (e.g., `~/dotfiles/.env` or project-specific)
- Document the setup process

---

## Task 3: Create Per-Project Environment Script

### 3.1 Main Script

**File:** `~/dotfiles/config/api-credentials/create_project_environment.sh`**Features:**

- Accepts project name and optional mount path
- Creates instructions for:
- Creating new 1Password Environment (via desktop app)
- Configuring local .env file destination
- Setting up Cursor hooks in project
- Creating `.1password/environments.toml` if needed

**Parameters:**

- `--project-name`: Name of the project
- `--env-name`: Name for the 1Password Environment (default: project-name)
- `--mount-path`: Path for .env file (default: `.env` in project root)
- `--cursor-hooks`: Whether to set up Cursor hooks (default: true)

### 3.2 Script Output

The script will:

1. Generate a `.1password/environments.toml` file template
2. Create `.cursor/hooks.json` if it doesn't exist
3. Copy the 1password hook to `.cursor/hooks/1password/`
4. Provide step-by-step instructions for:

- Creating the environment in 1Password
- Configuring the destination
- Testing the setup

**File:** `~/dotfiles/config/api-credentials/create_project_environment.sh`---

## Task 4: Automatic Environment Detection from Existing .env Files

### 4.1 Cursor Agent Integration Script

**File:** `~/dotfiles/config/api-credentials/sync_env_to_1password.sh`**Purpose:** Automatically detect existing .env files in projects and create/update 1Password Environments**Features:**

- Detect `.env` file in current project directory
- Check if 1Password Environment already exists for this project
- If not exists, generate instructions/automation to create it
- Parse .env file and format for 1Password Environment import
- Integrate with Cursor agent for automatic execution

**Usage from Cursor:**

- When Cursor agent detects a `.env` file in a project
- Automatically check if 1Password Environment exists
- If missing, prompt user or automatically create setup instructions
- Generate import-ready .env format

### 4.2 Cursor Agent Prompt/Integration

**File:** `~/dotfiles/config/api-credentials/cursor_env_sync.md`**Documentation for Cursor agent:**

- How to detect .env files in projects
- How to check for existing 1Password Environments
- How to generate environment creation instructions
- Integration with `create_project_environment.sh`

**Agent Workflow:**

1. Detect `.env` file in project root
2. Extract project name from directory or git remote
3. Check if 1Password Environment exists (via desktop app database or manual check)
4. If missing:

- Run `create_project_environment.sh` with detected project name
- Generate import-ready .env file
- Provide step-by-step instructions

5. If exists:

- Optionally sync changes from .env to 1Password Environment

### 4.3 Helper Functions

**File:** `~/dotfiles/config/api-credentials/env_helpers.sh`**Functions:**

- `detect_env_file()` - Find .env files in project
- `check_1password_env()` - Check if environment exists (via desktop app or instructions)
- `parse_env_file()` - Parse .env and format for 1Password
- `sync_env_to_1password()` - Main sync function

**Integration Points:**

- Can be called from Cursor agent when working in projects
- Can be used in project initialization scripts
- Can be integrated with git hooks

---

## Task 5: Documentation

### 5.1 Main README Update

**File:** `~/dotfiles/config/api-credentials/README.md`Update with:

- How to use the populate script
- How to set up Cursor hooks
- How to use the per-project environment script
- Links to 1Password documentation

### 5.2 Setup Guide

**File:** `~/dotfiles/config/api-credentials/SETUP_GUIDE.md`

- Step-by-step guide for initial setup
- Troubleshooting section
- Examples for different project types

---

## Implementation Details

### File Structure

```javascript
~/dotfiles/config/api-credentials/
├── update_1password_urls.sh         # Update URLs for all credentials (fixed)
├── populate_environment.sh          # Export credentials to .env format
├── import_to_environment.md         # Instructions for importing
├── create_project_environment.sh    # Per-project setup script
├── sync_env_to_1password.sh         # Auto-detect and sync .env files
├── env_helpers.sh                   # Helper functions for env detection
├── cursor_env_sync.md               # Cursor agent integration guide
├── CURSOR_HOOKS_SETUP.md            # Cursor hooks documentation
├── SETUP_GUIDE.md                   # Complete setup guide
├── README.md                        # Updated main README
├── services.json                     # Existing URL mapping
└── dollar_sign_references.md        # Existing reference doc
```



### Dependencies

- `op` CLI (1Password CLI)
- `jq` (for JSON parsing)
- `sqlite3` (for Cursor hook validation - installed separately)
- 1Password desktop app (for environment creation/configuration)

### Notes

- 1Password Environments are currently only configurable via the desktop app (no CLI support)
- The scripts will generate files and provide instructions for manual steps
- Cursor hooks require sqlite3 to query 1Password database
- The `default-1234` environment must already exist in 1Password

---

## Testing

1. Run `populate_environment.sh` and verify .env output
2. Import into `default-1234` environment manually
3. Configure destination in 1Password desktop app
4. Test Cursor hook validation
5. Test per-project script with a sample project

---

## Future Enhancements

- AppleScript automation for 1Password desktop app (if possible)
- Integration with project initialization scripts