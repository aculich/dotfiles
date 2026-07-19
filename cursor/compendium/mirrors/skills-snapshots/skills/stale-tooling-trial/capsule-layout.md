# Capsule layout

## PDV (contaminated SpecStory + briefing)

```text
$VAULT_ROOT/partitions/default/capsules/flotsam-and-jetsam/misc/vintage-YYYY-MM/
  <slug>-YYYY-MM-DD/
    AGENT-BRIEFING.md
    MANIFEST.md
    specstory/                 # full .specstory if it embeds secrets
    patches/                   # git diff of nested repo + untracked helpers
    LIVEWIRES-BRIEFING.md      # copy or symlink note (redacted)
    ROTATION-PLAN.md           # copy; secrets stay in op://chaos
```

Do **not** copy live secret values into PDV as a second plaintext store if already in `chaos` — SpecStory that **already** contains secrets is moved as contaminated evidence.

## Quickstart heritage (non-secret)

```text
~/tools/<tool>-quickstart/background/heritage/
  STATUS.md, SETUP_COMPLETE.md, scripts (redacted), repos.json
  POINTERS.md   # PDV path, chaos item titles, chatstory path
```

## MARK-AND-SWEEP.md (at old root)

One-liner + links to capsule, chaos items, new quickstart; **do not delete until verify**.
