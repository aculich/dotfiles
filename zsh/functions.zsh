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
op_load_item() {
    local vault="${1:?Vault name required}"
    local item="${2:?Item name required}"
    local vault_id="${3:-}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Get or create session token (cached for 30 minutes)
    local session_token
    session_token=$(op_get_session_token 2>/dev/null)
    if [[ -z "$session_token" ]]; then
        # Don't fail loudly - just return silently
        # User can manually run: op signin
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
    fields=$(op item get "$item" $vault_arg --session "$session_token" --format json 2>/dev/null | \
        jq -r '.fields[]? | select(.id != "notesPlain") | "\(.label)=\(.value)"' 2>/dev/null)
    
    if [[ -z "$fields" ]]; then
        echo "Warning: Could not load item ${vault}/${item}" >&2
        return 1
    fi
    
    # Export each field as an environment variable
    while IFS='=' read -r label value; do
        # Convert label to valid env var name (uppercase, replace spaces with underscores)
        local env_var
        env_var=$(echo "$label" | tr '[:lower:]' '[:upper:]' | tr ' ' '_' | tr -cd '[:alnum:]_')
        export "$env_var=$value"
    done <<< "$fields"
    
    return 0
}

# Get or create a 1Password session token (cached for 30 minutes)
# This avoids repeated unlock prompts in new shells
op_get_session_token() {
    local session_file="$HOME/.op_session"
    local session_age=0
    local session_token=""
    
    # Check if we have a cached session token
    if [[ -f "$session_file" ]]; then
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
        fi
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
    
    # Sign in (this will prompt for unlock)
    if op signin &> /dev/null; then
        # Get the session token from environment
        local account_id
        account_id=$(op account list 2>/dev/null | grep -i "$account_email" | awk '{print $3}' | head -1)
        
        if [[ -n "$account_id" ]]; then
            local env_var_name="OP_SESSION_${account_id}"
            eval "local session_token=\$$env_var_name" 2>/dev/null
            if [[ -n "$session_token" ]] && [[ ${#session_token} -gt 30 ]]; then
                # Cache it
                echo "$session_token" > "$session_file"
                chmod 600 "$session_file"
                echo "✓ Session token cached for 30 minutes"
                return 0
            fi
        fi
        
        # Try to get raw token as fallback
        local raw_token
        raw_token=$(op signin --raw 2>/dev/null)
        if [[ -n "$raw_token" ]] && [[ ${#raw_token} -gt 30 ]] && [[ ! "$raw_token" =~ "[Ee][Rr][Rr][Oo][Rr]" ]]; then
            echo "$raw_token" > "$session_file"
            chmod 600 "$session_file"
            echo "✓ Session token cached for 30 minutes"
            return 0
        fi
    fi
    
    echo "✗ Failed to cache session token"
    return 1
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
