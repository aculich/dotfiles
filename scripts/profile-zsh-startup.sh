#!/usr/bin/env bash
# Profile zsh startup time
# This script helps identify what's slowing down zsh startup

set -euo pipefail

echo "=========================================="
echo "Zsh Startup Profiling"
echo "=========================================="
echo ""

# Method 1: Use zsh -x for verbose tracing
echo "Method 1: Verbose trace (zsh -x)"
echo "This will show every command executed during startup"
echo "Press Ctrl+C to stop after startup completes"
echo ""
read -p "Run verbose trace? [y/N]: " RUN_VERBOSE
if [[ "$RUN_VERBOSE" =~ ^[Yy]$ ]]; then
    zsh -x -i -c exit 2>&1 | tee /tmp/zsh-startup-trace.log | tail -50
    echo ""
    echo "Full trace saved to: /tmp/zsh-startup-trace.log"
    echo ""
fi

# Method 2: Use zprof module
echo "Method 2: zprof profiling"
echo "This will show timing for each function/file loaded"
echo ""
read -p "Run zprof? [y/N]: " RUN_ZPROF
if [[ "$RUN_ZPROF" =~ ^[Yy]$ ]]; then
    cat > /tmp/zsh-profile-test.zsh <<'EOF'
zmodload zsh/zprof
# Source your actual zshrc
source ~/.zshrc
zprof
EOF
    zsh /tmp/zsh-profile-test.zsh 2>&1 | tee /tmp/zsh-startup-profile.log
    echo ""
    echo "Profile saved to: /tmp/zsh-startup-profile.log"
    echo ""
fi

# Method 3: Simple timing
echo "Method 3: Simple startup timing"
echo "Measuring time to start a new zsh shell..."
echo ""

for i in {1..3}; do
    START=$(date +%s.%N)
    zsh -i -c exit
    END=$(date +%s.%N)
    ELAPSED=$(echo "$END - $START" | bc)
    echo "Run $i: ${ELAPSED}s"
done

echo ""
echo "=========================================="
echo "Common slow startup causes:"
echo "=========================================="
echo "1. Oh My Zsh plugins (especially git, autosuggestions)"
echo "2. NVM initialization (slow on first load)"
echo "3. Conda initialization"
echo "4. Direnv hook (if checking many directories)"
echo "5. Large history file"
echo "6. Network calls (1Password, cloud sync, etc.)"
echo "7. Completion system (compinit)"
echo ""
echo "Check the logs above to identify bottlenecks!"

