#!/usr/bin/env bash
# Pin a freeze HTML blob: sha256 + oldest origin/main commit matching it.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: pin-freeze-blob.sh --repo DIR --path RELPATH [--url URL | --rev REV]

Prints sha256, byte length, and the oldest origin/main commit whose
RELPATH blob equals the target. Target is:
  --url  fetch live bytes (Pages freeze)
  --rev  git show REV:RELPATH
  (neither) use origin/main:RELPATH

Exit 2 if --url sha256 matches no blob on origin/main (Pages out of sync).
EOF
}

REPO=""
PATH_REL=""
URL=""
REV=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="${2:-}"; shift 2 ;;
    --path) PATH_REL="${2:-}"; shift 2 ;;
    --url) URL="${2:-}"; shift 2 ;;
    --rev) REV="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ -z "$REPO" || -z "$PATH_REL" ]]; then
  usage >&2
  exit 1
fi
if [[ -n "$URL" && -n "$REV" ]]; then
  echo "use --url or --rev, not both" >&2
  exit 1
fi

REPO="$(cd "$REPO" && pwd)"
cd "$REPO"

git fetch origin main --prune >/dev/null 2>&1 || true

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

if [[ -n "$URL" ]]; then
  curl -fsSL "$URL" -o "$tmp"
  SOURCE="url:$URL"
elif [[ -n "$REV" ]]; then
  git show "${REV}:${PATH_REL}" > "$tmp"
  SOURCE="rev:${REV}:${PATH_REL}"
else
  git show "origin/main:${PATH_REL}" > "$tmp"
  SOURCE="origin/main:${PATH_REL}"
fi

BYTES="$(wc -c < "$tmp" | tr -d ' ')"
SHA="$(shasum -a 256 "$tmp" | awk '{print $1}')"

oldest=""
while IFS= read -r commit; do
  blob="$(git show "${commit}:${PATH_REL}" 2>/dev/null | shasum -a 256 | awk '{print $1}')" || continue
  if [[ "$blob" == "$SHA" ]]; then
    oldest="$commit"
    break
  fi
done < <(git rev-list --reverse origin/main -- "$PATH_REL")

printf 'source=%s\n' "$SOURCE"
printf 'path=%s\n' "$PATH_REL"
printf 'bytes=%s\n' "$BYTES"
printf 'sha256=%s\n' "$SHA"

if [[ -z "$oldest" ]]; then
  printf 'oldest_main_commit=\n'
  echo "ERROR: sha256 matches no origin/main blob for $PATH_REL (Pages out of sync?)" >&2
  exit 2
fi

short="$(git rev-parse --short "$oldest")"
printf 'oldest_main_commit=%s\n' "$oldest"
printf 'oldest_main_short=%s\n' "$short"
git -C "$REPO" log -1 --format='oldest_main_subject=%s%noldest_main_date=%ci' "$oldest"
