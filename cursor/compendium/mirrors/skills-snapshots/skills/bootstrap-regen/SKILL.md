---
name: bootstrap-regen
description: >-
  Optional generate-and-compare regen on a second laptop. Forks from annotated
  metarepo/phase-*-done tags on main. Use with /bootstrap-regen. Not part of the
  standard singleton bootstrap path.
disable-model-invocation: true
---

# Bootstrap Regen (optional dual-laptop)

**Not standard.** Use only when deliberately comparing two regenerate paths.

## Usage

```
/bootstrap-regen
/bootstrap-regen C
/bootstrap-regen R
```

Stage defaults to **A** (inception tip). Allowed: `A|B|C|D|R`.

## Prerequisites

- Metarepo already on GitHub with `main`
- Annotated tags present: `metarepo/phase-A-done` … (create via `just tag-phase X` after each phase)
- Laptop nickname for branch: `regen/<laptop>` (e.g. `regen/workhorse`, `regen/sidequest`)

## Workflow

```
Regen Progress:
- [ ] 1. cd ~/tools/<slug>-metarepo (clone if needed)
- [ ] 2. git fetch --tags origin
- [ ] 3. Resolve start tag metarepo/phase-<STAGE>-done (default A)
- [ ] 4. git checkout main && git pull --ff-only
- [ ] 5. git checkout -b regen/<laptop> metarepo/phase-<STAGE>-done
- [ ] 6. Open bootstrap overview canvas; continue phases from STAGE forward
- [ ] 7. Do not claim done without runtime-doit + forks (DoD)
- [ ] 8. Push; fill COMPARE_REGEN.md; optional /bootstrap-aar
```

### Commands

```bash
cd ~/tools/<slug>-metarepo
git fetch origin --tags
STAGE="${1:-A}"   # A B C D R
TAG="metarepo/phase-${STAGE}-done"
git rev-parse "$TAG" >/dev/null || { echo "Missing tag $TAG — run just tag-phase on the inception laptop first"; exit 1; }
LAPTOP="$(scutil --get ComputerName 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' ' '-' || echo laptop)"
# Prefer explicit name from user: workhorse | sidequest
git checkout main && git pull --ff-only origin main
git checkout -b "regen/${LAPTOP_NAME:-$LAPTOP}" "$TAG"
just phase "$STAGE" || true
echo "Continue from Phase $STAGE → R. Open canvases/bootstrap-overview if present."
```

## Related

- Oracle: `PHASES.md`, optional [SIDEQUEST.md](../dwim-justfile/templates/SIDEQUEST.md)
- AAR: `/bootstrap-aar`
- Standard inception: `/bootstrap-quickstart` (singleton)
