#!/usr/bin/env bash
# Global Python CLI tools via `uv tool` (replaces pipx). Wave 3 runs this via
# script/setup after `mise install` gives us uv; chezmoi re-runs it when the
# list below changes. Libraries (pandas, polars, ...) are NEVER installed here:
# they are per project via `uv add`.
set -euo pipefail

if [[ -n "${BOOTSTRAP_SETUP:-}" ]]; then
  exit 0
fi

# uv comes from mise (~/.config/mise/config.toml). Find it without a live shell.
if command -v uv >/dev/null 2>&1; then
  UV=uv
elif command -v mise >/dev/null 2>&1 && mise which uv >/dev/null 2>&1; then
  UV="$(mise which uv)"
else
  echo "30-uv-tools: uv not available yet (wave 3 installs it); skipping" >&2
  exit 0
fi

tools=(
  pre-commit
  csvkit
  'visidata[xlsx]'
  sqlite-utils
)
for t in "${tools[@]}"; do
  "$UV" tool install --quiet "$t" || "$UV" tool upgrade --quiet "${t%%\[*}" || true
done
"$UV" tool list
