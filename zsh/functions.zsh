# Zsh Functions
# Professional development helper functions
# Last updated: 2025-11-28

# ============================================================================
# 1PASSWORD INTEGRATION FUNCTIONS
# ============================================================================

# Load a secret from 1Password into an environment variable
# Usage: op_load_secret "vault_name" "item_name" "field_name" "env_var_name"
# Example: op_load_secret "Development" "API Keys" "OPENAI_API_KEY" "OPENAI_API_KEY"
op_load_secret() {
    local vault="${1:?Vault name required}"
    local item="${2:?Item name required}"
    local field="${3:?Field name required}"
    local env_var="${4:-$field}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    local secret
    secret=$(op read "op://${vault}/${item}/${field}" 2>/dev/null)
    
    if [[ -z "$secret" ]]; then
        echo "Warning: Could not load secret op://${vault}/${item}/${field}" >&2
        return 1
    fi
    
    export "$env_var=$secret"
    return 0
}

# Load multiple secrets from a 1Password item
# Usage: op_load_item "vault_name" "item_name" [vault_id]
# Exports all fields from the item as environment variables
# Uses session token caching to avoid repeated unlock prompts
# Returns 0 on success, 1 on failure
op_load_item() {
    local vault="${1:?Vault name required}"
    local item="${2:?Item name required}"
    local vault_id="${3:-}"
    local verbose="${4:-false}"  # Set to "true" for debug output
    
    if ! command -v op &> /dev/null; then
        [[ "$verbose" == "true" ]] && echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Get or create session token (cached for 30 minutes)
    local session_token
    session_token=$(op_get_session_token 2>/dev/null)
    if [[ -z "$session_token" ]]; then
        [[ "$verbose" == "true" ]] && echo "Error: No 1Password session token. Run: op_signin_cached" >&2
        return 1
    fi
    
    # Use vault ID if provided, otherwise try to resolve vault name
    local vault_arg
    if [[ -n "$vault_id" ]]; then
        vault_arg="--vault $vault_id"
    else
        # If multiple vaults with same name, use first one
        vault_id=$(op vault list --session "$session_token" 2>/dev/null | grep -i "^[^ ]*[[:space:]]*$vault" | head -1 | awk '{print $1}')
        if [[ -n "$vault_id" ]]; then
            vault_arg="--vault $vault_id"
        else
            vault_arg="--vault $vault"
        fi
    fi
    
    # Get all fields from the item using session token
    local fields
    local item_json
    item_json=$(op item get "$item" $vault_arg --session "$session_token" --format json 2>/dev/null)
    
    if [[ -z "$item_json" ]]; then
        [[ "$verbose" == "true" ]] && echo "Error: Could not retrieve item '${item}' from vault '${vault}'" >&2
        return 1
    fi
    
    fields=$(echo "$item_json" | jq -r '.fields[]? | select(.id != "notesPlain") | "\(.label)=\(.value)"' 2>/dev/null)
    
    if [[ -z "$fields" ]]; then
        [[ "$verbose" == "true" ]] && echo "Warning: Item '${item}' has no fields to load" >&2
        return 1
    fi
    
    # Count fields for logging
    local field_count
    field_count=$(echo "$fields" | wc -l | tr -d ' ')
    
    # Export each field as an environment variable
    # In direnv context, we need to ensure exports are visible
    local exported_count=0
    while IFS='=' read -r label value; do
        # Skip empty lines
        [[ -z "$label" ]] && continue
        
        # Convert label to valid env var name (uppercase, replace spaces with underscores)
        local env_var
        env_var=$(echo "$label" | tr '[:lower:]' '[:upper:]' | tr ' ' '_' | tr -cd '[:alnum:]_')
        
        # Remove quotes from value if present
        value="${value#\"}"
        value="${value%\"}"
        value="${value#\'}"
        value="${value%\'}"
        
        # Export the variable
        export "$env_var=$value"
        ((exported_count++))
        
        [[ "$verbose" == "true" ]] && echo "Exported: $env_var" >&2
    done <<< "$fields"
    
    [[ "$verbose" == "true" ]] && echo "Loaded $exported_count environment variables from 1Password" >&2
    
    return 0
}

# Get or create a 1Password session token (cached for 30 minutes)
# This avoids repeated unlock prompts in new shells
op_get_session_token() {
    local session_file="$HOME/.op_session"
    local session_age=0
    local session_token=""
    
    # Check if we have a cached session token
    if [[ -f "$session_file" ]] && [[ -s "$session_file" ]]; then
        # Get file age in seconds
        session_age=$(($(date +%s) - $(stat -f %m "$session_file" 2>/dev/null || stat -c %Y "$session_file" 2>/dev/null || echo 0)))
        
        # Use cached token if less than 30 minutes old (1800 seconds)
        if [[ $session_age -lt 1800 ]]; then
            session_token=$(cat "$session_file" 2>/dev/null | head -1 | tr -d '\n\r')
            
            # Verify it's not an error message and is a valid token
            if [[ -n "$session_token" ]] && \
               [[ ${#session_token} -gt 30 ]] && \
               [[ ! "$session_token" =~ "[Ee][Rr][Rr][Oo][Rr]" ]] && \
               [[ ! "$session_token" =~ "found no accounts" ]] && \
               [[ ! "$session_token" =~ "Usage:" ]]; then
                # Verify token still works
                if op account list --session "$session_token" &> /dev/null; then
                    echo "$session_token"
                    return 0
                fi
            fi
            # Bad cached token - remove it
            rm -f "$session_file"
        else
            # Session file too old, clean up
            rm -f "$session_file"
        fi
    elif [[ -f "$session_file" ]] && [[ ! -s "$session_file" ]]; then
        # Empty session file - remove it
        rm -f "$session_file"
    fi
    
    # Check if OP_SESSION_* environment variable is already set
    # (This happens when op signin was run manually)
    local account_id
    account_id=$(op account list 2>/dev/null | grep -i "aculich@gmail.com" | awk '{print $3}' | head -1)
    
    if [[ -n "$account_id" ]]; then
        local env_var_name="OP_SESSION_${account_id}"
        eval "session_token=\$$env_var_name" 2>/dev/null
        if [[ -n "$session_token" ]] && [[ ${#session_token} -gt 30 ]]; then
            # Cache it for future use
            echo "$session_token" > "$session_file"
            chmod 600 "$session_file"
            echo "$session_token"
            return 0
        fi
    fi
    
    # If we can't get a token, return failure silently
    # User can manually run: op signin (which sets OP_SESSION_* env var)
    # Or use: ~/dotfiles/scripts/op-signin-helper.sh
    return 1
}

# Wrapper for op signin that caches the session token
# Usage: op_signin_cached [account_email]
op_signin_cached() {
    local account_email="${1:-aculich@gmail.com}"
    local session_file="$HOME/.op_session"
    
    echo "Signing in to 1Password..."
    echo "Account: $account_email"
    echo ""
    
    # Check if already signed in (might have valid session)
    if op account list &> /dev/null; then
        local existing_token
        existing_token=$(op_get_session_token 2>/dev/null)
        if [[ -n "$existing_token" ]]; then
            echo "✓ Already signed in (using existing session)"
            return 0
        fi
    fi
    
    echo "This will prompt for biometric authentication (e.g., Touch ID)."
    echo "Please authenticate when prompted..."
    echo ""
    
    # Get account UUID from email (needed for --account flag)
    local account_uuid
    if command -v jq &> /dev/null; then
        account_uuid=$(op account list --format json 2>/dev/null | \
            jq -r ".[] | select(.email == \"$account_email\") | .account_uuid" 2>/dev/null | head -1)
    else
        # Fallback: try to get from account list output
        account_uuid=$(op account list 2>/dev/null | grep -i "$account_email" | awk '{print $3}' | head -1)
    fi
    
    if [[ -z "$account_uuid" ]]; then
        echo "Error: Account '$account_email' not found in 1Password accounts." >&2
        echo "Available accounts:" >&2
        op account list 2>&1 | grep -v "^URL" >&2
        return 1
    fi
    
    # Sign in with --account flag
    # This will prompt for biometric unlock but won't ask which account
    # Try --raw first, fall back to checking environment variables
    
    local session_token
    local error_output
    
    # Method 1: Try --raw (works best if biometric prompt cooperates)
    # Capture stderr separately to see any errors
    session_token=$(op signin --account "$account_uuid" --raw 2>/dev/null)
    
    # Check if we got a valid token from --raw
    if [[ -n "$session_token" ]] && \
       [[ ${#session_token} -gt 30 ]] && \
       [[ ! "$session_token" =~ "[Ee][Rr][Rr][Oo][Rr]" ]] && \
       [[ ! "$session_token" =~ "Usage:" ]] && \
       [[ ! "$session_token" =~ "not found" ]]; then
        # Success with --raw method
        session_token=$(echo "$session_token" | tr -d '\n\r \t')
        
        # Verify it works
        if op account list --session "$session_token" &> /dev/null; then
            # Token is valid, use it
            :
        else
            # Token invalid, clear it and try alternative
            session_token=""
        fi
    else
        # --raw didn't work or returned invalid token
        session_token=""
    fi
    
    # Method 2: If --raw didn't work, try running signin and checking env vars
    if [[ -z "$session_token" ]]; then
        echo "Note: Using interactive sign-in method..." >&2
        
        # Run signin (this will show biometric prompt and set OP_SESSION_* env var)
        # We need to run this in a way that preserves the environment
        if op signin --account "$account_uuid" 2>&1; then
            # Look for OP_SESSION_* environment variable
            # The variable name is OP_SESSION_<account_uuid>
            local env_var_name="OP_SESSION_${account_uuid}"
            
            # Try to get the value using parameter expansion
            # In zsh, we can use ${(P)var} to get the value of a variable named by another variable
            if [[ -n "${(P)env_var_name:-}" ]]; then
                session_token="${(P)env_var_name}"
            else
                # Try finding any OP_SESSION_* variable that works
                for var_name in ${(k)parameters}; do
                    if [[ "$var_name" =~ "^OP_SESSION_" ]]; then
                        local test_token="${(P)var_name}"
                        if [[ -n "$test_token" ]] && \
                           [[ ${#test_token} -gt 30 ]] && \
                           op account list --session "$test_token" &> /dev/null; then
                            session_token="$test_token"
                            break
                        fi
                    fi
                done
            fi
        else
            error_output="Sign-in command failed"
        fi
        
        # If still no token, report error
        if [[ -z "$session_token" ]]; then
            echo "Error: Failed to sign in to 1Password" >&2
            if [[ -n "$error_output" ]]; then
                echo "Details: $error_output" >&2
            fi
            echo "" >&2
            echo "Troubleshooting:" >&2
            echo "1. Make sure 1Password app is running" >&2
            echo "2. Try manually: op signin --account $account_uuid" >&2
            echo "3. Complete the biometric authentication when prompted" >&2
            echo "4. Check if biometric authentication is enabled in 1Password settings" >&2
            return 1
        fi
    fi
    
    # Check if we got a valid token (not an error message)
    if [[ -z "$session_token" ]] || \
       [[ "$session_token" =~ "[Ee][Rr][Rr][Oo][Rr]" ]] || \
       [[ "$session_token" =~ "Usage:" ]] || \
       [[ "$session_token" =~ "not found" ]] || \
       [[ ${#session_token} -lt 30 ]]; then
        echo "Error: Failed to get valid session token from 1Password" >&2
        if [[ -n "$session_token" ]]; then
            echo "Received: ${session_token:0:50}..." >&2
        fi
        return 1
    fi
    
    # Verify the token works
    if ! op account list --session "$session_token" &> /dev/null; then
        echo "Error: Session token is invalid" >&2
        return 1
    fi
    
    # Cache the token
    echo "$session_token" > "$session_file"
    chmod 600 "$session_file"
    
    echo "✓ 1Password session token cached for 30 minutes."
    echo "  Account: $account_email"
    echo "  Account UUID: $account_uuid"
    
    return 0
}

# Check if 1Password CLI is authenticated
op_check_auth() {
    if ! command -v op &> /dev/null; then
        echo "1Password CLI not installed"
        return 1
    fi
    
    local session_token
    session_token=$(op_get_session_token 2>/dev/null)
    
    if [[ -n "$session_token" ]] && op account list --session "$session_token" &> /dev/null; then
        echo "1Password CLI authenticated (session cached)"
        return 0
    elif op account list &> /dev/null; then
        echo "1Password CLI authenticated (no session cache)"
        return 0
    else
        echo "1Password CLI not authenticated. Run: op_signin_cached"
        return 1
    fi
}

# ============================================================================
# DIRENV + 1PASSWORD HELPERS
# ============================================================================

# Generate a .envrc template that uses 1Password
# Usage: op_direnv_template "vault_name" "item_name"
op_direnv_template() {
    local vault="${1:-Development}"
    local item="${2:-API Keys}"
    
    cat <<EOF
# .envrc - Environment variables loaded via direnv
# This file uses 1Password CLI to securely load secrets
# 
# To use this, ensure you're signed in: op signin
# Then allow direnv: direnv allow

# Load secrets from 1Password
# Format: op_load_secret "vault" "item" "field" "env_var"
# Or load entire item: op_load_item "vault" "item"

# Example:
# op_load_secret "${vault}" "${item}" "OPENAI_API_KEY" "OPENAI_API_KEY"
# op_load_secret "${vault}" "${item}" "GITHUB_TOKEN" "GITHUB_TOKEN"

# Or load all fields from an item:
# op_load_item "${vault}" "${item}"

# Project-specific environment variables (non-secret)
# export PROJECT_NAME="my-project"
# export PROJECT_ENV="development"
EOF
}

# ============================================================================
# DEVELOPMENT WORKFLOW FUNCTIONS
# ============================================================================

# Quick check of development environment setup
dev_check() {
    echo "=== Development Environment Check ==="
    echo ""
    
    echo "Shell: $SHELL"
    echo "Zsh version: $ZSH_VERSION"
    echo ""
    
    echo "Tools:"
    command -v git &> /dev/null && echo "  ✓ git: $(git --version | cut -d' ' -f3)" || echo "  ✗ git: not found"
    command -v node &> /dev/null && echo "  ✓ node: $(node --version)" || echo "  ✗ node: not found"
    command -v python3 &> /dev/null && echo "  ✓ python3: $(python3 --version | cut -d' ' -f2)" || echo "  ✗ python3: not found"
    command -v direnv &> /dev/null && echo "  ✓ direnv: $(direnv --version)" || echo "  ✗ direnv: not found"
    command -v op &> /dev/null && echo "  ✓ 1Password CLI: $(op --version)" || echo "  ✗ 1Password CLI: not found"
    echo ""
    
    echo "1Password:"
    op_check_auth
    echo ""
    
    echo "Direnv:"
    if direnv status &> /dev/null; then
        echo "  ✓ direnv is active"
    else
        echo "  ✗ direnv not active in this directory"
    fi
    echo ""
    
    echo "Environment:"
    echo "  EDITOR: ${EDITOR:-not set}"
    echo "  PATH entries: $(echo $PATH | tr ':' '\n' | wc -l | tr -d ' ')"
}

# Reload zsh configuration
reload_zsh() {
    echo "Reloading zsh configuration..."
    exec zsh
}
