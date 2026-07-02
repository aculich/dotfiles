# Example: crb-macss-fiscal (MaCSS x CRB)

Use as a template when copying this skill to another repo; replace paths and titles.

| Artifact | Path |
|----------|------|
| Agent prefs / git workflow | `AGENTS.md` |
| Executive / long horizon | `docs/macss/EXECSUMMARY.md` |
| Capstone definition | `docs/macss/CAPSTONE.md` |
| Progress snapshot | `docs/macss/PROGRESS-2026-03-09.md` (filename may keep historical date) |
| Repo grounding | `docs/macss/MaCSS-GROUNDING.md` |
| Granola mirror | `granola/macss/` + `granola/macss/index.json` |
| Unified transcripts | `macss_transcripts/` + `macss_transcripts/index.json` |
| Meeting notes / stubs | `notes/YYYY-MM-DD-crb-macss-notes.md`, `notes/YYYY-MM-DD-crb-macss-transcript.md` |
| Zoom fetch script | `tools/zoom-mcp-server/scripts/fetch-macss-cloud.js` (documented in `macss_transcripts/README.md`) |
| Upstream pipeline | `upstream/CRB-and-MaCCS/` (design: `doc/Data_Integration_Design.md`, notebooks under `src/`) |

**Granola folder naming:** `<first-8-of-uuid>_<Title>_<MonDDYYYY>/` (see existing folders under `granola/macss/`).

**Transcript stub pattern:** Point to `granola/.../transcript.txt`, Zoom `transcript.VTT`, and `macss_transcripts/index.json` — do not paste full transcripts into `notes/`.

**Zoom `user_id` for recordings:** Use the host account email configured for cloud recording (e.g. project `people-emails.md`).

**LFS:** `GIT_LFS_SKIP_SMUDGE=1 git pull` when LFS objects 404; note pointer-only files in synthesis or PROGRESS.
