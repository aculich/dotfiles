#!/usr/bin/env bash
# Helper script to sign in to 1Password and cache the session token
# Run this once to unlock 1Password, then the token will be cached for 30 minutes

set -euo pipefail

ACCOUNT_EMAIL="${1:-aculich@gmail.com}"
SESSION_FILE="$HOME/.op_session"

echo "Signing in to 1Password..."
echo "Account: $ACCOUNT_EMAIL"
echo ""

# Sign in and get raw token
SESSION_TOKEN=$(op signin --raw 2>&1)

# Check if we got a valid token
if [[ -n "$SESSION_TOKEN" ]] && \
   [[ ${#SESSION_TOKEN} -gt 30 ]] && \
   [[ ! "$SESSION_TOKEN" =~ "[Ee][Rr][Rr][Oo][Rr]" ]] && \
   [[ ! "$SESSION_TOKEN" =~ "found no accounts" ]] && \
   [[ ! "$SESSION_TOKEN" =~ "not authenticated" ]] && \
   [[ ! "$SESSION_TOKEN" =~ "Usage:" ]]; then
    # Cache the token
    echo "$SESSION_TOKEN" > "$SESSION_FILE"
    chmod 600 "$SESSION_FILE"
    echo "✓ Session token cached for 30 minutes"
    echo "Token saved to: $SESSION_FILE"
    return 0
else
    echo "✗ Failed to get session token"
    echo "Output: $SESSION_TOKEN"
    return 1
fi

