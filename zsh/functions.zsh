# Zsh Functions
# Professional development helper functions
# Last updated: 2025-11-28

# ============================================================================
# 1PASSWORD INTEGRATION FUNCTIONS
# ============================================================================

# Load a secret from 1Password into an environment variable
# Usage: op_load_secret "vault_name" "item_name" "field_name" "env_var_name"
# Example: op_load_secret "develop" "apikeys" "OPENAI_API_KEY" "OPENAI_API_KEY"
op_load_secret() {
    local vault="${1:?Vault name required}"
    local item="${2:?Item name required}"
    local field="${3:?Field name required}"
    local env_var="${4:-$field}"
    local account_email="${5:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Get account UUID (this is what works in the test script)
    local account_uuid
    account_uuid=$(_op_get_account_uuid "$account_email")
    
    if [[ -z "$account_uuid" ]]; then
        echo "Error: Account '$account_email' not found" >&2
        return 1
    fi
    
    # Check if we can access 1Password (desktop app integration or existing session)
    # Try to use desktop app integration first (no prompts if app is unlocked)
    if ! op account list --account "$account_uuid" &> /dev/null; then
        # Try desktop app integration (uses system keychain/Touch ID)
        # This will silently use Touch ID if the desktop app is running and unlocked
        if ! op signin --account "$account_uuid" --raw &> /dev/null; then
            echo "Error: Could not access 1Password. Please unlock 1Password app first." >&2
            echo "The desktop app uses macOS system keychain/Touch ID for automatic unlocking." >&2
            return 1
        fi
    fi
    
    # Use op read with --account flag (more reliable)
    local secret
    secret=$(op read "op://${vault}/${item}/${field}" --account "$account_uuid" 2>/dev/null)
    
    if [[ -z "$secret" ]]; then
        echo "Warning: Could not load secret op://${vault}/${item}/${field} from account $account_email" >&2
        return 1
    fi
    
    export "$env_var=$secret"
    return 0
}

# Load multiple secrets from a 1Password item
# Usage: op_load_item "vault_name" "item_name" [vault_id] [account_email]
# Exports all fields from the item as environment variables
# Uses account UUID approach (more reliable than session tokens)
# Returns 0 on success, 1 on failure
op_load_item() {
    local vault="${1:?Vault name required}"
    local item="${2:?Item name required}"
    local vault_id="${3:-}"
    local account_email="${4:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    local verbose="${5:-false}"  # Set to "true" for debug output
    
    if ! command -v op &> /dev/null; then
        [[ "$verbose" == "true" ]] && echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Get account UUID (this is what works in the test script)
    local account_uuid
    account_uuid=$(_op_get_account_uuid "$account_email")
    
    if [[ -z "$account_uuid" ]]; then
        [[ "$verbose" == "true" ]] && echo "Error: Account '$account_email' not found" >&2
        return 1
    fi
    
    # Check if we can access 1Password via desktop app integration
    # The desktop app uses macOS system keychain/Touch ID for automatic unlocking
    # When the desktop app is unlocked, the CLI can use that session without prompting
    # We check by trying a simple operation - if it works, desktop app is unlocked
    # If it fails, we don't prompt (fail silently) - user should unlock app manually
    
    # First, check if we already have a valid session (no prompt)
    if ! op account list --account "$account_uuid" &> /dev/null; then
        # No session - check if desktop app is available and unlocked
        # Try a simple operation that won't prompt if desktop app is unlocked
        # If desktop app is locked, this will fail silently (no prompt)
        # The key is: if desktop app is unlocked, op commands work without prompting
        # If it's locked, we fail silently rather than prompting
        if ! op vault list --account "$account_uuid" &> /dev/null 2>&1; then
            # Desktop app not available or locked - fail silently
            # User should unlock 1Password app manually (it uses system keychain/Touch ID)
            # Don't prompt here - let the user unlock the app manually
            [[ "$verbose" == "true" ]] && echo "1Password desktop app is locked. Please unlock it manually." >&2
            return 1
        fi
    fi
    
    # Use vault ID if provided, otherwise use vault name
    local vault_arg
    if [[ -n "$vault_id" ]]; then
        vault_arg="--vault $vault_id"
    else
        vault_arg="--vault $vault"
    fi
    
    # Get all fields from the item using --account flag (this is what works)
    local fields
    local item_json
    item_json=$(op item get "$item" $vault_arg --account "$account_uuid" --format json 2>/dev/null)
    
    if [[ -z "$item_json" ]]; then
        [[ "$verbose" == "true" ]] && echo "Error: Could not retrieve item '${item}' from vault '${vault}' in account '${account_email}'" >&2
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
            # Read token and clean it up (remove all whitespace, newlines, etc.)
            session_token=$(cat "$session_file" 2>/dev/null | tr -d '\n\r \t' | head -c 200)
            
            # Verify it's not an error message and is a valid token
            if [[ -n "$session_token" ]] && \
               [[ ${#session_token} -gt 30 ]] && \
               [[ ! "$session_token" =~ "[Ee][Rr][Rr][Oo][Rr]" ]] && \
               [[ ! "$session_token" =~ "found no accounts" ]] && \
               [[ ! "$session_token" =~ "Usage:" ]] && \
               [[ ! "$session_token" =~ "Warning:" ]] && \
               [[ ! "$session_token" =~ "Error:" ]]; then
                # Verify token still works
                if op account list --session "$session_token" &> /dev/null; then
                    echo "$session_token"
                    return 0
                else
                    # Token doesn't work anymore, remove it
                    rm -f "$session_file"
                fi
            else
                # Bad cached token - remove it
                rm -f "$session_file"
            fi
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
    
    # Check if already signed in (might have valid session)
    # First check cached file
    local existing_token
    existing_token=$(op_get_session_token 2>/dev/null)
    if [[ -n "$existing_token" ]]; then
        # Already have a valid cached token
        if [[ -t 1 ]]; then
            # Only print if running interactively (not from direnv)
            echo "✓ Already signed in (using cached session token)"
        fi
        return 0
    fi
    
    # If op account list works, we have a session but no cached token
    # Try to extract it using --raw (might work if session is still valid)
    if op account list &> /dev/null; then
        if [[ -t 1 ]]; then
            echo "Note: 1Password session exists but token not cached." >&2
            echo "Attempting to extract token..." >&2
        fi
    fi
    
    # Only show prompts if running interactively (not from direnv)
    if [[ -t 1 ]]; then
        echo "Signing in to 1Password..."
        echo "Account: $account_email"
        echo ""
        echo "This will prompt for biometric authentication (e.g., Touch ID)."
        echo "Please authenticate when prompted..."
        echo ""
    fi
    
    # Get account UUID and user UUID from email (needed for --account flag and env var name)
    local account_uuid
    local user_uuid
    if command -v jq &> /dev/null; then
        account_uuid=$(op account list --format json 2>/dev/null | \
            jq -r ".[] | select(.email == \"$account_email\") | .account_uuid" 2>/dev/null | head -1)
        user_uuid=$(op account list --format json 2>/dev/null | \
            jq -r ".[] | select(.email == \"$account_email\") | .user_uuid" 2>/dev/null | head -1)
    else
        # Fallback: try to get from account list output
        account_uuid=$(op account list 2>/dev/null | grep -i "$account_email" | awk '{print $3}' | head -1)
        # User UUID is in a different column, need to parse differently
        user_uuid=$(op account list 2>/dev/null | grep -i "$account_email" | awk '{print $4}' | head -1)
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
    # Note: --raw might not work well with interactive biometric prompts
    # Capture both stdout and stderr to see what's happening
    local raw_output
    local raw_error
    raw_output=$(op signin --account "$account_uuid" --raw 2>&1)
    local raw_exit=$?
    
    # Check if we got a valid token from --raw
    if [[ $raw_exit -eq 0 ]] && \
       [[ -n "$raw_output" ]] && \
       [[ ${#raw_output} -gt 30 ]] && \
       [[ ! "$raw_output" =~ "[Ee][Rr][Rr][Oo][Rr]" ]] && \
       [[ ! "$raw_output" =~ "Usage:" ]] && \
       [[ ! "$raw_output" =~ "not found" ]] && \
       [[ ! "$raw_output" =~ "cancel" ]]; then
        # Success with --raw method
        session_token=$(echo "$raw_output" | tr -d '\n\r \t')
        
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
        # This is expected if biometric prompt doesn't work with --raw
        session_token=""
    fi
    
    # Method 2: If --raw didn't work, try running signin and checking env vars
    if [[ -z "$session_token" ]]; then
        if [[ -t 1 ]]; then
            echo "Note: Using interactive sign-in method..." >&2
        fi
        
        # Run signin (this will show biometric prompt and set OP_SESSION_* env var)
        # The env var name is OP_SESSION_<user_uuid>, not account_uuid!
        # IMPORTANT: We need to run this in the current shell context, not a subshell
        # So we can't use command substitution - we run it directly
        local signin_success=false
        
        # Try --raw first (might work if biometric prompt cooperates)
        # Note: --raw might hang if it needs interactive input, so we try it first
        local raw_token=""
        # Try to get raw token (use timeout if available, otherwise just try)
        if command -v timeout &> /dev/null || command -v gtimeout &> /dev/null; then
            local timeout_cmd=$(command -v timeout || command -v gtimeout)
            raw_token=$($timeout_cmd 30 op signin --account "$account_uuid" --raw 2>&1 || echo "")
        else
            # No timeout command - just try it (might hang on interactive prompt)
            raw_token=$(op signin --account "$account_uuid" --raw 2>&1 || echo "")
        fi
        
        if [[ -n "$raw_token" ]] && \
           [[ ${#raw_token} -gt 30 ]] && \
           [[ ! "$raw_token" =~ "[Ee][Rr][Rr][Oo][Rr]" ]] && \
           [[ ! "$raw_token" =~ "Usage:" ]] && \
           [[ ! "$raw_token" =~ "not found" ]] && \
           [[ ! "$raw_token" =~ "cancel" ]]; then
            session_token=$(echo "$raw_token" | tr -d '\n\r \t')
            if op account list --session "$session_token" &> /dev/null; then
                signin_success=true
            fi
        fi
        
        # If --raw didn't work, try interactive signin
        if [[ "$signin_success" != true ]]; then
            # Run op signin - this will set OP_SESSION_* environment variable
            # IMPORTANT: We must run this in the current shell, not a subshell
            # So we can't use command substitution - we run it directly and check env after
            
            # First, clear any existing OP_SESSION_* variables to avoid confusion
            unset $(env | grep -o '^OP_SESSION_[^=]*' || true) 2>/dev/null || true
            
            # Run signin (this sets OP_SESSION_<user_uuid> in current shell)
            if op signin --account "$account_uuid" 2>&1; then
                signin_success=true
                
                # Immediately check for OP_SESSION_* variables in the current shell
                # Method 1: Try using the known user_uuid with zsh parameter expansion
                if [[ -n "$user_uuid" ]]; then
                    local env_var_name="OP_SESSION_${user_uuid}"
                    # In zsh, use ${(P)var_name} to expand variable by name
                    local test_token="${(P)env_var_name:-}"
                    if [[ -n "$test_token" ]] && \
                       [[ ${#test_token} -gt 30 ]] && \
                       op account list --session "$test_token" &> /dev/null; then
                        session_token="$test_token"
                    fi
                fi
                
                # Method 2: Search all OP_SESSION_* variables using printenv
                if [[ -z "$session_token" ]]; then
                    # Use printenv to get all OP_SESSION_* variables
                    local op_session_vars
                    op_session_vars=$(printenv | grep "^OP_SESSION_" || true)
                    if [[ -n "$op_session_vars" ]]; then
                        while IFS='=' read -r var_name var_value; do
                            # Skip empty lines
                            [[ -z "$var_name" ]] && continue
                            
                            # Clean the value (remove any whitespace)
                            var_value=$(echo "$var_value" | tr -d '\n\r \t')
                            
                            # Test if this token works
                            if [[ -n "$var_value" ]] && \
                               [[ ${#var_value} -gt 30 ]] && \
                               op account list --session "$var_value" &> /dev/null; then
                                session_token="$var_value"
                                break
                            fi
                        done <<< "$op_session_vars"
                    fi
                fi
                
                # Method 3: Try eval as fallback (for compatibility)
                if [[ -z "$session_token" ]] && [[ -n "$user_uuid" ]]; then
                    local env_var_name="OP_SESSION_${user_uuid}"
                    eval "test_token=\$$env_var_name" 2>/dev/null || test_token=""
                    if [[ -n "$test_token" ]] && \
                       [[ ${#test_token} -gt 30 ]] && \
                       op account list --session "$test_token" &> /dev/null; then
                        session_token="$test_token"
                    fi
                fi
            else
                error_output="Sign-in command failed"
                signin_success=false
            fi
        fi
        
        # If signin succeeded but we still don't have a token, that's an error
        if [[ "$signin_success" == true ]] && [[ -z "$session_token" ]]; then
            error_output="Sign-in succeeded but could not extract session token from environment"
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
    
    # Cache the token - ensure we write it correctly
    # Remove any existing file first to avoid issues
    rm -f "$session_file"
    echo -n "$session_token" > "$session_file"
    chmod 600 "$session_file"
    
    # Verify the file was written correctly
    if [[ ! -f "$session_file" ]] || [[ ! -s "$session_file" ]]; then
        echo "Error: Failed to write session token to cache file" >&2
        return 1
    fi
    
    # Verify we can read it back
    local cached_token
    cached_token=$(cat "$session_file" 2>/dev/null | tr -d '\n\r')
    if [[ "$cached_token" != "$session_token" ]]; then
        echo "Warning: Cached token doesn't match original token" >&2
        # Try to fix it
        echo -n "$session_token" > "$session_file"
        chmod 600 "$session_file"
    fi
    
    echo "✓ 1Password session token cached for 30 minutes."
    echo "  Account: $account_email"
    echo "  Account UUID: $account_uuid"
    echo "  Token cached to: $session_file"
    
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
# 1PASSWORD ACCOUNT MANAGEMENT
# ============================================================================

# Default 1Password account (can be overridden with OP_ACCOUNT env var)
export OP_DEFAULT_ACCOUNT="${OP_DEFAULT_ACCOUNT:-aculich@gmail.com}"

# Get the account to use (from env var, default, or parameter)
# Usage: _op_get_account [account_email]
_op_get_account() {
    local account="${1:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    echo "$account"
}

# List all configured 1Password accounts
# Usage: op_list_accounts
op_list_accounts() {
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    echo "Configured 1Password Accounts:"
    echo "================================="
    op account list 2>/dev/null || {
        echo "Error: Could not list accounts. You may need to sign in first." >&2
        return 1
    }
    echo ""
    echo "Current default: ${OP_DEFAULT_ACCOUNT}"
    echo "Current OP_ACCOUNT: ${OP_ACCOUNT:-not set}"
}

# Set the default 1Password account
# Usage: op_set_account "aculich@gmail.com"
op_set_account() {
    local account="${1:?Account email required}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Verify account exists
    if ! op account list 2>/dev/null | grep -q "$account"; then
        echo "Error: Account '$account' not found in configured accounts" >&2
        echo ""
        echo "Available accounts:" >&2
        op account list >&2
        return 1
    fi
    
    export OP_DEFAULT_ACCOUNT="$account"
    export OP_ACCOUNT="$account"
    
    echo "✓ Set default 1Password account to: $account"
    echo ""
    echo "To make this permanent, add to your ~/.zshenv:"
    echo "  export OP_DEFAULT_ACCOUNT=\"$account\""
    echo "  export OP_ACCOUNT=\"$account\""
}

# Get account UUID from email
# Usage: _op_get_account_uuid "aculich@gmail.com"
_op_get_account_uuid() {
    local account_email="${1:?Account email required}"
    local account_uuid
    
    if command -v jq &> /dev/null; then
        account_uuid=$(op account list --format json 2>/dev/null | \
            jq -r ".[] | select(.email == \"$account_email\") | .account_uuid" 2>/dev/null | head -1)
    else
        account_uuid=$(op account list 2>/dev/null | grep -i "$account_email" | awk '{print $3}' | head -1)
    fi
    
    echo "$account_uuid"
}

# ============================================================================
# 1PASSWORD ITEM INSPECTION HELPERS
# ============================================================================

# List all fields in a 1Password item
# Usage: op_list_item_fields "vault_name" "item_name" [account_email]
# Example: op_list_item_fields "develop" "apikeys"
# Example: op_list_item_fields "develop" "apikeys" "aculich@gmail.com"
op_list_item_fields() {
    local vault="${1:?Vault name required}"
    local item="${2:?Item name required}"
    local account_email="${3:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Get account UUID
    local account_uuid
    account_uuid=$(_op_get_account_uuid "$account_email")
    
    if [[ -z "$account_uuid" ]]; then
        echo "Error: Account '$account_email' not found" >&2
        echo ""
        echo "Available accounts:" >&2
        op account list >&2
        return 1
    fi
    
    # Check if we can access 1Password (desktop app integration or existing session)
    # Try to use desktop app integration first (no prompts if app is unlocked)
    if ! op account list --account "$account_uuid" &> /dev/null; then
        # Try desktop app integration (uses system keychain/Touch ID)
        # This will silently use Touch ID if the desktop app is running and unlocked
        if ! op signin --account "$account_uuid" --raw &> /dev/null; then
            echo "Error: Could not access 1Password. Please unlock 1Password app first." >&2
            echo "The desktop app uses macOS system keychain/Touch ID for automatic unlocking." >&2
            return 1
        fi
    fi
    
    # Set OP_ACCOUNT for this command
    local old_op_account="${OP_ACCOUNT:-}"
    export OP_ACCOUNT="$account_uuid"
    
    echo "Fields in 1Password item: $vault/$item"
    echo "=========================================="
    
    echo "Using account: $account_email (UUID: $account_uuid)"
    echo ""
    
    # Get item details in JSON format (use --account flag)
    local item_json
    item_json=$(op item get "$item" --vault "$vault" --account "$account_uuid" --format json 2>/dev/null)
    
    # Restore OP_ACCOUNT
    if [[ -n "$old_op_account" ]]; then
        export OP_ACCOUNT="$old_op_account"
    else
        unset OP_ACCOUNT
    fi
    
    if [[ -z "$item_json" ]]; then
        echo "Error: Could not retrieve item '$item' from vault '$vault' in account '$account_email'" >&2
        echo "Troubleshooting:" >&2
        echo "1. Verify account: op account list" >&2
        echo "2. Verify vault name: op vault list --account $account_uuid" >&2
        echo "3. Verify item name: op item list --vault '$vault' --account $account_uuid" >&2
        return 1
    fi
    
    # Extract fields using jq if available
    if command -v jq &> /dev/null; then
        echo ""
        echo "Field names (for use in op:// references):"
        echo "-------------------------------------------"
        echo "$item_json" | jq -r '.fields[]? | "\(.label // .id) = \(.type // "unknown")"' 2>/dev/null || \
        echo "$item_json" | jq -r '.fields[]? | .label // .id' 2>/dev/null
        
        echo ""
        echo "Full item structure:"
        echo "-------------------------------------------"
        echo "$item_json" | jq '.' 2>/dev/null
    else
        # Fallback: show raw JSON
        echo ""
        echo "Item JSON (install 'jq' for better formatting):"
        echo "-------------------------------------------"
        echo "$item_json"
        echo ""
        echo "Install jq for better output: brew install jq"
    fi
    
    return 0
}

# Quick check: Show what fields are available in develop/apikeys
# Usage: op_check_apikeys [account_email]
op_check_apikeys() {
    op_list_item_fields "develop" "apikeys" "${1:-}"
}

# List just the field names (clean, simple output)
# Usage: op_list_fields "vault_name" "item_name" [account_email]
# Example: op_list_fields "develop" "apikeys"
op_list_fields() {
    local vault="${1:?Vault name required}"
    local item="${2:?Item name required}"
    local account_email="${3:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Get account UUID
    local account_uuid
    account_uuid=$(_op_get_account_uuid "$account_email")
    
    if [[ -z "$account_uuid" ]]; then
        echo "Error: Account '$account_email' not found" >&2
        return 1
    fi
    
    # Ensure we're signed in
    if ! op account list --account "$account_uuid" &> /dev/null; then
        op_signin_simple "$account_email" || return 1
    fi
    
    # Get item JSON
    local item_json
    item_json=$(op item get "$item" --vault "$vault" --account "$account_uuid" --format json 2>/dev/null)
    
    if [[ -z "$item_json" ]]; then
        echo "Error: Could not retrieve item '$item' from vault '$vault'" >&2
        return 1
    fi
    
    # Extract and display field names only
    if command -v jq &> /dev/null; then
        echo "$item_json" | jq -r '.fields[]? | select(.label) | .label' 2>/dev/null | sort
    else
        echo "Install jq for better output: brew install jq" >&2
        echo "$item_json"
    fi
}

# Quick list of fields in develop/apikeys (most common use case)
# Usage: op_list_apikeys [account_email]
op_list_apikeys() {
    op_list_fields "develop" "apikeys" "${1:-}"
}

# Inspect vault structure and configuration
# Usage: op_inspect_vault [vault_name] [account_email]
# Default: inspects "develop" vault with default account
op_inspect_vault() {
    local vault="${1:-develop}"
    local account_email="${2:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Get account UUID
    local account_uuid
    account_uuid=$(_op_get_account_uuid "$account_email")
    
    if [[ -z "$account_uuid" ]]; then
        echo "Error: Account '$account_email' not found" >&2
        echo ""
        echo "Available accounts:" >&2
        op account list >&2
        return 1
    fi
    
    # Check if we can access 1Password (desktop app integration or existing session)
    # Try to use desktop app integration first (no prompts if app is unlocked)
    if ! op account list --account "$account_uuid" &> /dev/null; then
        # Try desktop app integration (uses system keychain/Touch ID)
        # This will silently use Touch ID if the desktop app is running and unlocked
        if ! op signin --account "$account_uuid" --raw &> /dev/null; then
            echo "Error: Could not access 1Password. Please unlock 1Password app first." >&2
            echo "The desktop app uses macOS system keychain/Touch ID for automatic unlocking." >&2
            return 1
        fi
    fi
    
    echo "Using account: $account_email (UUID: $account_uuid)"
    echo ""
    
    echo "=========================================="
    echo "1Password Vault Inspection: $vault"
    echo "=========================================="
    echo ""
    
    # List all vaults first (for this account)
    echo "Available Vaults:"
    echo "----------------"
    op vault list --account "$account_uuid" 2>/dev/null || {
        echo "Error: Could not list vaults" >&2
        return 1
    }
    echo ""
    
    # Get vault details
    echo "Vault Details:"
    echo "---------------"
    local vault_info
    vault_info=$(op vault get "$vault" --account "$account_uuid" --format json 2>/dev/null)
    
    if [[ -z "$vault_info" ]]; then
        echo "Error: Vault '$vault' not found" >&2
        echo ""
        echo "Available vaults:" >&2
        op vault list >&2
        return 1
    fi
    
    if command -v jq &> /dev/null; then
        echo "$vault_info" | jq -r '
            "Name: \(.name // "N/A")
ID: \(.id // "N/A")
Description: \(.description // "N/A")
Type: \(.type // "N/A")
Created: \(.created_at // "N/A")
Updated: \(.updated_at // "N/A")"
        '
    else
        echo "$vault_info"
    fi
    echo ""
    
    # List items in vault
    echo "Items in Vault:"
    echo "---------------"
    local items
    items=$(op item list --vault "$vault" --account "$account_uuid" --format json 2>/dev/null)
    
    if [[ -z "$items" ]]; then
        echo "No items found in vault '$vault'"
        return 0
    fi
    
    if command -v jq &> /dev/null; then
        echo "$items" | jq -r '.[] | "  • \(.title // .id) (ID: \(.id))"'
        echo ""
        echo "Total items: $(echo "$items" | jq '. | length')"
    else
        op item list --vault "$vault"
    fi
    echo ""
}

# Show detailed information about a specific item
# Usage: op_inspect_item "vault_name" "item_name" [account_email]
# Example: op_inspect_item "develop" "apikeys"
# Example: op_inspect_item "develop" "apikeys" "aculich@gmail.com"
op_inspect_item() {
    local vault="${1:?Vault name required}"
    local item="${2:?Item name required}"
    local account_email="${3:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Get account UUID
    local account_uuid
    account_uuid=$(_op_get_account_uuid "$account_email")
    
    if [[ -z "$account_uuid" ]]; then
        echo "Error: Account '$account_email' not found" >&2
        echo ""
        echo "Available accounts:" >&2
        op account list >&2
        return 1
    fi
    
    # Check if we can access 1Password (desktop app integration or existing session)
    # Try to use desktop app integration first (no prompts if app is unlocked)
    if ! op account list --account "$account_uuid" &> /dev/null; then
        # Try desktop app integration (uses system keychain/Touch ID)
        # This will silently use Touch ID if the desktop app is running and unlocked
        if ! op signin --account "$account_uuid" --raw &> /dev/null; then
            echo "Error: Could not access 1Password. Please unlock 1Password app first." >&2
            echo "The desktop app uses macOS system keychain/Touch ID for automatic unlocking." >&2
            return 1
        fi
    fi
    
    echo "Using account: $account_email (UUID: $account_uuid)"
    echo ""
    
    echo "=========================================="
    echo "1Password Item Inspection: $vault/$item"
    echo "=========================================="
    echo ""
    
    # Get item details (use --account flag)
    local item_json
    item_json=$(op item get "$item" --vault "$vault" --account "$account_uuid" --format json 2>/dev/null)
    
    if [[ -z "$item_json" ]]; then
        echo "Error: Item '$item' not found in vault '$vault' in account '$account_email'" >&2
        echo ""
        echo "Available items in vault '$vault':" >&2
        op item list --vault "$vault" --account "$account_uuid" >&2
        return 1
    fi
    
    if command -v jq &> /dev/null; then
        echo "Item Information:"
        echo "------------------"
        echo "$item_json" | jq -r '
            "Title: \(.title // "N/A")
ID: \(.id // "N/A")
Category: \(.category // "N/A")
Created: \(.created_at // "N/A")
Updated: \(.updated_at // "N/A")
Vault: \(.vault.id // "N/A")"
        '
        echo ""
        
        echo "Fields (for use in op:// references):"
        echo "-------------------------------------"
        echo "$item_json" | jq -r '.fields[]? | 
            if .label then 
                "  • \(.label) (type: \(.type // "unknown"))"
            else 
                "  • \(.id) (type: \(.type // "unknown"))"
            end
        ' | sort
        
        echo ""
        echo "Field Count: $(echo "$item_json" | jq '.fields | length')"
        echo ""
        
        echo "Full JSON Structure:"
        echo "--------------------"
        echo "$item_json" | jq '.'
    else
        echo "Item JSON (install 'jq' for better formatting):"
        echo "-------------------------------------------"
        echo "$item_json"
        echo ""
        echo "Install jq for better output: brew install jq"
    fi
    
    return 0
}

# Quick inspection of develop vault and apikeys item
# Usage: op_inspect_develop [account_email]
op_inspect_develop() {
    local account_email="${1:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    echo "Inspecting develop vault and apikeys item..."
    echo "Using account: $account_email"
    echo ""
    op_inspect_vault "develop" "$account_email"
    echo ""
    echo "=========================================="
    echo ""
    op_inspect_item "develop" "apikeys" "$account_email"
}

# ============================================================================
# SIMPLIFIED 1PASSWORD SIGNIN (FIXED VERSION)
# ============================================================================

# Simplified signin that relies on 1Password's built-in session management
# This avoids the token extraction issues
# Usage: op_signin_simple [account_email]
op_signin_simple() {
    local account_email="${1:-aculich@gmail.com}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Check if already signed in
    if op account list &> /dev/null; then
        if [[ -t 1 ]]; then
            echo "✓ Already signed in to 1Password"
        fi
        return 0
    fi
    
    # Get account UUID
    local account_uuid
    if command -v jq &> /dev/null; then
        account_uuid=$(op account list --format json 2>/dev/null | \
            jq -r ".[] | select(.email == \"$account_email\") | .account_uuid" 2>/dev/null | head -1)
    else
        account_uuid=$(op account list 2>/dev/null | grep -i "$account_email" | awk '{print $3}' | head -1)
    fi
    
    if [[ -z "$account_uuid" ]]; then
        echo "Error: Account '$account_email' not found" >&2
        return 1
    fi
    
    # Sign in - let 1Password handle session management
    # This will prompt for biometric auth if needed
    if [[ -t 1 ]]; then
        echo "Signing in to 1Password..."
        echo "Account: $account_email"
        echo "Please authenticate when prompted..."
    fi
    
    if op signin --account "$account_uuid" &> /dev/null; then
        if [[ -t 1 ]]; then
            echo "✓ Successfully signed in to 1Password"
        fi
        return 0
    else
        echo "Error: Failed to sign in to 1Password" >&2
        echo "Troubleshooting:" >&2
        echo "1. Make sure 1Password app is running" >&2
        echo "2. Enable 'Connect with 1Password CLI' in 1Password Settings > Developer" >&2
        echo "3. Try manually: op signin --account $account_uuid" >&2
        return 1
    fi
}

# ============================================================================
# OP INJECT PATTERN (RECOMMENDED FOR DIRENV)
# ============================================================================

# Load secrets using op inject pattern (faster and more reliable)
# Usage: op_inject_envrc [template_file] [account_email]
# Default: looks for .env.1password in current directory, uses default account
op_inject_envrc() {
    local template_file="${1:-.env.1password}"
    local account_email="${2:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    if [[ ! -f "$template_file" ]]; then
        echo "Error: Template file '$template_file' not found" >&2
        echo "Create a template file with op:// references, e.g.:" >&2
        echo "  OPENAI_API_KEY=op://develop/apikeys/OPENAI_API_KEY" >&2
        return 1
    fi
    
    # Get account UUID (needed for --account flag)
    local account_uuid
    account_uuid=$(_op_get_account_uuid "$account_email")
    
    if [[ -z "$account_uuid" ]]; then
        echo "Error: Account '$account_email' not found" >&2
        echo ""
        echo "Available accounts:" >&2
        op account list >&2
        return 1
    fi
    
    # Check if we can access 1Password via desktop app integration
    # The desktop app uses macOS system keychain/Touch ID for automatic unlocking
    # When the desktop app is unlocked, the CLI can use that session without prompting
    # We check by trying a simple operation - if it works, desktop app is unlocked
    # IMPORTANT: Don't call op signin here - it will prompt even if desktop app is unlocked
    # Instead, just try the operation - if desktop app is unlocked, it works silently
    if ! op account list --account "$account_uuid" &> /dev/null; then
        # No session - check if desktop app is available and unlocked
        # Try a simple operation that won't prompt if desktop app is unlocked
        # If desktop app is locked, this will fail silently (no prompt)
        if ! op vault list --account "$account_uuid" &> /dev/null 2>&1; then
            # Desktop app not available or locked - fail silently (no prompt)
            # User should unlock 1Password app manually
            return 1
        fi
    fi
    
    # Use op inject to load secrets (with --account flag for reliability)
    # This is faster than op read and handles session automatically
    local temp_output
    local error_output
    temp_output=$(mktemp)
    error_output=$(mktemp)
    
    # Run op inject with --account flag (this is what works in the test script)
    if op inject -i "$template_file" --account "$account_uuid" > "$temp_output" 2> "$error_output"; then
        # Check if output is empty (might indicate an error)
        if [[ ! -s "$temp_output" ]]; then
            echo "Error: op inject returned empty output" >&2
            if [[ -s "$error_output" ]]; then
                echo "Error details:" >&2
                cat "$error_output" >&2
            fi
            rm -f "$temp_output" "$error_output"
            return 1
        fi
        
        # Source the output
        set -a
        source "$temp_output"
        set +a
        rm -f "$temp_output" "$error_output"
        return 0
    else
        echo "Error: Failed to inject secrets from '$template_file'" >&2
        if [[ -s "$error_output" ]]; then
            echo "Error details:" >&2
            cat "$error_output" >&2
        else
            echo "Troubleshooting:" >&2
            echo "1. Verify you're signed in: op account list" >&2
            echo "2. Check template file format (should use op:// references)" >&2
            echo "3. Verify vault/item/field names are correct" >&2
            echo "4. Try manually: op inject -i '$template_file' --account $account_uuid" >&2
        fi
        rm -f "$temp_output" "$error_output"
        return 1
    fi
}

# Inject all environment variables from a 1Password item into the current shell
# Usage: op_inject_all "vault_name" "item_name" [account_email]
# Example: op_inject_all "develop" "apikeys"
# This loads all fields from the item and exports them as environment variables
op_inject_all() {
    local vault="${1:?Vault name required}"
    local item="${2:?Item name required}"
    local account_email="${3:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Use existing op_load_item function which already handles all the complexity
    if op_load_item "$vault" "$item" "" "$account_email" "false"; then
        echo "✓ Injected all environment variables from 1Password item: $vault/$item" >&2
        return 0
    else
        echo "Error: Failed to inject environment variables from $vault/$item" >&2
        return 1
    fi
}

# Dump environment variables from a 1Password item to a .env file (with credentials)
# Usage: op_dump_env "vault_name" "item_name" [output_file] [account_email]
# Example: op_dump_env "develop" "apikeys" ".env"
# Example: op_dump_env "develop" "apikeys" ".env.local"
op_dump_env() {
    local vault="${1:?Vault name required}"
    local item="${2:?Item name required}"
    local output_file="${3:-.env}"
    local account_email="${4:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Get account UUID
    local account_uuid
    account_uuid=$(_op_get_account_uuid "$account_email")
    
    if [[ -z "$account_uuid" ]]; then
        echo "Error: Account '$account_email' not found" >&2
        echo ""
        echo "Available accounts:" >&2
        op account list >&2
        return 1
    fi
    
    # Check if we can access 1Password
    if ! op account list --account "$account_uuid" &> /dev/null; then
        if ! op vault list --account "$account_uuid" &> /dev/null 2>&1; then
            echo "Error: Could not access 1Password. Please unlock 1Password app first." >&2
            return 1
        fi
    fi
    
    # Get item JSON
    local item_json
    item_json=$(op item get "$item" --vault "$vault" --account "$account_uuid" --format json 2>/dev/null)
    
    if [[ -z "$item_json" ]]; then
        echo "Error: Could not retrieve item '${item}' from vault '${vault}'" >&2
        return 1
    fi
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required for this function. Install it with: brew install jq" >&2
        return 1
    fi
    
    # Extract fields and write to .env file
    # Match the pattern used in op_load_item but handle null labels
    # Use printf to avoid shell interpretation issues with special characters
    local fields
    local jq_stderr
    jq_stderr=$(mktemp)
    fields=$(printf '%s\n' "$item_json" | jq -r '.fields[]? | select(.id != "notesPlain") | select((.label // .id) != null and (.label // .id) != "") | "\(.label // .id)=\(.value // "")"' 2>"$jq_stderr")
    local jq_exit_code=$?
    
    # Check if jq command succeeded and produced output
    if [[ $jq_exit_code -ne 0 ]] || [[ -z "$fields" ]]; then
        echo "Warning: Item '${item}' has no fields to dump or jq parsing failed" >&2
        if [[ -s "$jq_stderr" ]]; then
            echo "jq error output:" >&2
            cat "$jq_stderr" >&2
        fi
        echo "Debug: Checking item structure..." >&2
        # Try a simpler jq query to see what we have
        printf '%s\n' "$item_json" | jq -r '.fields | length' 2>&1 | head -1
        printf '%s\n' "$item_json" | jq -r '.fields[]? | .id' 2>&1 | head -10
        rm -f "$jq_stderr"
        return 1
    fi
    rm -f "$jq_stderr"
    
    # Write to file
    # Disable xtrace/verbose mode to prevent variable assignments from being printed
    {
        set +x 2>/dev/null
        setopt +o xtrace 2>/dev/null
        
        echo "# Environment variables from 1Password: $vault/$item"
        echo "# Generated: $(date)"
        echo "# WARNING: This file contains sensitive credentials. Do not commit to version control!"
        echo ""
        
        local env_var
        while IFS='=' read -r label value; do
            # Skip empty lines
            [[ -z "$label" ]] && continue
            
            # Convert label to valid env var name (uppercase, replace spaces with underscores)
            env_var=$(echo "$label" | tr '[:lower:]' '[:upper:]' | tr ' ' '_' | tr -cd '[:alnum:]_')
            
            # Remove quotes from value if present
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            
            # Escape special characters in value for .env format
            # Escape backslashes, quotes, and newlines
            value=$(echo "$value" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')
            
            # Write VAR=value (quote if contains spaces or special chars)
            if [[ "$value" =~ [[:space:]] ]] || [[ "$value" =~ [\"\$\`] ]]; then
                echo "${env_var}=\"${value}\""
            else
                echo "${env_var}=${value}"
            fi
        done <<< "$fields"
    } > "$output_file"
    
    local field_count
    field_count=$(echo "$fields" | wc -l | tr -d ' ')
    
    echo "✓ Dumped $field_count environment variables to $output_file (with credentials)"
    echo "  WARNING: This file contains sensitive data. Do not commit to version control!"
    
    return 0
}

# Dump environment variable template from a 1Password item to a .env file (without credentials)
# Usage: op_dump_env_template "vault_name" "item_name" [output_file] [account_email]
# Example: op_dump_env_template "develop" "apikeys" ".env.template"
# Example: op_dump_env_template "develop" "apikeys" ".env.example"
op_dump_env_template() {
    local vault="${1:?Vault name required}"
    local item="${2:?Item name required}"
    local output_file="${3:-.env.template}"
    local account_email="${4:-${OP_ACCOUNT:-${OP_DEFAULT_ACCOUNT}}}"
    
    if ! command -v op &> /dev/null; then
        echo "Error: 1Password CLI (op) not found" >&2
        return 1
    fi
    
    # Get account UUID
    local account_uuid
    account_uuid=$(_op_get_account_uuid "$account_email")
    
    if [[ -z "$account_uuid" ]]; then
        echo "Error: Account '$account_email' not found" >&2
        echo ""
        echo "Available accounts:" >&2
        op account list >&2
        return 1
    fi
    
    # Check if we can access 1Password
    if ! op account list --account "$account_uuid" &> /dev/null; then
        if ! op vault list --account "$account_uuid" &> /dev/null 2>&1; then
            echo "Error: Could not access 1Password. Please unlock 1Password app first." >&2
            return 1
        fi
    fi
    
    # Get item JSON
    local item_json
    item_json=$(op item get "$item" --vault "$vault" --account "$account_uuid" --format json 2>/dev/null)
    
    if [[ -z "$item_json" ]]; then
        echo "Error: Could not retrieve item '${item}' from vault '${vault}'" >&2
        return 1
    fi
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required for this function. Install it with: brew install jq" >&2
        return 1
    fi
    
    # Extract fields and write template to .env file
    # Match the pattern used in op_load_item but extract only label/id
    # Use printf to avoid shell interpretation issues with special characters
    local fields
    local jq_stderr
    jq_stderr=$(mktemp)
    fields=$(printf '%s\n' "$item_json" | jq -r '.fields[]? | select(.id != "notesPlain") | select((.label // .id) != null and (.label // .id) != "") | (.label // .id)' 2>"$jq_stderr")
    local jq_exit_code=$?
    
    # Check if jq command succeeded and produced output
    if [[ $jq_exit_code -ne 0 ]] || [[ -z "$fields" ]]; then
        echo "Warning: Item '${item}' has no fields to dump or jq parsing failed" >&2
        if [[ -s "$jq_stderr" ]]; then
            echo "jq error output:" >&2
            cat "$jq_stderr" >&2
        fi
        echo "Debug: Checking item structure..." >&2
        # Try a simpler jq query to see what we have
        printf '%s\n' "$item_json" | jq -r '.fields | length' 2>&1 | head -1
        printf '%s\n' "$item_json" | jq -r '.fields[]? | .id' 2>&1 | head -10
        rm -f "$jq_stderr"
        return 1
    fi
    rm -f "$jq_stderr"
    
    # Write template to file
    # Disable xtrace/verbose mode to prevent variable assignments from being printed
    {
        set +x 2>/dev/null
        setopt +o xtrace 2>/dev/null
        
        echo "# Environment variable template from 1Password: $vault/$item"
        echo "# Generated: $(date)"
        echo "# This file contains variable names only (no credentials)"
        echo "# Fill in the values or use 1Password CLI to inject them"
        echo ""
        echo "# To load these variables from 1Password, use:"
        echo "#   op_inject_all \"$vault\" \"$item\""
        echo "# Or use op inject with a template file containing op:// references"
        echo ""
        
        local env_var
        while IFS= read -r label; do
            # Skip empty lines
            [[ -z "$label" ]] && continue
            
            # Convert label to valid env var name (uppercase, replace spaces with underscores)
            env_var=$(echo "$label" | tr '[:lower:]' '[:upper:]' | tr ' ' '_' | tr -cd '[:alnum:]_')
            
            # Write VAR= with placeholder
            echo "${env_var}="
        done <<< "$fields"
    } > "$output_file"
    
    local field_count
    field_count=$(echo "$fields" | wc -l | tr -d ' ')
    
    echo "✓ Dumped $field_count environment variable names to $output_file (template, no credentials)"
    echo "  This file is safe to commit to version control"
    
    return 0
}

# ============================================================================
# DIRENV + 1PASSWORD HELPERS
# ============================================================================

# Generate a .envrc template that uses 1Password
# Usage: op_direnv_template "vault_name" "item_name"
op_direnv_template() {
    local vault="${1:-develop}"
    local item="${2:-apikeys}"
    
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
