# skills-registry manifest schema

YAML files here drive **inventory only**; they do not install skills. Keep vendor paths accurate so you know what is third-party vs authored.

## `vendor.yaml`

List third-party or cached skills the agent did not write.

| Field | Required | Description |
| --- | --- | --- |
| `id` | yes | Stable slug, e.g. `marketplace-specstory` |
| `kind` | yes | `marketplace` \| `git` \| `path` \| `cursor-plugin-cache` |
| `source` | yes | URL, extension id, or absolute path on disk |
| `installed_path` | yes | Where it lives today (e.g. `~/.cursor/plugins/cache/...`) |
| `license` | no | SPDX or `unknown` |
| `pin` | no | Version, commit SHA, or extension version string |
| `notes` | no | Free text |

## `authored.yaml`

Skills you maintain and intend to commit (possibly in a **separate** private git repo).

| Field | Required | Description |
| --- | --- | --- |
| `id` | yes | Directory name under `~/.cursor/skills/` |
| `repo` | no | Git remote if skills live in dedicated repo |
| `local_path` | yes | Resolved path (symlink target allowed) |
| `compendium_mirror` | no | Relative path under this repo if you copy for backup |

## `project-index.yaml`

Projects whose `.cursor/` / `.specstory/` / `.cursor/plans` should be snapshotted.

| Field | Required | Description |
| --- | --- | --- |
| `slug` | yes | `github-com-org-repo` or `sha256-abc...` short prefix of project path hash |
| `path` | yes | Absolute path to project root |
| `origin_url` | no | From `git remote get-url origin` when available |
| `mirror_specstory` | no | `false` (default), `rules-only`, or `full` |
| `last_sync` | no | ISO8601; scripts may update |

## `project-paths.txt` (shell snapshots)

`scripts/snapshot-all.sh` reads **`../project-paths.txt`** at the compendium root: each non-comment line is **`slug<TAB>absolute_path`**. Copy from `../project-paths.example.txt`. Keep rows aligned with `project-index.yaml` by convention.

Fill `vendor.yaml` / `authored.yaml` manually for important pins; run **`scripts/discover-skills.py`** (or `snapshot-all-skills.sh`) for a full machine inventory:

- `skills-inventory.json` — structured scan (global + project-local)
- `skills-inventory.md` — human-readable index

See starter files: `vendor.yaml`, `authored.yaml`, `project-index.yaml` in this directory.
