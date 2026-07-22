# Cursor 3 Worktrees and Multi-Agent Guide (Mar-Apr 2026)

This guide prioritizes **new Cursor 3 material published in March-April 2026** and filters for articles that go deeper than launch recaps.

It then translates those findings into a practical workflow you can run day-to-day.

**Related in this repo:** [blog/worktrees-second-ledger.md](blog/worktrees-second-ledger.md) · [blog/worktrees-isolation-spectrum.md](blog/worktrees-isolation-spectrum.md) · [worktree-vcs-landscape.md](worktree-vcs-landscape.md) (June 2026 research: frontier providers, OSS ADEs, prose VCS) · [PROSE-VCS.md](PROSE-VCS.md) · [cursor-cloud-agents-vs-local.md](cursor-cloud-agents-vs-local.md) (Cloud vs local costs, limits, chat handoff — when *not* to use Cloud)

---

## 1) High-signal Cursor 3 sources (new, deep, useful)

### Official Cursor sources (highest confidence)

- [Meet the new Cursor (Apr 2, 2026)](https://cursor.com/blog/cursor-3)
  - Why it matters: canonical statement of the Cursor 3 architecture shift to an agent-first workspace.
- [Cursor 3.0 changelog (Apr 2, 2026)](https://cursor.com/changelog/3-0)
  - Why it matters: exact feature list and behavior changes (`/worktree`, `/best-of-n`, Agents Window, Design Mode).
- [Cursor 3 Worktrees & Best-of-N release thread (Apr 2026)](https://forum.cursor.com/t/cursor-3-worktrees-best-of-n/156507)
  - Why it matters: real-world friction reports and staff clarifications.
- [Introducing Composer 2 (Mar 19, 2026)](https://cursor.com/blog/composer-2)
  - Why it matters: model economics and speed, relevant for multi-agent cost/performance tradeoffs.
- [Cursor agents can now control their own computers (Feb 24, 2026)](https://cursor.com/blog/agent-computer-use)
  - Why it matters: cloud-agent behavior and artifacts; still directly relevant to Cursor 3 flows.
- [Run cloud agents in your own infrastructure (Mar 25, 2026)](https://cursor.com/blog/self-hosted-cloud-agents)
  - Why it matters: enterprise-safe parallelization pattern.

### Independent posts worth reading (practical and/or critical)

- [Running Parallel Agents in Cursor with Git Worktree (Apr 2, 2026)](https://engincanveske.substack.com/p/running-parallel-agents-in-cursor)
  - Why it matters: concrete daily workflow with examples.
- [Cursor 3 shipped parallel agents, but is any of it new? (Apr 2026)](https://liranbaba.dev/blog/cursor-3-parallel-agents/)
  - Why it matters: sober critique on cost visibility and context-sharing limits.
- [What is Cursor 3? (DataCamp, Apr 2026)](https://www.datacamp.com/blog/cursor-3)
  - Why it matters: broad but fairly detailed synthesis (feature behavior, plan constraints, pricing interpretation).

### Useful older/contextual reading (still valuable, but not Cursor 3-specific)

- [Best practices for coding with agents (Cursor)](https://cursor.com/blog/agent-best-practices)
  - Strong timeless workflow guidance (planning, context discipline, review loops).
- [Git worktrees for parallel AI coding agents (Upsun, Feb 2026)](https://devcenter.upsun.com/posts/git-worktrees-for-parallel-ai-coding-agents/)
  - Great systems-level framing of isolation tradeoffs beyond Cursor itself.

---

## 2) What actually changed in Cursor 3 for worktrees and multi-agent work

From the official release/changelog/docs + community reports:

- **Agent-first surface:** new Agents Window, multi-agent visibility, local/cloud/SSH/worktree contexts.
- **`/worktree` is explicit:** starts isolated git checkout for a chat; apply back to working branch with `/apply-worktree`.
- **`/best-of-n` is explicit:** runs same task in parallel across models, each in isolated worktree, then compares.
- **Design Mode:** UI-targeted selection and annotation in integrated browser.
- **Cloud handoff:** move local agent runs to cloud for long tasks, and back when needed.
- **Multi-repo support claims improved** in Cursor 3 release messaging.

---

## 3) Early Cursor 3 caveats to watch (important)

Community + staff responses in April 2026 show real rough edges:

- `/worktree` and `/best-of-n` were not consistently available in all surfaces/builds.
- Reports of instability in plan-mode interactions with worktree flows.
- Cases where worktree setup scripts or sandbox approvals added friction/token burn.
- Reports of ambiguity about whether the run truly remained isolated in the worktree.
- Usability regression complaints vs Cursor 2 visual affordances (worktree visibility/apply/discard speed).

Later reports from the [release thread](https://forum.cursor.com/t/cursor-3-worktrees-best-of-n/156507/34) (mid–late April 2026) sharpen the picture:

- **No UI indication of worktree context.** Branch–conversation association stayed locked to the *main* worktree; the changes and PR shown can belong to a different tree than the one the agent is editing. Users report only discovering the real location by inspecting git state directly.
- **Non-deterministic merge caused a production incident.** One team reported downtime after an agentic worktree merge created a commit that deployed unfinished work. The deterministic apply flow from Cursor 2 did not have this failure mode. Treat "let the agent merge the worktree" as unsafe; apply deterministically and validate after each apply.
- **`/apply-worktree` missing from the Agents Window** at the time, leaving only commit/push/PR — no way to apply a worktree's changes to your working branch locally.
- **A useful framing from the community:** Cursor 2 worktrees were *apply-oriented* (parallelize, then choose what lands on your branch); Cursor 3 worktrees are *PR-oriented* (each worktree session is expected to become its own PR against the default branch). If your workflow assumes the former, the latter feels broken rather than different.
- **Staff signal (Apr 21):** native worktree support in the Agent Window described as close to launch. Re-check current behavior before standardizing.

Practical conclusion: **treat worktree isolation as "verify, do not assume"** during each run — and treat the *merge back* as the highest-risk step, not the run itself.

---

## 4) Practical playbook: how to use Cursor 3 features well today

### A. Choose execution mode by task shape

- Use **single local agent** for quick edits, tiny bugfixes, short loops.
- Use **`/worktree`** for medium tasks that should stay isolated before apply.
- Use **`/best-of-n`** only for high-value ambiguous tasks (architecture/algorithm/refactor style differences).
- Use **cloud agents** for long-running work where you want to close laptop and review artifacts later. Skip Cloud when the task needs dirty local state, local-only tooling, or a tight approval loop — see [cursor-cloud-agents-vs-local.md](cursor-cloud-agents-vs-local.md).

### B. Partition work to avoid merge pain

Before parallelizing, split by boundaries:

- Agent 1: backend API contract
- Agent 2: frontend integration
- Agent 3: tests/docs

Avoid assigning two agents to same hotspot files (routing/config/schema core) unless intentional.

### C. Add deterministic worktree setup

Use `.cursor/worktrees.json` to standardize setup:

```json
{
  "setup-worktree-unix": [
    "cp -n .env.example .env || true",
    "pnpm install --frozen-lockfile",
    "pnpm -w build --if-present"
  ]
}
```

Then verify setup happened (do not trust silently):

- check expected files exist
- run baseline tests/lint in that worktree

### C2. Cross-vendor setup and merge-back (not Cursor-only)

Every major agent harness now has a worktree setup story; mechanisms differ ([full landscape](worktree-vcs-landscape.md)):

| Harness | Setup mechanism | Merge back |
|---------|-----------------|------------|
| **Cursor** | `.cursor/worktrees.json` | Apply / `/apply-worktree` from plan or Agents UI |
| **Claude Code** | [`.worktreeinclude`](https://code.claude.com/docs/en/worktrees) + optional `WorktreeCreate` hook | Manual merge or prompt on exit; hooks can customize |
| **Codex app** | [Local environment](https://developers.openai.com/codex/app/local-environments) scripts when starting a worktree thread | [Handoff](https://developers.openai.com/codex/app/worktrees) between Local and Worktree |
| **Fallback** | Slash command / skill at session start | Project-specific |

Claude's `.worktreeinclude` is the productized version of "copy gitignored env files into each tree" — same problem as our [left-behind manifest](blog/worktrees-second-ledger.md). Codex explicitly warns worktrees may miss unchecked-in dependencies.

### D. Use a baseline -> run -> verify loop

For each worktree run:

1. Confirm baseline on target branch (`tests`, `lint`, `typecheck`).
2. Kick off `/worktree` or `/best-of-n`.
3. Review diff quality and run validations again before apply.
4. Apply only scoped changes.
5. Commit immediately to keep clean integration points.

### E. Be intentional with `/best-of-n` cost

Treat best-of-n as a premium tool:

- use 2-3 models only for hard tasks
- cap retries
- pick a winner quickly and stop parallel runs

### F. Keep context quality high

Borrowing from older but still-relevant Cursor guidance:

- start with Plan mode when task is non-trivial
- save plans to workspace when useful
- start new chats per logical task to avoid context drift
- keep rules/commands concise and enforceable

---

## 5) Suggested "default workflow" you can adopt this week

1. **Plan** in one chat for each independent task.
2. For each approved plan, run **one worktree-backed agent**.
3. For only the hardest task, run **best-of-n**.
4. Use cloud handoff for anything expected to run more than ~20-30 minutes **and** already has a usable cloud env (otherwise prefer local — [cursor-cloud-agents-vs-local.md](cursor-cloud-agents-vs-local.md)).
5. Apply changes one worktree at a time, validating after each apply.
6. Keep commits small and per-task to reduce merge/revert pain.

---

## 6) Quick watchlist for April 2026+ updates

Track these before standardizing team workflow:

- maturity of worktree support inside Agents Window
- reliability of `/best-of-n` model routing and plan-mode behavior
- clearer cost telemetry for multi-agent/cloud-heavy use
- stronger first-class UI affordances for worktree state visibility and apply/discard

---

## 7) Reference links (curated)

- [Cursor 3 announcement](https://cursor.com/blog/cursor-3)
- [Cursor 3 changelog](https://cursor.com/changelog/3-0)
- [Worktrees and Best-of-N release discussion](https://forum.cursor.com/t/cursor-3-worktrees-best-of-n/156507)
- [Composer 2](https://cursor.com/blog/composer-2)
- [Cloud agents computer use](https://cursor.com/blog/agent-computer-use)
- [Self-hosted cloud agents](https://cursor.com/blog/self-hosted-cloud-agents)
- [Parallel agents practical walkthrough](https://engincanveske.substack.com/p/running-parallel-agents-in-cursor)
- [Critical review of Cursor 3 parallel agents](https://liranbaba.dev/blog/cursor-3-parallel-agents/)
- [DataCamp Cursor 3 analysis](https://www.datacamp.com/blog/cursor-3)
- [Cursor agent best practices (older but important)](https://cursor.com/blog/agent-best-practices)
- [Git worktree systems-level guide](https://devcenter.upsun.com/posts/git-worktrees-for-parallel-ai-coding-agents/)
- [Codex app worktrees](https://developers.openai.com/codex/app/worktrees)
- [Claude Code worktrees](https://code.claude.com/docs/en/worktrees)
- [Emdash ADE](https://github.com/generalaction/emdash)
- [worktree-vcs-landscape.md](worktree-vcs-landscape.md) (this repo)
- [cursor-cloud-agents-vs-local.md](cursor-cloud-agents-vs-local.md) (this repo — Cloud vs local field notes)
