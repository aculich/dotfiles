# skill-propagate

Propagate a prototype-born agent skill or Cursor slash command out of a product/tools birth site into its own pack (or agent-skills), leaving a pointer capsule behind.

## Usage

```
/skill-propagate <birth-path>
/skill-propagate <birth-path> --pack ~/projects/<name>
/skill-propagate <birth-path> --into-agent-skills
```

Default: dry-run. Apply only after confirm (`propagate apply` / `go ahead` / same-message `apply`).

## Implementation

1. Read and follow `skill-propagate-offshoot/SKILL.md` (in agent-skills `.experimental/` or installed under `~/.agents/skills/` / `~/.cursor/skills/`).
2. Inventory → classify → propose destination → wait for apply → generalize → install → capsule.
3. If the tree is messy data/vendor (not skills/commands), use `/chaos-containment` instead.
4. Do not ship manifesto essays or unrelated lore into the new pack (invasive species).

## Related

- `/chaos-containment` — umbrella inventory; `extract` defers skill trees here
- Propagation ≠ grafting — see code-sculpting `ideas/botanical-operations-crosswalk.md`
