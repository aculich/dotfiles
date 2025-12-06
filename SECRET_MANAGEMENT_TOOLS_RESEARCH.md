# Secret Management Tools Research & Recommendations

## Current Issue: 1Password CLI Integration

### Problem
The `op_signin_cached` function is failing during shell startup with direnv:
```
Error: Failed to sign in to 1Password
Details: Sign-in succeeded but could not extract session token from environment
```

### Root Cause
The function tries to extract the session token from environment variables after sign-in, but the token isn't being properly captured. This is a known issue with 1Password CLI when using biometric authentication.

### Immediate Fix
1. **Use `op signin` with explicit account**: The CLI should handle session management automatically
2. **Check desktop app integration**: Ensure "Connect with 1Password CLI" is enabled
3. **Use `op inject` pattern**: Better for direnv integration (see below)

---

## Open-Source Secret Management Tools Comparison

### 1. **gopass** ⭐ (Recommended for Local + Cloud Sync)
**GitHub**: https://github.com/gopasspw/gopass

**Features:**
- ✅ Local-first (stores secrets in encrypted Git repository)
- ✅ Cloud sync via Git (GitHub, GitLab, etc.)
- ✅ CLI-based, works great with direnv
- ✅ Per-project secret management
- ✅ Credential rotation support
- ✅ GCP/AWS/Azure integration via plugins
- ✅ Team sharing via Git
- ✅ Based on `pass` (standard Unix password manager)

**Pros:**
- Open source, actively maintained
- Works offline (local-first)
- Git-based sync (you control the storage)
- Excellent CLI integration
- Can import from 1Password
- Supports multiple stores (personal, work, projects)

**Cons:**
- Requires Git setup for sync
- Learning curve (GPG key management)
- No built-in GUI (CLI only)

**Installation:**
```bash
brew install gopass
```

**Usage with direnv:**
```bash
# In .envrc
export $(gopass show -f project/secrets | xargs)
```

**GCP Integration:**
```bash
gopass gcp configure  # Sets up GCP service account integration
```

---

### 2. **pass** (Standard Unix Password Manager)
**GitHub**: https://www.passwordstore.org/

**Features:**
- ✅ Local-first (GPG-encrypted files)
- ✅ Cloud sync via Git
- ✅ Simple, standard tool
- ✅ Works with direnv
- ✅ Per-project management

**Pros:**
- Simple, standard tool
- Works everywhere (Linux, macOS, Windows)
- Git-based sync
- Many integrations available

**Cons:**
- Basic feature set
- Manual credential rotation
- No built-in cloud provider integration

**Installation:**
```bash
brew install pass
```

---

### 3. **SOPS** (Secrets OPerationS) ⭐ (Best for GitOps)
**GitHub**: https://github.com/getsops/sops

**Features:**
- ✅ Encrypts YAML/JSON/ENV files
- ✅ Git-friendly (encrypted files can be committed)
- ✅ Multiple backends (GCP KMS, AWS KMS, Azure Key Vault, 1Password, age, etc.)
- ✅ Per-project secret files
- ✅ Works with direnv
- ✅ Credential rotation support

**Pros:**
- Encrypted files can be committed to Git
- Multiple backend support (including 1Password!)
- Great for infrastructure-as-code
- Works with Kubernetes secrets

**Cons:**
- Requires backend setup (KMS, etc.)
- More complex for simple use cases
- Not ideal for interactive shell usage

**Installation:**
```bash
brew install sops
```

**Usage with 1Password backend:**
```bash
# Encrypt file using 1Password
sops --encrypt --in-place secrets.yaml
# Uses 1Password as encryption backend
```

**Usage with direnv:**
```bash
# In .envrc
export $(sops -d .env.encrypted | xargs)
```

---

### 4. **Vaultwarden** (Self-Hosted Bitwarden)
**GitHub**: https://github.com/dani-garcia/vaultwarden

**Features:**
- ✅ Self-hosted (you control the server)
- ✅ Bitwarden-compatible API
- ✅ CLI available (`bw` - Bitwarden CLI)
- ✅ Local-first (can work offline)
- ✅ Cloud sync (your own server)

**Pros:**
- Self-hosted (full control)
- Bitwarden ecosystem (mobile apps, browser extensions)
- Good for teams
- Can sync across devices

**Cons:**
- Requires server setup
- Not as CLI-focused as other tools
- More complex setup

**Installation:**
```bash
# Server: Docker
docker run -d --name vaultwarden -v /vw-data/:/data/ -p 80:80 vaultwarden/server:latest

# CLI: Bitwarden CLI
brew install bitwarden-cli
```

---

### 5. **Doppler** (Cloud-First, Free Tier Available)
**Website**: https://www.doppler.com/

**Features:**
- ✅ Cloud-based (free tier available)
- ✅ CLI integration
- ✅ Per-project secrets
- ✅ Credential rotation
- ✅ GCP/AWS/Azure integration
- ✅ Works with direnv

**Pros:**
- Easy setup
- Good free tier
- Excellent documentation
- Built-in rotation
- Cloud provider integrations

**Cons:**
- Cloud-based (not local-first)
- Requires internet connection
- Free tier limitations

**Installation:**
```bash
brew install doppler
```

**Usage with direnv:**
```bash
# In .envrc
eval $(doppler secrets download --no-file --format env)
```

---

### 6. **env0** / **envkey** (Cloud-Based)
**Similar to Doppler** - cloud-first secret management

---

## Recommended Solution: Hybrid Approach

### Option A: **gopass** (Best for Local-First + Cloud Sync)

**Why:**
- Local-first (works offline)
- Git-based sync (you control storage)
- Excellent CLI integration
- Can import from 1Password
- Per-project management
- GCP/AWS/Azure plugins available

**Setup:**
```bash
# Install
brew install gopass

# Initialize
gopass setup

# Create stores
gopass init --store personal
gopass init --store work
gopass init --store projects

# Import from 1Password (if needed)
# Use migration script or manual export/import
```

**Integration with direnv:**
```bash
# In project .envrc
if command -v gopass &> /dev/null; then
    # Load secrets from gopass
    export $(gopass show -f projects/myproject/secrets | xargs)
fi
```

**GCP Integration:**
```bash
# Install GCP plugin
gopass gcp configure

# Store GCP service account
gopass insert projects/myproject/gcp-sa-key.json
```

---

### Option B: **SOPS with 1Password Backend** (Best for GitOps)

**Why:**
- Can use 1Password as backend (keep using 1Password!)
- Encrypted files can be committed to Git
- Great for infrastructure-as-code
- Works with direnv

**Setup:**
```bash
# Install
brew install sops

# Configure 1Password backend
export SOPS_1PASSWORD_ACCOUNT="aculich@gmail.com"
export SOPS_1PASSWORD_VAULT="Development"

# Encrypt secrets file
sops --encrypt --in-place .env.secrets
```

**Integration with direnv:**
```bash
# In .envrc
if command -v sops &> /dev/null; then
    export $(sops -d .env.secrets | xargs)
fi
```

---

### Option C: **Fix 1Password Integration + Use `op inject` Pattern**

**Why:**
- Keep using 1Password (you already have it set up)
- `op inject` is faster and more reliable than individual `op read` calls
- Better for direnv integration

**Fix the current issue:**
1. Use `op signin` without trying to extract token manually
2. Use `op inject` pattern instead of `op_load_item`
3. Create `.env.1password` template files

**Setup:**
```bash
# Sign in once (handles session automatically)
op signin --account aculich@gmail.com

# Create template file
cat > .env.1password <<EOF
OPENAI_API_KEY=op://Development/API Keys/OPENAI_API_KEY
DATABASE_URL=op://Development/API Keys/DATABASE_URL
EOF
```

**Integration with direnv:**
```bash
# In .envrc
if command -v op &> /dev/null; then
    # Use op inject (faster than op read)
    export $(op inject -i .env.1password | xargs)
fi
```

---

## Comparison Matrix

| Feature | gopass | pass | SOPS | Vaultwarden | Doppler | 1Password (fixed) |
|---------|--------|------|------|-------------|---------|-------------------|
| Local-first | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| Cloud sync | ✅ (Git) | ✅ (Git) | ✅ (Git) | ✅ (Self-hosted) | ✅ (Cloud) | ✅ (Cloud) |
| CLI integration | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| direnv support | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Per-project | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Credential rotation | ✅ | Manual | ✅ | ✅ | ✅ | ✅ |
| GCP integration | ✅ (Plugin) | ❌ | ✅ (KMS) | ❌ | ✅ | ✅ |
| AWS integration | ✅ (Plugin) | ❌ | ✅ (KMS) | ❌ | ✅ | ✅ |
| Azure integration | ✅ (Plugin) | ❌ | ✅ (Key Vault) | ❌ | ✅ | ✅ |
| 1Password import | ✅ | ✅ | ✅ (Backend) | ❌ | ❌ | N/A |
| Learning curve | Medium | Low | Medium | Medium | Low | Low |
| Setup complexity | Medium | Low | Medium | High | Low | Low |

---

## Recommendations

### For Your Use Case (Local + Cloud Sync + GCP + Per-Project)

**Primary Recommendation: gopass**
- Best balance of local-first and cloud sync
- Excellent CLI integration
- GCP plugin available
- Can import from 1Password
- Per-project management
- Active development

**Secondary Option: Fix 1Password + Use `op inject`**
- Keep using what you have
- Fix the token extraction issue
- Use `op inject` pattern (faster, more reliable)
- Better direnv integration

**For GitOps/Infrastructure: SOPS with 1Password Backend**
- Best for committing encrypted secrets to Git
- Can use 1Password as backend
- Great for Kubernetes, Terraform, etc.

---

## Next Steps

1. **Immediate**: Fix 1Password integration (use `op inject` pattern)
2. **Short-term**: Evaluate gopass for local-first secret management
3. **Long-term**: Consider SOPS for infrastructure secrets (if doing GitOps)

---

## References

- [gopass Documentation](https://www.gopass.pw/)
- [SOPS Documentation](https://github.com/getsops/sops)
- [1Password CLI Best Practices](./1PASSWORD_BEST_PRACTICES.md)
- [Doppler Documentation](https://docs.doppler.com/)
- [pass Documentation](https://www.passwordstore.org/)

