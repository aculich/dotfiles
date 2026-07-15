# Conventions (machine-oriented)

<!-- TODO: Fill key=value lines for automated skills (meeting-sync). -->

## Repo

- **project_slug:** TODO
- **repo_root:** `.`

## Granola

- **mcp_server:** TODO (e.g. user-granola)
- **mirror_root:** `granola/TODO-namespace/`
- **folder_pattern:** `<uuid-prefix>_<SanitizedTitle>_<MonDDYYYY>/`
- **index_file:** `granola/TODO-namespace/index.json`

## Zoom

- **host_user_id:** TODO (email or Zoom user id)
- **transcripts_root:** `TODO_transcripts/`
- **fetch_script:** TODO optional path
- **meeting_platform:** TODO (`zoom` | `google_meet` | `none`)

## Screenshots (Shottr)

- **screenshots_root:** `/Users/me/shottr/`
- **screenshots_glob:** `SCR-YYYYMMDD-*.{png,jpg,jpeg}`
- **screenshots_window_buffer_min:** 15

## Gmail discovery (bootstrap)

- **email_lookback:** `all` (alternatives: `90d`, `30d`)
- **google_workspace_email:** `aaron@cidrlab.org`
- **mcp_server_google:** `user-google-workspace`

## Notes

- **notes_transcript_stub:** `notes/<YYYY-MM-DD>-TODO-transcript.md`
- **notes_structured:** `notes/<YYYY-MM-DD>-TODO-notes.md`

## Git upstream

- **lfs_skip_smudge:** `GIT_LFS_SKIP_SMUDGE=1 git pull`
- **upstream_paths:**
  - `upstream/TODO-repo/`

## Cadence

- **sync_meeting:** TODO (e.g. weekly Thursday)

## Canonical docs (human)

- **progress:** `docs/TODO/PROGRESS.md`
- **capstone:** `docs/TODO/CAPSTONE.md`
