#!/usr/bin/env zsh
# Zsh Startup Profiling
# Add this to the top of your .zshrc to profile startup time
# Usage: Add `zmodload zsh/zprof` at the very top, and `zprof` at the very end

# Enable profiling module
zmodload zsh/zprof

# Track startup time
typeset -F SECONDS
START_TIME=$SECONDS

# Function to log timing
log_time() {
    local label="$1"
    local elapsed=$(($SECONDS - $START_TIME))
    echo "[PROFILE] ${elapsed}s - $label" >&2
}

# Override source to track file loading
_original_source=$(which source)
source() {
    local file="$1"
    local start=$SECONDS
    log_time "Loading: $file"
    $_original_source "$@"
    local elapsed=$(($SECONDS - $start))
    if (( elapsed > 0.1 )); then
        echo "[PROFILE]   └─ ${elapsed}s to load $file" >&2
    fi
}

# Track command execution time
preexec() {
    _cmd_start_time=$SECONDS
}

precmd() {
    if [[ -n "$_cmd_start_time" ]]; then
        local elapsed=$(($SECONDS - _cmd_start_time))
        if (( elapsed > 0.5 )); then
            echo "[PROFILE] Command took ${elapsed}s" >&2
        fi
    fi
}

log_time "Zsh startup profiling enabled"

