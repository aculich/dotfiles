#!/usr/bin/env bash
# Resolve Chatstory partition id and vault path for a project ROOT.
# Naming matches ~/projects/chatstory/src/vault/vaultPaths.ts
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: resolve-partition.sh <project-path>

Prints:
  realpath=<abs>
  slug=<slug>
  workspace_key=<16 hex>
  partition_id=<slug>__<key>
  vault_path=<path or NOT_FOUND>
  history_count=<n>
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 1 ]]; then
  usage
  [[ $# -ge 1 ]] || exit 1
  exit 0
fi

ROOT_IN="$1"
if [[ ! -e "$ROOT_IN" ]]; then
  echo "error: path does not exist: $ROOT_IN" >&2
  exit 1
fi

REAL="$(cd "$ROOT_IN" && pwd -P)"
BASE="$(basename "$REAL")"

# sanitizeSlug: lowercase, non [a-z0-9_-] -> -, collapse hyphens, trim, max 48
SLUG="$(
  printf '%s' "$BASE" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9_-]/-/g; s/-+/-/g; s/^-|-$//g' \
    | cut -c1-48
)"
if [[ -z "$SLUG" ]]; then
  SLUG="project"
fi

# workspaceKey: sha256(realpath).hex[:16]
if command -v shasum >/dev/null 2>&1; then
  KEY="$(printf '%s' "$REAL" | shasum -a 256 | awk '{print substr($1,1,16)}')"
elif command -v sha256sum >/dev/null 2>&1; then
  KEY="$(printf '%s' "$REAL" | sha256sum | awk '{print substr($1,1,16)}')"
else
  KEY="$(python3 -c "import hashlib,sys; print(hashlib.sha256(sys.argv[1].encode()).hexdigest()[:16])" "$REAL")"
fi

PARTITION_ID="${SLUG}__${KEY}"
VAULT_ROOT="${CHATSTORY_VAULT_PATH:-$HOME/.chatstory}"

VAULT_PATH=""
if [[ -d "$VAULT_ROOT/nodes" ]]; then
  # Prefer exact partition dir under any node
  while IFS= read -r -d '' cand; do
    VAULT_PATH="$cand"
    break
  done < <(find "$VAULT_ROOT/nodes" -type d -path "*/providers/cursor/workspaces/${PARTITION_ID}" -print0 2>/dev/null)
fi

HISTORY_COUNT=0
if [[ -n "$VAULT_PATH" && -d "$VAULT_PATH/history" ]]; then
  HISTORY_COUNT="$(find "$VAULT_PATH/history" -maxdepth 1 -type f \( -name '*.md' -o -name '*.plan.md' \) 2>/dev/null | wc -l | tr -d ' ')"
fi

printf 'realpath=%s\n' "$REAL"
printf 'slug=%s\n' "$SLUG"
printf 'workspace_key=%s\n' "$KEY"
printf 'partition_id=%s\n' "$PARTITION_ID"
if [[ -n "$VAULT_PATH" ]]; then
  printf 'vault_path=%s\n' "$VAULT_PATH"
else
  printf 'vault_path=NOT_FOUND\n'
fi
printf 'history_count=%s\n' "$HISTORY_COUNT"
