---
name: rowboat-upstream-digest
description: Produces upstream activity digests for the Rowboat fork — delta since last sync, GitHub PR/issue/fork intel, local branch matrix, and incorporation status for filed PRs. Use when the user asks for upstream digest, vendor activity, fork catch-up, what changed since last pull, or re-integrating feature branches onto upstream.
---

# Rowboat Upstream Digest

Periodic intelligence and catch-up workflow for the Rowboat fork in `rowboat-quickstart`.

## Config (this workspace)

| Key | Value |
|-----|-------|
| Quickstart root | `rowboat-quickstart/` |
| Fork | `rowboat__aculich/` |
| Upstream clone | `rowboat__rowboatlabs/` |
| Upstream repo | `rowboatlabs/rowboat` |
| GitHub author | `aculich` |
| State file | `rowboat-quickstart/.devdocs/upstream-digest-state.json` |
| Digest script | `rowboat-quickstart/scripts/upstream-digest.sh` |
| Digest output | `rowboat__aculich/.devdocs/digests/UPSTREAM_DIGEST_YYYY-MM-DD.md` |
| Template | `rowboat__aculich/.devdocs/templates/UPSTREAM_DIGEST.template.md` |

## When to use

- "Upstream digest", "what changed upstream", "catch up fork", "vendor activity"
- Before rebasing topic branches or rebuilding `develop`
- Checking whether filed PRs/issues were merged upstream
- Prioritizing active `feature/*` / `fix/*` / `pr/*` work after a long gap

## Gates (mandatory)

From workspace `AGENTS.md` and fork `rowboat__aculich/AGENTS.md`:

- **No upstream-visible actions** without user review: do not run `gh pr create`, `gh issue create`, or post comments on upstream threads unless the user explicitly approves.
- **Pushing `pr/*` branches** that advance open upstream PRs requires user review of diff/commits first (unless user waives).
- **Pushing to origin** from scripts requires confirmation or `--yes` on `sync-fork-rebuild.sh`.
- Pushing branches to fork only (backup) is safe; publishing upstream requires review.

Cross-reference (do not duplicate): `rowboat__aculich/AGENTS.md`, `scripts/sync-fork-rebuild.sh`, project skill `rowboat-fork-workflow`.

## Quick start

From **rowboat-quickstart** root:

```bash
# Full sync + digest + update baseline
./scripts/upstream-digest.sh --sync --update-state

# Report only (no git changes to main)
./scripts/upstream-digest.sh --no-sync

# Machine-readable for agent synthesis
./scripts/upstream-digest.sh --no-sync --json
```

Then read the markdown digest and JSON; synthesize operational recommendations.

## Seven-phase workflow

Copy this checklist and track progress:

```
Upstream digest:
- [ ] Phase 1: Read baseline from state file
- [ ] Phase 2: Sync (if requested)
- [ ] Phase 3: Upstream activity delta
- [ ] Phase 4: GitHub intel (PRs, issues, forks)
- [ ] Phase 5: Fork branch matrix
- [ ] Phase 6: Incorporation check
- [ ] Phase 7: Write digest + update state
```

### Phase 1: Baseline

Read `.devdocs/upstream-digest-state.json`:

- `last_upstream_main_sha` — start of delta window on `upstream/main`
- `last_fork_main_sha` — fork `main` at last digest
- `last_digest_at` — ISO timestamp

If missing or first run, script uses fork `main` SHA so backlog is visible once.

### Phase 2: Sync

When catching up (fork behind upstream):

```bash
./scripts/sync-upstream.sh --rebase
# then from fork root:
git push --force-with-lease origin main
```

Or let digest script run `--sync` (calls `sync-upstream.sh --rebase`).

For full topic rebase + develop rebuild, use:

```bash
./scripts/sync-fork-rebuild.sh --dry-run --rebase-main --rebase-topics --rebuild-develop
```

Edit `scripts/rowboat-fork-branches.conf` before rebuild to list branches in merge order (`feature/devscripts` first).

### Phase 3: Upstream activity

Script reports on `upstream/main` since baseline:

- Commit count and sample log
- Latest release tag vs fork `main`
- Theme buckets (feat/fix/refactor/docs/chore counts)
- Active upstream remote branches with commits in window (top N)

Summarize themes in plain language for the user (e.g. runtime optimizations, Composio toolkits, security fixes).

### Phase 4: GitHub intel

Script uses `gh` for:

- Your PRs/issues (`--author aculich`, all states)
- Top open upstream PRs
- Newest forks in the network

Highlight community PRs that overlap your open work (same paths or similar titles).

### Phase 5: Fork branch matrix

For each local `feature/*`, `fix/*`, `pr/*`:

- Ahead/behind vs `main`
- Last commit date
- Rebase priority (active features first, then open-PR branches, then stale)

Default priority hints in script: branches with recent commits before stale `pr/*`.

### Phase 6: Incorporation

Map your filed work:

| Local branch | Upstream PR | Issue | Status |
|--------------|-------------|-------|--------|

Script checks `gh pr list --author aculich` and heuristics:

- **MERGED** — close local tracking; drop from active rebase queue if fully upstream
- **OPEN** — rebase `pr/*` onto new `main`; triage CI (use `babysit` skill per PR)
- **Blocked** — e.g. `pr/file-cache-mtime-validation` waits for #429 per AGENTS.md pending actions
- **Superseded** — if upstream merged equivalent fix, note before rebase effort

For each `fix/*` without an open PR, compare unique commit subjects/files against upstream log since baseline.

### Phase 7: Output

1. Script writes markdown to `.devdocs/digests/UPSTREAM_DIGEST_YYYY-MM-DD.md`
2. With `--update-state`, writes new SHAs to state file
3. Agent presents:
   - Executive summary (commits behind, release, top themes)
   - Rebase queue (ordered)
   - PR/issue incorporation table
   - Concrete next commands (dry-run first)

## Recommended catch-up sequence

After a large upstream gap:

1. `./scripts/upstream-digest.sh --sync --update-state`
2. Review digest; confirm branch list in `rowboat-fork-branches.conf`
3. `./scripts/sync-fork-rebuild.sh --dry-run --rebase-main --rebase-topics --rebuild-develop`
4. Execute rebuild locally; run `./dev.sh` on `develop`
5. Rebase each open `pr/*`; babysit CI on upstream PRs one at a time
6. Push topic branches to origin for backup (not upstream PR updates without review)

## Related skills

- **tool-landscape-intel** (personal) — parent workflow: Discord, YouTube, web traction + optional git digest
- **rowboat-fork-workflow** (project) — branch roles, one-line sync commands
- **babysit** — keep a single upstream PR merge-ready
- **split-to-prs** — cut clean `pr/*` from `develop` when submitting upstream

## Troubleshooting

| Problem | Action |
|---------|--------|
| `gh: not authenticated` | `gh auth login` |
| `jq: command not found` | Install jq (brew/apt) |
| Rebase conflicts | Resolve per branch; do not force-push `pr/*` without user review |
| State shows zero delta after sync | Expected after `--update-state`; next run tracks incremental changes |
