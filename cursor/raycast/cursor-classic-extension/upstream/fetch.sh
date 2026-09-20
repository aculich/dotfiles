#!/usr/bin/env bash
# Sync raycast/extensions issues and PRs for the Cursor / cursor-recent-projects
# lineage (labeled OR) plus a keyword recall pass. Writes JSON under ./raw/.
# Use gh api search/issues — `gh search issues` mishandles label:"extension: cursor".

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
RAW="$ROOT/raw"

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh is required" >&2
  exit 1
fi

mkdir -p "$RAW/timelines"
export PYTHONUNBUFFERED=1
python3 - "$RAW" <<'PY'
import json, os, subprocess, sys, time, urllib.parse
from datetime import datetime, timezone

raw_dir = sys.argv[1]
repo = "raycast/extensions"
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

PRODUCT_Q = '(label:"extension: cursor" OR label:"extension: cursor-recent-projects")'
SEARCHES = [
    ("labeled-issues", f"repo:{repo} {PRODUCT_Q} is:issue"),
    ("labeled-prs", f"repo:{repo} {PRODUCT_Q} is:pr"),
    ("keyword-issues-open", f"repo:{repo} cursor is:issue state:open"),
    ("keyword-prs-open", f"repo:{repo} cursor is:pr state:open"),
    ("keyword-issues-closed-recent", f"repo:{repo} cursor is:issue state:closed updated:>=2025-01-01"),
    ("keyword-prs-closed-recent", f"repo:{repo} cursor is:pr state:closed updated:>=2025-01-01"),
]


def gh_api(path: str) -> dict | list:
    for attempt in range(5):
        try:
            out = subprocess.check_output(["gh", "api", path], text=True)
            return json.loads(out)
        except subprocess.CalledProcessError as exc:
            if attempt == 4:
                raise
            time.sleep(2 ** attempt)
            last = exc
    raise last  # pragma: no cover


def search_all(q: str, cap: int = 200) -> tuple[int, list]:
    items: list = []
    page = 1
    total = 0
    while len(items) < cap:
        qs = urllib.parse.quote(q, safe="")
        data = gh_api(f"search/issues?q={qs}&per_page=100&page={page}")
        if not isinstance(data, dict):
            break
        total = int(data.get("total_count") or 0)
        batch = data.get("items") or []
        items.extend(batch)
        if len(batch) < 100 or len(items) >= total:
            break
        page += 1
        if page > 10:
            break
    return total, items[:cap]


def slim_item(it: dict) -> dict:
    labels = [lab.get("name") for lab in (it.get("labels") or [])]
    pr = it.get("pull_request") or {}
    return {
        "number": it.get("number"),
        "title": it.get("title"),
        "state": it.get("state"),
        "html_url": it.get("html_url"),
        "is_pr": bool(it.get("pull_request")),
        "draft": it.get("draft"),
        "user": (it.get("user") or {}).get("login"),
        "created_at": it.get("created_at"),
        "updated_at": it.get("updated_at"),
        "closed_at": it.get("closed_at"),
        "comments": it.get("comments"),
        "labels": labels,
        "body": (it.get("body") or "")[:2000],
        "pull_request": {"url": pr.get("url"), "merged_at": pr.get("merged_at")} if pr else None,
    }


index = {"fetched_at": now, "repo": repo, "searches": {}, "items": {}}
seen: set[int] = set()

for name, q in SEARCHES:
    print(f"search  {name}")
    total, items = search_all(q)
    slims = [slim_item(it) for it in items]
    index["searches"][name] = {"query": q, "total_count": total, "fetched": len(slims)}
    path = os.path.join(raw_dir, f"{name}.json")
    with open(path, "w") as fh:
        json.dump({"query": q, "total_count": total, "items": slims}, fh, indent=2)
        fh.write("\n")
    for slim in slims:
        n = slim["number"]
        if n is None or n in seen:
            continue
        seen.add(n)
        index["items"][str(n)] = slim

# Enrich PRs with merge state; fetch timelines for every unique number.
for key, slim in list(index["items"].items()):
    n = slim["number"]
    print(f"detail  #{n}")
    issue = gh_api(f"repos/{repo}/issues/{n}")
    if isinstance(issue, dict):
        slim["state_reason"] = issue.get("state_reason")
        slim["closed_by"] = ((issue.get("closed_by") or {}) or {}).get("login")
    if slim["is_pr"]:
        pr = gh_api(f"repos/{repo}/pulls/{n}")
        if isinstance(pr, dict):
            slim["merged"] = bool(pr.get("merged"))
            slim["merged_at"] = pr.get("merged_at")
            slim["merged_by"] = ((pr.get("merged_by") or {}) or {}).get("login")
            slim["draft"] = pr.get("draft")
    timeline = gh_api(f"repos/{repo}/issues/{n}/timeline?per_page=100")
    events = []
    if isinstance(timeline, list):
        for ev in timeline:
            events.append(
                {
                    "event": ev.get("event"),
                    "created_at": ev.get("created_at"),
                    "actor": (ev.get("actor") or {}).get("login"),
                    "state": ev.get("state"),
                    "state_reason": ev.get("state_reason"),
                    "commit_id": ev.get("commit_id"),
                    "label": (ev.get("label") or {}).get("name") if isinstance(ev.get("label"), dict) else None,
                }
            )
    slim["timeline"] = events
    tpath = os.path.join(raw_dir, "timelines", f"{n}.json")
    with open(tpath, "w") as fh:
        json.dump(events, fh, indent=2)
        fh.write("\n")

index_path = os.path.join(raw_dir, "index.json")
with open(index_path, "w") as fh:
    json.dump(index, fh, indent=2)
    fh.write("\n")

print(f"wrote {len(index['items'])} unique items -> {raw_dir}")
PY
