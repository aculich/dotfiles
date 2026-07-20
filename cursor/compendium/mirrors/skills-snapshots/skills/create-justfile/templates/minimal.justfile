# {{PROJECT_LABEL}} — DWIM defaults
# Run bare `just` to list recipes. Customize doit for this project.

project_label := "{{PROJECT_LABEL}}"

default:
    @just --list --unsorted

# Recipe menu (same as bare `just`)
help: default

# Read-only orientation
status:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== {{project_label}} status ==="
    git status -sb 2>/dev/null || echo "(not a git repo)"
    [[ -f README.md ]] && echo "README: present" || echo "README: missing"

# Required tools on PATH
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

# DWIM happy path — replace body when stack is known
doit: status
    #!/usr/bin/env bash
    set -euo pipefail
    echo "doit: fill in the happy path for {{project_label}} (see create-justfile skill)"
    just doctor
