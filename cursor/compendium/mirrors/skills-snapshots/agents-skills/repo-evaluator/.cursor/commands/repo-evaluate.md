# Evaluate Repository Health

Evaluate the health, quality, and viability of an open source repository using the repo-evaluator rubric. Produces a scored evaluation as JSON and Markdown.

## Usage

```
/repo-evaluate [path-or-url]
```

- **No argument**: Evaluate the current workspace repo.
- **path-or-url**: Evaluate the repo at the given path (e.g. `../other-repo`) or GitHub URL (e.g. `owner/repo` or `https://github.com/owner/repo`).

## What It Does

1. Gathers metrics (git history, community files, CI/tests/deps) via `scripts/evaluate_repo.py` and optionally GitHub API.
2. Scores the repo across 6 categories (100 points total): Activity & Freshness, Community Health, Documentation Quality, Technical Health, Security Posture, Ecosystem Fit.
3. Writes `evaluation.json` and `evaluation.md` in the workspace (or the repo being evaluated).

## Output

- **evaluation.json**: Structured scores, rating (Excellent/Good/Fair/Poor/Critical), summary, strengths, concerns, recommendation.
- **evaluation.md**: Human-readable report with score table and category details.

## Batch Mode

To evaluate multiple repos (e.g. in `upstream/`), say: "Evaluate all repos in upstream/ and produce manifest.json and manifest.md."

Use the repo-evaluator skill (SKILL.md) for the full workflow and rubric details; see `references/rubric.md` for the point breakdown.
