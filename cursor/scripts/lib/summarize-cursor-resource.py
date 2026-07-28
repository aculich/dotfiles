#!/usr/bin/env python3
"""Summarize a Cursor + macOS resource snapshot directory.

Reads artifacts written by cursor-resource-snapshot.sh and produces:
  extension-hosts.json, system.json (enriched), hotspots.md, report.md, summary.json
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
from datetime import datetime, timezone
from pathlib import Path

HOST_RE = re.compile(
    r"extension-host\s*\((?P<kind>[^)]+)\)\s+(?P<name>.+?)\s*\[(?P<wid>[^\]]+)\]",
    re.IGNORECASE,
)
HOT_THRESHOLD = 50.0
SAMPLE_THRESHOLD = 80.0


def parse_ps_line(line: str) -> dict | None:
    line = line.rstrip("\n")
    if not line.strip():
        return None
    parts = line.split(None, 3)
    if len(parts) < 4:
        return None
    try:
        cpu = float(parts[0])
        rss_kb = float(parts[1])
        pid = int(parts[2])
    except ValueError:
        return None
    args = parts[3]
    return {
        "cpu_pct": cpu,
        "rss_mb": round(rss_kb / 1024.0, 1),
        "pid": pid,
        "args": args,
    }


def parse_extension_host(row: dict) -> dict | None:
    args = row["args"]
    if "extension-host" not in args.lower():
        return None
    m = HOST_RE.search(args)
    if m:
        name = m.group("name").strip()
        kind = m.group("kind").strip()
        wid = m.group("wid").strip()
    else:
        name = "(unknown)"
        kind = "unknown"
        wid = ""
        # fallback: take substring after extension-host
        idx = args.lower().find("extension-host")
        if idx >= 0:
            rest = args[idx:]
            name = rest[:120]
    return {
        "pid": row["pid"],
        "cpu_pct": row["cpu_pct"],
        "rss_mb": row["rss_mb"],
        "kind": kind,
        "workspace": name,
        "workspace_id": wid,
        "args": args,
    }


def parse_memory_pressure(text: str) -> dict:
    out: dict = {"raw_preview": "\n".join(text.splitlines()[:40])}
    # Pages free: N
    for key, pat in [
        ("pages_free", r"Pages free:\s*([\d.]+)"),
        ("pages_purgeable", r"Pages purgeable:\s*([\d.]+)"),
        ("pages_purged", r"Pages purged:\s*([\d.]+)"),
        ("pages_active", r"Pages active:\s*([\d.]+)"),
        ("pages_inactive", r"Pages inactive:\s*([\d.]+)"),
        ("pages_speculative", r"Pages speculative:\s*([\d.]+)"),
        ("pages_wired", r"Pages wired[^\d]*([\d.]+)"),
        ("swapins", r"Swapins:\s*([\d.]+)"),
        ("swapouts", r"Swapouts:\s*([\d.]+)"),
    ]:
        m = re.search(pat, text, re.I)
        if m:
            out[key] = float(m.group(1))
    # Total pages line
    m = re.search(r"(\d+)\s+\((\d+)\s+pages", text)
    if m:
        out["bytes_physical"] = int(m.group(1))
        out["pages_total"] = int(m.group(2))
    # Heuristic pressure: free pages very low vs total
    free = out.get("pages_free")
    total = out.get("pages_total")
    if free is not None and total:
        out["free_pct_of_pages"] = round(100.0 * free / total, 3)
        if free / total < 0.005:
            out["pressure_hint"] = "low_free_pages"
        else:
            out["pressure_hint"] = "ok"
    swapouts = out.get("swapouts") or 0
    if swapouts and swapouts > 0:
        out["pressure_hint"] = "swap_activity"
    return out


def loadavg() -> list[float]:
    try:
        return [round(x, 2) for x in os.getloadavg()]
    except OSError:
        return []


def swapusage() -> dict:
    try:
        out = subprocess.check_output(["sysctl", "vm.swapusage"], text=True, timeout=5)
    except (subprocess.SubprocessError, FileNotFoundError):
        return {}
    used_m = re.search(r"used = ([\d.]+)M", out)
    total_m = re.search(r"total = ([\d.]+)M", out)
    return {
        "swap_used_mb": float(used_m.group(1)) if used_m else None,
        "swap_total_mb": float(total_m.group(1)) if total_m else None,
        "raw": out.strip(),
    }


def write_hotspots(path: Path, hosts: list[dict], hot: list[dict]) -> None:
    lines = [
        "# Extension-host hotspots",
        "",
        f"Threshold: CPU ≥ {HOT_THRESHOLD:g}%",
        f"Hot hosts now: **{len(hot)}** (of {len(hosts)} extension-host processes)",
        "",
    ]
    if len(hot) >= 2:
        lines.append(
            f"**Simultaneous drivers:** {len(hot)} extension-hosts are hot at once — "
            "this is a multi-window tax, not a single misbehaving window."
        )
        lines.append("")
    lines.extend(
        [
            "| CPU % | RSS MB | PID | Kind | Workspace |",
            "|---:|---:|---:|---|---|",
        ]
    )
    for h in hot[:25]:
        lines.append(
            f"| {h['cpu_pct']:.1f} | {h['rss_mb']:.1f} | {h['pid']} | "
            f"`{h['kind']}` | `{h['workspace']}` |"
        )
    if not hot:
        lines.append("| — | — | — | — | (none above threshold) |")
    lines.append("")
    path.write_text("\n".join(lines) + "\n")


def write_report(
    path: Path,
    *,
    generated_at: str,
    out_dir: Path,
    hosts: list[dict],
    hot: list[dict],
    system: dict,
    samples: list[str],
) -> None:
    swap = system.get("swap") or {}
    mem = system.get("memory_pressure") or {}
    lines = [
        f"# Cursor resource snapshot — {out_dir.name}",
        "",
        f"Generated: `{generated_at}`",
        "",
        "## Summary",
        "",
        f"- Extension-host processes: **{len(hosts)}**",
        f"- Hot (≥{HOT_THRESHOLD:g}% CPU): **{len(hot)}**",
        f"- Load average: `{system.get('loadavg')}`",
        f"- Swap used MB: `{swap.get('swap_used_mb')}` / `{swap.get('swap_total_mb')}`",
        f"- Memory pressure hint: `{mem.get('pressure_hint', 'unknown')}`",
        "",
        "## Top extension-hosts by CPU",
        "",
        "| CPU % | RSS MB | PID | Kind | Workspace |",
        "|---:|---:|---:|---|---|",
    ]
    for h in hosts[:20]:
        lines.append(
            f"| {h['cpu_pct']:.1f} | {h['rss_mb']:.1f} | {h['pid']} | "
            f"`{h['kind']}` | `{h['workspace']}` |"
        )
    lines.extend(["", "## Mitigation strategies (diagnose-first)", ""])
    lines.extend(
        [
            "Primary goal: keep many Cursor windows, understand idle background CPU, reduce tax — "
            "**not** “close windows” as the first answer.",
            "",
            "1. **Name the hot workspaces** — use the table above; those extension-hosts are the simultaneous drivers.",
            "2. **Cut per-window extension tax** — `scripts/apply-cursor-resource-tuning.sh` "
            "(snapshot then apply; try `--dry-run` / keep manifests under `config/`).",
            "3. **MCP when idle** — `scripts/toggle-global-mcp.sh status|disable|enable`.",
            "4. **Huge trees** — `scripts/cursor-purification.sh` watcher/index excludes.",
            "5. **Deeper stack** — `sample <pid> 1` (samples/ may already contain top hot PIDs).",
            "6. **Interactive glance** — installed `btop`; optional `brew install macmon` for Apple Silicon power "
            "(see `~/tools/macosx-tools/research/macos-system-info/CLI-RESOURCE-TOOLS.md`).",
            "",
            "Do **not** confuse VoiceInk Debug tools / WindowServer resize logs with Cursor extension-host CPU.",
            "",
        ]
    )
    if samples:
        lines.append("## Samples captured")
        lines.append("")
        for s in samples:
            lines.append(f"- `{s}`")
        lines.append("")
    lines.extend(
        [
            "## Files",
            "",
            "| File | Purpose |",
            "| --- | --- |",
            "| `ps-cursor.txt` | Raw ps of Cursor/Electron |",
            "| `extension-hosts.json` | Parsed hosts |",
            "| `system.json` | memory_pressure + load/swap |",
            "| `hotspots.md` | Hot hosts table |",
            "| `summary.json` | Machine-readable rollup |",
            "| `samples/` | Optional `sample` output |",
            "",
        ]
    )
    path.write_text("\n".join(lines) + "\n")


def maybe_sample(hosts: list[dict], samples_dir: Path) -> list[str]:
    hot = [h for h in hosts if h["cpu_pct"] >= SAMPLE_THRESHOLD]
    if not hot:
        return []
    samples_dir.mkdir(parents=True, exist_ok=True)
    written: list[str] = []
    for h in hot[:3]:
        out = samples_dir / f"sample-{h['pid']}.txt"
        try:
            proc = subprocess.run(
                ["sample", str(h["pid"]), "1"],
                capture_output=True,
                text=True,
                timeout=15,
            )
            text = proc.stdout or proc.stderr or ""
            if not text.strip():
                continue
            # Keep preview — full sample can be large
            out.write_text(text[:200_000])
            written.append(out.name)
        except (subprocess.SubprocessError, FileNotFoundError, OSError):
            continue
    return written


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("out_dir", type=Path, help="Snapshot directory with ps-cursor.txt etc.")
    ap.add_argument("--no-sample", action="store_true", help="Skip sample(1) on hot PIDs")
    args = ap.parse_args()
    out_dir: Path = args.out_dir
    ps_path = out_dir / "ps-cursor.txt"
    mp_path = out_dir / "memory_pressure.txt"

    rows: list[dict] = []
    if ps_path.exists():
        for line in ps_path.read_text(errors="replace").splitlines():
            r = parse_ps_line(line)
            if r:
                rows.append(r)

    hosts: list[dict] = []
    for r in rows:
        h = parse_extension_host(r)
        if h:
            hosts.append(h)
    hosts.sort(key=lambda x: x["cpu_pct"], reverse=True)
    (out_dir / "extension-hosts.json").write_text(json.dumps(hosts, indent=2) + "\n")

    mp_text = mp_path.read_text(errors="replace") if mp_path.exists() else ""
    system = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "loadavg": loadavg(),
        "swap": swapusage(),
        "memory_pressure": parse_memory_pressure(mp_text),
        "cursor_process_rows": len(rows),
        "extension_host_count": len(hosts),
    }
    (out_dir / "system.json").write_text(json.dumps(system, indent=2) + "\n")

    hot = [h for h in hosts if h["cpu_pct"] >= HOT_THRESHOLD]
    write_hotspots(out_dir / "hotspots.md", hosts, hot)

    samples: list[str] = []
    if not args.no_sample:
        samples = maybe_sample(hosts, out_dir / "samples")

    generated_at = system["generated_at"]
    write_report(
        out_dir / "report.md",
        generated_at=generated_at,
        out_dir=out_dir,
        hosts=hosts,
        hot=hot,
        system=system,
        samples=samples,
    )

    summary = {
        "generated_at": generated_at,
        "out_dir": str(out_dir),
        "extension_host_count": len(hosts),
        "hot_count": len(hot),
        "hot_threshold_cpu": HOT_THRESHOLD,
        "simultaneous_hot": len(hot) >= 2,
        "top_hosts": [
            {
                "workspace": h["workspace"],
                "kind": h["kind"],
                "cpu_pct": h["cpu_pct"],
                "rss_mb": h["rss_mb"],
                "pid": h["pid"],
            }
            for h in hosts[:12]
        ],
        "loadavg": system["loadavg"],
        "swap_used_mb": (system.get("swap") or {}).get("swap_used_mb"),
        "pressure_hint": (system.get("memory_pressure") or {}).get("pressure_hint"),
        "samples": samples,
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")

    print(f"Wrote {out_dir}/report.md")
    print(
        f"extension_hosts={len(hosts)} hot={len(hot)} "
        f"simultaneous_hot={len(hot) >= 2} pressure={summary.get('pressure_hint')}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
