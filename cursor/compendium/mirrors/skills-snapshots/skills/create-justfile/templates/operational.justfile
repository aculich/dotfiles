# {{PROJECT_LABEL}} — operational (single package) justfile
# Thin wrappers over npm/cargo/etc. Not the umbrella DWIM surface.

default:
    @just --list --unsorted

help: default

status:
    #!/usr/bin/env bash
    set -euo pipefail
    git status -sb 2>/dev/null || true
    [[ -f package.json ]] && node -p "require('./package.json').name + '@' + require('./package.json').version" 2>/dev/null || true

doctor:
    #!/usr/bin/env bash
    set -euo pipefail
    ok=0
    for cmd in git just; do
      command -v "$cmd" >/dev/null 2>&1 && echo "OK  $cmd" || { echo "MISS $cmd"; ok=1; }
    done
    # Add node/npm, cargo, etc. as needed for this package
    command -v npm >/dev/null 2>&1 && echo "OK  npm" || echo "MISS npm (if this is a JS package)"
    exit "$ok"

install:
    npm install

run:
    npm run dev

build:
    npm run build

lint:
    npm run lint

# Happy path for local work on this package
doit: doctor install
    #!/usr/bin/env bash
    set -euo pipefail
    just run
