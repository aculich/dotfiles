#!/usr/bin/env bash
# Remove keyboard repeat overrides set by setup-vim-key-repeat.sh (restore macOS defaults).
#
# Usage:
#   reset-vim-key-repeat.sh
#   reset-vim-key-repeat.sh --apply-session
#   reset-vim-key-repeat.sh --verify

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/setup-vim-key-repeat.sh" --reset "$@"
