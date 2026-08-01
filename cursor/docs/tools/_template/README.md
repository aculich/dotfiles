# Tool cluster template

Copy this directory to `docs/tools/<slug>/` and fill:

| File | Purpose |
|------|---------|
| [PRD.md](PRD.md) | Problem, ICP, jobs-to-be-done, non-goals, Cursor surfaces |
| [FEATURES.md](FEATURES.md) | Atomic features with stable IDs (`F-*`) for SuperPRD matrices |
| [SOURCES.md](SOURCES.md) | Official docs, GitHub, creator/user blogs (used + unused) |
| [NOTES.md](NOTES.md) | Caveats, version breakage, smoke-test notes |
| `extracts/` | Optional verbatim extracts from `parallel-cli extract` |

**Hard filter:** tool must support Cursor (IDE and/or Cursor CLI).

**Priority tiers:** P0 Cursor-specific → P1 Cursor+Grok → P2 Cursor+1–3 majors → P3 Cursor+ocean → footnote (no Cursor).
