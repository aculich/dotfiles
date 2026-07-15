---
name: tidy-stash
description: >-
  Inventories and vacuums existing-repo flotsam (untracked, wrongly committed, or
  lying-about PII/dumps) into ~/pdv flotsam vintage buckets with provenance.
  Prefer stop-tracking over history rewrite. Use when the user says tidy-stash,
  vacuum this repo, clean committed PII out, or move long-standing dumps to pdv.
disable-model-invocation: true
---

# Tidy-stash

Vacuum **existing** repos: material that is already committed, ignored-but-present, or long-lying clutter that should live in `~/pdv` instead.

For **brand-new uncommitted** one-off files, prefer **`quick-stash`**.

## Resolve vault root

```bash
VAULT_ROOT="${PDV_ROOT:-${VAULT_ROOT:-$HOME/pdv}}"
```

If `$VAULT_ROOT` is missing or not a git repo, stop and tell the user to bootstrap `~/pdv` first.

**Do not** confuse with Obsidian `~/vaults`. Do not relocate `~/vaults` or registered Obsidian paths.

## Landing zone

Same as quick-stash:

```text
$VAULT_ROOT/partitions/default/capsules/flotsam-and-jetsam/misc/vintage-YYYY-MM/
```

## Workflow

```text
Tidy-stash:
- [ ] Pass A: inventory (read-only) + propose move set
- [ ] User confirms move set
- [ ] Pass B: move + provenance + vault commit
- [ ] Update source .gitignore; stop tracking if needed
- [ ] Update $VAULT_ROOT/MANIFEST.md
- [ ] History rewrite only if user explicitly asks
```

### Pass A — inventory (read-only)

From the target repo:

1. `git status -sb` (untracked / modified)
2. Sample large or sensitive-looking untracked trees
3. Flag **tracked** candidates (research dumps, takeouts, `*affiliations*`, exports) — do not move yet
4. Flag **history suspects** (file once committed) — note that scrubbing history is separate and dangerous

Emit a **proposal**:

| Path | State | Action |
|------|-------|--------|
| `path` | untracked / tracked / ignored-present | move to vintage-YYYY-MM |

End with: wait for confirmation before writes.

### Pass B — apply (after confirmation)

1. `mkdir -p` current `vintage-YYYY-MM`
2. **Move** files (`mv`). If tracked: `git rm --cached` or `git rm` after move so the working tree does not delete the vault copy — preferred sequence:
   - `mv` working copy to vault (if untracked), **or**
   - copy then `git rm` tracked file after vault has the bytes — safest: `git mv` is wrong across repos; use `mv` then `git rm --cached` / `git rm` in source for tracked paths **only after** the destination has the file
3. Provenance block in vintage `README.md` (whence, purpose, sensitivity, original path, whether it was tracked)
4. Commit in `$VAULT_ROOT`
5. Source repo: add `.gitignore` patterns; commit source cleanup **only if the user wants a source commit**
6. Append/update `$VAULT_ROOT/MANIFEST.md` for new external→in-pdv entries

### History rewrite

Default: **stop tracking + leave history**. If the user explicitly requests history scrub (`git filter-repo`, BFG, etc.):

- Warn about force-push / collaborator impact
- Proceed only with explicit go-ahead
- Never force-push `main`/`master` without explicit request

## Provenance template

```markdown
## Tidy-stash YYYY-MM-DD

- **Whence:** `<repo path>`
- **State:** `<untracked | tracked | ignored-present>`
- **Purpose:** `<why>`
- **Sensitivity:** `<...>`
- **Files:** `<...>`
- **Source follow-up:** `<gitignore / stop-track / history scrub TBD>`
```

## Anti-patterns

- Do not move Obsidian vaults or `~/personal` wholesale without an explicit scoped request
- Do not push `$VAULT_ROOT` remotes unless asked
- Do not delete without moving first
- Do not use `~/vault` — root is `~/pdv`
