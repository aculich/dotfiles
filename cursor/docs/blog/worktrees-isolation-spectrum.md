# When the worktree tax exceeds the merge tax: the isolation spectrum

*A sequel to [the second ledger](worktrees-second-ledger.md). Worktrees are the standard advice for parallel agents — but they're one point on a spectrum, and for some codebases the wrong one. On GitButler virtual branches, Trigger.dev's defection, and how to pick your isolation level.*

**Companions:** [worktrees-second-ledger.md](worktrees-second-ledger.md) · [CURSOR3-worktrees.md](../CURSOR3-worktrees.md) · [IGNORING.md](../IGNORING.md) · [worktree-vcs-landscape.md](../worktree-vcs-landscape.md)

---

## The rut

The tooling advice for parallel AI development has settled into a chant: *just use worktrees*. Each agent gets its own checkout, its own branch, no conflicts. We've written two ledgers' worth of material on making that work — what to isolate, what to share, what gets left behind.

Then [Trigger.dev published "We ditched worktrees for Claude Code"](https://trigger.dev/blog/parallel-agents-gitbutler), and the argument deserves engagement rather than dismissal, because it's our own argument pushed one step further.

Their setup: a large TypeScript monorepo — PostgreSQL, Redis, ClickHouse, a Remix app, a dozen internal packages. Their finding:

> When we tried worktrees for parallel Claude Code sessions, we spent more time on setup than shipping code.

Every line of that complaint is a row from the [first ledger](worktrees-second-ledger.md#the-first-ledger): port conflicts per tree, database migrations out of sync between trees, every shared service becoming "another thing to duplicate or isolate." The worktree pattern doesn't fail on small projects; it fails when the *services around the codebase* are heavy enough that the per-tree setup tax exceeds the merge-conflict tax the isolation was buying you.

So they moved to the opposite end of the spectrum.

## The spectrum

It helps to see the options as positions on one axis — how much of the world you duplicate per parallel task:

| Position | Working dirs | Services | Branch mechanism | Who it fits |
|----------|-------------|----------|------------------|-------------|
| **0. Single tree, sequential** | 1 | 1 set | Plain branches, one at a time | Solo work, no parallelism |
| **1. Worktrees + full per-tree env** | N | N sets (offset ports, per-tree test accounts) | One branch per tree | The [forum author's setup](https://community.theaiautomators.com/c/discussions/anyone-here-using-git-worktrees); apps light enough to duplicate |
| **2. Worktrees + shared services** | N | 1 set (shared DB, shared heavy deps, [portless](https://github.com/vercel-labs/portless)-named servers) | One branch per tree | Our setup; most full-stack work — see [the second ledger](worktrees-second-ledger.md) |
| **3. One tree, virtual branches** | 1 | 1 set | [GitButler](https://gitbutler.com/): N branches applied to one directory, changes assigned at commit time | Heavy-service monorepos; tasks touching disjoint files |
| **2b. Branch deploy previews** | 1 local + N deployed | N per preview URL | [Upsun](https://devcenter.upsun.com/posts/git-worktrees-for-parallel-ai-coding-agents/) / Cloudflare Pages / Vercel — validate on `<branch>.<project>.pages.dev` etc. | When local service duplication is too heavy but you still want per-branch environments |
| **3b. Jujutsu workspaces** | N (`jj workspace`) | 1 or N | [Jujutsu](https://docs.jj-vcs.dev/latest/git-compatibility): native multi-checkout, no `git-worktree` | Git-interop shops wanting jj's change model |

**Orthogonal choice — [Conductor](https://www.conductor.build/docs/concepts/parallel-agents):** multiple **workspaces** (independent branches, like worktrees) vs multiple **agents in one workspace** (shared branch — good when one agent implements and another fixes tests on the same diff).

Positions 1 and 2 isolate *files* and pay for it in environment setup. Position 3 isolates *nothing at runtime* and pays for it in commit-time discipline. Position 2b trades local duplication for deploy-time isolation. The Trigger.dev piece is the case study for when 3 beats 1 and 2.

## How position 3 actually works

GitButler inverts the worktree premise. Instead of giving each branch its own copy of the files, it keeps **multiple branches applied to the same working directory simultaneously** — "virtual branches" — and *assigns* changes to branches after the fact. Behind the scenes it maintains a `gitbutler/workspace` branch: a merge commit representing the union of all applied branches, so standard git tooling (and your dev server, and your one database) sees a single coherent state.

The agent-facing surface is the `but` CLI, and the detail that matters is `--changes`:

```bash
# Claude runs `but status --json`, sees two branches and three unassigned files:
#   Branch: feat/usage-api (fe)
#   Branch: docs/usage-api (do)
#   g0: apps/webapp/app/routes/api.v1.usage.ts
#   h0: apps/webapp/app/routes/api.v1.usage.test.ts
#   i0: docs/sdk/runs-usage.mdx

but commit fe -m "Add /api/v1/usage endpoint" --changes g0,h0
but commit do -m "Document usage API endpoint" --changes i0
```

One agent session, two branches, two future PRs — the session's output is *routed*, not isolated. Every `but` command takes `--json` (agent-friendly), and an operations log backs a universal `but undo`.

Two integration styles exist, and Trigger.dev's choice between them is instructive:

- **GitButler's [Claude Code hooks](https://docs.gitbutler.com/features/ai-integration/claude-code-hooks)** auto-assign each session's changes to one branch. Clean for "three agents, three tasks" — but it hardwires *one session = one branch*.
- **A skill teaching the `but` CLI directly** (their approach, and [GitButler publishes one](https://github.com/gitbutlerapp/claude)): the agent never runs git write commands, checks `but status --json` before mutations, and decides per-file which branch each change belongs to. They chose this because real sessions don't split cleanly — one feature session also touches docs and SDK types, and they want those in separate PRs.

That second style is worth noticing independent of GitButler: it's the same move as our committed worktree runbooks — **put the workflow in a committed instruction file the agent reads, rather than in per-session memory or per-machine hooks.** The lesson generalizes across the whole spectrum.

## When worktrees still win

Trigger.dev is candid about where position 3 breaks, and all three failure modes are familiar from our ledgers:

- **Same-file conflicts.** Virtual branches share one physical directory; GitButler's maintainers [confirm](https://github.com/gitbutlerapp/gitbutler/discussions/12228) that overlapping edits "can definitely lead to problems related to races and interference." If two tasks touch the same files, you need real file isolation (worktrees) or sequencing.
- **Build isolation.** Different build flags or env vars per task need separate directories.
- **Stateful test suites.** If tests mutate shared state — exactly the shared-database coordination problem from the first ledger — one directory makes it worse, not better.

So the decision factors come down to:

| Question | Points toward |
|----------|---------------|
| Do parallel tasks touch overlapping files? | Worktrees (1/2) |
| Are the surrounding services heavy (multi-service monorepo, big DBs)? | Virtual branches (3) |
| Do tests mutate shared state per task? | Worktrees + per-tree accounts (1), or sequence the test phase |
| Is the real goal *one session's output split into several clean PRs*? | Virtual branches (3) — worktrees can't do this at all |
| Do you need per-task build configs or env vars? | Worktrees (1/2) |

That fourth row is the one worktrees genuinely cannot answer. A worktree maps one tree to one branch; if a single agent session legitimately produces changes for three PRs, the worktree model forces you to either ship a mixed PR or manually tease commits apart afterward. Change-routing is a different capability than change-isolation, and it took a different tool to provide it.

## The fork-maintenance bonus: stacked branches

One more GitButler capability earns its place here even outside parallel-agent work: **stacked branches** — small dependent branches layered on each other, reviewable and landable incrementally.

We keep reference clones and forks of upstream open-source projects under an ignored `upstream/` directory ([IGNORING.md](../IGNORING.md)), and some of those forks carry local patches while tracking a moving upstream. The traditional cost is rebase pain and version drift: your patch pile and upstream's history diverge until reconciliation becomes a project of its own. Stacking turns the patch pile into an ordered set of small branches — rebase the stack on upstream, land what got accepted, keep carrying what didn't. Same discipline as stacked PRs at work, applied to fork maintenance. OSS alternatives to evaluate: [git-spice](https://github.com/abhinav/git-spice) (`gs stack restack`) alongside GitButler — see [landscape](../worktree-vcs-landscape.md).

## The bigger frame

GitButler [raised $17M](https://blog.gitbutler.com/series-a) in April 2026 to build, in co-founder Scott Chacon's words, "what comes after Git." His framing of the moment is hard to unhear:

> Today, with Git, we're all teaching swarms of agents to use a tool built for sending patches over mailing lists.

Whether or not GitButler is the answer, the diagnosis matches everything in these three posts: the friction in parallel agent work isn't generating change, it's **organizing, reviewing, and integrating change without chaos** — and the current toolchain handles that with a stack of compensations (worktrees, setup scripts, ignore manifests, apply discipline) layered over a model that assumed one person, one branch, one linear flow. Meanwhile the harnesses are productizing those compensations one by one: Claude Code's [`.worktreeinclude` and `WorktreeCreate` hooks](https://code.claude.com/docs/en/worktrees), Cursor's `worktrees.json` and in-progress Agent Window worktree support ([caveats](../CURSOR3-worktrees.md)), GitButler's session-to-branch routing.

The practical takeaway is smaller than the manifesto: **pick your position on the spectrum per project, not by fashion.** Light services and overlapping files → worktrees with a full per-tree environment. Typical full-stack app → worktrees with shared services and the two ledgers. Heavy monorepo with naturally disjoint tasks → one tree, virtual branches, and an agent that knows how to route its own changes. The chant "just use worktrees" was only ever right for the middle of that range.

---

*Last updated: 2026-06-12. GitButler is in open beta and the `but` CLI is evolving; check the [docs](https://docs.gitbutler.com/) before adopting.*
