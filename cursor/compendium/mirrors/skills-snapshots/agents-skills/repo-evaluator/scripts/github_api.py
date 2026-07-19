#!/usr/bin/env python3
"""
github_api.py — Fetch GitHub API data for a repository.

Usage:
    python3 github_api.py owner/repo [--json]

Requires: `gh` CLI tool (authenticated)

Outputs metrics that complement the local git-based evaluation.
"""

import json
import subprocess
import sys


def gh_api(endpoint):
    """Call the GitHub API via `gh` CLI and return parsed JSON."""
    try:
        result = subprocess.run(
            ["gh", "api", endpoint, "--jq", "."],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode == 0:
            return json.loads(result.stdout)
        return None
    except (subprocess.TimeoutExpired, FileNotFoundError, json.JSONDecodeError):
        return None


def gh_api_raw(endpoint):
    """Call the GitHub API and return raw text."""
    try:
        result = subprocess.run(
            ["gh", "api", endpoint],
            capture_output=True, text=True, timeout=30
        )
        if result.returncode == 0:
            return result.stdout.strip()
        return None
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None


def fetch_repo_data(owner_repo):
    """Fetch comprehensive repo data from GitHub API."""
    repo = gh_api(f"repos/{owner_repo}")
    if not repo:
        return {"error": f"Could not fetch repo data for {owner_repo}"}

    # Basic repo info
    data = {
        "name": repo.get("full_name"),
        "description": repo.get("description"),
        "url": repo.get("html_url"),
        "homepage": repo.get("homepage"),
        "primary_language": repo.get("language"),
        "license": repo.get("license", {}).get("spdx_id") if repo.get("license") else None,
        "created_at": repo.get("created_at"),
        "updated_at": repo.get("updated_at"),
        "pushed_at": repo.get("pushed_at"),
        "default_branch": repo.get("default_branch"),
        "archived": repo.get("archived", False),
        "disabled": repo.get("disabled", False),
        "fork": repo.get("fork", False),
    }

    # Community metrics
    data["community"] = {
        "stars": repo.get("stargazers_count", 0),
        "forks": repo.get("forks_count", 0),
        "watchers": repo.get("subscribers_count", 0),
        "open_issues": repo.get("open_issues_count", 0),
    }

    # Contributors count
    contributors = gh_api(f"repos/{owner_repo}/contributors?per_page=1&anon=true")
    if contributors:
        # The API doesn't give total count directly; we check the Link header
        # For simplicity, fetch up to 100
        all_contribs = gh_api(f"repos/{owner_repo}/contributors?per_page=100&anon=true")
        data["community"]["contributor_count"] = len(all_contribs) if all_contribs else 0
    else:
        data["community"]["contributor_count"] = 0

    # Recent releases
    releases = gh_api(f"repos/{owner_repo}/releases?per_page=5")
    if releases and isinstance(releases, list):
        data["releases"] = [{
            "tag": r.get("tag_name"),
            "name": r.get("name"),
            "published_at": r.get("published_at"),
            "prerelease": r.get("prerelease", False),
        } for r in releases[:5]]
    else:
        data["releases"] = []

    # Community health profile
    community = gh_api(f"repos/{owner_repo}/community/profile")
    if community:
        data["community_profile"] = {
            "health_percentage": community.get("health_percentage", 0),
            "has_description": community.get("description") is not None,
            "has_documentation": community.get("documentation") is not None,
            "has_code_of_conduct": community.get("files", {}).get("code_of_conduct") is not None,
            "has_contributing": community.get("files", {}).get("contributing") is not None,
            "has_license": community.get("files", {}).get("license") is not None,
            "has_readme": community.get("files", {}).get("readme") is not None,
            "has_issue_template": community.get("files", {}).get("issue_template") is not None,
            "has_pull_request_template": community.get("files", {}).get("pull_request_template") is not None,
        }
    else:
        data["community_profile"] = None

    # Topics / tags
    data["topics"] = repo.get("topics", [])

    return data


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 github_api.py owner/repo [--json]")
        print("Requires: gh CLI tool (authenticated)")
        sys.exit(1)

    owner_repo = sys.argv[1]
    output_json = "--json" in sys.argv

    data = fetch_repo_data(owner_repo)

    if output_json:
        print(json.dumps(data, indent=2, default=str))
    else:
        if "error" in data:
            print(f"Error: {data['error']}")
            sys.exit(1)

        print(f"Repository: {data['name']}")
        print(f"Description: {data.get('description', 'N/A')}")
        print(f"URL: {data['url']}")
        print(f"Language: {data.get('primary_language', 'N/A')}")
        print(f"License: {data.get('license', 'N/A')}")
        print(f"Archived: {data.get('archived', False)}")
        print()

        c = data['community']
        print("--- Community ---")
        print(f"  Stars: {c['stars']}")
        print(f"  Forks: {c['forks']}")
        print(f"  Watchers: {c['watchers']}")
        print(f"  Open issues: {c['open_issues']}")
        print(f"  Contributors: {c['contributor_count']}")
        print()

        print(f"--- Releases ({len(data['releases'])}) ---")
        for r in data['releases'][:3]:
            print(f"  {r['tag']}: {r['published_at']}")
        print()

        cp = data.get('community_profile')
        if cp:
            print(f"--- Community Health: {cp['health_percentage']}% ---")
            for key, val in cp.items():
                if key != 'health_percentage':
                    print(f"  {key}: {'yes' if val else 'no'}")


if __name__ == "__main__":
    main()
