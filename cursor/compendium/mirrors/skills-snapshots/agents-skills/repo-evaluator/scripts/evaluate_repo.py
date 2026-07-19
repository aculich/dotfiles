#!/usr/bin/env python3
"""
evaluate_repo.py — Gather git-based metrics from a local repository.

Usage:
    python3 evaluate_repo.py /path/to/repo [--json]

Outputs a JSON object with raw metrics that can feed into the scoring rubric.
"""

import json
import os
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


def run_git(repo_path, *args):
    """Run a git command and return stdout, or None on failure."""
    try:
        result = subprocess.run(
            ["git", "-C", str(repo_path)] + list(args),
            capture_output=True, text=True, timeout=30
        )
        if result.returncode == 0:
            return result.stdout.strip()
        return None
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None


def get_last_commit_date(repo_path):
    """Get the date of the most recent commit."""
    out = run_git(repo_path, "log", "-1", "--format=%aI")
    return out if out else None


def get_commit_count_last_6_months(repo_path):
    """Count commits in the last 6 months."""
    out = run_git(repo_path, "rev-list", "--count", "--since=6 months ago", "HEAD")
    return int(out) if out else 0


def get_commit_frequency(repo_path):
    """Estimate commit frequency from last 6 months of data."""
    count = get_commit_count_last_6_months(repo_path)
    weeks = 26  # roughly 6 months
    per_week = count / weeks if weeks > 0 else 0

    if per_week >= 3:
        return "daily"
    elif per_week >= 1:
        return "weekly"
    elif per_week >= 0.25:
        return "monthly"
    elif per_week >= 0.04:
        return "quarterly"
    elif count > 0:
        return "rare"
    else:
        return "inactive"


def get_contributor_count(repo_path):
    """Count unique contributors."""
    out = run_git(repo_path, "shortlog", "-sn", "--all", "--no-merges")
    if out:
        return len(out.strip().split("\n"))
    return 0


def get_tags(repo_path):
    """Get list of tags (proxy for releases)."""
    out = run_git(repo_path, "tag", "--sort=-creatordate")
    if out:
        return out.strip().split("\n")
    return []


def get_release_cadence(repo_path):
    """Estimate release cadence from tags."""
    tags = get_tags(repo_path)
    if len(tags) < 2:
        return "none" if len(tags) == 0 else "rare"

    # Get dates of last 5 tags
    dates = []
    for tag in tags[:5]:
        out = run_git(repo_path, "log", "-1", "--format=%aI", tag)
        if out:
            try:
                dates.append(datetime.fromisoformat(out))
            except ValueError:
                pass

    if len(dates) < 2:
        return "rare"

    # Average days between releases
    intervals = [(dates[i] - dates[i+1]).days for i in range(len(dates)-1)]
    avg_days = sum(intervals) / len(intervals)

    if avg_days <= 35:
        return "monthly"
    elif avg_days <= 100:
        return "quarterly"
    elif avg_days <= 200:
        return "semi-annual"
    else:
        return "annual_or_less"


def check_community_files(repo_path):
    """Check for presence of community health files."""
    repo = Path(repo_path)
    files = {}

    # Check various common locations
    for name, patterns in {
        "readme": ["README.md", "README.rst", "README.txt", "README", "readme.md"],
        "license": ["LICENSE", "LICENSE.md", "LICENSE.txt", "COPYING", "license"],
        "contributing": ["CONTRIBUTING.md", "CONTRIBUTING.rst", "CONTRIBUTING",
                        ".github/CONTRIBUTING.md"],
        "code_of_conduct": ["CODE_OF_CONDUCT.md", ".github/CODE_OF_CONDUCT.md",
                           "CODE_OF_CONDUCT"],
        "security": ["SECURITY.md", ".github/SECURITY.md", "SECURITY"],
        "changelog": ["CHANGELOG.md", "CHANGES.md", "HISTORY.md", "NEWS.md",
                      "CHANGELOG", "CHANGELOG.rst"],
    }.items():
        files[name] = any((repo / p).exists() for p in patterns)

    return files


def check_ci_config(repo_path):
    """Check for CI/CD configuration files."""
    repo = Path(repo_path)
    ci_systems = {}

    checks = {
        "github_actions": [".github/workflows"],
        "travis": [".travis.yml"],
        "circle_ci": [".circleci/config.yml"],
        "gitlab_ci": [".gitlab-ci.yml"],
        "jenkins": ["Jenkinsfile"],
        "azure_pipelines": ["azure-pipelines.yml"],
    }

    for system, paths in checks.items():
        ci_systems[system] = any(
            (repo / p).exists() for p in paths
        )

    return ci_systems


def check_test_directories(repo_path):
    """Check for test directories and files."""
    repo = Path(repo_path)
    test_indicators = {
        "test_dirs": any(
            (repo / d).is_dir()
            for d in ["tests", "test", "spec", "__tests__", "testing",
                      "src/test", "src/tests"]
        ),
        "test_config": any(
            (repo / f).exists()
            for f in ["pytest.ini", "setup.cfg", "tox.ini", "jest.config.js",
                      "jest.config.ts", "vitest.config.ts", ".mocharc.yml",
                      "phpunit.xml", "karma.conf.js", "cypress.json",
                      "playwright.config.ts"]
        ),
    }
    return test_indicators


def check_code_quality_tools(repo_path):
    """Check for linting, formatting, and type checking configs."""
    repo = Path(repo_path)
    tools = {
        "linter": any(
            (repo / f).exists()
            for f in [".eslintrc", ".eslintrc.js", ".eslintrc.json", ".eslintrc.yml",
                      ".flake8", ".pylintrc", "pylintrc", ".rubocop.yml",
                      "biome.json", ".ruff.toml", "ruff.toml"]
        ),
        "formatter": any(
            (repo / f).exists()
            for f in [".prettierrc", ".prettierrc.js", ".prettierrc.json",
                      "pyproject.toml", ".editorconfig", ".clang-format",
                      ".rustfmt.toml", "stylua.toml"]
        ),
        "type_checking": any(
            (repo / f).exists()
            for f in ["tsconfig.json", "mypy.ini", ".mypy.ini", "pyrightconfig.json",
                      "py.typed"]
        ),
    }
    return tools


def check_dependency_files(repo_path):
    """Check for dependency management files."""
    repo = Path(repo_path)
    dep_files = {}

    checks = {
        "npm": ["package.json"],
        "python_pip": ["requirements.txt", "setup.py", "setup.cfg"],
        "python_poetry": ["pyproject.toml"],
        "rust": ["Cargo.toml"],
        "go": ["go.mod"],
        "ruby": ["Gemfile"],
        "java_maven": ["pom.xml"],
        "java_gradle": ["build.gradle", "build.gradle.kts"],
        "dotnet": ["*.csproj", "*.fsproj"],
        "r": ["DESCRIPTION", "renv.lock"],
    }

    for ecosystem, files in checks.items():
        dep_files[ecosystem] = any(
            (repo / f).exists() or
            (f.startswith("*") and list(repo.glob(f)))
            for f in files
        )

    # Check for lockfiles (signals dependency pinning)
    dep_files["has_lockfile"] = any(
        (repo / f).exists()
        for f in ["package-lock.json", "yarn.lock", "pnpm-lock.yaml",
                  "Pipfile.lock", "poetry.lock", "Cargo.lock", "go.sum",
                  "Gemfile.lock", "renv.lock", "uv.lock"]
    )

    # Check for dependency update tools
    dep_files["has_dependency_bot"] = any(
        (repo / f).exists()
        for f in [".github/dependabot.yml", ".github/dependabot.yaml",
                  "renovate.json", ".renovaterc", ".renovaterc.json"]
    )

    return dep_files


def get_github_remote(repo_path):
    """Try to extract a GitHub owner/repo from the remote URL."""
    out = run_git(repo_path, "remote", "get-url", "origin")
    if not out:
        return None

    # Parse github.com URLs
    import re
    patterns = [
        r"github\.com[:/]([^/]+)/([^/.]+?)(?:\.git)?$",
    ]
    for pattern in patterns:
        match = re.search(pattern, out)
        if match:
            return f"{match.group(1)}/{match.group(2)}"
    return None


def evaluate(repo_path):
    """Gather all metrics for a local repository."""
    repo = Path(repo_path).resolve()

    if not repo.exists():
        return {"error": f"Path does not exist: {repo}"}

    if not (repo / ".git").exists():
        return {"error": f"Not a git repository: {repo}"}

    metrics = {
        "repo_path": str(repo),
        "repo_name": repo.name,
        "github_remote": get_github_remote(repo),
        "evaluated_at": datetime.now(timezone.utc).isoformat(),
        "activity": {
            "last_commit_date": get_last_commit_date(repo),
            "commits_last_6_months": get_commit_count_last_6_months(repo),
            "commit_frequency": get_commit_frequency(repo),
            "tag_count": len(get_tags(repo)),
            "release_cadence": get_release_cadence(repo),
        },
        "community": {
            "contributor_count": get_contributor_count(repo),
        },
        "documentation": check_community_files(repo),
        "technical": {
            "ci": check_ci_config(repo),
            "tests": check_test_directories(repo),
            "code_quality": check_code_quality_tools(repo),
            "dependencies": check_dependency_files(repo),
        },
    }

    return metrics


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 evaluate_repo.py /path/to/repo [--json]")
        sys.exit(1)

    repo_path = sys.argv[1]
    output_json = "--json" in sys.argv

    metrics = evaluate(repo_path)

    if output_json:
        print(json.dumps(metrics, indent=2, default=str))
    else:
        # Human-readable summary
        if "error" in metrics:
            print(f"Error: {metrics['error']}")
            sys.exit(1)

        print(f"Repository: {metrics['repo_name']}")
        if metrics['github_remote']:
            print(f"GitHub: {metrics['github_remote']}")
        print(f"Evaluated: {metrics['evaluated_at']}")
        print()

        a = metrics['activity']
        print("--- Activity & Freshness ---")
        print(f"  Last commit: {a['last_commit_date']}")
        print(f"  Commits (6mo): {a['commits_last_6_months']}")
        print(f"  Frequency: {a['commit_frequency']}")
        print(f"  Tags: {a['tag_count']}")
        print(f"  Release cadence: {a['release_cadence']}")
        print()

        print("--- Community ---")
        print(f"  Contributors: {metrics['community']['contributor_count']}")
        print()

        d = metrics['documentation']
        print("--- Documentation ---")
        for key, present in d.items():
            status = "yes" if present else "NO"
            print(f"  {key}: {status}")
        print()

        t = metrics['technical']
        print("--- Technical Health ---")
        ci_active = [k for k, v in t['ci'].items() if v]
        print(f"  CI systems: {', '.join(ci_active) if ci_active else 'none detected'}")
        print(f"  Test dirs: {'yes' if t['tests']['test_dirs'] else 'no'}")
        print(f"  Test config: {'yes' if t['tests']['test_config'] else 'no'}")
        cq = t['code_quality']
        print(f"  Linter: {'yes' if cq['linter'] else 'no'}")
        print(f"  Formatter: {'yes' if cq['formatter'] else 'no'}")
        print(f"  Type checking: {'yes' if cq['type_checking'] else 'no'}")
        deps = t['dependencies']
        ecosystems = [k for k, v in deps.items()
                     if v and k not in ('has_lockfile', 'has_dependency_bot')]
        print(f"  Ecosystems: {', '.join(ecosystems) if ecosystems else 'unknown'}")
        print(f"  Lockfile: {'yes' if deps['has_lockfile'] else 'no'}")
        print(f"  Dependency bot: {'yes' if deps['has_dependency_bot'] else 'no'}")


if __name__ == "__main__":
    main()
