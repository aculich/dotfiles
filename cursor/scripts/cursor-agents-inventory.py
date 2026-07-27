#!/usr/bin/env python3
"""Read-only inventory of Cursor Composer / Agents Window chats.

Reads:
  ~/Library/Application Support/Cursor/User/globalStorage/state.vscdb
  ~/Library/Application Support/Cursor/User/workspaceStorage/*/workspace.json
  ~/.cursor/projects/*/agent-transcripts/

Optional (if CURSOR_API_KEY is set):
  GET https://api.cursor.com/v1/agents

Safety: opens Cursor SQLite with mode=ro only; never INSERT/UPDATE/DELETE.
Writes only under this repo's observability/inventories/. Prefer quitting Cursor
before trusting counts if you just archived in the UI (flush timing can lag).
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sqlite3
import sys
import urllib.error
import urllib.request
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import unquote


def pretty_path(p: str | None) -> str:
    if not p:
        return "(unknown)"
    p = unquote(p)
    if p.startswith("file://"):
        p = p[7:]
    return p


def basename(p: str) -> str:
    p = pretty_path(p)
    if p.endswith(".code-workspace"):
        return Path(p).stem
    return Path(p.rstrip("/")).name or p


def load_workspace_paths(ws_root: Path) -> dict[str, str]:
    id_to_path: dict[str, str] = {}
    if not ws_root.is_dir():
        return id_to_path
    for d in ws_root.iterdir():
        if not d.is_dir():
            continue
        wj = d / "workspace.json"
        if not wj.exists():
            continue
        try:
            meta = json.loads(wj.read_text())
        except (OSError, json.JSONDecodeError):
            continue
        folder = meta.get("folder") or meta.get("workspace")
        if folder:
            id_to_path[d.name] = folder
    return id_to_path


def count_agent_transcripts(proj_root: Path) -> list[dict]:
    rows: list[dict] = []
    if not proj_root.is_dir():
        return rows
    for d in proj_root.iterdir():
        if not d.is_dir():
            continue
        at = d / "agent-transcripts"
        if not at.exists():
            continue
        n = 0
        for child in at.iterdir():
            if child.is_dir() or child.suffix == ".jsonl":
                n += 1
        if n:
            rows.append({"project": d.name, "transcripts": n})
    rows.sort(key=lambda x: x["transcripts"], reverse=True)
    return rows


def inventory_composer(
    global_db: Path, id_to_path: dict[str, str]
) -> tuple[dict, list[dict]]:
    # Read-only URI — never open Cursor-owned DBs for write.
    uri = f"file:{global_db}?mode=ro"
    con = sqlite3.connect(uri, uri=True)
    try:
        con.execute("PRAGMA query_only=ON")
    except sqlite3.Error:
        pass
    cur = con.cursor()
    rows = cur.execute(
        "SELECT composerId, workspaceId, createdAt, lastUpdatedAt, "
        "isArchived, isSubagent, recency, value FROM composerHeaders"
    ).fetchall()

    by_ws: dict = defaultdict(
        lambda: {
            "active": 0,
            "archived": 0,
            "subagent": 0,
            "draft": 0,
            "modes": Counter(),
            "chats": [],
        }
    )
    totals: Counter = Counter()

    for (
        composer_id,
        workspace_id,
        created_at,
        last_updated_at,
        is_archived,
        is_subagent,
        recency,
        value,
    ) in rows:
        totals["headers"] += 1
        archived = bool(is_archived)
        sub = bool(is_subagent)
        name = None
        mode = None
        draft = False
        try:
            meta = json.loads(value) if value else {}
            name = meta.get("name")
            mode = meta.get("unifiedMode")
            draft = bool(meta.get("isDraft"))
            if meta.get("isArchived") is not None:
                archived = bool(meta.get("isArchived"))
        except (TypeError, json.JSONDecodeError):
            pass

        if archived:
            totals["archived"] += 1
            bucket = "archived"
        else:
            totals["active"] += 1
            bucket = "active"
        if sub:
            totals["subagent"] += 1
        if draft:
            totals["draft"] += 1

        ws = by_ws[workspace_id or "(none)"]
        ws[bucket] += 1
        if sub:
            ws["subagent"] += 1
        if draft:
            ws["draft"] += 1
        if mode:
            ws["modes"][mode] += 1
            totals[f"mode:{mode}"] += 1

        if not archived and not sub and len(ws["chats"]) < 8:
            ws["chats"].append(
                {
                    "composerId": composer_id,
                    "name": name or "(untitled)",
                    "mode": mode,
                    "createdAt": created_at,
                    "lastUpdatedAt": last_updated_at or recency,
                }
            )

    con.close()

    ws_rows: list[dict] = []
    for wid, stats in by_ws.items():
        path = id_to_path.get(wid)
        ws_rows.append(
            {
                "workspaceId": wid,
                "path": pretty_path(path) if path else None,
                "name": basename(path) if path else wid[:12],
                "active": stats["active"],
                "archived": stats["archived"],
                "subagent": stats["subagent"],
                "draft": stats["draft"],
                "total": stats["active"] + stats["archived"],
                "modes": dict(stats["modes"]),
                "sample_active_chats": stats["chats"],
            }
        )
    ws_rows.sort(key=lambda r: (r["active"], r["total"]), reverse=True)

    summary = {
        "composerHeaders_total": totals["headers"],
        "active": totals["active"],
        "archived": totals["archived"],
        "subagent": totals["subagent"],
        "draft": totals["draft"],
        "workspaces_with_chats": len(ws_rows),
        "workspaces_with_active_chats": sum(1 for r in ws_rows if r["active"] > 0),
        "modes": {
            k.replace("mode:", ""): v
            for k, v in totals.items()
            if k.startswith("mode:")
        },
    }
    return summary, ws_rows


def fetch_cloud_agents(api_key: str, limit: int = 100) -> dict:
    """Paginate Cloud Agents API (v1). Returns raw list + counts."""
    agents: list[dict] = []
    cursor = None
    while True:
        url = f"https://api.cursor.com/v1/agents?limit={limit}&includeArchived=true"
        if cursor:
            url += f"&cursor={cursor}"
        req = urllib.request.Request(
            url,
            headers={"Authorization": f"Bearer {api_key}"},
            method="GET",
        )
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                body = json.loads(resp.read().decode())
        except urllib.error.HTTPError as e:
            return {"error": f"HTTP {e.code}: {e.read().decode()[:500]}", "agents": []}
        except urllib.error.URLError as e:
            return {"error": str(e), "agents": []}

        batch = body.get("agents") or body.get("items") or []
        agents.extend(batch)
        cursor = body.get("nextCursor")
        if not cursor or not batch:
            break

    status_counts: Counter = Counter()
    for a in agents:
        status_counts[str(a.get("status") or a.get("agentStatus") or "unknown")] += 1
    return {
        "count": len(agents),
        "by_status": dict(status_counts),
        "agents": agents,
    }


def write_markdown(
    out: Path,
    generated_at: str,
    summary: dict,
    ws_rows: list[dict],
    transcript_counts: list[dict],
    cloud: dict | None,
) -> None:
    md: list[str] = []
    md.append(f"# Agents Window / Composer inventory — {out.name.replace('agents-window-', '')}")
    md.append("")
    md.append(
        f"Generated: `{generated_at}` (read-only from `globalStorage/state.vscdb` "
        "+ `workspaceStorage/*/workspace.json`)."
    )
    md.append("")
    md.append("## Totals")
    md.append("")
    md.append("| Metric | Count |")
    md.append("| --- | ---: |")
    md.append(f"| Composer headers | {summary['composerHeaders_total']} |")
    md.append(f"| Active (not archived) | {summary['active']} |")
    md.append(f"| Archived | {summary['archived']} |")
    md.append(f"| Subagent | {summary['subagent']} |")
    md.append(f"| Draft | {summary['draft']} |")
    md.append(f"| Workspaces with any chats | {summary['workspaces_with_chats']} |")
    md.append(
        f"| Workspaces with **active** chats | {summary['workspaces_with_active_chats']} |"
    )
    md.append(
        f"| `~/.cursor/projects` with agent-transcripts | "
        f"{len(transcript_counts)} ({sum(t['transcripts'] for t in transcript_counts)} transcripts) |"
    )
    if cloud is None:
        md.append("| Cloud Agents API | skipped (`CURSOR_API_KEY` unset) |")
    elif cloud.get("error"):
        md.append(f"| Cloud Agents API | error: `{cloud['error'][:80]}` |")
    else:
        md.append(f"| Cloud Agents API | {cloud.get('count', 0)} agents |")
    md.append("")
    md.append("### Modes (from headers)")
    md.append("")
    for k, v in sorted(summary["modes"].items(), key=lambda x: -x[1]):
        md.append(f"- `{k}`: {v}")
    md.append("")
    md.append("## Workspaces with active chats (Archive All checklist)")
    md.append("")
    md.append(
        "Use Agents Window → workspace context menu → **Archive All**. Sorted by active count."
    )
    md.append("")
    md.append("| Active | Archived | Name | Path |")
    md.append("| ---: | ---: | --- | --- |")
    for r in ws_rows:
        if r["active"] <= 0:
            continue
        path = (r["path"] or "").replace("|", "\\|")
        md.append(f"| {r['active']} | {r['archived']} | `{r['name']}` | `{path}` |")
    md.append("")
    md.append("## Top workspaces by total chats (incl. already archived)")
    md.append("")
    md.append("| Total | Active | Archived | Name |")
    md.append("| ---: | ---: | ---: | --- |")
    for r in sorted(ws_rows, key=lambda x: x["total"], reverse=True)[:40]:
        md.append(f"| {r['total']} | {r['active']} | {r['archived']} | `{r['name']}` |")
    md.append("")
    md.append("## Files in this snapshot")
    md.append("")
    md.append("| File | Purpose |")
    md.append("| --- | --- |")
    md.append("| `summary-chats.json` | Counts |")
    md.append("| `chats-by-workspace.json` | Full per-workspace breakdown + sample titles |")
    md.append("| `chats-by-workspace.csv` | Spreadsheet-friendly checklist |")
    md.append("| `agent-transcripts.json` | Local agent-transcript folder counts |")
    md.append("| `cloud-agents.json` | Cloud Agents API dump (if key set) |")
    md.append("")
    (out / "README.md").write_text("\n".join(md) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=None,
        help="Output directory (default: observability/inventories/agents-window-YYYY-MM-DD)",
    )
    parser.add_argument(
        "--user-data",
        type=Path,
        default=Path.home()
        / "Library/Application Support/Cursor/User",
        help="Cursor User data directory",
    )
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    stamp = datetime.now().strftime("%Y-%m-%d")
    out = args.out_dir or (
        repo_root / "observability" / "inventories" / f"agents-window-{stamp}"
    )
    out.mkdir(parents=True, exist_ok=True)

    global_db = args.user_data / "globalStorage" / "state.vscdb"
    ws_root = args.user_data / "workspaceStorage"
    proj_root = Path.home() / ".cursor" / "projects"

    if not global_db.exists():
        print(f"Missing DB: {global_db}", file=sys.stderr)
        return 1

    generated_at = datetime.now(timezone.utc).isoformat()
    id_to_path = load_workspace_paths(ws_root)
    chat_summary, ws_rows = inventory_composer(global_db, id_to_path)
    transcript_counts = count_agent_transcripts(proj_root)

    api_key = os.environ.get("CURSOR_API_KEY", "").strip()
    cloud: dict | None = None
    if api_key:
        cloud = fetch_cloud_agents(api_key)
        (out / "cloud-agents.json").write_text(json.dumps(cloud, indent=2))

    summary = {
        "generated_at": generated_at,
        "source": str(global_db),
        **chat_summary,
        "workspaceStorage_mapped_paths": len(id_to_path),
        "agent_transcript_projects": len(transcript_counts),
        "agent_transcripts_total": sum(t["transcripts"] for t in transcript_counts),
        "cloud_agents_api": (
            "skipped (CURSOR_API_KEY unset)"
            if cloud is None
            else cloud.get("error") or f"{cloud.get('count', 0)} agents"
        ),
        "note": (
            "isArchived reflects Composer/Agents chat archive flag in globalStorage. "
            "Agents Window sidebar Remove-from-Sidebar UI state is not fully mirrored here."
        ),
    }

    (out / "summary-chats.json").write_text(json.dumps(summary, indent=2))
    (out / "chats-by-workspace.json").write_text(json.dumps(ws_rows, indent=2))
    (out / "agent-transcripts.json").write_text(json.dumps(transcript_counts, indent=2))

    with (out / "chats-by-workspace.csv").open("w", newline="") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "name",
                "active",
                "archived",
                "total",
                "subagent",
                "draft",
                "path",
                "workspaceId",
            ]
        )
        for r in ws_rows:
            w.writerow(
                [
                    r["name"],
                    r["active"],
                    r["archived"],
                    r["total"],
                    r["subagent"],
                    r["draft"],
                    r["path"] or "",
                    r["workspaceId"],
                ]
            )

    write_markdown(out, generated_at, summary, ws_rows, transcript_counts, cloud)
    print(f"Wrote {out}")
    print(
        f"active chats={summary['active']} archived={summary['archived']} "
        f"workspaces_with_active={summary['workspaces_with_active_chats']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
