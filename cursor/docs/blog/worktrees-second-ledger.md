# Worktrees copy the code, not the world: the second isolation ledger

*A companion to the parallel-agent worktree pattern making the rounds — extending the "what's isolated vs. shared" ledger from runtime services to the IDE and agent layer, based on our Cursor setup.*

**Inspired by:** ["Anyone here using Git Worktrees? Here's my New Local Dev Setup"](https://community.theaiautomators.com/c/discussions/anyone-here-using-git-worktrees) (The AI Automators community)
**Companions:** [CURSOR3-worktrees.md](../CURSOR3-worktrees.md) · [IGNORING.md](../IGNORING.md) · [MULTIROOT-cursor-lifecycle.md](../MULTIROOT-cursor-lifecycle.md) · [cursor-plans-agents-guide.md](../cursor-plans-agents-guide.md)

---

## The first ledger

The forum post that prompted this gets one sentence exactly right:

> Worktrees copy the codebase. They do **not** copy all the services around the codebase.

The author runs multiple coding agents (Claude Code, Codex) against a full-stack app, and works through what should be isolated per worktree versus shared. His ledger:

| Dimension | Decision | Why |
|-----------|----------|-----|
| Branch + working directory | **Isolated** | That's what worktrees are |
| Backend/frontend processes + ports | **Isolated** (offset per tree: 8002/5174, 8003/5175, …) | One agent restarting a server can't kill another's test loop |
| Heavy dependencies (multi-GB Python venv) | **Shared** (linked back to main) | Rebuilding PyTorch per tree is waste; most parallel work is app code |
| Database (local Supabase) | **Shared** | A Docker stack per tree is too much weight |
| Test accounts | **Isolated** (per-tree `TEST_USER1`/`TEST_USER2`) | Test suites wipe the logged-in user's data first — shared accounts mean agents destroy each other's fixtures |

This is the right way to think about it: not "isolate everything," but a deliberate ledger where each row has an owner and a reason. The test-accounts row is the underrated one — it's what lets an agent actually *validate* its work in parallel, not just edit files in parallel.

But running the same pattern inside Cursor, we found the ledger is incomplete. There's a second one.

## The second ledger: the IDE and agent layer

A worktree is a new directory. To your editor and your agents, a new directory is a new *world* — and almost none of your accumulated editor state copies into it. Here's the same exercise applied to the tool layer:

| Dimension | Isolated or shared? | Who enforces it |
|-----------|--------------------|-----------------|
| Chat / agent history | **Isolated by accident** — keyed to folder path, so every worktree starts blank | Editor internals; you can't opt out |
| Codebase index | **Isolated** — each opened worktree indexes from scratch | Editor; you pay the cost per tree |
| `.cursorignore` / `.cursorindexingignore` / `.vscode` excludes | **Shared if committed**, lost if personal | You, via git |
| Gitignored paths (`.env`, vendored `upstream/`, data files, artifacts) | **Left behind** — worktrees check out tracked files only | You, via setup script (symlink / copy / regenerate) |
| Rules (`.cursor/rules/`), `WORKTREES.md`-style docs | **Shared if committed** | You, via git |
| Saved plans (`.cursor/plans/`) | **Shared if committed**; agent/model assignments are not | You, via git ([details](../cursor-plans-agents-guide.md)) |
| Worktree setup (`.cursor/worktrees.json`) | **Shared** — committed config runs in each new tree | Cursor, if you declare it |
| Dev server URLs | **Isolated by name** — branch-prefixed `.localhost` hostnames per worktree | [portless](https://github.com/vercel-labs/portless), automatically |
| Model routing / spend | **Multiplied**, not isolated | You, between waves |

Four of these deserve elaboration.

### 1. Editor identity follows the path

Cursor (inheriting VS Code's model) keys workspace state to the folder path. We learned this the annoying way with project renames — chat history goes missing when a path changes ([lifecycle notes §2](../MULTIROOT-cursor-lifecycle.md)) — but worktrees hit the same mechanism *by design*: every tree is a new path, therefore a new workspace identity.

The consequence is a simple rule: **anything an agent must know in any worktree has to live in the repo.** The forum author wrote a `WORKTREES.md` explaining ports, shared services, test accounts, and teardown gotchas. That instinct is correct for a deeper reason than documentation hygiene — committed context is the *only* context that survives the copy. In Cursor terms that means:

- rules in `.cursor/rules/` (always-on instructions, boundaries, conventions)
- plans saved to `.cursor/plans/` and committed ([why](../MULTIROOT-cursor-lifecycle.md))
- a worktree runbook the agent is told to read first

Unsaved plans, chat threads, and UI-registry state (like per-todo agent assignments) stay behind in the original workspace. Treat them as ephemeral.

### 2. Ignore hygiene becomes load-bearing — and your ignore files map what you leave behind

One worktree re-indexing your `node_modules` is an annoyance. Four worktrees doing it concurrently while four agents run is CPU churn, watcher noise, and polluted semantic search — times four.

The fix costs nothing if you've already done it: commit your ignore policy so it travels with every tree. Our [IGNORING.md](../IGNORING.md) covers the three layers (git, Cursor AI scope, editor watchers/search); the worktree-relevant point is the split between **committed** rules (travel free) and **user-level / global** rules (apply everywhere anyway). What doesn't travel is anything you configured per-workspace in the UI and never wrote down. Audit for that before you scale past two trees.

But there's a deeper role for the ignore files here. A worktree checks out **tracked files only** — everything gitignored stays behind in the main tree. Which means your `.gitignore` is, read in reverse, a manifest of what a fresh worktree *won't* contain.

That's a genuine tradeoff, not just a gotcha:

- **The pro, by design:** each tree is a clean room. Stale caches, half-migrated databases, and leftover artifacts don't follow you in. Worktrees flush out hidden dependencies on untracked state — if your build only works because of a file nobody remembers creating, the first worktree run tells you.
- **The con, by surprise:** development often *relies* on untracked paths. Env files. Gitignored vendored clones or subrepos (we keep reference repos under an ignored `upstream/` — none of that exists in a new tree). Large data files and fixtures kept out of git deliberately ([MULTIROOT.md §6](../MULTIROOT.md) — DVC-style pointer-in-git, blob-in-object-storage setups need a `dvc pull` per tree). Generated artifacts a test suite assumes exist. In the new tree these are silently absent, and the failure modes are confusing by construction: "module not found," empty fixtures, tests that pass in main and fail in the worktree for no visible reason — exactly the kind of mystery that sends an agent down a rabbit hole burning tokens on a problem that is really just a missing symlink.

The forum author's multi-GB venv symlink is one instance of the general rule: **every ignored-but-load-bearing path needs an explicit row in the ledger**, with one of four dispositions:

| Disposition | When | Example |
|-------------|------|---------|
| **Symlink back to main** | Heavy, read-mostly, slow to rebuild | Python venv with PyTorch; `upstream/` reference clones |
| **Copy into the tree** | Cheap, and the worktree may mutate it | Small fixture sets, scratch dirs |
| **Regenerate via setup script** | Derivable from tracked sources | `.env` from `.env.example`, codegen output, `dvc pull` |
| **Declare out of scope** | Too heavy or too stateful to duplicate | "Worktrees don't run data-pipeline jobs" in the runbook |

In practice we now audit `.gitignore` while writing the worktree setup script, because the ignore file *doubles as the checklist* of what the script must symlink, copy, or regenerate. The `.cursor/worktrees.json` setup hook ([guide](../CURSOR3-worktrees.md)) is the natural home for it — and the baseline-test step below is what proves you didn't miss a row.

### 3. Name the trees, don't number them

The forum author solves port collisions with an offset scheme: main app on 8001/5173, then 8002/5174, 8003/5175 per worktree. It works, but it's bookkeeping — a mapping from tree to numbers that lives in someone's head (or `WORKTREES.md`), that agents have to be told about, and that breaks the moment two schemes collide.

We replaced the numbers with names using [portless](https://github.com/vercel-labs/portless) (Vercel Labs). It runs dev servers behind a local HTTPS proxy and hands each one a stable `.localhost` URL — and it understands git worktrees natively. In a linked worktree, the branch name is prepended as a subdomain, with zero per-tree configuration:

```bash
# Main worktree
portless run next dev   # -> https://myapp.localhost

# Linked worktree on branch "fix-ui"
portless run next dev   # -> https://fix-ui.myapp.localhost
```

Put `portless run` in `package.json` once and every worktree self-names. Under the hood each app gets a random free port via the `PORT` env var; nobody tracks offsets, because the port stopped being the identity of the service — the name is.

If that URL shape looks familiar, it should: it's **branch deploys, but local**. Cloudflare Pages gives every branch `<branch>.<project>.pages.dev`; Vercel and Netlify cut a preview URL per branch or PR. The reason those preview URLs transformed review workflows is that *a stable, predictable address per branch removes a whole class of coordination* — you never ask "where is this running?" Portless brings the same property to the laptop: worktree + branch-named URL ≈ a preview environment you didn't have to deploy. The mental model unifies end to end — `fix-ui.myapp.localhost` while the agent iterates, `fix-ui.myapp.pages.dev` when the branch pushes, same name both places.

Three knock-on effects matter specifically for parallel agents:

- **Agents stop guessing ports.** An agent validating its work hits the deterministic URL for *its* worktree (`portless get <name>` for scripts) instead of hardcoding `localhost:3000` and accidentally testing a sibling tree's server. This kills an entire failure mode from the original post — "one agent can restart the backend while another is testing" becomes structurally harder to do by accident.
- **Each worktree is a distinct browser origin.** Cookies, sessions, and localStorage are scoped per hostname, so one agent's logged-in Playwright session can't bleed into another's. This complements the per-tree test accounts from the first ledger: isolated *credentials* in the database, isolated *sessions* in the browser.
- **Sharing is one flag away.** `--tailscale` exposes a worktree's URL to your tailnet for a teammate to poke at — the local analog of pasting a preview-deploy link in a PR.

### 4. Parallelism multiplies spend

The forum ledger is about agents not breaking each other. The budget ledger is about agents not breaking *you*.

Cursor makes the multiplication explicit: `/best-of-n` runs the same task across N models in N worktrees ([guide](../CURSOR3-worktrees.md)). That's a premium tool for genuinely ambiguous tasks — architecture choices, algorithm tradeoffs — and a money bonfire for anything mechanical. The same model-routing discipline we use for plans ([hands-on walkthrough](cursor-plans-hands-on.v2.md)) applies per-worktree: default/cheap models for trees doing mechanical work, premium models pinned only on the one or two trees doing interpretive work, and a usage-dashboard check between merge waves.

The merge cadence and the budget cadence turn out to be the same cadence: **wave, validate, reconcile, next wave.**

## Verify isolation — don't assume it

One caveat from early Cursor 3 community reports that generalizes to any agent-worktree stack ([caveats list](../CURSOR3-worktrees.md)): runs that *looked* isolated sometimes weren't, and setup scripts sometimes silently didn't fire. Our standing loop for each worktree run:

1. **Baseline** — fresh tree passes tests/lint/typecheck before the agent touches anything. This also proves the setup script actually ran.
2. **Run** — agent works in the tree.
3. **Re-validate** — tests pass in the tree before applying back.
4. **Apply one tree at a time** — and validate after each apply, even when diffs look disjoint. Two agents that never touched the same file can still break each other through a shared schema, a shared config, or — per the first ledger — a shared database.
5. **Commit immediately** — small, per-task commits keep revert cheap when step 4 catches something.

Step 4 is where the two ledgers meet. The forum author keeps his database shared and notes that "migrations and global data still need coordination across worktrees." That coordination point *is* the apply step — code isolation ends exactly where service sharing begins, so that's where validation has to concentrate.

## The combined checklist

Before scaling past your second parallel worktree:

- [ ] **Runtime ledger** decided: ports offset (or named via portless), deps shared or copied, DB strategy, per-tree test accounts
- [ ] **Named dev URLs** if you run servers per tree: `portless run` in `package.json` so each worktree serves at `https://<branch>.<app>.localhost` — branch deploys, but local
- [ ] **Worktree runbook** committed (`WORKTREES.md` or equivalent) — ports, shared services, teardown gotchas
- [ ] **Rules and plans** committed under `.cursor/` — they're the only agent context that travels
- [ ] **Ignore policy** committed (`.cursorignore`, `.cursorindexingignore`, watcher/search excludes) — audited for anything stuck in user settings
- [ ] **`.gitignore` audited as a left-behind manifest** — every ignored-but-load-bearing path (env files, vendored clones, data, artifacts) assigned a disposition: symlink, copy, regenerate, or out of scope
- [ ] **Setup declared**, not tribal: `.cursor/worktrees.json` (or a setup script the runbook mandates), with a baseline check that proves it ran
- [ ] **Model routing** decided per tree; `/best-of-n` reserved for genuinely ambiguous tasks
- [ ] **Wave discipline**: apply one tree at a time, validate after each, reconcile spend between waves

The original post ends with "in theory this should allow each coding agent to safely run, test, fail, fix, and validate without stepping on the toes of others." The theory holds — but only if you keep both ledgers. The runtime ledger keeps agents from stepping on each other's *services*. The second ledger keeps the editor, the context, and the budget from quietly un-copying everything you thought the worktree copied.

---

*Last updated: 2026-06-12. Validate Cursor worktree behavior on your build — see the [caveats](../CURSOR3-worktrees.md).*
