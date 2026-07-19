# Naming & namespace — {{SLUG}}

Seed inspiration: {{SEED}} · Date: {{DATE}}

## Slug vs product name

| | Value |
|--|-------|
| **Lab slug** | `{{SLUG}}` (filesystem / workspace only — from seed) |
| **Working product name** | _TBD — pick from shortlist below_ |
| Seed trademark risk | Do **not** ship under the seed’s brand without legal clearance |

## Brainstorm (8–15)

| Candidate | Why it fits | Concerns |
|-----------|-------------|----------|
| | | |

## Namespace checks (shortlist)

For each candidate: GitHub `in:name` hit count + DNS for `.com` / `.app`.

| Candidate | GH name hits | `.com` | `.app` | Collisions / notes |
|-----------|--------------|--------|--------|--------------------|
| | | free / taken | free / taken | |

Commands used:

```bash
gh api "search/repositories?q=<name>+in:name&per_page=1" --jq '.total_count'
dig +short <name>.com A
dig +short <name>.app A
```

DNS “free” only means no A record seen — not a guarantee of registrar availability or trademark clearance.

## Shortlist for SUPER_PRD (pick 3)

1.
2.
3.

## Decision

- Preferred name (when chosen):
- GitHub org/repo plan:
- Domain plan:
