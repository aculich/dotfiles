# COMPARE_REGEN — WorkHorse vs SideQuest generate-and-compare

Branches: `regen/workhorse` vs `regen/sidequest` (after both pushed).

```bash
git fetch origin
git diff --stat origin/regen/workhorse...origin/regen/sidequest
```

## Expected file set (after B–D–R)

| Artifact | Present? WH | Present? SQ | Notes |
|----------|-------------|-------------|-------|
| EXECSUMMARY.md | | | |
| PRD.md | | | |
| dossier/USECASES,LANDSCAPE,ARCHITECTURE,TECHSTACK,SEARCH_KEYWORDS | | | |
| FORKS.md | | | |
| PLAYBOOK.md | | | |
| PRAXIS.md (runtime depth) | | | |
| PHASES.md (includes R) | | | |
| justfile runtime recipes (install/doit/flavors) | | | |
| Flavor xcconfigs on personal/team remotes | | | |

## Install proof

| Check | WorkHorse | SideQuest |
|-------|-----------|-----------|
| Upstream track launches | | |
| One key function (PRAXIS) | | |
| Personal flavor builds (optional) | | |
| Team flavor builds (optional) | | |

## Verdict

- Docs winner:
- Recipes winner:
- Merge plan:
