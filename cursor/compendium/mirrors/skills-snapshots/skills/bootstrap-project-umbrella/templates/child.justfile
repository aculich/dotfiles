# {{PROJECT_LABEL}} — lane DWIM defaults

project_label := "{{PROJECT_LABEL}}"

default:
    @just --list --unsorted

help: default

status:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== {{project_label}} ==="
    git status -sb 2>/dev/null || echo "(not a git repo)"
    [[ -f README.md ]] && echo "README: present" || echo "README: missing"

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

doit: status
    #!/usr/bin/env bash
    set -euo pipefail
    just doctor
    ls -la 2>/dev/null | head -20
