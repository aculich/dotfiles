# Repo Evaluator — Detailed Scoring Rubric

This document defines the full scoring rubric for evaluating open source repositories.
Total: 100 points across 6 categories.

## Table of Contents
- [1. Activity & Freshness (20 points)](#1-activity--freshness-20-points)
- [2. Community Health (20 points)](#2-community-health-20-points)
- [3. Documentation Quality (20 points)](#3-documentation-quality-20-points)
- [4. Technical Health (20 points)](#4-technical-health-20-points)
- [5. Security Posture (10 points)](#5-security-posture-10-points)
- [6. Ecosystem Fit (10 points)](#6-ecosystem-fit-10-points)
- [Interpreting Scores](#interpreting-scores)

---

## 1. Activity & Freshness (20 points)

How recently and consistently is this project being worked on?

### Last Commit Date (8 points)
| Recency | Points |
|---------|--------|
| Within 1 month | 8 |
| 1-3 months | 6 |
| 3-6 months | 4 |
| 6-12 months | 2 |
| Over 1 year | 1 |
| Over 2 years | 0 |

### Commit Frequency (6 points)
Look at the last 6 months of commit history:
| Frequency | Points |
|-----------|--------|
| Daily or multiple times per week | 6 |
| Weekly | 5 |
| Bi-weekly to monthly | 3 |
| Quarterly | 2 |
| Less than quarterly | 1 |
| No commits in 6 months | 0 |

### Release Cadence (6 points)
| Cadence | Points |
|---------|--------|
| Regular releases (monthly or more) | 6 |
| Quarterly releases | 4 |
| Semi-annual releases | 2 |
| Annual or less | 1 |
| No releases / no tags | 0 |

---

## 2. Community Health (20 points)

How vibrant and responsive is the community around this project?

### GitHub Stars (5 points)
Stars are a rough popularity proxy. Adjust expectations by project domain.
| Stars | Points |
|-------|--------|
| 1000+ | 5 |
| 500-999 | 4 |
| 100-499 | 3 |
| 20-99 | 2 |
| 1-19 | 1 |
| 0 | 0 |

### Contributors (5 points)
| Contributors | Points |
|-------------|--------|
| 20+ | 5 |
| 10-19 | 4 |
| 5-9 | 3 |
| 2-4 | 2 |
| 1 (solo maintainer) | 1 |

### Issue Responsiveness (5 points)
How well are issues handled? Look at median time to first response, close rate.
| Responsiveness | Points |
|---------------|--------|
| Most issues get response within days, good close rate | 5 |
| Reasonable response times, moderate close rate | 3 |
| Slow responses, large backlog of stale issues | 2 |
| Issues largely ignored | 1 |
| Issues disabled or no issues filed | 0 |

### Fork Activity (5 points)
Forks indicate community interest in building on the project.
| Forks | Points |
|-------|--------|
| 100+ | 5 |
| 50-99 | 4 |
| 20-49 | 3 |
| 5-19 | 2 |
| 1-4 | 1 |
| 0 | 0 |

---

## 3. Documentation Quality (20 points)

Can a new user or contributor understand and use this project?

### README Quality (7 points)
| Quality | Points |
|---------|--------|
| Comprehensive: purpose, install, usage, examples, badges, screenshots | 7 |
| Good: purpose, install, basic usage | 5 |
| Adequate: purpose and install | 3 |
| Minimal: just a title and brief description | 1 |
| Missing or empty | 0 |

### API / Usage Documentation (5 points)
| Quality | Points |
|---------|--------|
| Full API docs with examples (generated or hand-written) | 5 |
| Good coverage of main features | 3 |
| Basic docs exist | 2 |
| Minimal or only inline comments | 1 |
| None | 0 |

### Examples & Tutorials (4 points)
| Quality | Points |
|---------|--------|
| Rich examples directory, tutorials, or cookbook | 4 |
| Some examples in README or separate files | 2 |
| Code snippets only in README | 1 |
| None | 0 |

### Contributing Guide (4 points)
| Quality | Points |
|---------|--------|
| CONTRIBUTING.md with setup, style, PR process, CoC reference | 4 |
| Basic contributing guide | 2 |
| Mentioned in README but no dedicated file | 1 |
| None | 0 |

---

## 4. Technical Health (20 points)

Is the codebase well-engineered and maintainable?

### Test Coverage (6 points)
| Coverage | Points |
|----------|--------|
| Comprehensive test suite, visible coverage metrics | 6 |
| Good test suite, covers main functionality | 4 |
| Basic tests exist | 2 |
| Minimal tests | 1 |
| No tests | 0 |

### CI/CD (5 points)
| CI Status | Points |
|-----------|--------|
| Active CI with passing builds, multiple checks | 5 |
| CI exists and mostly passes | 3 |
| CI exists but failing or stale | 1 |
| No CI | 0 |

### Dependency Health (5 points)
| Status | Points |
|--------|--------|
| Dependencies up-to-date, automated update tooling (Dependabot, Renovate) | 5 |
| Mostly current dependencies | 3 |
| Some significantly outdated | 2 |
| Many outdated, known vulnerabilities | 1 |
| Severely outdated or unmaintainable | 0 |

### Code Quality Signals (4 points)
Look for: consistent style, linting config, type hints/annotations, clean project structure.
| Quality | Points |
|---------|--------|
| Strong signals: linter config, type safety, clean architecture | 4 |
| Good signals: some tooling, reasonable structure | 3 |
| Basic: functional but inconsistent | 2 |
| Poor: no tooling, messy structure | 1 |
| Very poor: monolithic, spaghetti, no organization | 0 |

---

## 5. Security Posture (10 points)

How seriously does the project take security? This category is informed by [OpenSSF Scorecard](https://scorecard.dev/) checks.

### Security Policy (3 points)
| Status | Points |
|--------|--------|
| SECURITY.md with disclosure process, response expectations | 3 |
| Basic security policy or email contact | 2 |
| Mentioned in README | 1 |
| None | 0 |

### Dependency Vulnerability Scanning (3 points)
| Status | Points |
|--------|--------|
| Automated scanning (Dependabot alerts, Snyk, etc.) enabled and acted on | 3 |
| Some scanning configured | 2 |
| Manual checks only | 1 |
| No evidence of vulnerability management | 0 |

### Branch Protection & Review (4 points)
| Status | Points |
|--------|--------|
| Branch protection on default branch, required reviews, signed commits | 4 |
| Branch protection with required reviews | 3 |
| Some branch protection | 2 |
| No branch protection visible | 0 |

---

## 6. Ecosystem Fit (10 points)

How easy is it to adopt this project in real-world use?

### Package Manager Presence (4 points)
| Status | Points |
|--------|--------|
| Published on relevant package manager(s) (npm, PyPI, crates.io, etc.), up-to-date | 4 |
| Published but slightly behind repo | 3 |
| Published but significantly outdated | 1 |
| Not published on any package manager | 0 |

### License Clarity (3 points)
| Status | Points |
|--------|--------|
| OSI-approved license, clearly stated in LICENSE file and package metadata | 3 |
| License file exists, standard license | 2 |
| License mentioned but unclear terms | 1 |
| No license (legally risky to use!) | 0 |

### Integration Ease (3 points)
| Status | Points |
|--------|--------|
| Simple install + import, minimal config, well-defined API | 3 |
| Moderate setup required, reasonable docs | 2 |
| Complex setup, many prerequisites | 1 |
| Extremely difficult to integrate | 0 |

---

## Interpreting Scores

### Overall Rating Bands

| Score | Rating | Interpretation |
|-------|--------|---------------|
| 90-100 | Excellent | Production-ready. Strong community, active maintenance, good security practices. Safe to depend on. |
| 70-89 | Good | Solid choice. May have minor gaps in one or two areas. Worth adopting with awareness of limitations. |
| 50-69 | Fair | Usable but with notable limitations. May lack active maintenance, docs, or security practices. Proceed with caution and have a fallback plan. |
| 30-49 | Poor | Significant concerns. May be abandoned, poorly documented, or have security issues. Consider alternatives seriously. |
| 0-29 | Critical | Major red flags. Likely abandoned, no docs, no security. Avoid unless you're prepared to fork and maintain it yourself. |

### Category-Level Flags

Even within an overall "Good" rating, flag individual categories that score below 50% of their maximum. For example, a project scoring 80 overall but 2/10 on Security Posture deserves a security warning.

### Contextual Adjustments

Some scoring criteria matter more in certain contexts:
- **Library you'll depend on in production**: Weight Security Posture and Technical Health more heavily
- **Tool you'll use occasionally**: Activity & Freshness matters less if it's feature-complete
- **Project you want to contribute to**: Community Health and Documentation Quality matter more
- **Academic/research code**: Ecosystem Fit expectations may be lower; Documentation and Reproducibility matter more

Note these contextual considerations in the recommendation section of the report.
