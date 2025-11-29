# Troubleshooting Guide

## NVM Issues in IDE Terminals

### Problem: "command not found: nvm version"

**Solution:** This is fixed! The `nvm` function now properly loads NVM on first use.

**How it works:**
- In IDE terminals, `nvm` is a wrapper function
- First time you run `nvm`, it loads NVM, then calls the real `nvm`
- Subsequent calls work normally

**Test:**
```bash
# In Cursor/VSCode terminal
nvm --version  # Should work now
node --version # Will load NVM automatically
```

## 1Password Sign-In Issues

### Problem: "Sign-in succeeded but could not extract session token from environment"

**Solution:** Improved token extraction with multiple fallback methods.

**Manual Fix:**
1. Run `op_signin_cached` in your shell
2. Complete biometric authentication
3. Run `direnv allow` to reload environment

**If that doesn't work:**
```bash
# Manual sign-in
op signin --account aculich@gmail.com

# Check if token was set
env | grep OP_SESSION_

# If you see OP_SESSION_*, the token is set
# Then run:
direnv allow
```

### Problem: Repeated sign-in prompts in new shells

**Solution:** The `.envrc` no longer tries to auto-signin. It will:
- Check for cached session token
- If found, load secrets automatically
- If not found, show helpful instructions (no blocking)

**To load secrets manually:**
```bash
# Option 1: Sign in and cache token
op_signin_cached

# Option 2: Load secrets directly (if already signed in)
op_load_item "Development" "Development API Keys"

# Option 3: Use direnv (after signing in)
direnv allow
```

## IDE Terminal Performance

### Problem: Terminals still slow in Cursor/VSCode

**Check if minimal config is active:**
```bash
echo $IS_IDE_TERMINAL
# Should output: true (in IDE) or false (in regular terminal)
```

**If it says `false` in Cursor:**
- Check `$TERM_PROGRAM` variable: `echo $TERM_PROGRAM`
- Should be `cursor` or `vscode`
- If not, the detection might need adjustment

## General Issues

### Problem: Functions not found

**Reload zsh config:**
```bash
source ~/.zshrc
# Or
exec zsh
```

### Problem: Changes not taking effect

**Make sure you're using the professional config:**
```bash
# Check which .zshrc is being used
echo $HOME/.zshrc
ls -la ~/.zshrc

# Should point to: ~/dotfiles/zsh/.zshrc.professional
```

