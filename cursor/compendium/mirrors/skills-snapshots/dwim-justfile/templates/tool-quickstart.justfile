# {{TOOL_LABEL}} — tool quickstart metarepo DWIM
# Phases: see PHASES.md | B = just doit | D lineages = just scaffold-lineages

tool_label := "{{TOOL_LABEL}}"
upstream_url := "{{UPSTREAM_URL}}"
upstream_dir := "{{UPSTREAM_DIR}}"
pin_file := "{{PIN_FILE}}"
root_dir := justfile_directory()
gh_owner := "{{GH_OWNER}}"
upstream_owner := "{{UPSTREAM_OWNER}}"
upstream_repo := "{{UPSTREAM_REPO}}"
public_fork_name := "{{PUBLIC_FORK_NAME}}"
personal_repo := "{{PERSONAL_REPO}}"
team_repo := "{{TEAM_REPO}}"

default:
    @just --list --unsorted

help: default

status:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== {{tool_label}} metarepo status ==="
    git status -sb 2>/dev/null || echo "(not a git repo)"
    if [[ -d "{{upstream_dir}}/.git" ]]; then
      echo "Upstream local: $(git -C {{upstream_dir}} rev-parse --short HEAD 2>/dev/null || echo missing)"
    else
      echo "Upstream: {{upstream_dir}} not cloned"
    fi
    [[ -f {{pin_file}} ]] && echo "Pin file:" && cat {{pin_file}} || echo "Pin file: missing (run: just pin)"
    for f in META.md PRAXIS.md EXECSUMMARY.md PRD.md PHASES.md FORKS.md PLAYBOOK.md; do
      [[ -f "$f" ]] && echo "Doc $f: present"
    done
    for d in forks/public forks/personal forks/team; do
      [[ -d "$d/.git" ]] && echo "OK  $d" || echo "MISS $d"
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
      echo "WARN gh (needed for scaffold-lineages)"
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

# Extract ## Phase X section from PHASES.md (through next ## or EOF)
_phase-brief PHASE:
    #!/usr/bin/env bash
    set -euo pipefail
    [[ -f PHASES.md ]] || { echo "Missing PHASES.md"; exit 1; }
    awk -v p="{{PHASE}}" '
      $0 ~ "^## Phase " p " " || $0 ~ "^## Phase " p " —" || $0 ~ "^## Phase " p "$" {show=1}
      show && $0 ~ /^## Phase / && $0 !~ "^## Phase " p {exit}
      show {print}
    ' PHASES.md

# Phase B DWIM
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
    echo "=== Next: Phase C (from PHASES.md) ==="
    just _phase-brief C

# just phase A|B|C|D|R|E
phase name:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{name}}" in
      A|a)
        echo "Phase A is the bootstrap skill (/bootstrap-quickstart), not re-run here."
        just _phase-brief A
        ;;
      B|b)
        just doit
        ;;
      C|c)
        just _phase-brief C
        ;;
      D|d)
        just _phase-brief D
        echo ""
        echo "Machine next: just scaffold-lineages   (WITHOUT_TEAM=1 to skip team)"
        ;;
      R|r)
        just _phase-brief R
        echo ""
        echo "Machine next: just scaffold-runtime"
        ;;
      E|e)
        just _phase-brief E
        ;;
      *)
        echo "Usage: just phase A|B|C|D|R|E"
        exit 1
        ;;
    esac

# Run B then hand off toward C→D→R
phases:
    #!/usr/bin/env bash
    set -euo pipefail
    just phase B
    echo ""
    echo "=== Kit hand-off ==="
    echo "Phase B done. Continue: just phase C → scaffold-lineages → phase D → scaffold-runtime → phase R"
    echo "Branch tip: git checkout -b regen/<laptop> before regenerating (generate-and-compare)."

# Phase D: public GitHub fork + personal private + team private (unless WITHOUT_TEAM=1)
scaffold-lineages:
    #!/usr/bin/env bash
    set -euo pipefail
    command -v gh >/dev/null || { echo "MISS gh"; exit 1; }
    [[ -d "{{upstream_dir}}/.git" ]] || just ensure-upstream
    mkdir -p forks

    echo "=== Public GitHub fork {{gh_owner}}/{{public_fork_name}} ==="
    if gh repo view "{{gh_owner}}/{{public_fork_name}}" >/dev/null 2>&1; then
      echo "ATTACH existing {{gh_owner}}/{{public_fork_name}}"
    else
      gh repo fork "{{upstream_owner}}/{{upstream_repo}}" --fork-name "{{public_fork_name}}" --clone=false
      echo "CREATED fork {{gh_owner}}/{{public_fork_name}}"
    fi
    if [[ ! -d forks/public/.git ]]; then
      gh repo clone "{{gh_owner}}/{{public_fork_name}}" forks/public
    else
      echo "OK  forks/public present"
    fi

    _private_fork() {
      local name="$1" dest="$2"
      echo "=== Private fork {{gh_owner}}/$name → $dest ==="
      if gh repo view "{{gh_owner}}/$name" >/dev/null 2>&1; then
        echo "ATTACH existing {{gh_owner}}/$name"
      else
        gh repo create "{{gh_owner}}/$name" --private --description "{{tool_label}} private fork (metarepo lineage)" >/dev/null
        # Seed main with full history of that branch (shallow push lacks parent objects)
        local tmp
        tmp="$(mktemp -d)"
        git clone --branch main --single-branch "{{upstream_url}}.git" "$tmp/src"
        git -C "$tmp/src" remote remove origin
        git -C "$tmp/src" remote add origin "git@github.com:{{gh_owner}}/$name.git"
        if ! git -C "$tmp/src" push -u origin main; then
          git -C "$tmp/src" remote set-url origin "https://github.com/{{gh_owner}}/$name.git"
          git -C "$tmp/src" push -u origin main
        fi
        rm -rf "$tmp"
        echo "CREATED private {{gh_owner}}/$name (main seeded from upstream)"
      fi
      if [[ ! -d "$dest/.git" ]]; then
        gh repo clone "{{gh_owner}}/$name" "$dest"
      fi
      git -C "$dest" remote remove upstream 2>/dev/null || true
      git -C "$dest" remote add upstream "{{upstream_url}}.git"
      git -C "$dest" remote -v
    }

    _private_fork "{{personal_repo}}" forks/personal

    if [[ "${WITHOUT_TEAM:-}" == "1" ]]; then
      echo "SKIP team (WITHOUT_TEAM=1)"
    else
      _private_fork "{{team_repo}}" forks/team
    fi

    echo ""
    echo "scaffold-lineages done. Next: write FORKS.md + PLAYBOOK.md (just phase D brief)."

# Phase R: ensure forks + print runtime checklist (agent writes recipes)
scaffold-runtime:
    #!/usr/bin/env bash
    set -euo pipefail
    just ensure-upstream
    mkdir -p forks dossier/overlays
    missing=0
    for d in forks/public forks/personal forks/team; do
      if [[ -d "$d/.git" ]]; then
        echo "OK  $d"
      else
        echo "MISS $d — run: just scaffold-lineages"
        missing=1
      fi
    done
    if [[ -d "{{upstream_dir}}" ]]; then
      if ls "{{upstream_dir}}"/*.xcodeproj >/dev/null 2>&1 || ls "{{upstream_dir}}"/**/*.xcodeproj >/dev/null 2>&1; then
        echo "SHAPE xcodeproj detected — prefer LOCAL_BUILD recipes"
      fi
      if [[ -f "{{upstream_dir}}/Casks" ]] || grep -qi homebrew "{{upstream_dir}}/README.md" 2>/dev/null; then
        echo "SHAPE brew hints in upstream README — consider cask for Upstream track"
      fi
    fi
    echo ""
    echo "=== Phase R checklist ==="
    echo "1. Agent: just phase R (write just recipes + flavor xcconfigs + deepen PRAXIS/PLAYBOOK)"
    echo "2. Upstream install on this Mac"
    echo "3. Personal/team flavors with io.github.aculich.* bundle IDs; push forks"
    echo "4. Rewrite doit to daily-driver DWIM; prove one key function"
    [[ "$missing" -eq 0 ]] || exit 1

# Fresh laptop / after Phase R: lineages then daily-driver doit
bootstrap-machine: scaffold-lineages
    #!/usr/bin/env bash
    set -euo pipefail
    echo "=== bootstrap-machine ==="
    just scaffold-runtime || true
    just doit
    echo "bootstrap-machine finished — if doit is still smoke-only, complete Phase R first."

open-folder:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v open >/dev/null 2>&1; then
      open "{{root_dir}}"
    else
      echo "{{root_dir}}"
    fi
