#!/usr/bin/env bash
# DWIM diagnose-first entrypoint for Cursor ops (never kills / never auto-tunes).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "======== just doit (diagnose-first) ========"
just status
echo ""
echo "== resource snapshot =="
"$ROOT/scripts/cursor-resource-snapshot.sh" --no-sample

out="$(cat observability/perf/last-resource-snapshot.txt 2>/dev/null || true)"
if [[ -n "$out" && -f "$out/summary.json" ]]; then
  python3 - "$out" <<'PY'
import json, sys
from pathlib import Path
out = Path(sys.argv[1])
s = json.loads((out / "summary.json").read_text())
print("")
print(
    f"extension_hosts={s.get('extension_host_count')} hot={s.get('hot_count')} "
    f"simultaneous_hot={s.get('simultaneous_hot')} pressure={s.get('pressure_hint')}"
)
if s.get("simultaneous_hot") or (s.get("hot_count") or 0) >= 2:
    print("Hotspot report:", out / "report.md")
    print("Tip: cut per-window extension tax via scripts/apply-cursor-resource-tuning.sh (dry-run first).")
    print("Tip: MCP toggle scripts/toggle-global-mcp.sh — do not lead with closing windows.")
for h in (s.get("top_hosts") or [])[:5]:
    print(f"  {h['cpu_pct']:.0f}%  {h['workspace']}  pid={h['pid']}")
PY
fi

mirror="$ROOT/compendium/mirrors/skills-snapshots"
live_c=$(ls -1 ~/.cursor/skills 2>/dev/null | wc -l | tr -d ' ')
mir_c=$(ls -1 "$mirror/skills" 2>/dev/null | wc -l | tr -d ' ')
live_a=$(ls -1 ~/.agents/skills 2>/dev/null | wc -l | tr -d ' ')
mir_a=$(ls -1 "$mirror/agents-skills" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$live_c" != "$mir_c" || "$live_a" != "$mir_a" ]]; then
  echo ""
  echo "Skill counts differ from mirror (live skills=$live_c/$live_a mirror=$mir_c/$mir_a)."
  echo "Tip: just skill-backup-fast"
fi

echo ""
echo "Canvas: /Users/me/.cursor/projects/Users-me-dotfiles-cursor/canvases/cursor-ops-status.canvas.tsx"
echo "Re-embed after snapshots so the Resources view stays current."
echo "======== done ========"
