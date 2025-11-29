#!/usr/bin/env bash
# Add zsh profiling to .zshrc to identify slow startup
# This temporarily adds timing information to help debug startup performance

set -euo pipefail

ZSH_PROFESSIONAL="$HOME/dotfiles/zsh/.zshrc.professional"
ZSH_PROFILE_TEMP="/tmp/.zshrc.professional.profile"

if [[ ! -f "$ZSH_PROFESSIONAL" ]]; then
    echo "Error: $ZSH_PROFESSIONAL not found"
    exit 1
fi

echo "Adding profiling to zsh startup..."
echo ""

# Create profiled version
cat > "$ZSH_PROFILE_TEMP" <<'PROFILE_HEADER'
#!/usr/bin/env zsh
# PROFILED VERSION - Timing information added
# Remove this file and restore original when done profiling

# Enable profiling
zmodload zsh/zprof

# Track startup time
typeset -F SECONDS
typeset -g _zsh_start_time=$SECONDS

# Function to log timing
_zsh_log_time() {
    local label="$1"
    local elapsed=$(($SECONDS - $_zsh_start_time))
    printf "[PROFILE] %6.3fs - %s\n" "$elapsed" "$label" >&2
}

_zsh_log_time "=== Zsh startup begins ==="

PROFILE_HEADER

# Add timing before each major section
sed -E '
    /^# =+.*SETUP/,/^# =+.*SETUP/ {
        s/^(# =+.*SETUP.*)/_zsh_log_time "\1"\
\1/
    }
    /^# OH-MY-ZSH SETUP/ {
        i\
_zsh_log_time "Loading Oh My Zsh..."
    }
    /^source.*oh-my-zsh\.sh/ {
        a\
_zsh_log_time "Oh My Zsh loaded"
    }
    /^eval.*direnv hook/ {
        i\
_zsh_log_time "Setting up direnv..."
        a\
_zsh_log_time "Direnv hook installed"
    }
    /^# CUSTOM CONFIGURATION MODULES/ {
        i\
_zsh_log_time "Loading custom modules..."
    }
    /^\[\[ -f.*functions\.zsh/ {
        a\
_zsh_log_time "Functions loaded"
    }
    /^\[\[ -f.*aliases\.zsh/ {
        a\
_zsh_log_time "Aliases loaded"
    }
    /^# NODE VERSION MANAGER/ {
        i\
_zsh_log_time "Loading development tools..."
    }
    /^autoload -Uz compinit/ {
        i\
_zsh_log_time "Initializing completion system..."
        a\
_zsh_log_time "Completion system initialized"
    }
' "$ZSH_PROFESSIONAL" >> "$ZSH_PROFILE_TEMP"

# Add footer with zprof
cat >> "$ZSH_PROFILE_TEMP" <<'PROFILE_FOOTER'

_zsh_log_time "=== Zsh startup complete ==="
_zsh_log_time "Total startup time"

# Show profile if ZPROF is set
if [[ -n "$ZPROF" ]]; then
    echo ""
    echo "=== Detailed Profile (zprof) ===" >&2
    zprof >&2
fi
PROFILE_FOOTER

echo "Profiled version created at: $ZSH_PROFILE_TEMP"
echo ""
echo "To use profiling:"
echo "  1. Backup your current .zshrc: cp ~/.zshrc ~/.zshrc.backup"
echo "  2. Use the profiled version: cp $ZSH_PROFILE_TEMP ~/.zshrc"
echo "  3. Start a new shell and check the timing output"
echo "  4. For detailed profiling, set ZPROF=1 before starting shell"
echo ""
echo "To restore:"
echo "  cp ~/.zshrc.backup ~/.zshrc"
echo ""
echo "Or use the original:"
echo "  ln -sf $ZSH_PROFESSIONAL ~/.zshrc"

