# justfile (common layer). `just` lists recipes.
# Installing is script/setup (waves). These recipes are the day-2 surface.

set shell := ["bash", "-euo", "pipefail", "-c"]

# Org overlay recipes live in org.just (not re-rendered by the factory).
import? "org.just"

repo := justfile_directory()
log_dir := env_var('HOME') + "/Library/Logs/bootstrap"

default:
    @just --list --unsorted

# Install everything in waves (shell + Cursor first, rest in background)
setup:
    {{repo}}/script/setup

# Read-only machine-layer check; `just preflight fix` repairs what is safe
preflight mode="":
    {{repo}}/script/preflight {{ if mode == "fix" { "--fix" } else { "" } }}

# Progress of the background chain; `just status wait` blocks until done
status mode="":
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{repo}}/script/lib.sh"
    if [[ "{{mode}}" == "wait" || "{{mode}}" == "--wait" ]]; then
        if bootstrap_chain_running; then
            echo "waiting for the install chain (pid $(cat "$BOOTSTRAP_PID")) ..."
            tail -n 0 -f "$BOOTSTRAP_LOG" & tp=$!
            while bootstrap_chain_running; do sleep 3; done
            kill "$tp" 2>/dev/null || true
        fi
    fi
    if bootstrap_chain_running; then echo "chain: running (pid $(cat "$BOOTSTRAP_PID"))"; else echo "chain: not running"; fi
    echo "log:   $BOOTSTRAP_LOG"
    [[ -f "$BOOTSTRAP_LOG" ]] && tail -n 5 "$BOOTSTRAP_LOG" | sed 's/^/  /'
    echo ""
    for f in "{{repo}}"/brew/[0-4]*.Brewfile; do
        if bootstrap_brew_bundle_check "$f"; then printf '  ok       %s\n' "$(basename "$f")"; else printf '  MISSING  %s\n' "$(basename "$f")"; fi
    done

# Same as `just status wait`
status-wait:
    @just status wait

# Install one layer by name: just bundle 10-common | pdf-ocr | media | data-heavy
bundle layer:
    #!/usr/bin/env bash
    set -euo pipefail
    . "{{repo}}/script/lib.sh"
    if [[ "{{layer}}" == data-heavy ]]; then
        bootstrap_sudo_keepalive
        bootstrap_brew_bundle "{{repo}}/brew/pdf-ocr.Brewfile"
        bootstrap_brew_bundle "{{repo}}/brew/media.Brewfile"
        exit 0
    fi
    f="{{repo}}/brew/{{layer}}.Brewfile"
    [[ -f "$f" ]] || f="$(ls "{{repo}}"/brew/*-{{layer}}.Brewfile 2>/dev/null | head -1)"
    # A personal overlay may carry its own opt-in layers (e.g. keyboard-hid).
    [[ -f "$f" ]] || f="$HOME/src/dotfiles-private/brew/{{layer}}.Brewfile"
    [[ -f "$f" ]] || { echo "no such layer: {{layer}}  (ls brew/ and ~/src/dotfiles-private/brew/)" >&2; exit 1; }
    bootstrap_sudo_keepalive
    bootstrap_brew_bundle "$f"

# Re-apply dotfiles from this repo (hooks re-run only when their inputs changed)
apply:
    chezmoi apply --source {{repo}}

# Preview what apply would change
diff:
    chezmoi diff --source {{repo}}

# Personal overlay (me only): second chezmoi source with its own state
apply-private:
    #!/usr/bin/env bash
    set -euo pipefail
    src="$HOME/src/dotfiles-private"
    [[ -d "$src" ]] || { echo "no $src; clone aculich/dotfiles-private first" >&2; exit 1; }
    cfg="$HOME/.config/chezmoi/private.toml"
    if [[ ! -f "$cfg" && -x "$src/script/setup" ]]; then "$src/script/setup"; fi
    [[ -f "$cfg" ]] || { echo "no $cfg; see dotfiles-private README" >&2; exit 1; }
    chezmoi --config "$cfg" apply --force
    if [[ -f "$src/brew/personal.Brewfile" ]]; then
        . "{{repo}}/script/lib.sh"
        bootstrap_brew_bundle "$src/brew/personal.Brewfile"
    fi

# Doctor: brew owner, chezmoi, mise, shell startup
doctor:
    #!/usr/bin/env bash
    set -uo pipefail
    . "{{repo}}/script/lib.sh"
    echo "user:        $(id -un)"
    echo "brew prefix: $(bootstrap_brew_prefix || echo none)  owner: $(bootstrap_brew_owner || echo none)"
    echo "chezmoi:     $(command -v chezmoi || echo missing)"
    echo "mise:        $(command -v mise || echo missing)"
    echo "uv:          $(command -v uv || (command -v mise >/dev/null && mise which uv 2>/dev/null) || echo missing)"
    echo "starship:    $(command -v starship || echo missing)"
    echo "Cursor:      $([[ -d /Applications/Cursor.app ]] && echo present || echo missing)"
    echo "iTerm2:      $([[ -d /Applications/iTerm.app ]] && echo present || echo missing)"
    echo "identity:    $(git config user.email || echo 'NOT SET (overlay writes ~/.config/git/identity)')"
    echo ""
    just status

# Shell startup time (target: < 100 ms once everything is installed)
bench:
    #!/usr/bin/env bash
    if command -v hyperfine >/dev/null 2>&1; then
        hyperfine --warmup 3 --runs 20 'zsh -i -c exit'
    else
        for i in 1 2 3 4 5; do /usr/bin/time -p zsh -i -c exit 2>&1 | awk '/real/{print $2 " s"}'; done
    fi

# Drift: what changed since the last whatbroke snapshot
drift:
    whatbroke today || echo "whatbroke not installed yet (wave 4)"
