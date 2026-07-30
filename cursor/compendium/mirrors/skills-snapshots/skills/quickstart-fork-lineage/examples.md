# Examples — PR policy branching

## Closed PRs (VoiceInk / Beingpax)

Upstream [CONTRIBUTING.md](https://github.com/Beingpax/VoiceInk/blob/main/CONTRIBUTING.md): **pull requests not accepted**.

Workflow:

1. Reproduce / fix on `forks/public` branch `fix/…`.
2. Push to `aculich/VoiceInk` (GitHub fork).
3. Open an **issue** on Beingpax/VoiceInk linking the public branch.
4. Optionally cherry-pick sanitized commits into personal/team private forks.
5. Do **not** open a PR against Beingpax.

## Open PRs (generic quickstart)

When another upstream accepts contributions:

1. Same GitHub-fork branch workflow.
2. Also `gh pr create` against upstream from the public fork.
3. Private forks may track the PR branch via ephemeral worktree until merge, then merge `upstream/main`.

## Private-fork sync (both cases)

```bash
cd forks/personal   # or team
git fetch upstream --prune --tags
git merge upstream/main
# resolve conflicts; keep flavor xcconfig + private patches
git push origin main
```

Pace releases on **tags / appcast**, not every remote `feature/*` branch. Observe with the quickstart `watch-upstream` recipe (or equivalent).
