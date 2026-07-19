---
name: repo-evaluator
description: |
  Evaluate the health, quality, and viability of open source repositories using a structured rubric.
  Generates scored evaluations as JSON manifests and human-readable Markdown reports.
  Works on local repos (cloned directories), GitHub URLs, or batches of repos in an `upstream/` directory.
  Use this skill whenever the user wants to: assess whether an open source project is worth depending on,
  evaluate repo health or quality, generate a manifest of evaluated repos, compare multiple projects,
  audit dependencies, review upstream repos, score a GitHub project, or do any kind of open source
  due diligence. Also trigger when the user mentions "repo evaluation", "project health", "repo scoring",
  "upstream manifest", "dependency audit", or asks "is this project maintained?" or "should I use this library?"
---

# Repo Evaluator

## Overview

This skill evaluates open source repositories across 6 dimensions (100 points total) and produces structured output: a JSON manifest for machine consumption and a Markdown report for humans. It works in three modes: single repo evaluation, batch evaluation of repos in a directory, and comparison of multiple candidates.

The rubric synthesizes scoring criteria from your custom rubric, the [CHAOSS project](https://chaoss.community/) metrics framework, [OpenSSF Scorecard](https://scorecard.dev/) security checks, and [GitHub OSPO](https://github.com/github/github-ospo) health metrics.

## When To Use

- "Evaluate this repo" / "Is this project healthy?"
- "Score these upstream repos" / "Generate a manifest"
- "Should I depend on this library?"
- "Compare project X vs project Y"
- "Audit my upstream/ directory"
- Any request involving open source project assessment

## Workflow

### Step 1: Determine Mode and Inputs

Ask the user (or infer from context):

| Mode | Input | Output |
|------|-------|--------|
| **Single** | One repo path or GitHub URL | `evaluation.json` + `evaluation.md` |
| **Batch** | Directory containing repos (e.g. `upstream/`) | `manifest.json` + `manifest.md` |
| **Compare** | 2-4 repos (paths or URLs) | `comparison.json` + `comparison.md` |

### Step 2: Gather Data

For each repo, collect data from these sources (use whichever are available):

**For local repos:**
1. Run `git log`, `git shortlog`, `git tag` to get commit history, contributors, releases
2. Check for community health files: README, LICENSE, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY
3. Inspect directory structure, test directories, CI config files
4. If repomix is available (`npx repomix` or `repomix`), use it with `--compress` to get a structural overview
5. Check `package.json`, `pyproject.toml`, `Cargo.toml`, etc. for dependency info

**For GitHub URLs:**
1. Use `gh api repos/{owner}/{repo}` for stars, forks, issues, license
2. Use `gh api repos/{owner}/{repo}/contributors` for contributor count
3. Use `gh api repos/{owner}/{repo}/commits?per_page=1` for last commit date
4. Use `gh api repos/{owner}/{repo}/releases?per_page=5` for release info
5. Use `gh api repos/{owner}/{repo}/community/profile` for community health
6. Check if OpenSSF Scorecard data exists at `gh api repos/{owner}/{repo}/` or via `scorecard.dev`

### Step 3: Score Using Rubric

Read the full rubric at `references/rubric.md` for detailed scoring criteria. Here's the summary:

| Category | Points | What It Measures |
|----------|--------|-----------------|
| **Activity & Freshness** | 20 | Last commit, commit frequency, release cadence |
| **Community Health** | 20 | Stars, forks, contributor count, issue responsiveness |
| **Documentation Quality** | 20 | README, API docs, examples, contributing guide |
| **Technical Health** | 20 | Dependencies, tests, CI/CD, code quality signals |
| **Security Posture** | 10 | Security policy, dependency scanning, branch protection |
| **Ecosystem Fit** | 10 | Package manager presence, integration ease, license |

**Total: 100 points**

Score ranges:
- **90-100**: Excellent — production-ready, actively maintained, strong community
- **70-89**: Good — solid choice with minor gaps
- **50-69**: Fair — usable but notable limitations or risks
- **30-49**: Poor — significant concerns, consider alternatives
- **0-29**: Critical — likely abandoned or deeply problematic

### Step 4: Generate Output

**Always produce both JSON and Markdown.** Use the output templates below.

#### JSON Output Structure

```json
{
  "schema_version": "1.0.0",
  "generated_at": "2026-02-14T12:00:00Z",
  "generator": "repo-evaluator",
  "evaluations": [
    {
      "repo": {
        "name": "owner/repo-name",
        "url": "https://github.com/owner/repo-name",
        "description": "Brief description",
        "primary_language": "Python",
        "license": "MIT"
      },
      "scores": {
        "activity_and_freshness": {
          "score": 16,
          "max": 20,
          "details": {
            "last_commit": {"value": "2026-01-15", "points": 8, "max": 8},
            "commit_frequency": {"value": "weekly", "points": 5, "max": 6},
            "release_cadence": {"value": "monthly", "points": 3, "max": 6}
          }
        },
        "community_health": {
          "score": 14,
          "max": 20,
          "details": {}
        },
        "documentation_quality": {
          "score": 17,
          "max": 20,
          "details": {}
        },
        "technical_health": {
          "score": 15,
          "max": 20,
          "details": {}
        },
        "security_posture": {
          "score": 7,
          "max": 10,
          "details": {}
        },
        "ecosystem_fit": {
          "score": 8,
          "max": 10,
          "details": {}
        }
      },
      "total_score": 77,
      "rating": "Good",
      "summary": "One paragraph assessment of the project",
      "strengths": ["...", "..."],
      "concerns": ["...", "..."],
      "recommendation": "Recommended with caveats: ..."
    }
  ]
}
```

#### Markdown Report Structure

For single repos, use this template:

```markdown
# Repo Evaluation: {repo-name}

**Score: {total}/100 ({rating})**
**Evaluated: {date}**
**Source: {url or local path}**

## Summary
{One paragraph assessment}

## Scores

| Category | Score | Rating |
|----------|-------|--------|
| Activity & Freshness | {n}/20 | {bar} |
| Community Health | {n}/20 | {bar} |
| Documentation Quality | {n}/20 | {bar} |
| Technical Health | {n}/20 | {bar} |
| Security Posture | {n}/10 | {bar} |
| Ecosystem Fit | {n}/10 | {bar} |
| **Total** | **{n}/100** | **{rating}** |

## Strengths
- ...

## Concerns
- ...

## Recommendation
{recommendation}

## Data Sources
{list what data was available and used}
```

For batch manifests, produce a summary table first, then individual evaluations.

### Step 5: Save Output

- **Single repo**: Save to `{repo-name}-evaluation.json` and `{repo-name}-evaluation.md`
- **Batch**: Save to `manifest.json` and `manifest.md` in the parent directory
- **Compare**: Save to `comparison.json` and `comparison.md`

Always tell the user where the files are saved.

## Using Repomix

If repomix is available, it's useful for getting a compressed structural view of a repo's codebase. Run:

```bash
npx repomix --compress --output repomix-output.xml /path/to/repo
```

This gives you the repo's file structure and key code elements, which helps assess:
- Code organization and modularity (Technical Health)
- Documentation presence (Documentation Quality)
- Test coverage indicators (Technical Health)
- Dependency declarations (Technical Health, Security)

Repomix output is supplementary — the rubric scoring should work fine without it, but it enriches the Technical Health and Documentation Quality assessments.

## Handling Incomplete Data

Not all data will be available for every repo (e.g., local repos without a GitHub remote, or GitHub repos you can't clone). Score based on what's available and note gaps:

- If GitHub API data is unavailable, skip Community Health sub-metrics that require it (stars, forks) and note "GitHub data unavailable" in the report
- If the repo isn't cloned locally, skip deep code inspection and note it
- Never fabricate data — mark unavailable metrics as `null` in JSON and "N/A" in Markdown
- Adjust the total possible points to reflect what was measurable

## Resources

### references/
- `rubric.md` — The full detailed scoring rubric with point breakdowns per sub-metric
- `chaoss-mapping.md` — How this rubric maps to CHAOSS metrics and OpenSSF Scorecard checks

### scripts/
- `evaluate_repo.py` — Helper script for gathering git-based metrics from a local repo
- `github_api.py` — Helper for fetching GitHub API data for a repo
