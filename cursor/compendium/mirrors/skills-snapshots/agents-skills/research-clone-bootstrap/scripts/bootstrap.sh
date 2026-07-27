#!/usr/bin/env zsh
# Scaffold a dual-workspace research+product lab from a seed URL.
# Usage: bootstrap.sh <seed-url> [--slug SLUG] [--root DIR]
set -euo pipefail

SEED="${1:-}"
[[ -z "$SEED" || "$SEED" == -* ]] && {
  echo "Usage: bootstrap.sh <https://…|github.com/owner/repo> [--slug SLUG] [--root DIR]" >&2
  exit 1
}
shift || true

ROOT_DEFAULT="${HOME}/tools/macosx-tools/labs"
ROOT="$ROOT_DEFAULT"
SLUG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --slug) SLUG="$2"; shift 2 ;;
    --root) ROOT="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

# Derive slug from URL if missing
if [[ -z "$SLUG" ]]; then
  if [[ "$SEED" =~ github.com/([^/]+)/([^/#?]+) ]]; then
    SLUG="${match[2]}"
    SLUG="${SLUG%.git}"
  else
    host="$(printf '%s' "$SEED" | sed -E 's#https?://##; s#/.*##; s/^www\.//')"
    SLUG="$(printf '%s' "$host" | sed -E 's/\.[a-z]+$//' | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')"
  fi
fi
SLUG="$(printf '%s' "$SLUG" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')"
[[ -z "$SLUG" ]] && { echo "Could not derive --slug from $SEED" >&2; exit 1; }

LAB="$ROOT/$SLUG"
PRODUCT="$LAB/product"
PEERS="$LAB/peers"
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$SKILL_DIR/templates"

if [[ -e "$LAB" ]]; then
  echo "Lab already exists: $LAB" >&2
  echo "Open product:  cursor $PRODUCT/${SLUG}.code-workspace" >&2
  echo "Open research: cursor $PEERS/${SLUG}-research.code-workspace" >&2
  exit 0
fi

mkdir -p "$PRODUCT/research/packages" "$PRODUCT/research/docs" "$PRODUCT/research/binaries" \
  "$PRODUCT/research/search-archives" "$PEERS/clones"

# Copy templates
cp "$TPL/product/.gitignore" "$PRODUCT/.gitignore"
cp "$TPL/peers/.gitignore" "$PEERS/.gitignore"
cp "$TPL/peers/sync.sh" "$PEERS/sync.sh"
chmod +x "$PEERS/sync.sh"
cp "$TPL/peers/repos.txt" "$PEERS/repos.txt"
cp "$TPL/product/research/binaries/.gitignore" "$PRODUCT/research/binaries/.gitignore"
printf '%s\n' '{"apps":[]}' > "$PRODUCT/research/binaries/MANIFEST.json"

# Seed-aware files
DATE="$(date +%Y-%m-%d)"
export SEED SLUG DATE LAB PRODUCT PEERS

# README lab root
cat > "$LAB/README.md" <<EOF
# ${SLUG} lab

Seed: ${SEED}  
Created: ${DATE}

## Workspaces (keep separate)

| Workspace | Path | Indexed |
|-----------|------|---------|
| **Product** | \`product/${SLUG}.code-workspace\` | Your OSS implementation + research *docs* only |
| **Research** | \`peers/${SLUG}-research.code-workspace\` | Peer clones + matrix (open only when studying) |

\`\`\`bash
cursor ${PRODUCT}/${SLUG}.code-workspace
cursor ${PEERS}/${SLUG}-research.code-workspace
\`\`\`

Never add \`peers/clones/\` as a folder in the product workspace.

## Next steps

1. Fill \`SEARCH_TERMS.md\` → dual search (Parallel + Exa) → \`SEARCH_COMPARE.md\`
2. Brainstorm product names in \`NAMING.md\` (slug ≠ product name)
3. \`alternatives-matrix.md\` + \`cd peers && ./sync.sh\`
4. Package PRDs → \`SUPER_PRD.md\` (scope + naming shortlist)
5. \`cd product && just\`

Skill: \`research-clone-bootstrap\` · Command: \`/research-clone-bootstrap\`

**Slug** (\`${SLUG}\`) is the lab id only — not the shipped product name.
EOF

# Product README
cat > "$PRODUCT/README.md" <<EOF
# ${SLUG} (product)

Open-source implementation workspace for a competitor/alternative to:

**${SEED}**

Docs: [\`research/\`](research/) · Peers (clones): [\`../peers/\`](../peers/)

\`\`\`bash
just                  # list
just research-clone-all
just research-workspace
\`\`\`
EOF

# Seed + stubs
cat > "$PRODUCT/research/SEED.md" <<EOF
# Seed

| Field | Value |
|-------|-------|
| URL | ${SEED} |
| Slug | \`${SLUG}\` |
| Lab | \`${LAB}\` |
| Bootstrapped | ${DATE} |

## Classification

- [ ] Proprietary product site (no public app source)
- [ ] Open-source GitHub repo
- [ ] Hybrid (closed app + open extensions/plugins)

## Notes

(Agent fills after fetch.)
EOF

for f in SEARCH_TERMS.md SEARCH_COMPARE.md NAMING.md alternatives-matrix.md SUPER_PRD.md SPEC.md GITHUB.md; do
  sed -e "s/{{SLUG}}/${SLUG}/g" -e "s|{{SEED}}|${SEED}|g" -e "s/{{DATE}}/${DATE}/g" \
    "$TPL/product/research/$f" > "$PRODUCT/research/$f"
done

cp "$TPL/product/research/packages/_TEMPLATE.md" "$PRODUCT/research/packages/_TEMPLATE.md"

# justfile
sed -e "s/{{SLUG}}/${SLUG}/g" "$TPL/product/justfile" > "$PRODUCT/justfile"

# Workspaces
cat > "$PRODUCT/${SLUG}.code-workspace" <<EOF
{
  "folders": [
    { "name": "${SLUG} product", "path": "." }
  ],
  "settings": {
    "files.exclude": {
      "**/.build": true,
      "**/DerivedData": true,
      "**/node_modules": true
    }
  }
}
EOF

cat > "$PEERS/${SLUG}-research.code-workspace" <<EOF
{
  "folders": [
    { "name": "${SLUG} peers", "path": "." },
    { "name": "${SLUG} research docs", "path": "../product/research" }
  ],
  "settings": {
    "files.exclude": { "**/DerivedData": true, "**/.build": true },
    "search.exclude": { "**/.git": true }
  }
}
EOF

# If seed is GitHub, pin as primary upstream clone
if [[ "$SEED" =~ github.com/([^/]+)/([^/#?]+) ]]; then
  owner="${match[1]}"
  repo="${match[2]%.git}"
  echo "${owner}/${repo}" >> "$PEERS/repos.txt"
  echo "Primary upstream added to peers/repos.txt: ${owner}/${repo}"
fi

# Init product git (empty commit-ready)
( cd "$PRODUCT" && git init -b main >/dev/null && git add -A && git commit -m "chore: bootstrap ${SLUG} research+product lab from ${SEED}" >/dev/null )

echo "Created lab: $LAB"
echo "  Product workspace:  cursor $PRODUCT/${SLUG}.code-workspace"
echo "  Research workspace: cursor $PEERS/${SLUG}-research.code-workspace"
echo "Next: agent runs landscape phases (SEARCH_TERMS → Parallel+Exa → NAMING → matrix → PRDs → SUPER_PRD → sync)"
