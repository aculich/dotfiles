#!/usr/bin/env bash
# Finalize Inter embedding in a docx-js output file.
# Usage: embed-docx-fonts.sh file.docx [FontName]
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 file.docx [FontName]" >&2
  exit 1
fi

DOCX="$1"
FONT="${2:-Inter}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

export_cidr_library

if [[ ! -f "$DOCX" ]]; then
  echo "File not found: $DOCX" >&2
  exit 1
fi

python3 "$CIDR_LIBRARY/templates/_build/embed_fonts.py" "$DOCX" "$FONT"
echo "Embedded $FONT in $DOCX"
