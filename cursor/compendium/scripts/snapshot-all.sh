#!/usr/bin/env bash
set -euo pipefail

ROOT="${CURSOR_COMPENDIUM_ROOT:?Set CURSOR_COMPENDIUM_ROOT}"
cd "${ROOT}"
DOTFILES_CURSOR="${DOTFILES_CURSOR:-$HOME/dotfiles/cursor}"

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
  exit 0
fi

while IFS=$'\t' read -r slug path; do
  [[ -z "${slug}" || "${slug}" =~ ^# ]] && continue
  [[ -z "${path}" ]] && continue
  "${ROOT}/scripts/snapshot-project.sh" "${slug}" "${path}"
done < "${PATHS}"

echo "snapshot-all complete."
