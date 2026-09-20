#!/usr/bin/env bash
# List cursor-related labels on raycast/extensions and open OR/keyword searches.
# GitHub's label picker ANDs selections; this product needs OR (cursor +
# cursor-recent-projects). gh search issues mishandles the space in
# label:"extension: cursor" — use encoded URLs / gh api instead.

set -euo pipefail

REPO="raycast/extensions"
BASE="https://github.com/${REPO}"

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh is required" >&2
  exit 1
fi

python3 - "$REPO" "$BASE" "$@" <<'PY'
import json, subprocess, sys, urllib.parse

repo, base = sys.argv[1], sys.argv[2]
raw = subprocess.check_output(
    ["gh", "label", "list", "--repo", repo, "--limit", "200", "--search", "cursor", "--json", "name,description"],
    text=True,
)
labels = json.loads(raw)
print("cursor-related labels on %s:" % repo)
for lab in labels:
    print("  - %s" % lab["name"])
    if lab.get("description"):
        print("      %s" % lab["description"])
print()

product = [
    'label:"extension: cursor"',
    'label:"extension: cursor-recent-projects"',
]
siblings = [
    'label:"extension: cursor-directory"',
    'label:"extension: cursor-agents"',
    'label:"extension: cursor-costs"',
    'label:"extension: open-in-cursor"',
    'label:"extension: cursors"',
    'label:"extension: where-is-my-cursor"',
]
or_product = " OR ".join(product)
minus_siblings = " ".join("-" + s for s in siblings)

queries = [
    ("labeled issues (open)", f"{or_product} is:issue state:open", "issues"),
    ("labeled issues (all states)", f"{or_product} is:issue", "issues"),
    ("labeled PRs (open)", f"{or_product} is:pr state:open", "pulls"),
    ("labeled PRs (all states)", f"{or_product} is:pr", "pulls"),
    ("keyword issues (open)", "cursor is:issue state:open", "issues"),
    ("keyword issues (all)", "cursor is:issue", "issues"),
    ("keyword PRs (open)", "cursor is:pr state:open", "pulls"),
    ("keyword PRs (all)", "cursor is:pr", "pulls"),
    (
        "keyword minus sibling extensions (open issues)",
        f"( {or_product} OR cursor ) is:issue state:open {minus_siblings}",
        "issues",
    ),
]

urls = []
print("search URLs:")
for title, q, kind in queries:
    url = f"{base}/{kind}?q={urllib.parse.quote(q, safe='')}"
    urls.append(url)
    print("  %s" % title)
    print("    %s" % q)
    print("    %s" % url)
    print()

open_now = "--print-only" not in sys.argv
if open_now:
    for url in urls:
        subprocess.run(["open", url], check=False)
PY
