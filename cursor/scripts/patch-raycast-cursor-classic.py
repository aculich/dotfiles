#!/usr/bin/env python3
"""Status/undo helper for a retired Store-extension JS patch.

Rewriting ~/.config/raycast/extensions/<id>/*.js makes Raycast reject the
entry point (Could not load command / file appears to be corrupted). Apply
is disabled. Use the script commands instead:

  just install-raycast-classic

Usage:
  patch-raycast-cursor-classic.py           # refused (prints next step)
  patch-raycast-cursor-classic.py --status
  patch-raycast-cursor-classic.py --undo
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from pathlib import Path

MARKER = "/* cursor-classic-raycast-patch */"
EXT_ROOT = Path.home() / ".config/raycast/extensions"
WRAPPER = Path.home() / "dotfiles/cursor/scripts/cursor-classic-wrapper.sh"
BACKUP_SUFFIX = ".pre-classic-patch"

HELPER = r"""/* cursor-classic-raycast-patch */
function __cursorClassicOpen(target){return new Promise(function(resolve,reject){var execFile=require("child_process").execFile;var p=String(target||"");if(p.indexOf("file://")===0){try{p=decodeURIComponent(p.replace(/^file:\/\//,""))}catch(e){p=p.replace(/^file:\/\//,"")}}var bin=process.env.CURSOR_CLASSIC_WRAPPER||%s;execFile(bin,["--classic",p],function(err){return err?reject(err):resolve()})});}
function __cursorClassicNewWindow(){return new Promise(function(resolve,reject){var execFile=require("child_process").execFile;var bin=process.env.CURSOR_CLASSIC_WRAPPER||%s;execFile(bin,["--classic","--new-window"],function(err){return err?reject(err):resolve()})});}
"""

OPEN_RE = re.compile(r"await\((\d+),([A-Za-z_$][\w$]*)\.open\)\(([^,]+),\"Cursor\"\)")
BROKEN_AWAIT_RE = re.compile(r"await__cursorClassicOpen\(")
NEW_WINDOW_RE = re.compile(
    r"(\w+)=async\(\)=>\{await\(0,(\w+)\.runAppleScript\)\(`[\s\S]*?click menu item \"New Window\"[\s\S]*?`\)\}"
)


def js_string(path: Path) -> str:
    return json.dumps(str(path))


def find_extension() -> Path | None:
    if not EXT_ROOT.is_dir():
        return None
    for pkg in EXT_ROOT.glob("*/package.json"):
        try:
            data = json.loads(pkg.read_text())
        except json.JSONDecodeError:
            continue
        if data.get("name") == "cursor-recent-projects":
            return pkg.parent
    return None


def helper_src() -> str:
    quoted = js_string(WRAPPER)
    return HELPER % (quoted, quoted)


def is_patched(text: str) -> bool:
    return MARKER in text


def patch_text(text: str) -> tuple[str, int, int]:
    if not is_patched(text):
        if text.startswith('"use strict";'):
            text = '"use strict";' + helper_src() + text[len('"use strict";') :]
        else:
            text = helper_src() + text

    text, broken_n = BROKEN_AWAIT_RE.subn("__cursorClassicOpen_PLACEHOLDER(", text)
    text = text.replace("__cursorClassicOpen_PLACEHOLDER(", "await __cursorClassicOpen(")
    text, open_n = OPEN_RE.subn(r"await __cursorClassicOpen(\3)", text)
    text, win_n = NEW_WINDOW_RE.subn(
        r"\1=async()=>{await __cursorClassicNewWindow()}", text
    )
    return text, open_n + broken_n, win_n


def backup_path(src: Path) -> Path:
    return src.with_name(src.name + BACKUP_SUFFIX)


def apply(ext: Path) -> int:
    print(
        "error: rewriting the Store Cursor extension JS makes Raycast reject it",
        file=sys.stderr,
    )
    print(
        "(Could not load command / The entry point file appears to be corrupted)",
        file=sys.stderr,
    )
    print(
        "Use script commands instead: just install-raycast-classic",
        file=sys.stderr,
    )
    print(
        "If commands are still broken, restore then quit Raycast: just unpatch-raycast-cursor",
        file=sys.stderr,
    )
    _ = ext
    return 1


def undo(ext: Path) -> int:
    restored = 0
    for bak in ext.glob(f"*{BACKUP_SUFFIX}"):
        dest = bak.with_name(bak.name[: -len(BACKUP_SUFFIX)])
        shutil.copy2(bak, dest)
        bak.unlink()
        print(f"restored {dest.name}")
        restored += 1
    stamp = ext / ".cursor-classic-patch"
    if stamp.exists():
        stamp.unlink()
    if restored == 0:
        print("no backups found; nothing to undo")
    return 0


def status(ext: Path | None) -> int:
    if ext is None:
        print("Raycast Cursor extension (cursor-recent-projects) not found under ~/.config/raycast/extensions")
        return 1
    print(f"extension: {ext}")
    print(f"package: {json.loads((ext / 'package.json').read_text()).get('title')} ({json.loads((ext / 'package.json').read_text()).get('name')})")
    stamp = ext / ".cursor-classic-patch"
    print(f"stamp: {stamp.read_text().strip() if stamp.exists() else '(none)'}")
    for js in sorted(ext.glob("*.js")):
        if BACKUP_SUFFIX in js.name:
            continue
        text = js.read_text()
        opens = len(OPEN_RE.findall(text))
        classic = text.count("__cursorClassicOpen(")
        print(f"  {js.name}: patched={MARKER in text} leftover_open_a={opens} classic_opens={classic}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--status", action="store_true")
    parser.add_argument("--undo", action="store_true")
    args = parser.parse_args()
    ext = find_extension()
    if args.status:
        return status(ext)
    if ext is None:
        print("error: cursor-recent-projects not installed", file=sys.stderr)
        return 1
    if args.undo:
        return undo(ext)
    return apply(ext)


if __name__ == "__main__":
    raise SystemExit(main())
