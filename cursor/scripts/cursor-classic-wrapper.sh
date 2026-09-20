#!/usr/bin/env bash
# Inject --classic so desktop `cursor` opens the IDE, not Agents Window (glass).
#
# Cursor 3 routes many folder / .code-workspace opens into Agents Window when
# that was the last focused window. There is no settings.json / argv.json /
# cli-config.json key that makes --classic the default; this wrapper is the
# supported workaround (same flag as `cursor --help`).
#
# Pass-through (no --classic): agent, tunnel, and anything that already has
# --classic or --glass. Disable with CURSOR_CLASSIC=0.
#
# Usage: installed as `cursor` on PATH (see install-cursor-classic-cli.sh).
# Debug: CURSOR_CLASSIC_DEBUG=1 cursor …

set -euo pipefail

abspath() {
  python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"
}

THIS="$(abspath "${BASH_SOURCE[0]}")"

is_app_cli_path() {
  local dest="$1"
  [[ "$dest" == *"/Contents/Resources/app/bin/cursor" || "$dest" == *"/Contents/Resources/app/bin/code" ]]
}

find_real_cursor() {
  if [[ -n "${CURSOR_REAL_BIN:-}" && -x "${CURSOR_REAL_BIN}" ]]; then
    printf '%s\n' "${CURSOR_REAL_BIN}"
    return 0
  fi

  local c dest
  for c in \
    /usr/local/bin/cursor \
    /opt/homebrew/bin/cursor
  do
    if [[ -e "$c" ]]; then
      dest="$(abspath "$c")"
      if [[ "$dest" != "$THIS" && -x "$dest" ]] && is_app_cli_path "$dest"; then
        printf '%s\n' "$dest"
        return 0
      fi
    fi
  done

  for c in \
    "/Applications/Cursor.app/Contents/Resources/app/bin/cursor" \
    "/Applications/Cursor.app/Contents/Resources/app/bin/code" \
    "${HOME}/Applications/Cursor.app/Contents/Resources/app/bin/cursor" \
    "${HOME}/Applications/Cursor.app/Contents/Resources/app/bin/code" \
    "/Applications/Cursor Nightly.app/Contents/Resources/app/bin/cursor" \
    "/Applications/Cursor Nightly.app/Contents/Resources/app/bin/code"
  do
    if [[ -x "$c" ]]; then
      printf '%s\n' "$c"
      return 0
    fi
  done

  local p
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    dest="$(abspath "$p")"
    if [[ "$dest" != "$THIS" && -x "$p" ]]; then
      printf '%s\n' "$p"
      return 0
    fi
  done < <(which -a cursor 2>/dev/null || true)

  return 1
}

REAL="$(find_real_cursor)" || {
  echo "error: could not find Cursor.app CLI (Contents/Resources/app/bin/cursor)" >&2
  exit 127
}

already=0
glass=0
for arg in "$@"; do
  case "$arg" in
    --classic) already=1 ;;
    --glass) glass=1 ;;
  esac
done

first_pos=""
for arg in "$@"; do
  case "$arg" in
    --) break ;;
    -*) continue ;;
    *) first_pos="$arg"; break ;;
  esac
done

run() {
  if [[ "${CURSOR_CLASSIC_DEBUG:-}" == "1" ]]; then
    printf 'cursor-classic-wrapper: %s' "$REAL" >&2
    printf ' %q' "$@" >&2
    printf '\n' >&2
  fi
  exec "$REAL" "$@"
}

if [[ "${CURSOR_CLASSIC:-1}" == "0" || "$already" -eq 1 || "$glass" -eq 1 ]]; then
  run "$@"
fi

case "$first_pos" in
  agent|tunnel)
    run "$@"
    ;;
esac

if [[ "$first_pos" == "editor" ]]; then
  args=()
  seen_editor=0
  for arg in "$@"; do
    args+=("$arg")
    if [[ "$seen_editor" -eq 0 && "$arg" == "editor" ]]; then
      args+=(--classic)
      seen_editor=1
    fi
  done
  run "${args[@]}"
fi

run --classic "$@"
