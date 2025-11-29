# Quick Start: Profile Your Zsh Startup

## Problem
Zsh startup is slow. We need to identify what's taking so long.

## Solution: Use the Timed Version

### Step 1: Backup Current Config
```bash
cp ~/.zshrc ~/.zshrc.backup
```

### Step 2: Use Timed Version
```bash
ln -sf ~/dotfiles/zsh/.zshrc.professional.timed ~/.zshrc
```

### Step 3: Start a New Shell
Open a new terminal window. You'll see timing output like:
```
[PROFILE]  0.023s - === Zsh startup begins ===
[PROFILE]  0.045s - Loading Oh My Zsh...
[PROFILE]  1.234s - Oh My Zsh loaded
[PROFILE]  1.256s - Setting up direnv...
[PROFILE]  1.267s - Direnv hook installed
...
[PROFILE]  2.145s - === Zsh startup complete ===
```

### Step 4: Identify Slow Components
Look for lines with high times (> 0.2s). These are your bottlenecks.

### Step 5: For Detailed Profiling
```bash
ZPROF=1 zsh
```
This will show function-level timing at the end.

### Step 6: Restore Original
```bash
ln -sf ~/dotfiles/zsh/.zshrc.professional ~/.zshrc
```

## Alternative: Use Profiling Script

```bash
~/dotfiles/scripts/profile-zsh-startup.sh
```

This script offers three methods:
1. Verbose trace (shows every command)
2. zprof profiling (function-level timing)
3. Simple timing (just total time)

## Common Slow Components

Based on typical setups, these are often slow:

1. **Oh My Zsh plugins** (especially `git`, `autosuggestions`)
   - Solution: Remove unused plugins

2. **NVM initialization** (can take 1-2 seconds)
   - Solution: Use lazy loading or switch to `fnm`

3. **Conda initialization** (very slow)
   - Solution: Only load when needed

4. **Completion system** (`compinit`)
   - Already optimized (only regenerates if >24h old)

5. **Direnv hook** (if checking many directories)
   - Solution: Limit direnv to specific directories

6. **Large history file**
   - Solution: Reduce `HISTSIZE` and `SAVEHIST`

## Interpreting Results

- **< 0.5s**: Excellent
- **0.5-1.0s**: Good  
- **1.0-2.0s**: Acceptable
- **> 2.0s**: Needs optimization

Look for components taking > 0.2s and consider optimizing or removing them.

