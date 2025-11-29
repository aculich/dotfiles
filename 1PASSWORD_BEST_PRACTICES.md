# 1Password Integration Best Practices

Based on research and current best practices (November 2025), here's a comprehensive guide for integrating 1Password CLI with your development environment.

## Current Architecture Analysis

### What We Have
- ✅ 1Password CLI integration with session token caching
- ✅ Direnv integration for project-specific environment variables
- ✅ Global `.envrc` for home directory secrets
- ✅ Helper functions for loading secrets

### Current Issues
- ⚠️ Token extraction from environment variables not working reliably
- ⚠️ Direnv can be slow (checks directories on every prompt)
- ⚠️ No project-specific `.envrc` templates
- ⚠️ No clear separation between interactive shell vs. project environments

## Best Practices Research Summary

### 1. 1Password CLI Patterns

#### Pattern A: `op inject` (Recommended for Projects)
1Password CLI provides `op inject` which is faster than loading individual secrets:

```bash
# In project .envrc
export $(op inject -i .env.1password | xargs)
```

**Advantages:**
- Faster than loading secrets one-by-one
- Works with `.env.1password` template files
- Better for CI/CD and production
- No need for custom functions

**Disadvantages:**
- Requires creating `.env.1password` template files
- Less flexible than custom functions

#### Pattern B: `op read` with Shell Functions (Current Approach)
```bash
# Load individual secrets
op read "op://vault/item/field"
```

**Advantages:**
- More flexible
- Can load entire items
- Works with custom functions

**Disadvantages:**
- Slower (multiple API calls)
- More complex error handling

#### Pattern C: Session Token Caching (What We're Doing)
```bash
# Cache session token for 30 minutes
~/.op_session
```

**Advantages:**
- Reduces unlock prompts
- Faster subsequent loads

**Disadvantages:**
- Token extraction issues
- Need to handle expiration

### 2. Alternatives to Direnv

#### Option 1: Keep Direnv (Recommended for Development)
**Pros:**
- Automatic environment loading per directory
- Widely used and well-documented
- Good for project-specific configs

**Cons:**
- Can be slow (checks directories on prompt)
- Requires `.envrc` files in each project

**Optimization:**
- Use `DIRENV_LOG_FORMAT=""` to reduce output
- Limit direnv to specific directories
- Use `direnv allow` only where needed

#### Option 2: `op inject` with Shell Scripts
**Pros:**
- Faster than direnv
- Better for production/CI
- No directory checking overhead

**Cons:**
- Manual execution required
- Less automatic than direnv

**Use Case:**
- Production deployments
- CI/CD pipelines
- One-off script execution

#### Option 3: Zsh Hooks (For Interactive Shell)
**Pros:**
- Fast (runs in current shell)
- No external tool needed
- Can be project-aware

**Cons:**
- More complex to implement
- Shell-specific (zsh only)

**Implementation:**
```zsh
# In .zshrc
autoload -Uz add-zsh-hook

load_project_secrets() {
    if [[ -f .envrc ]] && [[ -f .envrc.1password ]]; then
        eval "$(op inject -i .envrc.1password)"
    fi
}

add-zsh-hook chpwd load_project_secrets
```

### 3. Context-Specific Strategies

#### Interactive Shell (Global Secrets)
**Current:** `~/.envrc` with direnv
**Better:** Load in `.zshrc` or `.zshenv` with lazy loading

```zsh
# In .zshrc - Load global secrets lazily
load_global_secrets() {
    if [[ -f ~/.op_session ]] && [[ -s ~/.op_session ]]; then
        source ~/dotfiles/zsh/functions.zsh
        op_load_item "Development" "Development API Keys" "y5l42cppvgu22o2obesu4ctla4"
    fi
}

# Only load if not in a project directory
if [[ ! -f .envrc ]]; then
    load_global_secrets
fi
```

#### Project Development (Project-Specific Secrets)
**Current:** `.envrc` in each project
**Better:** Use `op inject` with `.env.1password` templates

**Project Structure:**
```
my-project/
  .env.1password          # Template with op:// references
  .envrc                  # Uses op inject
  .gitignore              # Excludes .env (generated)
```

**.env.1password template:**
```bash
# .env.1password - Template file (commit to git)
# Use op inject to generate .env from this
OPENAI_API_KEY=op://Development/Project API Keys/OPENAI_API_KEY
DATABASE_URL=op://Development/Project API Keys/DATABASE_URL
```

**.envrc:**
```bash
# .envrc - Load secrets using op inject
if command -v op &> /dev/null; then
    # Check if .env.1password exists
    if [[ -f .env.1password ]]; then
        # Generate .env from template
        op inject -i .env.1password > .env
        
        # Load .env
        set -a
        source .env
        set +a
    fi
fi
```

#### Production/CI/CD
**Best Practice:** Use `op inject` directly

```bash
# In deployment script
op inject -i .env.1password > .env
# Or inject directly into process
op inject -i .env.1password | xargs -0 env
```

### 4. Oh-My-Zsh Integration

#### Option 1: Custom Plugin (Recommended)
Create `~/.oh-my-zsh/custom/plugins/1password/1password.plugin.zsh`:

```zsh
# 1Password CLI integration for Oh My Zsh
# Provides helper functions and lazy loading

# Lazy load 1Password functions
1password() {
    unfunction 1password
    source ~/dotfiles/zsh/functions.zsh
    1password "$@"
}

# Auto-load session if available
if [[ -f ~/.op_session ]] && [[ -s ~/.op_session ]]; then
    # Session exists, but don't load secrets automatically
    # Let user or direnv handle it
    :
fi
```

#### Option 2: Source Functions in .zshrc
**Current approach** - works but loads on every shell startup.

**Better:** Lazy load only when needed:
```zsh
# Lazy load 1Password functions
op_load_item() {
    unfunction op_load_item
    source ~/dotfiles/zsh/functions.zsh
    op_load_item "$@"
}
```

### 5. Shell Integration (Cursor, VSCode, Antigravity)

#### Cursor/VSCode Integration
**Current:** Shell integration works, but slow startup affects IDE terminals.

**Optimization:**
1. **Lazy load everything** - Don't load secrets in IDE terminals automatically
2. **Use IDE-specific detection:**
   ```zsh
   if [[ "$TERM_PROGRAM" == "cursor" ]] || [[ "$TERM_PROGRAM" == "vscode" ]]; then
       # Minimal config for IDE terminals
       export GIT_PAGER='cat'
       # Don't load heavy plugins
   fi
   ```

3. **Separate config for IDE:**
   - Create `.zshrc.ide` with minimal config
   - Source it when `$TERM_PROGRAM` is cursor/vscode

#### Antigravity Integration
Similar to Cursor/VSCode - detect and use minimal config.

### 6. Recommended Architecture

#### Global Shell (Interactive)
```
~/.zshenv          # Minimal PATH setup
~/.zshrc           # Interactive config (lazy load everything)
~/.envrc           # Global secrets (loaded by direnv, but lazy)
```

#### Project Development
```
project/
  .env.1password   # Template (committed)
  .envrc           # Uses op inject (committed)
  .env             # Generated (gitignored)
```

#### Production/CI
```bash
# Use op inject directly
op inject -i .env.1password | xargs -0 env node app.js
```

## Implementation Recommendations

### Phase 1: Fix Current Issues
1. ✅ Fix token extraction (in progress)
2. ⏳ Implement lazy loading for 1Password functions
3. ⏳ Optimize direnv usage

### Phase 2: Adopt `op inject` Pattern
1. Create `.env.1password` templates for projects
2. Update `.envrc` files to use `op inject`
3. Keep custom functions for interactive use

### Phase 3: Optimize Shell Startup
1. Lazy load NVM (saves ~2s)
2. Lazy load Conda (saves ~0.3s)
3. Lazy load 1Password functions
4. Optimize completion system

### Phase 4: IDE-Specific Optimizations
1. Create minimal `.zshrc.ide` config
2. Detect IDE terminals and use minimal config
3. Load secrets only when explicitly needed

## Fastest Approach Summary

**For Interactive Shell:**
- Lazy load everything (NVM, Conda, 1Password)
- Use session token caching
- Load global secrets only when needed

**For Projects:**
- Use `op inject` with `.env.1password` templates
- Keep `.envrc` simple (just calls `op inject`)
- Commit templates, ignore generated `.env`

**For Production:**
- Use `op inject` directly in deployment scripts
- No shell integration needed
- Fast and secure

## References

- [1Password CLI Documentation](https://developer.1password.com/docs/cli)
- [Direnv Documentation](https://direnv.net/)
- [Oh My Zsh Performance](https://github.com/ohmyzsh/ohmyzsh/wiki/Performance)

