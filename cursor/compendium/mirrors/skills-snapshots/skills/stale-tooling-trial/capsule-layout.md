# Capsule layout

## PDV — chat / SpecStory (delegate)

Prefer [`chatstory-preserve`](file:///Users/me/.cursor/skills/chatstory-preserve/SKILL.md) capsule:

```text
$VAULT_ROOT/.../vintage-YYYY-MM/chatstory-preserve-{slug}__{key}/
```

See that skill’s [capsule-layout.md](file:///Users/me/.cursor/skills/chatstory-preserve/capsule-layout.md). MARK-AND-SWEEP must link it.

## PDV (heritage trial capsule — patches / livewires)

```text
$VAULT_ROOT/partitions/default/capsules/flotsam-and-jetsam/misc/vintage-YYYY-MM/
  <slug>-YYYY-MM-DD/
    AGENT-BRIEFING.md
    MANIFEST.md
    CHATSTORY-PRESERVE.md      # pointer to chatstory-preserve-{slug}__{key}/ (or nest)
    specstory/                 # optional if already copied by chatstory-preserve
    patches/                   # git diff of nested repo + untracked helpers
    LIVEWIRES-BRIEFING.md      # copy or symlink note (redacted)
    ROTATION-PLAN.md           # copy; secrets stay in op://chaos
```

Do **not** copy live secret values into PDV as a second plaintext store if already in `chaos` — SpecStory that **already** contains secrets is moved as contaminated evidence (via chatstory-preserve).

## Quickstart heritage (non-secret)

```text
~/tools/<tool>-quickstart/background/heritage/
  STATUS.md, SETUP_COMPLETE.md, scripts (redacted), repos.json
  POINTERS.md   # PDV path, chaos item titles, chatstory path
```

## MARK-AND-SWEEP.md (at old root)

One-liner + links to capsule, chaos items, new quickstart; **do not delete until verify**.
