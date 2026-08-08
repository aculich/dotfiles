#!/usr/bin/env bash
# Shared logging helpers for compendium scripts (source, do not execute).
#
#   COMPENDIUM_LOG=quiet|progress|verbose   (default: progress)
#     quiet    — final summary and errors only (progress + signals muted)
#     progress — rewriting progress line on a TTY (throttled plain lines
#                off-TTY, e.g. launchd logs), plus append-only signal lines
#                for notable events, plus the final summary
#     verbose  — legacy per-path output; the rewriting progress line is
#                disabled so chatty lines do not garble it
#
# All helper output goes to stdout (launchd StandardOutPath); real errors
# should stay on the caller's stderr. Safe under `set -euo pipefail` and
# macOS bash 3.2 (no associative arrays, no ${var^^}).

COMP_LOG_MODE="${COMPENDIUM_LOG:-progress}"
case "${COMP_LOG_MODE}" in
  quiet|progress|verbose) ;;
  *) COMP_LOG_MODE="progress" ;;
esac

if [[ -t 1 ]]; then
  COMP_TTY=1
else
  COMP_TTY=0
fi

_COMP_PROGRESS_ACTIVE=0
_COMP_PROGRESS_LAST_TS=0
# Off-TTY: minimum seconds between emitted progress lines.
COMP_PROGRESS_INTERVAL="${COMP_PROGRESS_INTERVAL:-30}"

comp_now() {
  date +%s
}

# comp_duration_fmt SECONDS -> "3m41s" / "24s"
comp_duration_fmt() {
  local s="${1:-0}" m
  if [[ "${s}" -ge 60 ]]; then
    m=$(( s / 60 ))
    s=$(( s % 60 ))
    printf '%dm%02ds' "${m}" "${s}"
  else
    printf '%ds' "${s}"
  fi
}

# Rewriting (TTY) or throttled (off-TTY) progress line. progress mode only.
comp_progress() {
  if [[ "${COMP_LOG_MODE}" != "progress" ]]; then
    return 0
  fi
  if [[ "${COMP_TTY}" -eq 1 ]]; then
    printf '\r\033[2K%s' "$1"
    _COMP_PROGRESS_ACTIVE=1
  else
    local now
    now="$(comp_now)"
    if [[ $(( now - _COMP_PROGRESS_LAST_TS )) -ge "${COMP_PROGRESS_INTERVAL}" ]]; then
      printf '%s\n' "$1"
      _COMP_PROGRESS_LAST_TS="${now}"
    fi
  fi
}

# Finalize an in-flight progress line with a terminal newline.
comp_progress_done() {
  if [[ "${COMP_LOG_MODE}" != "progress" ]]; then
    return 0
  fi
  if [[ "${COMP_TTY}" -eq 1 ]]; then
    printf '\r\033[2K%s\n' "$1"
    _COMP_PROGRESS_ACTIVE=0
  else
    printf '%s\n' "$1"
  fi
}

# Append-only notable-event line (skills +/~/-, discover deltas, publish …).
# Muted in quiet mode. On a TTY always clears the current line first so a
# parent process's in-flight progress line is never garbled (parent and child
# each source this lib in their own process).
comp_signal() {
  if [[ "${COMP_LOG_MODE}" == "quiet" ]]; then
    return 0
  fi
  if [[ "${COMP_TTY}" -eq 1 ]]; then
    printf '\r\033[2K'
    _COMP_PROGRESS_ACTIVE=0
  fi
  printf '%s\n' "$1"
}

# Legacy chatty output; verbose mode only.
comp_verbose() {
  if [[ "${COMP_LOG_MODE}" != "verbose" ]]; then
    return 0
  fi
  printf '%s\n' "$1"
}
