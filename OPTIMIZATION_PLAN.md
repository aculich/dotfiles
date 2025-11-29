# Zsh Startup Optimization Plan

## Current Performance
**Total startup time: ~5.3-5.4 seconds** ⚠️ (Very slow!)

## Top Bottlenecks (from zprof profiling)

### 1. NVM (Node Version Manager) - **1,244ms (45%)** 🔴 CRITICAL
- **8 calls** taking 1,243.57ms total
- **Self time**: 961.08ms (34.76%)
- **Related functions**:
  - `nvm_auto`: 655.80ms (23.72%) - 2 calls
  - `load-nvmrc`: 234.55ms (8.48%) - 1 call
  - `nvm_ensure_version_installed`: 248.45ms (8.98%) - 4 calls

**Total NVM overhead: ~2.1 seconds!**

### 2. Completion System - **849ms (31%)** 🟡 HIGH
- **compinit**: 591.70ms (21.40%) - 4 calls
- **compdump**: 257.39ms (9.31%) - 2 calls
- **compdef**: 122.27ms (4.42%) - 1,711 calls (but only 0.07ms each)

**Total completion overhead: ~850ms**

### 3. Conda - **279ms (10%)** 🟡 HIGH
- **__conda_exe**: 279.14ms (10.09%) - 1 call

### 4. Other Components
- **fzf_setup_using_fzf**: 21.72ms (0.79%)
- **Oh My Zsh plugins**: ~115ms total

## Optimization Recommendations

### Priority 1: Fix NVM (Saves ~2 seconds)

**Option A: Lazy Load NVM** (Recommended)
```zsh
# Instead of loading nvm immediately, load it only when needed
export NVM_DIR="$HOME/.nvm"
nvm() {
    unfunction nvm
    [[ -s "$(brew --prefix nvm)/nvm.sh" ]] && source "$(brew --prefix nvm)/nvm.sh"
    nvm "$@"
}
```

**Option B: Switch to fnm (Faster NVM alternative)**
```bash
brew install fnm
# fnm is much faster than nvm
```

**Option C: Disable nvm_auto**
```zsh
# In .zshrc, comment out or remove:
# [[ -s "$(brew --prefix nvm)/nvm.sh" ]] && source "$(brew --prefix nvm)/nvm.sh"
# Only load when you actually need it
```

### Priority 2: Optimize Completion System (Saves ~400ms)

**Already optimized**: Completion dump only regenerates if >24h old
- But we can further optimize by:
  - Reducing number of completion functions loaded
  - Using `compinit -C` more aggressively (skip security checks)

### Priority 3: Lazy Load Conda (Saves ~280ms)

```zsh
# Only load conda when actually needed
conda() {
    unfunction conda
    eval "$(conda shell.zsh hook 2>/dev/null)"
    conda "$@"
}
```

### Priority 4: Optimize Oh My Zsh

- Remove unused plugins
- Consider lighter alternatives:
  - `zsh-autosuggestions` → can be slow
  - `git` plugin → can be slow if repo is large

## Expected Results

After optimizations:
- **NVM lazy loading**: -2.0s
- **Conda lazy loading**: -0.3s
- **Completion optimization**: -0.2s
- **Total improvement**: **~2.5 seconds faster**
- **New startup time**: **~2.8-3.0 seconds** (much better!)

## Implementation Steps

1. ✅ Profile startup (DONE)
2. ⏳ Implement NVM lazy loading
3. ⏳ Implement Conda lazy loading
4. ⏳ Optimize completion system
5. ⏳ Test and measure improvements
6. ⏳ Fine-tune based on results

