# SQLite and DuckDB CLI integration

This document describes how to work with local `.db`, `.sqlite`, and `.duckdb` files from the terminal: pick a file with fzf, inspect schema, run a REPL, or browse in a TUI.

## Prerequisites (Homebrew)

```bash
brew install sqlite duckdb fd fzf
brew install litecli sqlite-utils visidata
```

| Tool | Role |
|------|------|
| **sqlite3** | Minimal SQLite shell; always available once `sqlite` is installed. |
| **litecli** | Nicer SQLite REPL (completion, highlighting). Used by `sqpick` when present. |
| **duckdb** | DuckDB CLI for `.duckdb` files and in-memory workflows. |
| **sqlite-utils** | One-off inspection (`sqlite-utils schema`, `rows`, etc.). Used by `sqschema` when you want structured output. |
| **visidata** | TUI to browse tables and columns (`vd file.db`, `vd file.duckdb`). |
| **fd**, **fzf** | Fuzzy file pickers for `sqpick`, `duckpick`, `vdpick`. |

## Shell helpers (in `zsh/aliases.zsh`)

| Command | What it does |
|---------|----------------|
| **sqpick** | With **no args**: search under `.` with `fd`. With a **directory**: search under that path. With a **single `.db` / `.sqlite` / `.sqlite3` file**: open it directly (do not pass a file as the only arg to the old behavior—that made `fd` use the file as a search root and showed **0/0** in fzf). With **multiple args** (e.g. `sqpick *.db`): fzf over those paths. |
| **duckpick** | Same pattern: no args / directory / one `.duckdb` file / multiple paths. |
| **vdpick** | Same pattern for SQLite + DuckDB extensions; opens **visidata**. |
| **sqschema** `file` | Print full schema: **sqlite3** `.schema`, or **sqlite-utils schema** if available. |
| **duckschema** `file` | List tables with **duckdb** `SHOW TABLES`. |

## Usage examples

```bash
# Interactive SQLite: search current tree, or a directory, or open one file
sqpick
sqpick ~/projects/myapp
sqpick ./vcro.db          # opens that DB directly (no empty fzf)
sqpick *.db               # fzf if several matches

# DuckDB
duckpick
duckpick ./data

# Schema only (no REPL)
sqschema ./app.sqlite
duckschema ./analytics.duckdb

# TUI browse (tables, scroll, filters)
vdpick
vd ./path/to/file.db
```

## When to use which

- **sqpick / litecli** – Ad-hoc SQL, history, completion. Falls back to `sqlite3` if litecli is not installed.
- **duckpick** – Native DuckDB SQL and extensions.
- **visidata** – Explore row counts, skim data, pivot without writing much SQL.
- **sqlite-utils** – Scripts and JSON-friendly dumps (`sqlite-utils rows db.db table --json`).

## Implementation notes

- Pickers use the same `f=$(fd … \| fzf) && tool "$f"` pattern as `mdr` (no GNU `xargs -r` on macOS).
- `fd` respects `.gitignore` by default; use `fd -I` in a custom wrapper if you need ignored paths.

## Verify (smoke test)

After the [Prerequisites](#prerequisites-homebrew) install:

```bash
~/dotfiles/scripts/database-cli-smoke.sh
```

This creates temporary SQLite and DuckDB files, checks `fd` discovery, `sqlite3` / `sqlite-utils` / `duckdb`, and the `sqschema` / `duckschema` zsh functions. Interactive pickers (`sqpick`, `duckpick`, `vdpick`) need a TTY; run them manually in a terminal.

## Out of scope here

- GUI clients (TablePlus, DBeaver).
- Remote Postgres/MySQL (use `pgcli`, etc.).

See also **[FZF_JQ_SETUP.md](FZF_JQ_SETUP.md)** for fzf keybindings and related tooling.
