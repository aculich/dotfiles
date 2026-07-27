# {{PROJECT_LABEL}} — meta umbrella coordination
# Fan-out to lane justfiles. Never overwrite nested repo justfiles from here.

project_label := "{{PROJECT_LABEL}}"
root := justfile_directory()

default:
    @just --list --unsorted

help: default

status:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== {{project_label}} (meta) ==="
    git -C "{{root}}" status -sb 2>/dev/null || echo "(meta not a git repo)"
    for lane in inquiry product studies; do
      if [[ -f "{{root}}/$lane/justfile" ]]; then
        echo ""
        just --justfile "{{root}}/$lane/justfile" --working-directory "{{root}}/$lane" status || true
      elif [[ -d "{{root}}/$lane" ]]; then
        echo ""
        echo "=== $lane (no justfile) ==="
        git -C "{{root}}/$lane" status -sb 2>/dev/null || echo "(missing git)"
      fi
    done

doctor:
    #!/usr/bin/env bash
    set -euo pipefail
    ok=0
    for cmd in git just gh; do
      if command -v "$cmd" >/dev/null 2>&1; then
        echo "OK  $cmd"
      else
        echo "MISS $cmd"
        ok=1
      fi
    done
    command -v parallel-cli >/dev/null 2>&1 && echo "OK  parallel-cli" || echo "warn parallel-cli missing"
    exit "$ok"

# Fan-out: just inquiry status | just product doit | …
inquiry *ARGS:
    just --justfile "{{root}}/inquiry/justfile" --working-directory "{{root}}/inquiry" {{ARGS}}

product *ARGS:
    just --justfile "{{root}}/product/justfile" --working-directory "{{root}}/product" {{ARGS}}

studies *ARGS:
    just --justfile "{{root}}/studies/justfile" --working-directory "{{root}}/studies" {{ARGS}}

doit: status
    #!/usr/bin/env bash
    set -euo pipefail
    just doctor
    if [[ -f "{{root}}/product/SuperPRD.md" ]]; then
      echo "SuperPRD: {{root}}/product/SuperPRD.md"
      command -v open >/dev/null 2>&1 && open "{{root}}/product/SuperPRD.md" || true
    else
      echo "No product/SuperPRD.md yet — continue inquiry → product"
    fi
