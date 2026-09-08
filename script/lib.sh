#!/usr/bin/env bash
# Shared helpers for script/setup, script/preflight and the chezmoi hooks.
# bash 3.2 compatible (macOS /bin/bash) until brew bash lands in wave 1.
# Sourced, not executed.

BOOTSTRAP_LOG_DIR="$HOME/Library/Logs/bootstrap"
BOOTSTRAP_PID="$BOOTSTRAP_LOG_DIR/current.pid"
BOOTSTRAP_LOG="$BOOTSTRAP_LOG_DIR/$(date +%Y-%m-%d).log"

# Inside the background chain stdout IS the log file, so do not tee twice.
_bootstrap_out() {
  if [[ -n "${BOOTSTRAP_CHAIN:-}" ]]; then cat; else tee -a "$BOOTSTRAP_LOG"; fi
}

bootstrap_log() {
  mkdir -p "$BOOTSTRAP_LOG_DIR"
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" | _bootstrap_out
}

bootstrap_die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

# --- Homebrew owner / delegate -------------------------------------------
bootstrap_brew_prefix() {
  if [[ -x /opt/homebrew/bin/brew ]]; then echo /opt/homebrew
  elif [[ -x /usr/local/bin/brew ]]; then echo /usr/local
  else return 1; fi
}

bootstrap_brew_owner() {
  local p
  p="$(bootstrap_brew_prefix)" || return 1
  stat -f %Su "$p"
}

bootstrap_is_owner() {
  [[ "$(bootstrap_brew_owner 2>/dev/null)" == "$(id -un)" ]]
}

# brew as the prefix owner. Owner runs it directly; a delegate impersonates the
# owner with sudo -H so the cache lands in the owner's home, never ours.
# Environment we care about is passed explicitly because sudo resets it.
bootstrap_brew() {
  local p
  p="$(bootstrap_brew_prefix)" || bootstrap_die "no Homebrew prefix"
  if bootstrap_is_owner; then
    HOMEBREW_NO_ENV_HINTS=1 "$p/bin/brew" "$@"
  else
    sudo -Hu "$(bootstrap_brew_owner)" env \
      HOMEBREW_NO_AUTO_UPDATE="${HOMEBREW_NO_AUTO_UPDATE:-}" \
      HOMEBREW_DOWNLOAD_CONCURRENCY="${HOMEBREW_DOWNLOAD_CONCURRENCY:-}" \
      HOMEBREW_NO_ENV_HINTS=1 \
      "$p/bin/brew" "$@"
  fi
}

# `brew bundle` with the Brewfile on stdin, so the owner never has to read a
# path inside another user's home. One brew process at a time.
bootstrap_brew_bundle() {
  local file="$1"
  [[ -f "$file" ]] || bootstrap_die "no Brewfile: $file"
  bootstrap_log "brew bundle  $(basename "$file")"
  bootstrap_brew bundle install --file=- <"$file" 2>&1 | _bootstrap_out
  return "${PIPESTATUS[0]}"
}

bootstrap_brew_bundle_check() {
  local file="$1"
  bootstrap_brew bundle check --file=- <"$file" >/dev/null 2>&1
}

# Names from a Brewfile, for prefetch. Prints "formula NAME" / "cask NAME".
bootstrap_brewfile_names() {
  awk '
    /^brew "/ { gsub(/"/, "", $2); print "formula", $2 }
    /^cask "/ { gsub(/"/, "", $2); print "cask", $2 }
  ' "$1"
}

# Download bottles for a Brewfile without installing. Runs while the previous
# wave installs. Failures are fine: install will fetch what is missing.
bootstrap_brew_fetch_file() {
  local file="$1" kind name
  local formulae=() casks=()
  while read -r kind name; do
    case "$kind" in
      formula) formulae+=("$name") ;;
      cask) casks+=("$name") ;;
    esac
  done < <(bootstrap_brewfile_names "$file")
  if (( ${#formulae[@]} )); then
    bootstrap_brew fetch --deps "${formulae[@]}" >/dev/null 2>&1 || true
  fi
  if (( ${#casks[@]} )); then
    bootstrap_brew fetch --cask "${casks[@]}" >/dev/null 2>&1 || true
  fi
}

# --- sudo keepalive for delegates ------------------------------------------
bootstrap_sudo_keepalive() {
  bootstrap_is_owner && return 0
  sudo -v || bootstrap_die "sudo is required to impersonate the brew owner"
  ( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) 2>/dev/null &
  BOOTSTRAP_KEEPALIVE_PID=$!
}

bootstrap_sudo_keepalive_stop() {
  [[ -n "${BOOTSTRAP_KEEPALIVE_PID:-}" ]] && kill "$BOOTSTRAP_KEEPALIVE_PID" 2>/dev/null || true
}

# --- mise / uv without a live shell ------------------------------------------
bootstrap_mise() {
  local p
  p="$(bootstrap_brew_prefix)" || return 1
  if [[ -x "$p/bin/mise" ]]; then "$p/bin/mise" "$@"; else return 1; fi
}

# --- chain status -----------------------------------------------------------
bootstrap_chain_running() {
  [[ -f "$BOOTSTRAP_PID" ]] && kill -0 "$(cat "$BOOTSTRAP_PID")" 2>/dev/null
}
