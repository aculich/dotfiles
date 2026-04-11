#!/usr/bin/env bash
# Smoke test for DATABASE_CLI.md helpers (fd, sqlite, duckdb, zsh functions).
# Run from anywhere: ~/dotfiles/scripts/database-cli-smoke.sh

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SMOKE="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-db-smoke.XXXXXX")"
cleanup() { rm -rf "$SMOKE"; }
trap cleanup EXIT

need() { command -v "$1" >/dev/null 2>&1 || { echo "missing: $1"; exit 1; }; }

for c in sqlite3 duckdb fd fzf litecli sqlite-utils vd; do
	need "$c"
done

sqlite3 "$SMOKE/smoke.sqlite" "CREATE TABLE items (id INTEGER PRIMARY KEY, name TEXT); INSERT INTO items VALUES (1,'alpha');"
duckdb "$SMOKE/smoke.duckdb" -c "CREATE TABLE items (id INTEGER, name VARCHAR); INSERT INTO items VALUES (1, 'alpha');"

assert_contains() {
	local hay="$1" needle="$2" msg="$3"
	case "$hay" in
		*"$needle"*) ;;
		*)
			echo "FAIL: $msg"
			echo "expected substring: $needle"
			exit 1
			;;
	esac
}

sqcount="$(fd -e db -e sqlite -e sqlite3 . "$SMOKE" 2>/dev/null | wc -l | tr -d ' ')"
[[ "$sqcount" == "1" ]] || { echo "FAIL: expected 1 sqlite file from fd, got $sqcount"; exit 1; }
sqfile="$(fd -e db -e sqlite -e sqlite3 . "$SMOKE" 2>/dev/null | head -1)"
[[ "$sqfile" == "$SMOKE/smoke.sqlite" ]] || { echo "FAIL: wrong sqlite path: $sqfile"; exit 1; }

dkcount="$(fd -e duckdb . "$SMOKE" 2>/dev/null | wc -l | tr -d ' ')"
[[ "$dkcount" == "1" ]] || { echo "FAIL: expected 1 duckdb file from fd, got $dkcount"; exit 1; }

out="$(sqlite3 "$SMOKE/smoke.sqlite" ".schema")"
assert_contains "$out" "CREATE TABLE items" "sqlite3 .schema"

out="$(sqlite-utils schema "$SMOKE/smoke.sqlite")"
assert_contains "$out" "CREATE TABLE items" "sqlite-utils schema"

out="$(duckdb "$SMOKE/smoke.duckdb" -c "SHOW TABLES;")"
assert_contains "$out" "items" "duckdb SHOW TABLES"

out="$(zsh -c "source \"$ROOT/zsh/aliases.zsh\" 2>/dev/null; sqschema \"$SMOKE/smoke.sqlite\"")"
assert_contains "$out" "CREATE TABLE items" "zsh sqschema"

out="$(zsh -c "source \"$ROOT/zsh/aliases.zsh\" 2>/dev/null; duckschema \"$SMOKE/smoke.duckdb\"")"
assert_contains "$out" "items" "zsh duckschema"

picked="$(printf '%s\n' "$SMOKE/smoke.sqlite" "$SMOKE/smoke.duckdb" | fzf -f smoke.sqlite)"
[[ "$picked" == "$SMOKE/smoke.sqlite" ]] || { echo "FAIL: fzf filter pick"; exit 1; }

echo "database-cli-smoke: OK (all checks passed)"
