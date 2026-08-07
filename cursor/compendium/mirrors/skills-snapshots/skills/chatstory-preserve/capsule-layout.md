# Capsule layout — chatstory-preserve

> Never drop data without its context and intent — leave a capsule, not a dig site.

## PDV destination

```text
$VAULT_ROOT/partitions/default/capsules/flotsam-and-jetsam/misc/vintage-YYYY-MM/
  chatstory-preserve-{slug}__{key}/
    AGENT-BRIEFING.md          # required
    MANIFEST.md                # inventory + sizes + freshen status
    CHATSTORY-POINTER.md       # absolute vault path + workspace_key + realpath
    specstory/                 # rsync of each discovered .specstory
      <relpath>/               # e.g. root/ or Ice__jordanbaird/
        history/ …
    cursor-agent-transcripts/  # from ~/.cursor/projects/.../agent-transcripts
    canvases/                  # optional; if present and small
    plans/                     # matched ~/.cursor/plans + project .cursor/plans
    claude/                    # if ~/.claude/projects entry exists
    workspaces/                # *.code-workspace copies
```

`$VAULT_ROOT` = `${PDV_ROOT:-${VAULT_ROOT:-$HOME/pdv}}`  
`{slug}__{key}` from [`scripts/resolve-partition.sh`](scripts/resolve-partition.sh).

## CHATSTORY-POINTER.md (minimum)

```markdown
# Chatstory pointer

- **realpath:** /absolute/project/path
- **partition_id:** slug__key
- **vault_path:** /Users/me/.chatstory/nodes/<node>/providers/cursor/workspaces/slug__key/
- **history_count:** N
- **freshen:** ok | skipped-no-cli | failed
- **vault_git:** clean | dirty | n/a
```

Do **not** copy the full Chatstory partition into PDV by default.

## AGENT-BRIEFING.md

Use `~/.cursor/skills/chaos-containment/agent-briefing.md`. Set:

- **Moved by:** `chatstory-preserve` (+ caller skill name)
- **Sensitivity:** `SENSITIVE/PII` when SpecStory/transcripts may embed secrets
- **Inventory:** table of copied paths + Chatstory pointer
- **Intent:** receiving agent may summarize/index inside PDV; do not push public; do not treat Chatstory pointer as optional

## Contaminated SpecStory

If SpecStory embeds live secrets, still copy as evidence (same rule as stale-tooling-trial). Live secret *values* stay in `op://chaos` via hot-livewires — do not re-paste into briefing.

## Caller integration

After capsule write, callers must link this path from:

- `MARK-AND-SWEEP.md`
- `OFFLOAD.md`
- quick-stash vintage `README.md` / batch `AGENT-BRIEFING.md`

stale-tooling-trial may keep heritage/patches beside or under a sibling `<slug>-YYYY-MM-DD/` capsule; SpecStory/chat portion **delegates** to this layout (or nest a pointer to `chatstory-preserve-{slug}__{key}/`).
