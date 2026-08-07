---
name: quick-stash
description: >-
  Moves new uncommitted clutter (PII, research dumps, ad-hoc notes) from any
  repo into ~/pdv flotsam vintage buckets with provenance and AGENT-BRIEFING.md,
  then commits in the vault. Use when the user says quick-stash, stash to
  pdv/vault, get this out of the repo, or wants flotsam-and-jetsam mark-and-sweep
  for uncommitted files.
disable-model-invocation: true
---

# Quick-stash

Move **new / uncommitted** junk out of any project repo into the personal data vault (`~/pdv`) so the repo stays tidy.

> Never drop data without its context and intent — leave a capsule, not a dig site.

Not for vacuuming already-committed history — use **`tidy-stash`** for that.

Ethos: `~/pdv/meta/AGENTIC-DATA-STEWARDSHIP-GUIDE.md`. Briefing template: `~/.cursor/skills/chaos-containment/agent-briefing.md`.

## Resolve vault root

```bash
VAULT_ROOT="${PDV_ROOT:-${VAULT_ROOT:-$HOME/pdv}}"
```

If `$VAULT_ROOT` is missing or not a git repo, stop and tell the user to bootstrap `~/pdv` first.

**Do not** confuse with Obsidian `~/vaults`.

## Landing zone

```text
$VAULT_ROOT/partitions/default/capsules/flotsam-and-jetsam/misc/vintage-YYYY-MM/
```

Create `vintage-YYYY-MM` for the current UTC month if it does not exist.

## Workflow

Copy this checklist:

```text
Quick-stash:
- [ ] Confirm file/dir targets with user (never delete; move only)
- [ ] If targets are project trees or contain .specstory / Cursor workspace history: chatstory-preserve first
- [ ] Resolve VAULT_ROOT; ensure vintage-YYYY-MM exists
- [ ] mv (or git mv in source if tracked-uncommitted) into vintage
- [ ] Append provenance to vintage README.md
- [ ] Write AGENT-BRIEFING.md (required — incomplete briefing = incomplete stash)
- [ ] Commit in $VAULT_ROOT
- [ ] Optionally add source .gitignore patterns so files do not reappear
- [ ] Leave source repo clean; do not push vault remotes unless asked
```

### 0. chatstory-preserve (when applicable)

If any stash target is a project tree, contains `.specstory/`, or is otherwise a Cursor/Claude workspace with chat history, invoke [`chatstory-preserve`](file:///Users/me/.cursor/skills/chatstory-preserve/SKILL.md) **before** the move (`--apply` capsule, or user `preserve-waive: <path>`). Link the capsule from the stash briefing. Incomplete preserve = incomplete stash for those paths.

### 1. Confirm targets

List paths to move. Proceed only after explicit confirmation (or the user listed exact paths in the same message).

Never `rm` stash targets. Never move secrets into a vault with a public remote without warning.

### 2. Move

```bash
YYYY_MM=$(date -u +%Y-%m)
DEST="$VAULT_ROOT/partitions/default/capsules/flotsam-and-jetsam/misc/vintage-$YYYY_MM"
mkdir -p "$DEST"
mv <sources...> "$DEST/"
```

### 3. Provenance (required)

Append to `$DEST/README.md` (create if needed):

```markdown
## Stash YYYY-MM-DD

- **Whence:** `<absolute original path or repo>`
- **Purpose:** `<why it existed>`
- **Sensitivity:** `<public | internal | SENSITIVE/PII>`
- **Files:** `<names moved>`
- **Agent briefing:** `<AGENT-BRIEFING.md or path>`
```

### 4. Agent briefing (required)

Write `$DEST/AGENT-BRIEFING.md` (or a uniquely named briefing beside a sub-batch if purposes differ).

**Incomplete briefing = incomplete stash.** Do not commit until the briefing exists.

Use the template in `~/.cursor/skills/chaos-containment/agent-briefing.md`. Minimum: one-liner, what, whence, when, purpose (label inferences), sensitivity, moved-by, inventory, intent for receiving agent, anticipated Q&A (≥2–3), do-not, links to `~/pdv/meta/`.

If several unrelated purposes share one vintage month, prefer one briefing per logical batch (subdirectory or dated filename) rather than one vague mega-briefing.

### 5. Commit in the vault

```bash
git -C "$VAULT_ROOT" add -A
git -C "$VAULT_ROOT" status -sb
git -C "$VAULT_ROOT" commit -m "$(cat <<'EOF'
Quick-stash: <short summary from whence>

EOF
)"
```

Do **not** `git push` unless the user asks.

### 6. Source repo hygiene

If similar files might land again, add ignore patterns in the source `.gitignore`. Do not commit unrelated source changes.

Optionally note the stash in `$VAULT_ROOT/MANIFEST.md` if it is a new accumulation class.

## Anti-patterns

- Do not stash into Obsidian `~/vaults` or `~/GranolaVault`
- Do not rewrite source git history (that is `tidy-stash` + explicit ask)
- Do not invent a second vault root when `~/pdv` exists
- Do not finish without `AGENT-BRIEFING.md`
