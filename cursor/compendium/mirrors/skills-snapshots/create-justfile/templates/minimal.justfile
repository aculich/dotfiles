# {{PROJECT_LABEL}} — DWIM defaults
# Run bare `just` to list recipes. Shape doit from stack — never a fill-in placeholder.

project_label := "{{PROJECT_LABEL}}"

default:
    @just --list --unsorted

help: default

status:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== {{project_label}} status ==="
    git status -sb 2>/dev/null || echo "(not a git repo)"
    [[ -f README.md ]] && echo "README: present" || echo "README: missing"
    [[ -f package.json ]] && echo "package.json: present"
    [[ -f pyproject.toml ]] && echo "pyproject.toml: present"
    ls docker-compose*.yml compose.yaml compose.yml 2>/dev/null || true

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
    exit "$ok"

# DWIM orientation when stack-specific path is not yet wired
doit: doctor status
    #!/usr/bin/env bash
    set -euo pipefail
    echo "doit: {{project_label}} — oriented via doctor+status."
    if [[ -f README.md ]]; then
      echo "Next: read README.md and wire a stack-specific happy path (compose/npm/cargo)."
      if command -v open >/dev/null 2>&1; then
        open README.md || true
      fi
    else
      echo "Next: add README or a stack marker (package.json, compose.yaml) then re-run /dwim-justfile apply."
    fi
