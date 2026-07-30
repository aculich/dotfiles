# {{TOOL_LABEL}} — tool quickstart metarepo DWIM
# Phase B: `just doit` (doctor → pin → smoke → functional-proof checklist → Phase C prompt)

tool_label := "{{TOOL_LABEL}}"
upstream_url := "{{UPSTREAM_URL}}"
upstream_dir := "{{UPSTREAM_DIR}}"
pin_file := "{{PIN_FILE}}"
root_dir := justfile_directory()

default:
    @just --list --unsorted

help: default

status:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== {{tool_label}} quickstart status ==="
    git status -sb 2>/dev/null || echo "(not a git repo)"
    if [[ -d "{{upstream_dir}}/.git" ]]; then
      echo "Upstream local: $(git -C {{upstream_dir}} rev-parse --short HEAD 2>/dev/null || echo missing)"
      echo "Upstream remote: $(git -C {{upstream_dir}} ls-remote origin HEAD 2>/dev/null | cut -f1 | head -c 12 || echo unavailable)"
    else
      echo "Upstream: {{upstream_dir}} not cloned"
    fi
    [[ -f {{pin_file}} ]] && echo "Pin file:" && cat {{pin_file}} || echo "Pin file: missing (run: just pin)"
    for f in META.md PRAXIS.md EXECSUMMARY.md QUICKSTART.md; do
      if [[ -f "$f" ]]; then
        echo "Doc $f: present"
      fi
    done

doctor:
    #!/usr/bin/env bash
    set -euo pipefail
    ok=0
    for cmd in git just; do
      if command -v "$cmd" >/dev/null 2>&1; then
        echo "OK  $cmd"
      else
        echo "MISS $cmd"
        ok=1
      fi
    done
    if command -v gh >/dev/null 2>&1; then
      echo "OK  gh"
    else
      echo "WARN gh (optional for landscape/API checks)"
    fi
    if [[ -d "{{upstream_dir}}/.git" ]]; then
      echo "OK  upstream clone {{upstream_dir}} @ $(git -C {{upstream_dir}} rev-parse --short HEAD)"
    else
      echo "MISS upstream clone at {{upstream_dir}}"
      ok=1
    fi
    exit "$ok"

ensure-upstream:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -d "{{upstream_dir}}/.git" ]]; then
      echo "Upstream present: $(git -C {{upstream_dir}} rev-parse --short HEAD)"
      exit 0
    fi
    mkdir -p "$(dirname "{{upstream_dir}}")"
    git clone --depth 1 "{{upstream_url}}.git" "{{upstream_dir}}"
    just pin
    echo "Cloned {{upstream_dir}}"

pin:
    #!/usr/bin/env bash
    set -euo pipefail
    [[ -d "{{upstream_dir}}/.git" ]] || { echo "Missing {{upstream_dir}} — run: just ensure-upstream"; exit 1; }
    mkdir -p "$(dirname "{{pin_file}}")"
    {
      echo "upstream: {{upstream_url}}"
      echo "commit: $(git -C {{upstream_dir}} rev-parse HEAD)"
      echo "short: $(git -C {{upstream_dir}} rev-parse --short HEAD)"
      echo "date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
      echo "ref: $(git -C {{upstream_dir}} rev-parse --abbrev-ref HEAD 2>/dev/null || echo DETACHED)"
    } > "{{pin_file}}"
    echo "Wrote {{pin_file}}"
    cat "{{pin_file}}"

# Tool-specific: override in the metarepo once install path is known.
# Default smoke = upstream tree exists + README or obvious entrypoint present.
smoke: ensure-upstream
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== smoke {{tool_label}} ==="
    [[ -d "{{upstream_dir}}" ]] || { echo "FAIL missing {{upstream_dir}}"; exit 1; }
    if [[ -f "{{upstream_dir}}/README.md" ]]; then
      echo "OK  README present"
    else
      echo "WARN no README in upstream"
    fi
    echo "OK  smoke baseline (replace with install/--help/launch checks when known)"

# Phase B DWIM — real path, not a placeholder
doit: doctor ensure-upstream
    #!/usr/bin/env bash
    set -euo pipefail
    just pin
    just smoke
    echo ""
    echo "=== Functional-proof checklist (Phase B) ==="
    echo "Smoke proves the tree/install turns on. Next: prove ONE key function for {{tool_label}}."
    if [[ -f PRAXIS.md ]]; then
      echo "See PRAXIS.md for the intended proof steps."
    else
      echo "Add PRAXIS.md when you know the one key function."
    fi
    echo ""
    echo "=== Open folder ==="
    if command -v open >/dev/null 2>&1; then
      open "{{root_dir}}" || true
    else
      echo "Open: {{root_dir}}"
    fi
    echo ""
    echo "=== Phase C paste prompt (inquiry + per-tool PRD) ==="
    if [[ -f PHASE_C_PROMPT.md ]]; then
      cat PHASE_C_PROMPT.md
    else
      echo "Missing PHASE_C_PROMPT.md — copy from dwim-justfile skill bundle."
    fi

open-folder:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v open >/dev/null 2>&1; then
      open "{{root_dir}}"
    else
      echo "{{root_dir}}"
    fi
