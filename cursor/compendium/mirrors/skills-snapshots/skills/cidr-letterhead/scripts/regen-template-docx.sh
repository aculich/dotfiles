#!/usr/bin/env bash
# Regenerate a blank branded .docx template and embed Inter.
# Usage: regen-template-docx.sh letterhead|memo|qualifications
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 letterhead|memo|qualifications" >&2
  exit 1
fi

TEMPLATE="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

export_cidr_library

case "$TEMPLATE" in
  letterhead)
    DIR="$CIDR_LIBRARY/templates/letterhead"
    BUILD="build_letterhead.js"
    OUT="letterhead.docx"
    ;;
  memo)
    DIR="$CIDR_LIBRARY/templates/memo"
    BUILD="build_memo.js"
    OUT="memo.docx"
    ;;
  qualifications)
    DIR="$CIDR_LIBRARY/templates/qualifications"
    BUILD="build_qualifications.js"
    OUT="qualifications-references.docx"
    ;;
  *)
    echo "Unknown template: $TEMPLATE" >&2
    exit 1
    ;;
esac

if [[ ! -d "$CIDR_LIBRARY/templates/node_modules/docx" ]]; then
  (cd "$CIDR_LIBRARY/templates" && npm install)
fi

(cd "$DIR" && node "$BUILD")
python3 "$CIDR_LIBRARY/templates/_build/embed_fonts.py" "$DIR/$OUT" Inter
echo "Regenerated $DIR/$OUT"
