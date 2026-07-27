#!/usr/bin/env bash
# Build a CiDR letterhead PDF from pandoc markdown using the library letterhead
# template (templates/letterhead/letterhead.md pattern: LaTeX masthead + xelatex).
#
# The masthead uses a raw-LaTeX \includegraphics, which xelatex resolves against
# its own working directory (pandoc's --resource-path does not apply to raw
# LaTeX). So the logo reference is rewritten to the resolved absolute path,
# which makes the build work from any source location. Both conventions are
# handled: the in-repo relative path (...wide-a-light.png) and a portable
# __LOGO_PATH__ placeholder.
#
# Optional: a __FONT_DIR__ placeholder is rewritten to the repo Inter font dir,
# so a source can load real Inter via fontspec (Path=__FONT_DIR__/) instead of
# relying on a system font. Without it, the source's own font fallback applies.
#
# Usage: build-letter-pdf.sh input.md output.pdf
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 input.md output.pdf" >&2
  exit 1
fi

INPUT="$1"
OUTPUT="$2"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

export_cidr_library

if [[ ! -f "$INPUT" ]]; then
  echo "Input not found: $INPUT" >&2
  exit 1
fi

LOGO="$(logo_path)"
if [[ ! -f "$LOGO" ]]; then
  echo "Logo not found: $LOGO" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"
TMP="$(mktemp -t cidr-letter).md"
trap 'rm -f "$TMP"' EXIT

# Point the logo include at the resolved absolute path:
#   - any {...wide-a-light.png} include  (the in-repo relative path)
#   - the __LOGO_PATH__ placeholder       (portable copies)
# and rewrite the optional __FONT_DIR__ placeholder to the repo Inter dir.
FONT_DIR="$CIDR_LIBRARY/brand/fonts/inter"
sed -E "s|\{[^{}]*wide-a-light\.png\}|{$LOGO}|g; s|__LOGO_PATH__|$LOGO|g; s|__FONT_DIR__|$FONT_DIR|g" "$INPUT" > "$TMP"

pandoc "$TMP" --pdf-engine=xelatex -o "$OUTPUT"
echo "PDF: $OUTPUT"
