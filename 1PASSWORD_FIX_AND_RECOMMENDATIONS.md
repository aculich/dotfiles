# 1Password Integration Fix & Recommendations

## Current Issue Fixed

### Problem
The `op_signin_cached` function was failing during shell startup with direnv:
```
Error: Failed to sign in to 1Password
Details: Sign-in succeeded but could not extract session token from environment
```

### Root Cause
The function tried to manually extract the session token from environment variables after sign-in, but this doesn't work reliably with biometric authentication in direnv context.

### Solution
**New simplified function: `op_signin_simple`**
- Relies on 1Password's built-in session management
- No manual token extraction
- Works reliably with biometric authentication
- Simpler and more maintainable

**Usage:**
```bash
op_signin_simple
# or
op_signin_simple "aculich@gmail.com"
```

---

## Recommended Approach: Use `op inject` Pattern

### Why `op inject` is Better

1. **Faster**: Single command instead of multiple `op read` calls
2. **More Reliable**: Handles session management automatically
3. **Better for direnv**: Works seamlessly in non-interactive contexts
4. **Template-based**: Use `.env.1password` template files (can commit to git)

### New Function: `op_inject_envrc`

**Usage:**
```bash
# In your .envrc file
if command -v op_inject_envrc &> /dev/null; then
    op_inject_envrc .env.1password
fi
```

**Create `.env.1password` template:**
```bash
# .env.1password - Template file (safe to commit to git)
OPENAI_API_KEY=op://develop/apikeys/OPENAI_API_KEY
DATABASE_URL=op://develop/apikeys/DATABASE_URL
GITHUB_TOKEN=op://develop/apikeys/GITHUB_TOKEN
```

---

## Migration Guide

### Step 1: Update Your `.envrc` Files

**Old approach (using `op_load_item`):**
```bash
# Old .envrc
if command -v op_load_item &> /dev/null; then
    op_load_item "develop" "apikeys"
fi
```

**New approach (using `op inject`):**
```bash
# New .envrc
if command -v op_inject_envrc &> /dev/null; then
    op_inject_envrc .env.1password
fi
```

### Step 2: Create `.env.1password` Template Files

For each project, create a `.env.1password` file:

```bash
# In your project directory
cat > .env.1password <<EOF
# Project secrets - safe to commit to git
# Use op inject to load these
OPENAI_API_KEY=op://develop/apikeys/OPENAI_API_KEY
DATABASE_URL=op://develop/apikes/DATABASE_URL
EOF
```

### Step 3: Update Global `.envrc` (if you have one)

```bash
# ~/.envrc
if command -v op_inject_envrc &> /dev/null; then
    op_inject_envrc ~/.env.1password
fi
```

---

## Alternative: Open-Source Secret Management Tools

See [SECRET_MANAGEMENT_TOOLS_RESEARCH.md](./SECRET_MANAGEMENT_TOOLS_RESEARCH.md) for comprehensive comparison.

### Quick Recommendations

**For Local-First + Cloud Sync:**
- **gopass** ⭐ - Best balance of local-first and Git-based sync
- Works great with direnv
- GCP/AWS/Azure plugins available
- Can import from 1Password

**For GitOps/Infrastructure:**
- **SOPS** - Encrypts files that can be committed to Git
- Can use 1Password as backend
- Great for Kubernetes, Terraform

**For Cloud-First:**
- **Doppler** - Easy setup, good free tier
- Built-in GCP/AWS/Azure integration

---

## Immediate Action Items

1. **Fix current issue**: Use `op_signin_simple` instead of `op_signin_cached`
2. **Migrate to `op inject`**: Update `.envrc` files to use `op_inject_envrc`
3. **Create templates**: Create `.env.1password` files for each project
4. **Evaluate alternatives**: Consider gopass for local-first secret management

---

## Testing

### Test the Fix

```bash
# Test simplified signin
op_signin_simple

# Test op inject
op_inject_envrc .env.1password

# Verify secrets loaded
echo $OPENAI_API_KEY
```

### Test with direnv

```bash
# In a project directory with .envrc
direnv allow
direnv status
```

---

## References

- [1Password CLI Documentation](https://developer.1password.com/docs/cli)
- [Secret Management Tools Research](./SECRET_MANAGEMENT_TOOLS_RESEARCH.md)
- [1Password Best Practices](./1PASSWORD_BEST_PRACTICES.md)

