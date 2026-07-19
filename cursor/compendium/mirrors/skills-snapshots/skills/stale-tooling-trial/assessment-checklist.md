# Assessment checklist

```bash
ROOT=…   # e.g. macosx-tools/universal-inbox

# Nested repos
find "$ROOT" -maxdepth 3 -name .git -type d

# Per repo
git -C <repo> remote -v
git -C <repo> status -sb
git -C <repo> rev-list --count origin/main..HEAD 2>/dev/null
gh api user --jq .login
# fork? (no personal fork of upstream name)

# Size
du -sh "$ROOT" "$ROOT"/*/target "$ROOT"/*/.devbox 2>/dev/null

# Intent metadata
ls "$ROOT/.specstory/history" 2>/dev/null
ls ~/.chatstory/nodes/*/providers/cursor/workspaces/* 2>/dev/null | rg -i "$(basename "$ROOT")"
```

Classification:

| Class | Meaning |
|-------|---------|
| `clean-abandoned` | No local commits, no dirty, no secrets |
| `abandoned-with-config` | No fork/commits ahead; local.toml / wrapper / secrets leftover |
| `fork-or-product` | Own fork or commits ahead — do not treat as disposable trial |
