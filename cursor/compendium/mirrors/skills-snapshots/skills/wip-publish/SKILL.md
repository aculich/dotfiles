---
name: wip-publish
description: Sync WIP audio to the EchoTrails Cloud Run app under an obscure /wip/<slug-uuid8>/ prefix, generate per-slug + rolling-master RSS feeds, and print the shareable listen/feed URLs. Strictly EchoTrails only; never touches the Baloney R2 pipeline.
---

# wip-publish

Use when the user says **`wip-publish`**, **`/wip-publish`**, or asks to "publish <source-dir> to my private feed". Final stage of the EchoTrails WIP audiocast pipeline. Input is distilled mp3s under `examples/audio_output/levels/{L1_instant,essence,critique_fold}/<slug>-<stamp>/`; output is a listenable URL on the EchoTrails Cloud Run app + RSS feeds.

## Scope (and what is explicitly OUT of scope)

- IN scope: upload to `gs://peeq-voicegen-audiocast-public/wip/<slug>-<uuid8>/`, build `feeds/wip_<slug>-<uuid8>.xml` + `feeds/wip_master_<salt-uuid8>.xml`, print the three URLs, append to the local ledger in `docs/WIP_FEEDS.md`.
- OUT of scope: the **Baloney** pipeline (`https://audio.thebaloney.ai`, Cloudflare R2, [bin/generate_rss_feed.py](../../bin/generate_rss_feed.py), [skills/baloney-scan/SKILL.md](../../skills/baloney-scan/SKILL.md)). Do NOT touch any of these from this skill. They are a different, public, silly-project pipeline that happens to share the GCS bucket.

## Prerequisites

- **gsutil** on PATH, authenticated against the GCP project hosting the bucket. `gcloud auth login` once if needed.
- **Python** + `pyyaml` + `python-dotenv` + `google-genai` (installed via requirements.txt).
- **Cached API keys in `.env`** — populate once via `bash bin/refresh_env.sh` (one Touch ID). Scripts auto-load from `.env` so no further 1Password prompts.
- **Bucket exists**: `gs://peeq-voicegen-audiocast-public`.
- **Cloud Run app deployed** at `https://audio-server-7tpoxg7xwq-uc.a.run.app` (redeploy via [cloudrun/deploy_simple_server.sh](../../cloudrun/deploy_simple_server.sh) after any change to `cloudrun/simple-audio-server/server.py`).

## File contract

| Artifact | Path |
|----------|------|
| Audio (mp3 + sidecars) | `gs://peeq-voicegen-audiocast-public/wip/<slug>-<uuid8>/{L1_instant,essence,critique_fold}/<file>` |
| Per-slug feed XML (local + GCS) | `feeds/wip_<slug>-<uuid8>.xml`; also at `gs://.../feeds/wip_<slug>-<uuid8>.xml` |
| Master feed XML (local + GCS) | `feeds/wip_master_<salt-uuid8>.xml`; also at `gs://.../feeds/wip_master_<salt-uuid8>.xml` |
| Slug → uuid8 cache (keeps URLs stable) | [config/wip_slug_uuids.json](../../config/wip_slug_uuids.json) (gitignored) |
| Local URL ledger | [docs/WIP_FEEDS.md](../../docs/WIP_FEEDS.md) (gitignored) |

## Configuration

Lives in [config/echotrails.yaml](../../config/echotrails.yaml):

```yaml
echotrails_app: https://audio-server-7tpoxg7xwq-uc.a.run.app
echotrails_bucket: gs://peeq-voicegen-audiocast-public
echotrails_gcs_base: https://storage.googleapis.com/peeq-voicegen-audiocast-public
wip_prefix: wip/
feeds_prefix: feeds/
```

## Ordered steps

1. **Check that distill output exists**:
    ```bash
    ls examples/audio_output/levels/L1_instant/<slug>-<stamp>/ 2>/dev/null
    ls examples/audio_output/levels/essence/<slug>-<stamp>/ 2>/dev/null
    ls examples/audio_output/levels/critique_fold/<slug>-<stamp>/ 2>/dev/null
    ```
    At least one should have contents.
2. **Sync to GCS**:
    ```bash
    python bin/sync_to_public_bucket.py --wip-slug <slug>-<stamp>
    ```
    - Walks all three level-subdirs for this slug, uploads to `gs://.../wip/<slug>-<uuid8>/<level>/<file>.mp3`
    - Also uploads `*.md` and `*_meta.json` sidecars so the Cloud Run page can show transcripts / essence highlights later.
    - Mints or reuses the per-slug uuid8 in `config/wip_slug_uuids.json`. **Never** edit that file manually; regenerating the uuid8 rotates the URL (see "Privacy model" below).
3. **Build + upload feeds**:
    ```bash
    python bin/generate_wip_rss.py --slug <slug>-<stamp> --upload
    ```
    - Builds `feeds/wip_<slug>-<uuid8>.xml` by listing the GCS prefix.
    - Builds `feeds/wip_master_<salt-uuid8>.xml` aggregating every slug in `config/wip_slug_uuids.json`.
    - `--upload` copies both XMLs to `gs://.../feeds/`, where the Cloud Run app's `/feeds/<name>` proxy already serves them.
4. **Smoke-test the URLs**:
    ```bash
    curl -I https://audio-server-7tpoxg7xwq-uc.a.run.app/wip/<slug>-<uuid8>/
    curl -I https://audio-server-7tpoxg7xwq-uc.a.run.app/feeds/wip_master_<salt>.xml
    ```
    Both should return `200 OK`. The first request triggers the `/wip/<slug_uuid>/` route added to [cloudrun/simple-audio-server/server.py](../../cloudrun/simple-audio-server/server.py).
5. **Append to the local ledger** — the script prints the three URLs. Paste them into `docs/WIP_FEEDS.md` (gitignored) so you can find them later:
    ```
    ## <slug>-<stamp>  (published YYYY-MM-DD)
    - Listen:     https://audio-server-.../wip/<slug>-<uuid8>/
    - Per-slug:   https://audio-server-.../feeds/wip_<slug>-<uuid8>.xml
    - Master:     https://audio-server-.../feeds/wip_master_<salt>.xml
    ```

## What gets printed (shareable surface)

After a successful run you get three URLs:

1. **Listen page** — `https://audio-server-7tpoxg7xwq-uc.a.run.app/wip/<slug>-<uuid8>/` — inline player with a "WIP (Private Draft)" badge, does NOT appear on the default `/` landing.
2. **Per-slug feed** — `https://audio-server-.../feeds/wip_<slug>-<uuid8>.xml` — one workstream's feed. Share with collaborators on that workstream only.
3. **Master feed** — `https://audio-server-.../feeds/wip_master_<salt-uuid8>.xml` — subscribe once in your podcast client; every future slug auto-appears.

## Privacy model: URL-obscurity, not access control

The bucket `gs://peeq-voicegen-audiocast-public` is public by design (it serves both the levels/ L-tier audio AND the Baloney pipeline; making it private would break both). WIP content lives there too, protected only by the unguessable `-<uuid8>` suffix in the path.

Implications:

- Anyone who learns `<slug>-<uuid8>` can stream your WIP. **Do not paste the URL into GitHub issues, Slack channels, LinkedIn posts, or anywhere Googleable.**
- The `uuid8` is a SHA-256-truncated hash of `slug + machine_salt`. The salt is stored in `config/wip_slug_uuids.json` (gitignored) and never leaves your machine, so two people running this skill on different machines would get different uuid8 values for the same slug.
- To **rotate** a compromised URL: delete the entry for that slug from `config/wip_slug_uuids.json` and re-run `wip-publish`. The old path stays published in GCS (you'd need to `gsutil rm -r` it manually) but a new uuid8 is minted. Update `docs/WIP_FEEDS.md` accordingly.

## Out-of-scope reminders

- Do NOT call `bin/generate_rss_feed.py` from this skill — that is the Baloney-scoped generator (hardcodes `R2_BASE_URL = "https://audio.thebaloney.ai"`).
- Do NOT mirror WIP content to R2 / `audio.thebaloney.ai`. Only the EchoTrails Cloud Run surface.
- Do NOT modify the default `/` landing page logic in [cloudrun/simple-audio-server/server.py](../../cloudrun/simple-audio-server/server.py) (the `bucket.list_blobs(prefix="levels/")` call). WIP content must stay invisible there for the obscurity model to hold.

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | sync + feed build + upload all succeeded |
| 1 | feed build failed (slug has no uuid8 yet — did you run `--wip-slug` sync first?) |
| 2 | missing dependency or invalid args |

## Optional: local Cursor skills picker

Symlink `skills/wip-publish` into `~/.cursor/skills/wip-publish/` on your machine.
