---
name: chatstory-preserve
description: >-
  Inventories and capsules SpecStory, Chatstory vault partitions, Cursor
  agent-transcripts/plans, and Claude project chats before move/delete. Use when
  chaos-containment apply/offload, quick-stash, mark-and-sweep, stale-tooling-trial,
  or the user says chatstory-preserve, preserve chat history, archive SpecStory
  before delete, or preserve-waive.
disable-model-invocation: true
metadata:
  internal: true
  source:
    upstream: https://github.com/aculich/agent-skills
    canonical: https://github.com/aculich/agent-skills
  pairs-with:
    - skill: chaos-containment
      reason: Gate before apply/offload/quick-stash moves
    - skill: quick-stash
      reason: Preserve workspace chat artifacts when stashing project trees
    - skill: stale-tooling-trial
      reason: Step 3 SpecStory/chat preserve delegates here
---

# chatstory-preserve

Preserve workspace chat history and plans **before** any move or delete.

> Never drop data without its context and intent — leave a capsule, not a dig site.

Ethos: [`~/pdv/meta/AGENTIC-DATA-STEWARDSHIP-GUIDE.md`](file:///Users/me/pdv/meta/AGENTIC-DATA-STEWARDSHIP-GUIDE.md).  
Artifact map: [artifact-map.md](artifact-map.md). Capsule layout: [capsule-layout.md](capsule-layout.md).

## Invocation

```text
/chatstory-preserve <path…>           # dry-run inventory + propose capsule
/chatstory-preserve <path…> --apply   # write PDV capsule + briefing
```

Optional: `--include-agent-tools` (copy large `agent-tools/` blobs; default skip).  
Waive only with explicit user language: `preserve-waive: <path>`.

**Incomplete preserve = incomplete move** (same ethos as incomplete briefing).

## Checklist

```text
chatstory-preserve:
- [ ] Resolve each ROOT (realpath)
- [ ] Discover artifacts (SpecStory, Chatstory, Cursor project, plans, Claude, workspaces)
- [ ] Emit inventory table (Path | Kind | Size | Action)
- [ ] Freshen Chatstory vault when possible (saveNow → reexport → sync)
- [ ] Dry-run stops here unless --apply
- [ ] --apply: write PDV capsule + AGENT-BRIEFING + MANIFEST + CHATSTORY-POINTER
- [ ] Return capsule path to caller; gate move/delete until done or waived
```

## Discover

For each ROOT (and nested subtrees in the move/delete set):

1. `{ROOT}/.specstory/` and nested `.specstory` under swept children
2. Chatstory partition via [`scripts/resolve-partition.sh`](scripts/resolve-partition.sh) → `{slug}__{key}` under `~/.chatstory/nodes/*/providers/cursor/workspaces/`
3. Cursor project: `~/.cursor/projects/<path-encoded>/` → `agent-transcripts/`, `canvases/`; note `agent-tools/` size (skip copy unless `--include-agent-tools`)
4. Plans: match under `~/.cursor/plans/` by basename/slug keywords; also `{ROOT}/.cursor/plans/`
5. Claude: `~/.claude/projects/` entry for encoded ROOT (if any)
6. `*.code-workspace` under ROOT

Prefer [`scripts/inventory-chat-artifacts.sh`](scripts/inventory-chat-artifacts.sh) for the dry-run table.

| Action | Meaning |
|--------|---------|
| `pointer` | Survives delete outside tree — record absolute path in briefing |
| `copy-to-pdv` | Would be lost or orphaned — copy into capsule |
| `freshen` | Chatstory partition — force capture then pointer |
| `skip` | Too large / not needed (e.g. default `agent-tools/`) |

## Freshen Chatstory

While Cursor still has the workspace open when possible:

1. Run (Command Palette / extension): `chatstory.saveNow` → `chatstory.reexportHistory` → `chatstory.syncArchive`
2. Optional: `chatstory.auditWorkspace`, `chatstory.verifyCapture`
3. Verify partition exists; count `history/*.md`; note latest mtime and `~/.chatstory` git dirty/clean
4. If extension commands unavailable: proceed with verify + SpecStory/transcript copy; set `chatstory_freshen: skipped-no-cli` in briefing

Do **not** duplicate the whole Chatstory partition into PDV by default — pointer only (vault already survives project delete).

## Apply — PDV capsule

```bash
VAULT_ROOT="${PDV_ROOT:-${VAULT_ROOT:-$HOME/pdv}}"
YYYY_MM=$(date -u +%Y-%m)
# partition id from resolve-partition.sh
DEST="$VAULT_ROOT/partitions/default/capsules/flotsam-and-jetsam/misc/vintage-$YYYY_MM/chatstory-preserve-{slug}__{key}/"
```

Create layout per [capsule-layout.md](capsule-layout.md). Required files:

- `AGENT-BRIEFING.md` (template: `~/.cursor/skills/chaos-containment/agent-briefing.md`)
- `MANIFEST.md` (inventory + sizes + freshen status)
- `CHATSTORY-POINTER.md` (absolute vault path + workspace_key + realpath)

Copy: SpecStory trees, agent-transcripts, matched plans, Claude dir if present, workspace files.  
Sensitivity: default `SENSITIVE/PII` when transcripts/SpecStory may embed secrets — never paste secret values into briefing.

## Gate rule (for callers)

Before `mv` / `rm` / Drive upload of a path that had any discover hit:

- [ ] `chatstory-preserve --apply` succeeded for that ROOT, **or** user said `preserve-waive: <path>`
- [ ] Briefing lists Chatstory pointer + SpecStory copy status
- [ ] MARK-AND-SWEEP / OFFLOAD / stash briefing links the capsule path

Callers that **must** invoke this skill (after livewires, before bytes move):

- `chaos-containment` — `apply`, `offload`, `quick-stash` handoff
- `quick-stash` — when stashing project trees or paths containing `.specstory`
- `stale-tooling-trial` — step 3 preserve (delegate SpecStory/chat here; keep heritage/patches in stale-tool)

## Out of scope

- Chatstory headless CLI (`chatstory archive --project` — future product work)
- Full `workspaceStorage/*.vscdb` or default `agent-tools/` copies
- SpecStory → Chatstory import (Chatstory is clean-room)

## See also

- [artifact-map.md](artifact-map.md), [capsule-layout.md](capsule-layout.md)
- `chaos-containment`, `quick-stash`, `stale-tooling-trial`, `hot-livewires-preflight`
- Chatstory naming: `~/projects/chatstory/src/vault/vaultPaths.ts`
- Ethos: `~/pdv/meta/AGENTIC-DATA-STEWARDSHIP-GUIDE.md`
