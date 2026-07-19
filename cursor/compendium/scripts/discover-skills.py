#!/usr/bin/env python3
"""Thin shim — do not fork discover logic here.

Canonical implementation: $AGENT_SKILLS_ROOT/scripts/discover-skills.py
(default: ~/projects/agent-skills). See agent-skills research/skills-mgmt/SUPER-PRD.md.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path


def _canonical() -> Path:
    roots: list[Path] = []
    env = os.environ.get("AGENT_SKILLS_ROOT", "").strip()
    if env:
        roots.append(Path(env).expanduser())
    roots.append(Path.home() / "projects" / "agent-skills")
    here = Path(__file__).resolve()
    for root in roots:
        script = (root / "scripts" / "discover-skills.py").resolve()
        if script.is_file() and script != here:
            return script
    raise SystemExit(
        "Canonical discover-skills.py not found. "
        "Clone agent-skills and/or set AGENT_SKILLS_ROOT "
        "(expected $AGENT_SKILLS_ROOT/scripts/discover-skills.py)."
    )


def main() -> None:
    target = _canonical()
    os.execv(sys.executable, [sys.executable, str(target), *sys.argv[1:]])


if __name__ == "__main__":
    main()
