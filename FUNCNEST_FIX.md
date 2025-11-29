# FUNCNEST Fix for NVM Errors

## The Problem

You were getting these errors:
```
nvm:6: maximum nested function level reached; increase FUNCNEST?
```

## Why This Happens

**NVM uses deeply nested function calls** internally. When zsh evaluates these nested functions, it can exceed the default nesting limit (usually 50).

**Common causes:**
1. NVM's internal functions call other functions recursively
2. The `nvm()` function itself wraps commands that call other functions
3. When NVM loads, it sets up completion functions that nest deeply
4. The `load-nvmrc` hook can trigger nested calls during directory changes

## The Solution

Set `FUNCNEST` to a higher value **BEFORE** NVM loads.

### What We Did

1. **Added to `.zshenv.professional`** (loads first, for all shells):
   ```zsh
   export FUNCNEST=100
   ```

2. **Added to `.zshrc.professional`** (early, as a safety check):
   ```zsh
   export FUNCNEST="${FUNCNEST:-100}"
   ```

### Why 100?

- **Default**: Usually 50 (too low for nvm)
- **Recommended**: 100 (safe for most use cases)
- **Higher values**: 200-700 work but may indicate other issues
- **Our choice**: 100 is a good balance - high enough for nvm, not so high as to hide real problems

### Why Set It Early?

FUNCNEST must be set **before** NVM loads because:
- NVM's initialization creates nested functions immediately
- If FUNCNEST isn't set, zsh uses the default (50)
- Once NVM hits the limit, it's too late to increase it

## Testing

After restarting your shell, verify:
```bash
echo $FUNCNEST  # Should output: 100
nvm --version   # Should work without errors
```

## If You Still See Errors

If you still get FUNCNEST errors after this fix:

1. **Check if FUNCNEST is actually set:**
   ```bash
   echo $FUNCNEST
   ```

2. **Check when it's being set:**
   ```bash
   zsh -x -c 'source ~/.zshenv; source ~/.zshrc' 2>&1 | grep FUNCNEST
   ```

3. **Increase the limit** (if needed):
   ```zsh
   export FUNCNEST=200  # In .zshenv
   ```

4. **Check for other sources** that might reset it:
   ```bash
   grep -r FUNCNEST ~/.z* ~/.oh-my-zsh 2>/dev/null
   ```

## Related Issues

- **NVM wrapper recursion**: Our wrapper functions are safe (they check before calling)
- **Site-specific configs**: The `load-nvmrc` function is now safe (checks if nvm is available)
- **IDE terminals**: Lazy loading still works, FUNCNEST applies to all shells

## References

- [Zsh FUNCNEST documentation](https://zsh.sourceforge.io/Doc/Release/Parameters.html#index-FUNCNEST)
- [NVM GitHub issues about FUNCNEST](https://github.com/nvm-sh/nvm/issues?q=funcnest)

