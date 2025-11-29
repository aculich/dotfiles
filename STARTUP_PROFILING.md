# Zsh Startup Profiling Guide

## Problem
Zsh startup is slow, making new shells take too long to become usable.

## Solution
We've added profiling tools to identify bottlenecks.

## Quick Start

### Method 1: Use the Timed Version (Easiest)

```bash
# Backup your current .zshrc
cp ~/.zshrc ~/.zshrc.backup

# Use the timed version
ln -sf ~/dotfiles/zsh/.zshrc.professional.timed ~/.zshrc

# Start a new shell - you'll see timing output like:
# [PROFILE]  0.023s - === Zsh startup begins ===
# [PROFILE]  0.045s - Loading Oh My Zsh...
# [PROFILE]  1.234s - Oh My Zsh loaded
# ...

# For detailed function-level profiling:
ZPROF=1 zsh

# Restore original when done:
ln -sf ~/dotfiles/zsh/.zshrc.professional ~/.zshrc
```

### Method 2: Use the Profiling Script

```bash
~/dotfiles/scripts/profile-zsh-startup.sh
```

This script offers three profiling methods:
1. **Verbose trace** (`zsh -x`) - Shows every command
2. **zprof profiling** - Shows function-level timing
3. **Simple timing** - Just measures total startup time

### Method 3: Manual zprof

Add to the **very top** of your `.zshrc`:
```zsh
zmodload zsh/zprof
```

Add to the **very end** of your `.zshrc`:
```zsh
zprof
```

Then start a new shell to see the profile.

## Common Slow Components

Based on typical zsh setups, these are often the culprits:

1. **Oh My Zsh plugins** (especially `git`, `autosuggestions`)
   - Solution: Remove unused plugins, use lighter alternatives

2. **NVM initialization** (can take 1-2 seconds)
   - Solution: Use `nvm` lazy loading or switch to `fnm`

3. **Conda initialization** (very slow)
   - Solution: Only load when needed, use `conda activate` manually

4. **Completion system** (`compinit`)
   - Solution: Already optimized (only regenerates if >24h old)

5. **Direnv hook** (if checking many directories)
   - Solution: Limit direnv to specific directories

6. **Large history file**
   - Solution: Reduce `HISTSIZE` and `SAVEHIST`

7. **Network calls** (1Password, cloud sync)
   - Solution: Use session caching (already implemented)

## Interpreting Results

- **< 0.5s**: Excellent
- **0.5-1.0s**: Good
- **1.0-2.0s**: Acceptable
- **> 2.0s**: Needs optimization

Look for components taking > 0.2s and consider optimizing or removing them.

## Next Steps

1. Run profiling to identify slow components
2. Remove or optimize slow components
3. Re-test startup time
4. Remove profiling code when done

