#!/usr/bin/env bash
# Dry-run inventory of chat/plan artifacts for a project ROOT.
# Emits a markdown table: Path | Kind | Size | Action
set -euo pipefail

INCLUDE_AGENT_TOOLS=0
ROOT_IN=""

usage() {
  cat <<'EOF'
Usage: inventory-chat-artifacts.sh [--include-agent-tools] <project-path>

Prints a markdown inventory table for chatstory-preserve dry-run.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --include-agent-tools) INCLUDE_AGENT_TOOLS=1; shift ;;
    *)
      if [[ -z "$ROOT_IN" ]]; then
        ROOT_IN="$1"
        shift
      else
        echo "error: unexpected arg: $1" >&2
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$ROOT_IN" ]]; then
  usage
  exit 1
fi
if [[ ! -e "$ROOT_IN" ]]; then
  echo "error: path does not exist: $ROOT_IN" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REAL="$(cd "$ROOT_IN" && pwd -P)"
BASE="$(basename "$REAL")"

# Cursor project encoding: strip leading /, replace / with -
# Also try collapsing __ → - (Cursor often normalizes owner__repo folders)
ENCODED="$(printf '%s' "$REAL" | sed 's|^/||; s|/|-|g')"
ENCODED_COLLAPSED="$(printf '%s' "$ENCODED" | sed -E 's/__+/-/g')"
CURSOR_PROJECT=""
for cand in \
  "$HOME/.cursor/projects/$ENCODED" \
  "$HOME/.cursor/projects/$ENCODED_COLLAPSED"
do
  if [[ -d "$cand" ]]; then
    CURSOR_PROJECT="$cand"
    break
  fi
done
# Fallback: case-insensitive basename match under .cursor/projects
if [[ -z "$CURSOR_PROJECT" ]]; then
  while IFS= read -r -d '' d; do
    CURSOR_PROJECT="$d"
    break
  done < <(find "$HOME/.cursor/projects" -maxdepth 1 -type d -iname "*$(printf '%s' "$BASE" | sed -E 's/__+/-/g')*" -print0 2>/dev/null)
fi

# size helper
sz() {
  local p="$1"
  if [[ -e "$p" ]]; then
    du -sh "$p" 2>/dev/null | awk '{print $1}'
  else
    echo "-"
  fi
}

row() {
  # path | kind | size | action
  printf '| `%s` | %s | %s | %s |\n' "$1" "$2" "$3" "$4"
}

echo "## chatstory-preserve inventory"
echo
echo "- **realpath:** \`$REAL\`"
echo

# Resolve partition
PART_OUT="$("$SCRIPT_DIR/resolve-partition.sh" "$REAL")"
PARTITION_ID="$(printf '%s\n' "$PART_OUT" | sed -n 's/^partition_id=//p')"
VAULT_PATH="$(printf '%s\n' "$PART_OUT" | sed -n 's/^vault_path=//p')"
HISTORY_COUNT="$(printf '%s\n' "$PART_OUT" | sed -n 's/^history_count=//p')"
WORKSPACE_KEY="$(printf '%s\n' "$PART_OUT" | sed -n 's/^workspace_key=//p')"

echo '```'
printf '%s\n' "$PART_OUT"
echo '```'
echo
echo "| Path | Kind | Size | Action |"
echo "|------|------|------|--------|"

# SpecStory (root + nested, depth-limited)
while IFS= read -r -d '' ss; do
  rel="${ss#"$REAL"/}"
  row "$ss" "specstory ($rel)" "$(sz "$ss")" "copy-to-pdv"
done < <(find "$REAL" -maxdepth 4 -type d -name '.specstory' -print0 2>/dev/null)

# Chatstory
if [[ "$VAULT_PATH" != "NOT_FOUND" && -n "$VAULT_PATH" ]]; then
  row "$VAULT_PATH" "chatstory ($PARTITION_ID, history=$HISTORY_COUNT)" "$(sz "$VAULT_PATH")" "freshen+pointer"
else
  row "~/.chatstory/.../workspaces/$PARTITION_ID" "chatstory (missing)" "-" "freshen+pointer"
fi

# Cursor project
if [[ -d "$CURSOR_PROJECT" ]]; then
  if [[ -d "$CURSOR_PROJECT/agent-transcripts" ]]; then
    row "$CURSOR_PROJECT/agent-transcripts" "cursor-agent-transcripts" "$(sz "$CURSOR_PROJECT/agent-transcripts")" "copy-to-pdv"
  fi
  if [[ -d "$CURSOR_PROJECT/canvases" ]]; then
    row "$CURSOR_PROJECT/canvases" "cursor-canvases" "$(sz "$CURSOR_PROJECT/canvases")" "copy-to-pdv"
  fi
  if [[ -d "$CURSOR_PROJECT/agent-tools" ]]; then
    if [[ "$INCLUDE_AGENT_TOOLS" -eq 1 ]]; then
      row "$CURSOR_PROJECT/agent-tools" "cursor-agent-tools" "$(sz "$CURSOR_PROJECT/agent-tools")" "copy-to-pdv"
    else
      row "$CURSOR_PROJECT/agent-tools" "cursor-agent-tools" "$(sz "$CURSOR_PROJECT/agent-tools")" "skip"
    fi
  fi
  if [[ -d "$CURSOR_PROJECT/terminals" ]]; then
    row "$CURSOR_PROJECT/terminals" "cursor-terminals" "$(sz "$CURSOR_PROJECT/terminals")" "copy-to-pdv"
  fi
else
  row "$CURSOR_PROJECT" "cursor-project" "-" "skip"
fi

# Project-local plans
if [[ -d "$REAL/.cursor/plans" ]]; then
  row "$REAL/.cursor/plans" "project-plans" "$(sz "$REAL/.cursor/plans")" "copy-to-pdv"
fi

# Global plans — keyword match on basename / slug fragments
# Prefer full path-segment / basename slugs (macosx-tools, universal-inbox).
# Do NOT split into short tokens (avoids "inbox" matching unrelated plans).
PLANS_DIR="$HOME/.cursor/plans"
SLUG_BASE="$(printf '%s' "$BASE" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g')"
KEYWORDS=("$SLUG_BASE" "${SLUG_BASE//-/_}")
# Collapse owner__repo → owner-repo style for matching
KEYWORDS+=("$(printf '%s' "$SLUG_BASE" | sed -E 's/--+/-/g')")
# First segment of basename (macosx from macosx-tools) — length>=6 to avoid short false hits
FIRST_SEG="$(printf '%s' "$SLUG_BASE" | awk -F'[-_]' '{print $1}')"
if [[ ${#FIRST_SEG} -ge 6 ]]; then
  KEYWORDS+=("$FIRST_SEG")
fi
while IFS= read -r seg; do
  [[ -z "$seg" ]] && continue
  case "$seg" in
    users|me|tools|projects|home|var|tmp) continue ;;
  esac
  # Keep whole path segments only (length>=5); hyphen and underscore variants
  KEYWORDS+=("$seg" "${seg//-/_}" "${seg//_/-}")
  # First component of multi-part segment if long enough (universal from universal-inbox)
  fs="$(printf '%s' "$seg" | awk -F'[-_]' '{print $1}')"
  if [[ ${#fs} -ge 6 ]]; then
    KEYWORDS+=("$fs")
  fi
done < <(printf '%s' "$REAL" | tr '/' '\n' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9_-]+/-/g; s/__+/-/g' | awk 'length>=5')

MATCHED_PLANS=0
if [[ -d "$PLANS_DIR" ]]; then
  uniq_kw="$(printf '%s\n' "${KEYWORDS[@]}" | awk 'NF && length>=5' | sort -u | head -40)"
  while IFS= read -r plan; do
    [[ -z "$plan" ]] && continue
    bn="$(basename "$plan" | tr '[:upper:]' '[:lower:]')"
    bn_norm="${bn//_/-}"
    hit=0
    while IFS= read -r kw; do
      [[ -z "$kw" ]] && continue
      kw_norm="${kw//_/-}"
      if [[ "$bn" == *"$kw"* || "$bn_norm" == *"$kw_norm"* ]]; then
        hit=1
        break
      fi
    done <<< "$uniq_kw"
    if [[ "$hit" -eq 1 ]]; then
      row "$plan" "global-plan" "$(sz "$plan")" "copy-to-pdv"
      MATCHED_PLANS=$((MATCHED_PLANS + 1))
    fi
  done < <(find "$PLANS_DIR" -maxdepth 1 -type f -name '*.plan.md' 2>/dev/null | sort)
fi
if [[ "$MATCHED_PLANS" -eq 0 ]]; then
  row "$PLANS_DIR" "global-plans (no keyword match for $SLUG_BASE)" "-" "skip"
fi

# Claude projects — try common encodings
CLAUDE_ROOT="$HOME/.claude/projects"
CLAUDE_HIT=""
if [[ -d "$CLAUDE_ROOT" ]]; then
  # Claude often uses path with leading - and / -> -
  for cand in \
    "$CLAUDE_ROOT/-$(printf '%s' "$REAL" | sed 's|^/||; s|/|-|g')" \
    "$CLAUDE_ROOT/$ENCODED" \
    "$CLAUDE_ROOT/$(printf '%s' "$REAL" | sed 's|/|-|g')"
  do
    if [[ -d "$cand" ]]; then
      CLAUDE_HIT="$cand"
      break
    fi
  done
  # Fallback: scan for directory name containing basename
  if [[ -z "$CLAUDE_HIT" ]]; then
    while IFS= read -r -d '' d; do
      CLAUDE_HIT="$d"
      break
    done < <(find "$CLAUDE_ROOT" -maxdepth 1 -type d -iname "*${BASE}*" -print0 2>/dev/null)
  fi
fi
if [[ -n "$CLAUDE_HIT" ]]; then
  row "$CLAUDE_HIT" "claude-project" "$(sz "$CLAUDE_HIT")" "copy-to-pdv"
else
  row "$CLAUDE_ROOT/*$BASE*" "claude-project" "-" "skip"
fi

# code-workspace files
WS_COUNT=0
while IFS= read -r -d '' ws; do
  row "$ws" "code-workspace" "$(sz "$ws")" "copy-to-pdv"
  WS_COUNT=$((WS_COUNT + 1))
done < <(find "$REAL" -maxdepth 3 -type f -name '*.code-workspace' -print0 2>/dev/null)
if [[ "$WS_COUNT" -eq 0 ]]; then
  row "$REAL/*.code-workspace" "code-workspace" "-" "skip"
fi

echo
YYYY_MM="$(date -u +%Y-%m)"
echo "### Proposed capsule"
echo
echo "\`chatstory-preserve-${PARTITION_ID}/\` under PDV \`vintage-${YYYY_MM}\`"
echo
echo "- **workspace_key:** \`$WORKSPACE_KEY\`"
echo "- **Default:** dry-run only. Apply with \`/chatstory-preserve $REAL --apply\`"
