#!/usr/bin/env bash
set -euo pipefail

ROOT="${CURSOR_COMPENDIUM_ROOT:?Set CURSOR_COMPENDIUM_ROOT}"
cd "${ROOT}"
DOTFILES_CURSOR="${DOTFILES_CURSOR:-$HOME/dotfiles/cursor}"

# ------------------------------------------------------------------
# Logging (COMPENDIUM_LOG=quiet|progress|verbose; see lib/logging.sh)
# ------------------------------------------------------------------
if [[ -f "${ROOT}/scripts/lib/logging.sh" ]]; then
  # shellcheck source=lib/logging.sh
  source "${ROOT}/scripts/lib/logging.sh"
else
  # Fallback stubs so an un-synced ops tree still runs (chatty but safe).
  COMP_LOG_MODE="${COMPENDIUM_LOG:-verbose}"
  comp_now() { date +%s; }
  comp_duration_fmt() { printf '%ss' "${1:-0}"; }
  comp_progress() { :; }
  comp_progress_done() { printf '%s\n' "$1"; }
  comp_signal() { printf '%s\n' "$1"; }
  comp_verbose() { printf '%s\n' "$1"; }
fi

# Children (snapshot-project.sh, snapshot-skills.sh) read this directly.
export COMPENDIUM_LOG="${COMP_LOG_MODE}"
# Mute the [discover +N.Ns] tick spam from discover-skills.py unless verbose.
if [[ "${COMP_LOG_MODE}" != "verbose" ]]; then
  export DISCOVER_QUIET=1
fi

T_RUN_START="$(comp_now)"
SECS_SKILLS=0
SECS_DISCOVER=0
SECS_PROJECTS=0
SECS_PUBLISH=0
PROJECT_TOTAL=0
PUBLISH_OUTCOME="not run"
PUBLISH_SHA=""

# ------------------------------------------------------------------
# Publish (commit + push to the private ops remote; COMPENDIUM_AUTO_PUSH=0 skips)
# ------------------------------------------------------------------
publish() {
  local t0 head_before head_after ahead upstream
  t0="$(comp_now)"
  if [[ "${COMPENDIUM_AUTO_PUSH:-1}" != "0" ]]; then
    if [[ -x "${ROOT}/scripts/commit-and-push.sh" ]]; then
      head_before="$(git -C "${ROOT}" rev-parse HEAD 2>/dev/null || echo none)"
      "${ROOT}/scripts/commit-and-push.sh"
      head_after="$(git -C "${ROOT}" rev-parse HEAD 2>/dev/null || echo none)"
      if [[ "${head_after}" != "${head_before}" && "${head_after}" != "none" ]]; then
        PUBLISH_SHA="$(git -C "${ROOT}" rev-parse --short HEAD)"
        PUBLISH_OUTCOME="committed ${PUBLISH_SHA}"
      else
        PUBLISH_OUTCOME="nothing to commit"
      fi
      upstream="$(git -C "${ROOT}" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || true)"
      if [[ -n "${upstream}" ]]; then
        ahead="$(git -C "${ROOT}" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo '?')"
        if [[ "${ahead}" == "0" ]]; then
          PUBLISH_OUTCOME="${PUBLISH_OUTCOME}, up to date with ${upstream}"
        else
          PUBLISH_OUTCOME="${PUBLISH_OUTCOME}, ${ahead} ahead of ${upstream}"
        fi
      fi
    else
      echo "snapshot-all: warn: commit-and-push.sh missing; skipped publish" >&2
      PUBLISH_OUTCOME="skipped (commit-and-push.sh missing)"
    fi
  else
    comp_signal "publish skipped (COMPENDIUM_AUTO_PUSH=0)"
    PUBLISH_OUTCOME="skipped (COMPENDIUM_AUTO_PUSH=0)"
  fi
  SECS_PUBLISH=$(( $(comp_now) - t0 ))
}

# ------------------------------------------------------------------
# Summary helpers
# ------------------------------------------------------------------
count_dir() {
  # entries in a directory (0 when missing)
  if [[ -d "$1" ]]; then
    ls -1 "$1" 2>/dev/null | wc -l | tr -d ' '
  else
    echo 0
  fi
}

read_discover_counts() {
  # -> "known scan orphans stale" (empty when report missing/unreadable)
  python3 - "${ROOT}/discover-report.json" <<'PY' 2>/dev/null || true
import json, sys
try:
    d = json.load(open(sys.argv[1]))
    print(d.get("cursor_known_count", 0), d.get("scan_found_count", 0),
          d.get("orphans_count", 0), d.get("stale_known_count", 0))
except Exception:
    pass
PY
}

read_inventory_line() {
  # -> "global project unresolved" (empty when inventory missing/unreadable)
  python3 - "${ROOT}/skills-registry/skills-inventory.json" <<'PY' 2>/dev/null || true
import json, sys
try:
    d = json.load(open(sys.argv[1]))
    g = sum(len(v) for v in d.get("global", {}).values())
    p = len(d.get("project", []))
    u = d.get("summary", {}).get("unknown_source", "?")
    if isinstance(u, list):
        u = len(u)
    print(g, p, u)
except Exception:
    pass
PY
}

skill_drift_status() {
  # "none" when live trees match the ops mirror; else "yes"
  local mirror="${ROOT}/mirrors/skills-snapshots" out
  local excl=(--exclude '.git/' --exclude '__pycache__/' --exclude '*.pyc'
              --exclude '.DS_Store' --exclude 'node_modules/' --exclude '.venv/')
  local pair
  for pair in "$HOME/.cursor/skills:skills" \
              "$HOME/.cursor/skills-cursor:skills-cursor" \
              "$HOME/.agents/skills:agents-skills"; do
    local live="${pair%%:*}" dst="${pair##*:}"
    [[ -d "${live}" ]] || continue
    out="$(rsync -rniL --delete "${excl[@]}" "${live}/" "${mirror}/${dst}/" 2>/dev/null | head -1 || true)"
    if [[ -n "${out}" ]]; then
      echo "yes"
      return 0
    fi
  done
  echo "none"
}

print_summary() {
  local total_secs live_c live_cc live_a mir_c mir_cc mir_a drift inv disc git_line
  total_secs=$(( $(comp_now) - T_RUN_START ))

  live_c="$(count_dir "$HOME/.cursor/skills")"
  live_cc="$(count_dir "$HOME/.cursor/skills-cursor")"
  live_a="$(count_dir "$HOME/.agents/skills")"
  mir_c="$(count_dir "${ROOT}/mirrors/skills-snapshots/skills")"
  mir_cc="$(count_dir "${ROOT}/mirrors/skills-snapshots/skills-cursor")"
  mir_a="$(count_dir "${ROOT}/mirrors/skills-snapshots/agents-skills")"
  drift="$(skill_drift_status)"
  inv="$(read_inventory_line)"
  disc="$(read_discover_counts)"

  echo ""
  echo "======== summary ========"
  echo "skills live/mirror: ${live_c}/${mir_c}  ${live_cc}/${mir_cc}  ${live_a}/${mir_a}   drift: ${drift}"
  if [[ -n "${inv}" ]]; then
    set -- ${inv}
    echo "inventory: ${1:-?} global, ${2:-?} project-local   unresolved: ${3:-?}"
  else
    echo "inventory: (no skills-inventory.json)"
  fi
  if [[ -n "${disc}" ]]; then
    set -- ${disc}
    echo "projects: ${PROJECT_TOTAL}   known=${1:-?} scan=${2:-?} orphans=${3:-?} stale=${4:-?}"
  else
    echo "projects: ${PROJECT_TOTAL}   (no discover-report.json)"
  fi
  echo "duration: $(comp_duration_fmt "${total_secs}")   skills $(comp_duration_fmt "${SECS_SKILLS}") | discover $(comp_duration_fmt "${SECS_DISCOVER}") | projects $(comp_duration_fmt "${SECS_PROJECTS}") | publish $(comp_duration_fmt "${SECS_PUBLISH}")"
  git_line="git: ${PUBLISH_OUTCOME}"
  if [[ "${COMPENDIUM_AUTO_PUSH:-1}" != "0" && "${PUBLISH_OUTCOME}" != "not run" && "${PUBLISH_OUTCOME}" != skipped* ]]; then
    git_line="${git_line}  |  remote PRIVATE ok"
  fi
  echo "${git_line}"
  echo "tip: git -C ${ROOT} show --stat HEAD"
  echo "========================="
}

# ------------------------------------------------------------------
# Phase: global + agents skills mirror (script lives in dotfiles/cursor)
# ------------------------------------------------------------------
t0="$(comp_now)"
comp_progress "skills: mirroring 3 trees..."
if [[ -x "${DOTFILES_CURSOR}/scripts/snapshot-skills.sh" ]]; then
  "${DOTFILES_CURSOR}/scripts/snapshot-skills.sh" "${ROOT}/mirrors/skills-snapshots"
fi
SECS_SKILLS=$(( $(comp_now) - t0 ))

# ------------------------------------------------------------------
# Phase: discover (skills inventory + project paths)
# ------------------------------------------------------------------
t0="$(comp_now)"
PREV_DISC="$(read_discover_counts)"

comp_progress "discover: skills inventory..."
if [[ -f "${ROOT}/scripts/discover-skills.py" && "${SKILL_DISCOVER:-1}" != "0" ]]; then
  if [[ "${COMP_LOG_MODE}" == "verbose" ]]; then
    python3 "${ROOT}/scripts/discover-skills.py" --compendium-root "${ROOT}"
  else
    # Keep real warnings/errors, drop the routine "Wrote ..." status lines
    # (the summary reports inventory totals instead).
    errf="$(mktemp)"
    if python3 "${ROOT}/scripts/discover-skills.py" --compendium-root "${ROOT}" 2>"${errf}"; then
      grep -Ev '^(Wrote|Also wrote) ' "${errf}" >&2 || true
      rm -f "${errf}"
    else
      rc=$?
      cat "${errf}" >&2
      rm -f "${errf}"
      exit "${rc}"
    fi
  fi
fi

comp_progress "discover: project paths..."
if [[ -f "${ROOT}/scripts/discover-project-paths.py" && "${COMPENDIUM_AUTO_DISCOVER:-1}" != "0" ]]; then
  if [[ "${COMP_LOG_MODE}" == "verbose" ]]; then
    python3 "${ROOT}/scripts/discover-project-paths.py" --compendium-root "${ROOT}"
  else
    python3 "${ROOT}/scripts/discover-project-paths.py" --compendium-root "${ROOT}" >/dev/null
  fi
fi
SECS_DISCOVER=$(( $(comp_now) - t0 ))

NEW_DISC="$(read_discover_counts)"
if [[ -n "${NEW_DISC}" ]]; then
  set -- ${NEW_DISC}
  comp_progress_done "discover $(comp_duration_fmt "${SECS_DISCOVER}")  known=${1:-?} scan=${2:-?} orphans=${3:-?} stale=${4:-?}"
  if [[ -n "${PREV_DISC}" && "${NEW_DISC}" != "${PREV_DISC}" ]]; then
    comp_signal "discover changed: was [known scan orphans stale] = ${PREV_DISC}, now ${NEW_DISC}"
  fi
fi

# ------------------------------------------------------------------
# Phase: global plans + per-project snapshots
# ------------------------------------------------------------------
t0="$(comp_now)"
if [[ "${COMP_LOG_MODE}" == "verbose" ]]; then
  "${ROOT}/scripts/sync-global-plans.sh"
else
  "${ROOT}/scripts/sync-global-plans.sh" >/dev/null
fi

PATHS="${ROOT}/project-paths.txt"
if [[ ! -f "${PATHS}" ]]; then
  echo "No ${PATHS}; only global plans synced. Run discover-project-paths.py or copy project-paths.example.txt."
  SECS_PROJECTS=$(( $(comp_now) - t0 ))
  publish
  print_summary
  exit 0
fi

PROJECT_TOTAL="$(awk -F'\t' 'NF >= 2 && $1 !~ /^[[:space:]]*#/ && $1 != "" { n++ } END { print n+0 }' "${PATHS}")"
i=0
while IFS=$'\t' read -r slug path; do
  [[ -z "${slug}" || "${slug}" =~ ^# ]] && continue
  [[ -z "${path}" ]] && continue
  i=$(( i + 1 ))
  if [[ "${PROJECT_TOTAL}" -gt 0 ]]; then
    comp_progress "projects  ${i}/${PROJECT_TOTAL}  ($(( i * 100 / PROJECT_TOTAL ))%)  ${slug}"
  fi
  "${ROOT}/scripts/snapshot-project.sh" "${slug}" "${path}"
done < "${PATHS}"
SECS_PROJECTS=$(( $(comp_now) - t0 ))
comp_progress_done "projects  ${i}/${PROJECT_TOTAL}  (100%)  ($(comp_duration_fmt "${SECS_PROJECTS}"))"

comp_verbose "snapshot-all complete."

# ------------------------------------------------------------------
# Publish + summary
# ------------------------------------------------------------------
publish
print_summary
