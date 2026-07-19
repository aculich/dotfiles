# CHAOSS & OpenSSF Scorecard Mapping

This document maps our rubric categories to established open source health frameworks,
showing where our metrics align and where we've simplified or extended them.

## CHAOSS Metrics Alignment

[CHAOSS](https://chaoss.community/) (Community Health Analytics in Open Source Software)
is a Linux Foundation project that defines implementation-agnostic metrics for open source health.

| Our Category | CHAOSS Metric Area | CHAOSS Metrics Used |
|-------------|-------------------|-------------------|
| Activity & Freshness | Code Development Activity | Technical Fork, Code Changes, Code Changes Lines |
| Activity & Freshness | Code Development Efficiency | Change Request Closure Ratio, Change Request Duration |
| Community Health | Community Growth | Contributors, New Contributors |
| Community Health | Community Engagement | Issue Response Time, Issue Resolution Duration |
| Documentation Quality | Community Documentation | Documentation Usability |
| Technical Health | Code Quality | Test Coverage (via CI), Code Review Ratio |
| Security Posture | Risk | Bus Factor, Elephant Factor |

### What We Simplified

CHAOSS defines 100+ metrics. Our rubric collapses these into 6 scorable categories because:
- Many CHAOSS metrics require deep data collection (mailing lists, Slack, Discourse)
- Our tool needs to work from GitHub API + local git data alone
- The goal is a quick health check, not a full analytics platform

### What We Added Beyond CHAOSS

- **Security Posture** as a standalone category (CHAOSS treats this within Risk)
- **Ecosystem Fit** (package manager presence, integration ease) — practical adoption concerns
- **Rating bands** (Excellent/Good/Fair/Poor/Critical) — CHAOSS doesn't prescribe scoring

## OpenSSF Scorecard Alignment

[OpenSSF Scorecard](https://scorecard.dev/) runs 18 automated security checks on GitHub repos.

| Our Sub-metric | OpenSSF Check(s) | Notes |
|----------------|-------------------|-------|
| Security Policy | Security-Policy | Checks for SECURITY.md |
| Dependency Scanning | Vulnerabilities, Dependency-Update-Tool | Checks Dependabot/Renovate |
| Branch Protection | Branch-Protection, Code-Review | Checks required reviews, protections |
| CI/CD | CI-Tests, Fuzzing, SAST | We check CI broadly; OSSF checks specific types |
| Signed Releases | Signed-Releases | We note this but don't score separately |

### Using OpenSSF Scorecard Data

If you can run `scorecard` or check `scorecard.dev` for a repo, use those scores as
authoritative inputs for the Security Posture category. The OpenSSF scores (0-10 per check)
can be normalized into our 0-10 Security Posture points:

```
our_security_score = round(avg(ossf_security_policy, ossf_vulnerabilities,
                                ossf_branch_protection, ossf_code_review) * 10 / 10)
```

## GitHub OSPO Health Metrics

[GitHub OSPO](https://github.com/github/github-ospo) tracks:

| GitHub OSPO Metric | Our Category | How We Use It |
|-------------------|-------------|---------------|
| Open/closed issue counts | Community Health > Issue Responsiveness | Close ratio as health signal |
| PR merge vs close-without-merge | Community Health | High close-without-merge = spam/low quality signal |
| Last activity date | Activity & Freshness | Direct input to Last Commit scoring |
| Community profile (license, CoC, contributing) | Documentation Quality + Security | Direct checks |

## Amsterdam Open Source Health Guide

The City of Amsterdam grades projects on a scale for open source health. Their approach
is similar to ours: they check for documentation, activity, community standards, and
code quality. We share the same spirit of making health visible and actionable.

## Data Source Priority

When multiple data sources are available, prefer:
1. **Local git data** — most accurate for activity metrics
2. **GitHub API** — authoritative for community metrics
3. **OpenSSF Scorecard** — authoritative for security metrics
4. **Repomix output** — supplementary for code structure assessment
5. **Manual inspection** — fill gaps with qualitative assessment
