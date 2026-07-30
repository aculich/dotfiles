---
name: quickstart-fork-lineage
description: >-
  Scaffold and operate multi-lineage forks under a *-quickstart metarepo:
  Upstream pin track, public GitHub fork, personal/team private forks,
  distinct app identities, observe-all-refs vs worktree-on-demand, and
  team DMG release scaffolding. Use when setting up or extending fork
  lineages for VoiceInk or other quickstarts; when the user mentions
  private fork, GitHub fork, Upstream track, metarepo, control plane,
  flavor builds, or quickstart-fork-lineage.
disable-model-invocation: true
---

# Quickstart fork lineage

VoiceInk-first pattern for any `*-quickstart` **metarepo** that vendors an upstream and needs coexistence of an Upstream daily driver plus private forks. The metarepo is the control plane (docs + `just`); product remotes stay product.

## Locked vocabulary

| Term | Meaning |
|------|---------|
| **Metarepo / control plane** | Thin `*-quickstart` that orchestrates lineages (not a monorepo of app source). |
| **Upstream pin** | Fetch-only pin track. Not an app display name. |
| **GitHub fork** | `gh repo fork` network; brand/bundle usually unchanged; sync with `gh repo sync`. |
| **Private fork** | Independent private repo + remotes `upstream` + `origin` (not the Fork button). Sync with `git fetch upstream && merge`. |
| **Observe** | Fetch all refs; report branches/tags/releases — no permanent worktrees. |
| **Checkout** | Ephemeral `git worktree add` only while evaluating a tip. |

Avoid: hard/soft fork, derivative, “upstream fork” for the public copy.

Exemplar docs: [GLOSSARY.md](file:///Users/me/tools/voiceink-quickstart/GLOSSARY.md), [READING.md](file:///Users/me/tools/voiceink-quickstart/READING.md), [TOOLBOX.md](file:///Users/me/tools/voiceink-quickstart/TOOLBOX.md).

## Identity rules

- Same bundle ID ⇒ shared prefs, TCC, Keychain, Sparkle. Coexistence requires distinct `PRODUCT_BUNDLE_IDENTIFIER` + display name + install path.
- Private-fork starter prefix for aculich: `io.github.aculich.`
- Never overwrite the Upstream `/Applications/<App>.app` with a flavor build.
- Always quit all app variants before launching a flavor (hotkey / single-instance conflicts).
- Prefs remint later is fine when starting team distribution fresh — no migrator required in v1.

## Scaffold steps

1. Document topology in `FORKS.md` + link from `PRAXIS.md`; add `GLOSSARY.md` / `READING.md` when teaching agents.
2. Keep Upstream vendor at `upstream/<Owner>__<Repo>/` (gitignored).
3. Create `forks/{public,personal,team}/` (gitignored clones).
4. Public: `gh repo fork` → clone → ensure `upstream` remote.
5. Private forks: clone upstream → `remote rename origin upstream` → `gh repo create --private --source=. --remote=origin --push`.
6. Add flavor xcconfigs (include LOCAL_BUILD / local-sign base; override bundle id, display name; keep `PRODUCT_NAME` without spaces).
7. Add control-plane recipes: `watch-upstream`, `sync-upstream`/`use-upstream`, `quit-<app>-all`, `dev-personal`, `dev-team`, `release-team`, `scaffold-forks`, `refresh-lineage`.
8. Team install notes + DMG scaffold; skip notarization/Sparkle until needed.

## Upstream PRs

If upstream **does not accept PRs** (VoiceInk): public fix branches + **upstream issues only**.

If upstream **accepts PRs**: also open a PR from the public GitHub fork.

## Private-fork pace

Merge **`main` + release tags / appcast commit**. Do not auto-merge every `feature/*` / `fix/*`. Cherry-pick watched branches only after an explicit decision.

## Tooling (shell out)

- Keep **`just` + scripts** as the metarepo runner (see TOOLBOX: defer gita/myrepos; skip Bazel/Nx/moon/meta CLI).
- git-cliff / cliff-jumper for changelogs and cuts
- `gh repo fork` / `gh repo sync` for GitHub forks
- Private forks: `git fetch upstream && merge`
- `git worktree` for ephemeral eval only
- Prefer sanitized cherry-pick personal→public over blind repo-sync

## VoiceInk exemplar

See [reference.md](reference.md) for concrete paths, bundle IDs, and recipes. See [examples.md](examples.md) for open-vs-closed PR upstreams.
