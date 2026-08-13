#!/usr/bin/env python3
"""Validate a rate-card.yaml and render client, web, and deck views."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

import yaml
from jinja2 import Environment, FileSystemLoader, StrictUndefined

SKILL_ROOT = Path(__file__).resolve().parents[1]
TEMPLATES = SKILL_ROOT / "templates"

REQUIRED_BRAND = ("id", "name", "entity", "tagline", "email")
DEFAULT_COLORS = {
    "ink": "#1c1917",
    "paper": "#eef2f1",
    "accent": "#0f766e",
    "muted": "#57534e",
}
DEFAULT_FONTS = {"display": "Fraunces", "body": "Figtree"}


def money(value) -> str:
    if value is None or value == "":
        return ""
    try:
        n = int(round(float(value)))
    except (TypeError, ValueError):
        return str(value)
    return f"${n:,}"


def rate_range(row: dict) -> str:
    lo = row.get("rate_low")
    hi = row.get("rate_high")
    unit = row.get("unit", "hour")
    suffix = "/hr" if unit == "hour" else f"/{unit}"
    if lo is None and hi is None:
        return ""
    if hi is None or lo == hi:
        return f"{money(lo)}{suffix}"
    return f"{money(lo)}–{money(hi)}{suffix}"


def google_fonts_import(fonts: dict) -> str:
    display = (fonts or {}).get("display") or DEFAULT_FONTS["display"]
    body = (fonts or {}).get("body") or DEFAULT_FONTS["body"]
    families = []
    for name, spec in ((display, "wght@600"), (body, "wght@400;600")):
        q = name.replace(" ", "+")
        families.append(f"family={q}:{spec}")
    return (
        "@import url('https://fonts.googleapis.com/css2?"
        + "&".join(families)
        + "&display=swap');"
    )


def load_card(path: Path) -> dict:
    data = yaml.safe_load(path.read_text())
    if not isinstance(data, dict):
        raise SystemExit(f"{path}: expected a mapping at the root")
    return data


def validate(card: dict) -> list[str]:
    errors: list[str] = []
    if card.get("schema_version") != 1:
        errors.append("schema_version must be 1")
    brand = card.get("brand") or {}
    for key in REQUIRED_BRAND:
        if not brand.get(key):
            errors.append(f"brand.{key} is required")
    if "offerings" in card and not isinstance(card.get("offerings"), list):
        errors.append("offerings must be a list")
    if "engagement_models" in card and not isinstance(card.get("engagement_models"), list):
        errors.append("engagement_models must be a list")
    publish = card.get("publish") or {}
    for flag in ("show_from_prices", "show_hourly", "show_hourly_client"):
        if flag in publish and not isinstance(publish[flag], bool):
            errors.append(f"publish.{flag} must be a boolean")
    return errors


def critique(card: dict) -> list[str]:
    notes: list[str] = []
    offerings = card.get("offerings") or []
    seen: dict[str, dict] = {}
    floor = card.get("cost_floor") or {}
    min_hourly = floor.get("min_hourly")
    project_floor = floor.get("new_client_project_floor")
    exceptions = set(floor.get("exceptions") or [])
    publish = card.get("publish") or {}

    for off in offerings:
        oid = off.get("id")
        if not oid:
            notes.append("WARN: offering is missing id")
            continue
        if oid in seen:
            notes.append(f"ERROR: duplicate offering id {oid}")
        seen[oid] = off
        pricing = off.get("pricing") or {}
        from_price = pricing.get("from_price")
        if off.get("public", True) and publish.get("show_from_prices", True) and from_price is None:
            notes.append(f"WARN: public offering {oid} has no from_price")
        if from_price is not None and isinstance(project_floor, (int, float)):
            if from_price < project_floor and oid not in exceptions:
                notes.append(
                    f"WARN: {oid} from_price {from_price} is below "
                    f"new_client_project_floor {project_floor} and is not an exception"
                )
        tiers = pricing.get("tiers") or []
        prices = [t.get("price") for t in tiers if t.get("price") is not None]
        if from_price is not None and prices and from_price != min(prices):
            notes.append(
                f"WARN: {oid} from_price {from_price} does not match lowest tier {min(prices)}"
            )

    for row in card.get("hourly_ladder") or []:
        lo = row.get("rate_low")
        if isinstance(min_hourly, (int, float)) and lo is not None and lo < min_hourly:
            notes.append(
                f"WARN: hourly {row.get('id') or row.get('name')} low {lo} "
                f"is below min_hourly {min_hourly}"
            )

    for row in card.get("retainers") or []:
        rate = row.get("rate")
        if isinstance(min_hourly, (int, float)) and rate is not None and rate < min_hourly:
            notes.append(
                f"WARN: retainer {row.get('id') or row.get('name')} {rate} "
                f"is below min_hourly {min_hourly}"
            )

    regime = (card.get("compliance") or {}).get("regime")
    if regime and regime not in ("none", None, ""):
        notes.append(
            f"INFO: compliance regime is {regime} — keep published rates at or below the bound in compliance.notes"
        )

    stack = (card.get("discount_policy") or {}).get("stack") or []
    if stack:
        notes.append("INFO: discount stack is " + " → ".join(str(s) for s in stack) + "; do not bake cuts into sticker")

    if not notes:
        notes.append("OK: no critique findings")
    return notes


def normalize(card: dict) -> dict:
    brand = dict(card.get("brand") or {})
    colors = dict(DEFAULT_COLORS)
    colors.update(brand.get("colors") or {})
    brand["colors"] = colors
    fonts = dict(DEFAULT_FONTS)
    fonts.update(brand.get("fonts") or {})
    brand["fonts"] = fonts
    if not brand.get("short_name"):
        brand["short_name"] = brand.get("name") or ""
    if not brand.get("website"):
        brand["website"] = ""
    if not brand.get("voice"):
        brand["voice"] = ""
    publish = {
        "show_from_prices": True,
        "show_hourly": False,
        "show_hourly_client": True,
    }
    publish.update(card.get("publish") or {})
    offerings = []
    for raw in card.get("offerings") or []:
        off = dict(raw)
        off.setdefault("includes", [])
        off.setdefault("excludes", [])
        off.setdefault("outcomes", [])
        off.setdefault("summary", "")
        off.setdefault("duration", "")
        off.setdefault("public", True)
        off["pricing"] = dict(off.get("pricing") or {})
        off["pricing"].setdefault("from_price", None)
        off["pricing"].setdefault("tiers", [])
        off["pricing"].setdefault("currency", "USD")
        offerings.append(off)
    public_offerings = [o for o in offerings if o.get("public", True)]
    ctx = dict(card)
    ctx["brand"] = brand
    ctx["publish"] = publish
    ctx["offerings"] = offerings
    ctx["public_offerings"] = public_offerings
    ctx["hourly_ladder"] = card.get("hourly_ladder") or []
    ctx["retainers"] = card.get("retainers") or []
    ctx["engagement_models"] = card.get("engagement_models") or []
    ctx["problems"] = card.get("problems") or []
    ctx["terms"] = card.get("terms") or {}
    ctx["cta"] = card.get("cta") or {}
    ctx["who_we_help"] = (card.get("who_we_help") or "").strip()
    ctx["effective_date"] = card.get("effective_date") or ""
    ctx["google_fonts_css"] = google_fonts_import(fonts)
    return ctx


def env() -> Environment:
    jinja = Environment(
        loader=FileSystemLoader(str(TEMPLATES)),
        undefined=StrictUndefined,
        trim_blocks=True,
        lstrip_blocks=True,
    )
    jinja.filters["money"] = money
    jinja.filters["rate_range"] = rate_range
    return jinja


def render_to(jinja: Environment, name: str, ctx: dict, dest: Path) -> None:
    dest.write_text(jinja.get_template(name).render(**ctx))


def generate_rationale(ctx: dict) -> str:
    brand = ctx["brand"]
    floor = ctx.get("cost_floor") or {}
    disc = ctx.get("discount_policy") or {}
    lines = [
        f"# Rate-card rationale — {brand['name']}",
        "",
        "Internal. Generated from YAML because no sibling rationale.md was found.",
        "",
        f"**Brand:** {brand['name']} (`{brand['id']}`)",
        f"**Entity:** {brand['entity']}",
        f"**Effective:** {ctx.get('effective_date')}",
        "",
        "## Cost floor",
        "",
        f"- min_hourly: {floor.get('min_hourly')}",
        f"- new_client_project_floor: {floor.get('new_client_project_floor')}",
        f"- exceptions: {', '.join(floor.get('exceptions') or []) or 'none'}",
        f"- notes: {(floor.get('notes') or '').strip()}",
        "",
        "## Discount stack",
        "",
        "- " + " → ".join(str(s) for s in (disc.get("stack") or [])) if disc.get("stack") else "- (none)",
        "",
        (disc.get("notes") or "").strip(),
        "",
        "## Compliance",
        "",
        yaml.safe_dump(ctx.get("compliance") or {}, sort_keys=False),
    ]
    return "\n".join(lines).rstrip() + "\n"


def which(cmd: str) -> str | None:
    return shutil.which(cmd)


def chrome_bin() -> str | None:
    candidates = [
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        "/Applications/Chromium.app/Contents/MacOS/Chromium",
        which("google-chrome"),
        which("chromium"),
        which("chromium-browser"),
    ]
    for path in candidates:
        if path and Path(path).is_file():
            return path
    return None


def write_pdf(html_path: Path, pdf_path: Path) -> str | None:
    try:
        from weasyprint import HTML

        HTML(filename=str(html_path), base_url=str(html_path.parent)).write_pdf(str(pdf_path))
        return None
    except Exception:
        pass

    chrome = chrome_bin()
    if chrome:
        try:
            subprocess.run(
                [
                    chrome,
                    "--headless=new",
                    "--disable-gpu",
                    "--no-pdf-header-footer",
                    f"--print-to-pdf={pdf_path}",
                    html_path.resolve().as_uri(),
                ],
                check=True,
                capture_output=True,
                text=True,
            )
            if pdf_path.is_file() and pdf_path.stat().st_size > 0:
                return None
        except subprocess.CalledProcessError as err:
            return f"PDF failed (Chrome): {err.stderr or err}"

    binary = which("weasyprint")
    if binary:
        try:
            subprocess.run(
                [binary, str(html_path), str(pdf_path)],
                check=True,
                capture_output=True,
                text=True,
            )
            return None
        except subprocess.CalledProcessError:
            pass
    return "PDF skipped (WeasyPrint unavailable; Chrome not found)"


def marp_commands() -> list[list[str]]:
    cmds: list[list[str]] = []
    fnm = which("fnm")
    npx = which("npx")
    if fnm and npx:
        cmds.append(
            [fnm, "exec", "--using=22", "--", "npx", "--yes", "@marp-team/marp-cli"]
        )
    if npx:
        cmds.append([npx, "--yes", "@marp-team/marp-cli"])
    marp = which("marp")
    if marp:
        cmds.append([marp])
    return cmds


def write_marp(deck_md: Path, html_path: Path, pptx_path: Path) -> list[str]:
    notes: list[str] = []
    cmds = marp_commands()
    if not cmds:
        notes.append("Marp CLI not found; wrote deck.md only")
        return notes + _pptx_via_pandoc(deck_md, pptx_path)

    last_err = ""
    for cmd_base in cmds:
        ok = True
        for dest, extra in ((html_path, ["--html"]), (pptx_path, ["--pptx"])):
            try:
                subprocess.run(
                    [*cmd_base, str(deck_md), *extra, "-o", str(dest)],
                    check=True,
                    capture_output=True,
                    text=True,
                )
            except subprocess.CalledProcessError as err:
                ok = False
                last_err = (err.stderr or str(err)).strip().splitlines()[-1] if err.stderr else str(err)
                break
        if ok and html_path.is_file() and pptx_path.is_file():
            return notes
    notes.append(f"Marp export failed ({last_err or 'unknown error'})")
    notes.extend(_pptx_via_pandoc(deck_md, pptx_path))
    return notes


def _pptx_via_pandoc(deck_md: Path, pptx_path: Path) -> list[str]:
    if pptx_path.is_file():
        return []
    pandoc = which("pandoc")
    if not pandoc:
        return ["PPTX skipped (pandoc not found)"]
    try:
        subprocess.run(
            [pandoc, str(deck_md), "-t", "pptx", "-o", str(pptx_path)],
            check=True,
            capture_output=True,
            text=True,
        )
        return ["PPTX wrote via pandoc (Marp unavailable)"]
    except subprocess.CalledProcessError as err:
        return [f"PPTX failed: {err.stderr or err}"]


def inject_font_css(html: str, google_fonts_css: str) -> str:
    if "@import" in html:
        return html
    return html.replace("<style>", "<style>\n    " + google_fonts_css + "\n", 1)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("yaml_path", type=Path)
    parser.add_argument("--out", type=Path, default=None)
    parser.add_argument("--skip-pdf", action="store_true")
    parser.add_argument("--skip-deck-export", action="store_true")
    args = parser.parse_args(argv)

    src = args.yaml_path.expanduser().resolve()
    if not src.is_file():
        print(f"not found: {src}", file=sys.stderr)
        return 1

    card = load_card(src)
    errors = validate(card)
    if errors:
        print("Validation failed:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1

    findings = critique(card)
    ctx = normalize(card)
    out = (args.out or (src.parent / "out")).expanduser().resolve()
    out.mkdir(parents=True, exist_ok=True)

    jinja = env()
    sibling_rationale = src.parent / "rationale.md"
    if sibling_rationale.is_file():
        shutil.copyfile(sibling_rationale, out / "rationale.md")
    else:
        (out / "rationale.md").write_text(generate_rationale(ctx))

    (out / "critique.md").write_text(
        "# Rate-card critique\n\n"
        + "\n".join(f"- {n}" for n in findings)
        + "\n"
    )

    render_to(jinja, "rate-card-full.md.j2", ctx, out / "rate-card-full.md")
    render_to(jinja, "services-stub.md.j2", ctx, out / "services-stub.md")
    render_to(jinja, "deck.md.j2", ctx, out / "deck.md")

    one_pager = jinja.get_template("one-pager.html.j2").render(**ctx)
    one_pager = inject_font_css(one_pager, ctx["google_fonts_css"])
    (out / "one-pager.html").write_text(one_pager)

    stub_html = jinja.get_template("services-stub.html.j2").render(**ctx)
    stub_html = inject_font_css(stub_html, ctx["google_fonts_css"])
    (out / "services-stub.html").write_text(stub_html)

    extras: list[str] = []
    if not args.skip_pdf:
        pdf_note = write_pdf(out / "one-pager.html", out / "one-pager.pdf")
        if pdf_note:
            extras.append(pdf_note)
    if not args.skip_deck_export:
        extras.extend(write_marp(out / "deck.md", out / "deck.html", out / "deck.pptx"))

    print(f"Wrote {out}")
    for n in findings:
        print(f"  {n}")
    for n in extras:
        print(f"  {n}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
