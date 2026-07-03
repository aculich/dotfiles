#!/usr/bin/env python3
"""
Render MD / CSV / SRT from a Fireflies GraphQL-shaped JSON saved as raw/api-response.json.

Expected shape: {"data": {"transcript": { ... } } } or {"transcript": { ... } }.
Transcript must include "sentences" (list) with at least: text, speaker_name, start_time, end_time.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path


def load_transcript_obj(raw: dict) -> dict:
    t = raw.get("data", raw).get("transcript", raw.get("transcript"))
    if not t or not isinstance(t, dict):
        raise SystemExit("Could not find transcript object in JSON")
    return t


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    print("wrote", path)


def fmt_time_srt(seconds: float) -> str:
    s = max(0.0, float(seconds if seconds is not None else 0))
    h = int(s // 3600)
    m = int((s % 3600) // 60)
    sec = s - (h * 3600 + m * 60)
    whole = int(sec)
    ms = int(round((sec - whole) * 1000))
    if ms == 1000:
        whole += 1
        ms = 0
    return f"{h:02d}:{m:02d}:{whole:02d},{ms:03d}"


def build_srt(sentences: list) -> str:
    lines: list[str] = []
    n = 0
    for s in sentences:
        text = (s.get("text") or "").strip()
        if not text:
            continue
        n += 1
        t0 = s.get("start_time")
        t1 = s.get("end_time")
        if t1 is None:
            t1 = t0
        lines.append(str(n))
        lines.append(f"{fmt_time_srt(t0 or 0)} --> {fmt_time_srt(t1 or 0)}")
        sp = (s.get("speaker_name") or "").strip()
        if sp:
            text = f"{sp}: {text}"
        lines.append(text)
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def build_csv(sentences: list) -> str:
    rows = ["index,speaker_name,start_time,end_time,text"]
    for s in sentences:
        def esc(x) -> str:
            if x is None:
                return ""
            t = str(x).replace('"', '""')
            if any(c in t for c in ',"\n'):
                return f"\"{t}\""
            return t

        rows.append(
            f'{s.get("index","")},{esc(s.get("speaker_name"))},{s.get("start_time","")},{s.get("end_time","")},{esc(s.get("text"))}'
        )
    return "\n".join(rows) + "\n"


def build_md_speakers_time(sentences: list) -> str:
    out: list[str] = []
    for s in sentences:
        text = (s.get("text") or "").strip()
        if not text:
            continue
        sp = (s.get("speaker_name") or "").strip()
        t0 = s.get("start_time")
        line = f'[{t0:>8.2f}s] **{sp}** — {text}' if sp else f'[{t0:>8.2f}s] {text}'
        out.append(line)
    return "\n\n".join(out) + "\n" if out else ""


def build_md_speakers_only(sentences: list) -> str:
    out: list[str] = []
    for s in sentences:
        text = (s.get("text") or "").strip()
        if not text:
            continue
        sp = (s.get("speaker_name") or "").strip()
        line = f"**{sp}:** {text}" if sp else text
        out.append(line)
    return "\n\n".join(out) + "\n" if out else ""


def build_md_plain(sentences: list) -> str:
    return " ".join(
        (s.get("text") or "").strip()
        for s in sentences
        if (s.get("text") or "").strip()
    ) + "\n"


def main() -> None:
    base = Path(__file__).resolve().parents[1]
    raw_path = base / "raw" / "api-response.json"
    if len(sys.argv) > 1:
        base = Path(sys.argv[1]).resolve()
        raw_path = base / "raw" / "api-response.json"
    if not raw_path.is_file():
        raise SystemExit(f"Missing {raw_path}; save GraphQL output there first")

    raw = json.loads(raw_path.read_text(encoding="utf-8"))
    t = load_transcript_obj(raw)
    sentences = t.get("sentences") or []
    tr = base / "transcript"
    write_text(tr / "transcript--speakers+time.md", build_md_speakers_time(sentences))
    write_text(tr / "transcript--speakers.md", build_md_speakers_only(sentences))
    write_text(tr / "transcript--plain.md", build_md_plain(sentences))
    write_text(tr / "utterances.csv", build_csv(sentences))
    write_text(tr / "transcript.srt", build_srt(sentences))
    sm = t.get("summary")
    if sm:
        sdir = base / "summary"
        write_text(sdir / "summary.json", json.dumps(sm, ensure_ascii=False, indent=2) + "\n")
        ov = sm.get("overview") or ""
        if isinstance(ov, str) and ov.strip():
            write_text(sdir / "summary.overview.md", ov.strip() + "\n")


if __name__ == "__main__":
    main()
