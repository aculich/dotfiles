# repo-evaluator

A Claude Code skill and standalone tool for evaluating the health, quality, and viability of open source repositories.

## What It Does

Scores repos across 6 dimensions (100 points total):

| Category | Points | What It Measures |
|----------|--------|-----------------|
| Activity & Freshness | 20 | Last commit, commit frequency, release cadence |
| Community Health | 20 | Stars, forks, contributors, issue responsiveness |
| Documentation Quality | 20 | README, API docs, examples, contributing guide |
| Technical Health | 20 | Tests, CI/CD, dependencies, code quality |
| Security Posture | 10 | Security policy, vuln scanning, branch protection |
| Ecosystem Fit | 10 | Package manager, license, integration ease |

Produces both JSON manifests and Markdown reports.

## Installation

### As a Claude Code Skill

**Global (all projects):**
```bash
cp -r repo-evaluator ~/.claude/skills/repo-evaluator
```

**Per project:**
```bash
cp -r repo-evaluator /path/to/your/project/.claude/skills/repo-evaluator
```

Then in Claude Code, say: "evaluate this repo" or "score the repos in upstream/".

### As a Cursor Skill

**Global (all projects):**
```bash
cp -r repo-evaluator ~/.cursor/skills-cursor/repo-evaluator
```

The agent will use the skill when you ask to evaluate repos, score project health, or compare upstream projects.

### As a Cursor Rule (project-specific)

Copy the rule file into your project so the agent follows the rubric when evaluating repos:

```bash
mkdir -p /path/to/your/project/.cursor/rules
cp .cursor/rules/repo-evaluator.mdc /path/to/your/project/.cursor/rules/
```

### As a Cursor Slash Command

**Global:** Copy the command file into your Cursor commands directory:

```bash
mkdir -p ~/.cursor/commands
cp .cursor/commands/repo-evaluate.md ~/.cursor/commands/
```

Then in Cursor, type `/repo-evaluate` (or `/repo-evaluate path-or-url`) to evaluate the current repo or a given path/URL.

### Standalone Scripts

```bash
# Evaluate a local repo
python3 scripts/evaluate_repo.py /path/to/repo --json

# Fetch GitHub API data
python3 scripts/github_api.py owner/repo --json
```

## Scoring Methodology

The rubric draws from:
- [CHAOSS](https://chaoss.community/) — community health metrics framework
- [OpenSSF Scorecard](https://scorecard.dev/) — security health checks
- [GitHub OSPO](https://github.com/github/github-ospo) — open source program office metrics

See `references/rubric.md` for the full point-by-point breakdown.
See `references/chaoss-mapping.md` for how this maps to established frameworks.

## License

MIT
