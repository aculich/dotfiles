#!/usr/bin/env python3
"""Sum or compute plan todo costs from annotated .plan.md frontmatter.

Usage:
  python3 scripts/estimate-plan-cost.py path/to/plan.plan.md
  python3 scripts/estimate-plan-cost.py --compute plan.plan.md
  python3 scripts/estimate-plan-cost.py plan1.plan.md plan2.plan.md --by-pool
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("PyYAML required: uv pip install pyyaml", file=sys.stderr)
    sys.exit(1)

SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_RATES = SCRIPT_DIR.parent / "data" / "cursor-plan-rates.json"

POOL_LABELS = {
    "auto": "Auto + Composer",
    "auto_composer": "Auto + Composer",
    "composer": "Auto + Composer",
    "api": "API",
}


def load_plan(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---"):
        raise ValueError(f"{path}: missing YAML frontmatter")
    end = text.find("\n---", 3)
    if end == -1:
        raise ValueError(f"{path}: unclosed frontmatter")
    return yaml.safe_load(text[3:end]) or {}


def load_rates(path: Path) -> dict:
    data = json.loads(path.read_text(encoding="utf-8"))
    return data.get("models") or {}


def compute_cost(
    model: str | None,
    tokens_in: int | float | None,
    tokens_out: int | float | None,
    rates: dict,
) -> float | None:
    if not model or tokens_in is None or tokens_out is None:
        return None
    entry = rates.get(model)
    if not entry:
        return None
    tin = float(tokens_in) / 1_000_000
    tout = float(tokens_out) / 1_000_000
    return tin * float(entry["input"]) + tout * float(entry["output"])


def effective_est(todo: dict, rates: dict, compute: bool) -> dict | None:
    est = todo.get("est_cost_usd")
    if isinstance(est, dict) and est.get("typical") is not None:
        return est
    if not compute:
        return None
    typical = compute_cost(
        todo.get("model"),
        todo.get("est_tokens_in"),
        todo.get("est_tokens_out"),
        rates,
    )
    if typical is None:
        return None
    return {
        "low": round(typical * 0.7, 2),
        "typical": round(typical, 2),
        "high": round(typical * 1.6, 2),
    }


def sum_bands(
    todos: list, rates: dict, compute: bool
) -> tuple[float, float, float, int, dict[str, float]]:
    low = typical = high = 0.0
    counted = 0
    by_pool: dict[str, float] = {}
    for todo in todos or []:
        if not isinstance(todo, dict):
            continue
        est = effective_est(todo, rates, compute)
        if not isinstance(est, dict):
            continue
        raw_pool = str(todo.get("pool", "unknown"))
        pool = "api" if raw_pool == "api" else "auto_composer"
        t = float(est.get("typical", 0) or 0)
        by_pool[pool] = by_pool.get(pool, 0.0) + t
        low += float(est.get("low", 0) or 0)
        typical += t
        high += float(est.get("high", 0) or 0)
        counted += 1
    return low, typical, high, counted, by_pool


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("plans", nargs="+", type=Path, help=".plan.md files")
    parser.add_argument(
        "--scenario",
        choices=("low", "typical", "high", "all"),
        default="all",
        help="Which cost band to emphasize when printing totals",
    )
    parser.add_argument(
        "--compute",
        action="store_true",
        help="Compute est_cost_usd from model + tokens when missing",
    )
    parser.add_argument(
        "--rates",
        type=Path,
        default=DEFAULT_RATES,
        help=f"Rate card JSON (default: {DEFAULT_RATES})",
    )
    parser.add_argument(
        "--by-pool",
        action="store_true",
        help="Show typical $ grouped by pool",
    )
    args = parser.parse_args()

    if not args.rates.is_file():
        print(f"error: rates file not found: {args.rates}", file=sys.stderr)
        return 1
    rates = load_rates(args.rates)

    grand_low = grand_typical = grand_high = 0.0
    grand_by_pool: dict[str, float] = {}

    for plan_path in args.plans:
        if not plan_path.is_file():
            print(f"skip (not found): {plan_path}", file=sys.stderr)
            continue
        try:
            data = load_plan(plan_path)
        except (ValueError, yaml.YAMLError) as exc:
            print(f"error: {exc}", file=sys.stderr)
            continue
        todos = data.get("todos") or []
        low, typical, high, n, by_pool = sum_bands(todos, rates, args.compute)
        name = data.get("name", plan_path.stem)
        print(f"\n{name} ({plan_path})")
        print(f"  annotated todos: {n}/{len(todos)}")
        print(f"  low:     ${low:.2f}")
        print(f"  typical: ${typical:.2f}")
        print(f"  high:    ${high:.2f}")
        if args.by_pool and by_pool:
            print("  by pool (typical):")
            for pool, amount in sorted(by_pool.items(), key=lambda x: -x[1]):
                label = POOL_LABELS.get(pool, pool)
                print(f"    {label}: ${amount:.2f}")
        grand_low += low
        grand_typical += typical
        grand_high += high
        for pool, amount in by_pool.items():
            grand_by_pool[pool] = grand_by_pool.get(pool, 0.0) + amount

    if len(args.plans) > 1:
        print("\n--- total ---")
        if args.scenario == "all":
            print(f"  low:     ${grand_low:.2f}")
            print(f"  typical: ${grand_typical:.2f}")
            print(f"  high:    ${grand_high:.2f}")
        else:
            val = {"low": grand_low, "typical": grand_typical, "high": grand_high}[
                args.scenario
            ]
            print(f"  {args.scenario}: ${val:.2f}")
        if args.by_pool and grand_by_pool:
            print("  by pool (typical):")
            for pool, amount in sorted(grand_by_pool.items(), key=lambda x: -x[1]):
                label = POOL_LABELS.get(pool, pool)
                print(f"    {label}: ${amount:.2f}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
