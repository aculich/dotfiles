---
name: rowboat-safe-startup
description: Audit ~/.rowboat workdir, estimate LLM costs, run preflight checks, and safely test Rowboat with a relocated workdir and test accounts. Use before starting Rowboat after a long idle period, when concerned about API spend, or when mixing credentials with personal data in ~/.rowboat.
---

# Rowboat safe startup

Use this skill before launching Rowboat when:

- The workdir has been idle for weeks (Gmail full sync + labeling backlog risk)
- BYOK OpenAI keys are configured (no Rowboat gateway spend caps)
- You need to test without touching production Gmail/data

## Quick answer

**Do not start Rowboat on production `~/.rowboat` without a preflight pass.**

With ~10k unlabeled emails and BYOK `o4-mini`, startup can cost **~$85–450+** with **no in-app cost confirmation**. Gmail fetch is capped (500 threads default); labeling and KG are **not**.

## Workflow

### 1. Inventory (read-only)

From `rowboat-quickstart` root:

```bash
chmod +x scripts/rowboat-workdir-inventory.sh scripts/rowboat-preflight.sh
./scripts/rowboat-workdir-inventory.sh
./scripts/rowboat-workdir-inventory.sh ~/.rowboat-test   # if using test dir
```

Review:

- `gmail unlabeled` count and estimated labeling batches
- `sync_state.json` idle days (>7 → full sync)
- Redacted config summary (never print API keys)

Full audit: `rowboat__aculich/.devdocs/ROWBOAT_WORKDIR_AUDIT.md`

### 2. Cost estimate

Open `rowboat__aculich/.devdocs/ROWBOAT_COST_WORKSHEET.md` and plug in inventory numbers.

Pricing references:

- o4-mini: [$1.10/M in, $4.40/M out](https://openrouter.ai/openai/o4-mini)
- Gemini 3.1 Flash Lite (Rowboat gateway KG): [Gemini API pricing](https://ai.google.dev/gemini-api/docs/pricing)

### 3. Preflight

```bash
./scripts/rowboat-preflight.sh
# or test workdir:
export ROWBOAT_WORKDIR=~/.rowboat-test
./scripts/rowboat-preflight.sh
```

Fix all `[FAIL]` items before launch. Treat `[WARN]` as explicit accept-or-mitigate decisions.

### 4. Relocate workdir for testing

Rowboat honors **`ROWBOAT_WORKDIR`** (see `apps/x/packages/core/src/config/config.ts`).

```bash
# Quit Rowboat first
mv ~/.rowboat ~/.rowboat.production-YYYYMMDD
mkdir -p ~/.rowboat-test/config

# Seed test config (see controlled test plan)
# gmail_sync.json: { "maxEmails": 50 }
# granola.json: { "enabled": false }
# models.json: test OpenAI key ONLY

export ROWBOAT_WORKDIR=~/.rowboat-test
./scripts/rowboat-preflight.sh
# start app (./dev.sh from rowboat__aculich)
```

Restore production:

```bash
mv ~/.rowboat-test ~/.rowboat-test-retired-YYYYMMDD
mv ~/.rowboat.production-YYYYMMDD ~/.rowboat
unset ROWBOAT_WORKDIR
```

### 5. Controlled test run

Follow phases in `rowboat__aculich/.devdocs/ROWBOAT_CONTROLLED_TEST_PLAN.md`:

1. Empty test workdir inventory
2. Test Google + `maxEmails: 50`
3. 1-hour spend observation
4. Labeling smoke (≤30 emails)
5. KG smoke (≤5 files)
6. Archive test; decide production labeling strategy before restore

## Backlog containment (production)

Before reconnecting production Gmail:

| Goal | Action |
|------|--------|
| Skip labeling for historical mail | Seed `labeling_state.json` with absolute paths OR add `---` frontmatter |
| Limit new sync only | `gmail_sync.json` `{ "maxEmails": N }` (does **not** cap local backlog) |
| Clean test | Fresh empty workdir + test Google account |
| Block labeling temporarily | Move/rename `gmail_sync/` out of workdir |

`labeling_state.json` schema:

```json
{
  "processedFiles": {
    "/absolute/path/to/gmail_sync/thread.md": { "labeledAt": "ISO-8601" }
  },
  "lastRunTime": "ISO-8601"
}
```

## Security

- `~/.rowboat` mixes **credentials + PII** — never commit or paste config files
- Rotate OpenAI key if exposed; use dashboard spend limits on test keys
- Production OAuth tokens live in `config/oauth.json`

## Guardrails gap (current code)

Present: Gmail `maxEmails`, 7-day full-sync fallback, labeling batches of 15.

Missing: pre-batch cost estimate, labeling/KG backlog cap, daily spend ceiling in app.

## Related

- Fork workflow: `rowboat-quickstart/.cursor/skills/rowboat-fork-workflow/SKILL.md`
- Upstream digest: `~/.cursor/skills/rowboat-upstream-digest/SKILL.md`
