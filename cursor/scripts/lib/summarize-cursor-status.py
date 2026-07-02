#!/usr/bin/env python3
"""Parse cursor -s output and optional Process Explorer JSONL into a markdown report."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable


@dataclass
class ProcessRow:
    cpu_pct: float
    mem_mb: float
    pid: int
    name: str
    raw: str


DUP_PATTERNS: dict[str, str] = {
    "snyk mcp": r"snyk.*mcp|snyk-macos",
    "repomix --mcp": r"repomix.*--mcp",
    "zoom-mcp-server": r"zoom-mcp-server",
    "cursorpyright": r"cursorpyright",
    "code-spell-checker": r"code-spell-checker",
    "eslint": r"eslintServer|vscode-eslint",
    "tailwind LSP": r"tailwindServer",
}


def parse_header(lines: list[str]) -> dict[str, str]:
    out: dict[str, str] = {}
    for line in lines:
        if line.startswith("Version:"):
            out["version"] = line.split("Version:", 1)[1].strip()
        elif line.startswith("Memory (System):"):
            out["memory"] = line.split("Memory (System):", 1)[1].strip()
        elif line.startswith("Load (avg):"):
            out["load"] = line.split("Load (avg):", 1)[1].strip()
        elif line.startswith("OS Version:"):
            out["os"] = line.split("OS Version:", 1)[1].strip()
    return out


def parse_process_table(text: str) -> list[ProcessRow]:
    rows: list[ProcessRow] = []
    in_table = False
    for line in text.splitlines():
        if line.startswith("CPU %\tMem MB"):
            in_table = True
            continue
        if not in_table:
            continue
        if line.startswith("Workspace Stats:"):
            break
        if not line.strip():
            continue
        parts = line.split("\t", 3)
        if len(parts) < 4:
            continue
        try:
            cpu = float(parts[0].strip())
            mem = float(parts[1].strip())
            pid = int(parts[2].strip())
        except ValueError:
            continue
        name = parts[3].strip()
        rows.append(ProcessRow(cpu, mem, pid, name, line))
    return rows


def parse_workspace_stats(text: str) -> list[str]:
    if "Workspace Stats:" not in text:
        return []
    block = text.split("Workspace Stats:", 1)[1]
    return [ln.strip() for ln in block.splitlines() if ln.strip()]


def macos_memory_pressure() -> tuple[float | None, float | None]:
    """Return (swap_used_mb, swap_total_mb) from sysctl, or (None, None)."""
    try:
        out = subprocess.check_output(["sysctl", "vm.swapusage"], text=True, timeout=5)
    except (subprocess.SubprocessError, FileNotFoundError):
        return None, None
    # vm.swapusage: total = 2048.00M  used = 512.00M  free = 1536.00M
    used_m = re.search(r"used = ([\d.]+)M", out)
    total_m = re.search(r"total = ([\d.]+)M", out)
    if not used_m:
        return None, None
    used = float(used_m.group(1))
    total = float(total_m.group(1)) if total_m else None
    return used, total


def classify_row(row: ProcessRow) -> str:
    n = row.name
    if n == "cursor main" or re.match(r"^\s*cursor main", n):
        return "main"
    if "gpu-process" in n:
        return "gpu"
    if re.search(r"window \[\d+\]", n):
        return "window"
    if "fileWatcher" in n:
        return "fileWatcher"
    if "extensionHost" in n or "extension-host" in n.lower():
        return "extensionHost"
    if "ptyHost" in n or "/bin/zsh" in n:
        return "terminal"
    if "shared-process" in n:
        return "shared"
    return "other"


def count_dup_subprocesses(rows: list[ProcessRow]) -> dict[str, int]:
    counts: dict[str, int] = {}
    blob = "\n".join(r.raw for r in rows)
    for label, pattern in DUP_PATTERNS.items():
        counts[label] = len(re.findall(pattern, blob, re.I))
    return counts


def flag_large_folders(stats_lines: Iterable[str], threshold: int = 50_000) -> list[str]:
    flagged: list[str] = []
    for line in stats_lines:
        if "more than" in line.lower():
            flagged.append(line)
            continue
        m = re.search(r":\s*(\d+)\s+files", line)
        if m and int(m.group(1)) >= threshold:
            flagged.append(line)
    return flagged


def action_hints(
    header: dict[str, str],
    rows: list[ProcessRow],
    dup_counts: dict[str, int],
    large_folders: list[str],
    swap_used_mb: float | None,
    swap_total_mb: float | None,
) -> list[str]:
    hints: list[str] = []
    mem = header.get("memory", "")
    free_m = re.search(r"\(([\d.]+)GB free\)", mem)
    if free_m and float(free_m.group(1)) < 2.0:
        hints.append(
            f"Low free RAM ({free_m.group(1)} GB). Close unused Cursor windows or quit other apps."
        )
    if swap_used_mb is not None and swap_used_mb > 1024:
        total_note = f" / {swap_total_mb:.0f} MB" if swap_total_mb else ""
        hints.append(
            f"Swap in use: ~{swap_used_mb:.0f} MB{total_note}. Memory overcommit likely."
        )
    windows = [r for r in rows if classify_row(r) == "window"]
    if len(windows) > 12:
        hints.append(
            f"{len(windows)} renderer windows open. Each window costs ~400MB–1GB+."
        )
    hosts = [r for r in rows if classify_row(r) == "extensionHost"]
    if len(hosts) > 20:
        hints.append(
            f"{len(hosts)} extension-host processes. Consider fewer workspace roots or "
            "`scripts/apply-cursor-resource-tuning.sh apply` after snapshot."
        )
    for label, count in sorted(dup_counts.items(), key=lambda x: -x[1]):
        if count > 3:
            hints.append(
                f"Duplicate `{label}` subprocesses: {count}. Often one copy per workspace host."
            )
    if large_folders:
        hints.append(
            "Large indexed/watched folders detected. Add `.cursorindexingignore` and "
            "`files.watcherExclude` per repo (see docs/IGNORING.md)."
        )
    top_cpu = sorted(rows, key=lambda r: r.cpu_pct, reverse=True)[:3]
    for r in top_cpu:
        if r.cpu_pct >= 15 and classify_row(r) in ("window", "gpu"):
            hints.append(
                f"Hot process PID {r.pid} ({r.cpu_pct:.0f}% CPU): {r.name[:90]}. "
                "Sample with Activity Monitor or `sample <pid> 5`."
            )
    if not hints:
        hints.append("No critical hints. Re-run after changes to compare.")
    return hints


def summarize_jsonl(path: Path, max_samples: int = 50) -> str:
    agg_cpu: dict[str, float] = defaultdict(float)
    agg_mem: dict[str, float] = defaultdict(float)
    samples = 0
    with path.open(encoding="utf-8") as f:
        for line in f:
            if samples >= max_samples:
                break
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            samples += 1
            for row in obj.get("rows", []):
                name = row.get("processName") or ""
                cpu = float(row.get("cpuDuringSamplePeakPct") or 0)
                mem = float(row.get("sessionPeakMemMb") or 0)
                agg_cpu[name] = max(agg_cpu[name], cpu)
                agg_mem[name] = max(agg_mem[name], mem)
    if not agg_cpu:
        return "_No JSONL samples parsed._\n"
    lines = ["| Max peak CPU % | Session peak MB | Process |", "|---:|---:|---|"]
    for name in sorted(agg_cpu, key=lambda k: agg_cpu[k], reverse=True)[:25]:
        if agg_cpu[name] < 1 and agg_mem[name] < 200:
            continue
        short = name[:100] + ("…" if len(name) > 100 else "")
        lines.append(
            f"| {agg_cpu[name]:.1f} | {agg_mem[name]:.0f} | `{short}` |"
        )
    lines.append(f"\n_Sampled {samples} JSONL record(s) from `{path}`._\n")
    return "\n".join(lines) + "\n"


def build_report(
    status_path: Path,
    jsonl_path: Path | None,
    out_path: Path,
) -> None:
    text = status_path.read_text(encoding="utf-8", errors="replace")
    header_lines = text.splitlines()[:30]
    header = parse_header(header_lines)
    rows = parse_process_table(text)
    stats = parse_workspace_stats(text)
    swap_used_mb, swap_total_mb = macos_memory_pressure()
    dup_counts = count_dup_subprocesses(rows)
    large = flag_large_folders(stats)

    by_cpu = sorted(rows, key=lambda r: r.cpu_pct, reverse=True)
    by_mem = sorted(rows, key=lambda r: r.mem_mb, reverse=True)
    windows = [r for r in rows if classify_row(r) == "window"]
    watchers = [r for r in rows if classify_row(r) == "fileWatcher"]
    hosts = [r for r in rows if classify_row(r) == "extensionHost"]
    zsh = [r for r in rows if "/bin/zsh" in r.name]

    ts = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%SZ")
    parts: list[str] = [
        "# Cursor performance report",
        "",
        f"Generated: {ts}",
        f"Source: `{status_path}`",
        "",
        "## System",
        "",
        f"- **Cursor**: {header.get('version', 'unknown')}",
        f"- **OS**: {header.get('os', 'unknown')}",
        f"- **Memory**: {header.get('memory', 'unknown')}",
        f"- **Load (1/5/15m)**: {header.get('load', 'unknown')}",
    ]
    if swap_used_mb is not None:
        total_note = f", total {swap_total_mb:.0f} MB" if swap_total_mb else ""
        parts.append(f"- **Swap (sysctl)**: {swap_used_mb:.0f} MB used{total_note}")
    parts.extend(["", "## Process counts", ""])
    parts.append(f"| Kind | Count |")
    parts.append(f"|------|------:|")
    parts.append(f"| Renderer windows | {len(windows)} |")
    parts.append(f"| fileWatcher | {len(watchers)} |")
    parts.append(f"| extensionHost | {len(hosts)} |")
    parts.append(f"| zsh (integrated terminals) | {len(zsh)} |")
    parts.append(f"| Total parsed rows | {len(rows)} |")

    parts.extend(["", "## Top CPU (snapshot)", "", "| CPU % | Mem MB | PID | Process |", "|---:|---:|---:|---|"])
    for r in by_cpu[:15]:
        parts.append(f"| {r.cpu_pct:.1f} | {r.mem_mb:.0f} | {r.pid} | {r.name[:100]} |")

    parts.extend(["", "## Top memory (snapshot)", "", "| Mem MB | CPU % | PID | Process |", "|---:|---:|---:|---|"])
    for r in by_mem[:15]:
        parts.append(f"| {r.mem_mb:.0f} | {r.cpu_pct:.1f} | {r.pid} | {r.name[:100]} |")

    parts.extend(["", "## Duplicate subprocess patterns", ""])
    for label, count in sorted(dup_counts.items(), key=lambda x: -x[1]):
        parts.append(f"- **{label}**: {count}")

    if large:
        parts.extend(["", "## Large workspace folders", ""])
        for line in large[:20]:
            parts.append(f"- {line}")

    if stats:
        parts.extend(["", "## Workspace stats (excerpt)", ""])
        for line in stats[:30]:
            parts.append(f"- {line}")
        if len(stats) > 30:
            parts.append(f"- _… and {len(stats) - 30} more lines_")

    parts.extend(["", "## Action hints", ""])
    for hint in action_hints(header, rows, dup_counts, large, swap_used_mb, swap_total_mb):
        parts.append(f"- {hint}")

    if jsonl_path and jsonl_path.is_file():
        parts.extend(["", "## Process Explorer history (JSONL)", ""])
        parts.append(summarize_jsonl(jsonl_path))

    parts.append("")
    out_path.write_text("\n".join(parts), encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description="Summarize cursor -s output into report.md")
    ap.add_argument("status_log", type=Path, help="Path to cursor-status.log")
    ap.add_argument("-o", "--output", type=Path, required=True, help="Output report.md")
    ap.add_argument("--jsonl", type=Path, default=None, help="Optional process history JSONL")
    args = ap.parse_args()
    if not args.status_log.is_file():
        print(f"Missing status log: {args.status_log}", file=sys.stderr)
        return 1
    build_report(args.status_log, args.jsonl, args.output)
    print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
