#!/usr/bin/env bash
set -euo pipefail

ROOT="${CURSOR_COMPENDIUM_ROOT:?Set CURSOR_COMPENDIUM_ROOT}"
cd "${ROOT}"
DOTFILES_CURSOR="${DOTFILES_CURSOR:-$HOME/dotfiles/cursor}"

publish() {
  # Default: commit + push to the private ops remote after every snapshot.
  # Set COMPENDIUM_AUTO_PUSH=0 for a local-only dry snapshot.
  if [[ "${COMPENDIUM_AUTO_PUSH:-1}" != "0" ]]; then
    if [[ -x "${ROOT}/scripts/commit-and-push.sh" ]]; then
      "${ROOT}/scripts/commit-and-push.sh"
    else
      echo "snapshot-all: warn: commit-and-push.sh missing; skipped publish" >&2
    fi
  else
    echo "snapshot-all: COMPENDIUM_AUTO_PUSH=0; skipped commit+push"
  fi
}

# Global + agents skills mirror (snapshot scripts live in dotfiles/cursor).
# Inventory invent: scripts/discover-skills.py is a shim → $AGENT_SKILLS_ROOT (canonical).
if [[ -x "${DOTFILES_CURSOR}/scripts/snapshot-skills.sh" ]]; then
  "${DOTFILES_CURSOR}/scripts/snapshot-skills.sh" "${ROOT}/mirrors/skills-snapshots"
fi
if [[ -f "${ROOT}/scripts/discover-skills.py" && "${SKILL_DISCOVER:-1}" != "0" ]]; then
  python3 "${ROOT}/scripts/discover-skills.py" --compendium-root "${ROOT}"
fi

# Regenerate project-paths.txt from Cursor storage + disk scan (unless disabled).
# Set COMPENDIUM_AUTO_DISCOVER=0 to skip.
if [[ -f "${ROOT}/scripts/discover-project-paths.py" && "${COMPENDIUM_AUTO_DISCOVER:-1}" != "0" ]]; then
  python3 "${ROOT}/scripts/discover-project-paths.py" --compendium-root "${ROOT}"
fi

"${ROOT}/scripts/sync-global-plans.sh"

PATHS="${ROOT}/project-paths.txt"
if [[ ! -f "${PATHS}" ]]; then
  echo "No ${PATHS}; only global plans synced. Run discover-project-paths.py or copy project-paths.example.txt."
  echo "snapshot-all complete."
  publish
  exit 0
fi

while IFS=$'\t' read -r slug path; do
  [[ -z "${slug}" || "${slug}" =~ ^# ]] && continue
  [[ -z "${path}" ]] && continue
  "${ROOT}/scripts/snapshot-project.sh" "${slug}" "${path}"
done < "${PATHS}"

echo "snapshot-all complete."
publish
