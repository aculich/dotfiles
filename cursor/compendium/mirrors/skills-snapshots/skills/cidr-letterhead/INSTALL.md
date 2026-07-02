# Install cidr-letterhead for global Cursor use

The skill is versioned in **`cidrlab/library`** at `.cursor/skills/cidr-letterhead/`. Do not copy files to `~/.cursor/skills/` — symlink instead.

## One-time install

From your `cidrlab/library` clone:

```bash
git pull origin main
cd templates && npm install && cd ..
.cursor/skills/cidr-letterhead/scripts/install.sh
```

This creates:

```
~/.cursor/skills/cidr-letterhead -> /path/to/your/library/.cursor/skills/cidr-letterhead
```

## Verify

1. Restart Cursor or reload skills if needed
2. Invoke `/cidr-letterhead` from any project
3. Run `ensure-library.sh` to confirm the library path resolves

## Update after pull

When Tim updates templates or the skill:

```bash
cd /path/to/library
git pull origin main
# symlink picks up changes automatically — no reinstall needed
```

If you moved the library clone, re-run `install.sh`.

## Uninstall

```bash
rm ~/.cursor/skills/cidr-letterhead
```

## Optional: `CIDR_LIBRARY` override

The skill resolves the library checkout from its own location, so you normally
do not need to set anything. Set `CIDR_LIBRARY` only to point at a different
checkout — e.g. in a shell profile:

```bash
export CIDR_LIBRARY="/path/to/your/cidrlab-library"
```

Standalone build scripts and this skill use it when set.
