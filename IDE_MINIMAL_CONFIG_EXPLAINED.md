# Minimal IDE Terminal Configuration - Explained

## What is "Minimal Config" and Why?

### The Problem

When you open a terminal in Cursor, VSCode, or Antigravity, the IDE creates a new shell instance. If your `.zshrc` loads everything (NVM, Conda, Oh My Zsh plugins, 1Password secrets, etc.), **every single terminal tab** takes 5+ seconds to start up.

**This is especially painful because:**
- IDEs often open multiple terminals automatically
- Each terminal tab is a new shell instance
- You might open 5-10 terminals in a coding session
- That's 25-50 seconds of waiting just for shells to start!

### What "Minimal" Means

**Minimal config** = Only load what's absolutely necessary for IDE terminals to function:

✅ **Keep:**
- Basic PATH setup (Homebrew, local bin)
- Essential environment variables (EDITOR, LANG)
- Git pager optimization (already done)
- Basic shell functionality

❌ **Skip in IDE terminals:**
- NVM (lazy load - only when you run `node`/`npm`)
- Conda (lazy load - only when you run `conda`)
- Heavy Oh My Zsh plugins (git status checks, etc.)
- 1Password secret loading (load manually when needed)
- Complex prompt themes (use simple prompt)
- Completion system (can be slow)

### The Benefits

**Before (Full Config):**
- Terminal startup: ~5.3 seconds
- 10 terminals opened = 53 seconds of waiting
- Every terminal is slow

**After (Minimal Config):**
- Terminal startup: ~0.5-1.0 seconds
- 10 terminals opened = 5-10 seconds total
- Terminals are instant!

**Plus:**
- Tools still work - they just load on-demand
- When you run `node`, NVM loads automatically
- When you run `conda`, Conda loads automatically
- You can still load secrets manually if needed

### How It Works

1. **Detect IDE Terminal:**
   ```zsh
   if [[ "$TERM_PROGRAM" == "cursor" ]] || [[ "$TERM_PROGRAM" == "vscode" ]]; then
       # We're in an IDE terminal - use minimal config
   fi
   ```

2. **Skip Heavy Loads:**
   - Don't source NVM immediately
   - Don't source Conda immediately
   - Don't load all Oh My Zsh plugins
   - Don't load 1Password secrets

3. **Lazy Load Functions:**
   - Create wrapper functions that load the tool on first use
   - Example: `node()` function that loads NVM, then runs `node`

### Real-World Example

**Scenario:** You're working in Cursor and need to run `npm install`

**With Full Config:**
1. Open terminal → Wait 5.3 seconds
2. Run `npm install` → Works immediately

**With Minimal Config:**
1. Open terminal → Wait 0.5 seconds ⚡
2. Run `npm install` → NVM loads automatically (1-2 seconds, but only once)
3. `npm install` runs → Works perfectly

**Result:** You saved 4.8 seconds on terminal startup, and NVM only loads when you actually need it!

### What Gets Loaded When

| Tool | Full Config | Minimal Config |
|------|-------------|----------------|
| Terminal opens | Everything (5.3s) | Basics only (0.5s) |
| Run `node` | Already loaded | Loads NVM (~1s), then runs |
| Run `conda` | Already loaded | Loads Conda (~0.3s), then runs |
| Run `op_load_item` | Already loaded | Loads 1Password functions (~0.1s), then runs |

### The Trade-off

**Trade-off:** First use of a tool is slightly slower (because it loads on-demand)

**Benefit:** Every terminal opens instantly, and you only pay the cost when you actually use the tool.

**Net win:** For most developers, you open many more terminals than you use Node/Conda, so you save time overall.

