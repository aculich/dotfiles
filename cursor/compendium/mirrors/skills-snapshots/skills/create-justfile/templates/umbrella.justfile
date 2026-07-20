# {{PROJECT_LABEL}} — umbrella / coordination justfile
# Root coordinates vendored trees under upstream/; do not overwrite their justfiles.
# Never `cd` before nested `just` — use subshells for compose.

tool := "{{TOOL_SLUG}}"
tool_label := "{{PROJECT_LABEL}}"
upstream_dir := "{{UPSTREAM_DIR}}"
docker_dir := "{{DOCKER_DIR}}"
# Example overlay pattern (adjust paths):
# compose := "docker compose -f docker-compose.yaml -f ../../../local/compose.overlay.yaml"
compose := "docker compose"
ui_url := "{{UI_URL}}"
pin_file := "background/UPSTREAM_PIN.txt"
date := `date +%F`

default:
    @just --list --unsorted

help: default

status:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "{{BOLD}}{{CYAN}}=== {{tool_label}} status ==={{NORMAL}}"
    git status -sb 2>/dev/null || echo "(not a git repo)"
    if [[ -d "{{upstream_dir}}/.git" ]]; then
      echo "Upstream: $(git -C {{upstream_dir}} rev-parse --short HEAD 2>/dev/null || echo missing)"
      dirty="$(git -C {{upstream_dir}} status --porcelain 2>/dev/null || true)"
      if [[ -n "$dirty" ]]; then
        echo "WARNING: upstream tree dirty — prefer local/ overlays"
      else
        echo "Upstream tree: clean"
      fi
    fi
    [[ -f {{pin_file}} ]] && echo "Pin:" && cat {{pin_file}} || echo "Pin file: missing"
    just ps || true

doctor:
    #!/usr/bin/env bash
    set -euo pipefail
    ok=0
    for cmd in git just docker; do
      if command -v "$cmd" >/dev/null 2>&1; then
        echo "OK  $cmd"
      else
        echo "MISS $cmd"
        ok=1
      fi
    done
    docker info >/dev/null 2>&1 || { echo "MISS docker daemon"; ok=1; }
    exit "$ok"

ensure-deps: doctor
    #!/usr/bin/env bash
    set -euo pipefail
    [[ -d "{{docker_dir}}" ]] || { echo "missing docker_dir: {{docker_dir}}"; exit 1; }

ps:
    @cd {{docker_dir}} && {{compose}} ps

start: ensure-deps
    #!/usr/bin/env bash
    set -euo pipefail
    just ps || true
    ( cd {{docker_dir}} && {{compose}} up -d )
    just ps

stop:
    #!/usr/bin/env bash
    set -euo pipefail
    just ps || true
    ( cd {{docker_dir}} && {{compose}} stop )
    just ps

open:
    open "{{ui_url}}"

smoke:
    #!/usr/bin/env bash
    set -euo pipefail
    just ps || true
    curl -sf -o /dev/null -w "%{http_code}\n" "{{ui_url}}/" || \
      curl -sf -o /dev/null -w "%{http_code}\n" "{{ui_url}}/health" || true

# DWIM: deps → start → wait → open → smoke
doit: ensure-deps start
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Waiting for stack..."
    for i in $(seq 1 60); do
      if curl -sf -o /dev/null "{{ui_url}}/" || curl -sf -o /dev/null "{{ui_url}}/health"; then
        echo "HTTP ready"
        break
      fi
      sleep 2
    done
    just open || true
    just smoke
    echo "doit complete — UI at {{ui_url}}"
