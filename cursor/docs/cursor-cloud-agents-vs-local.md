# Cloud Agents vs local Agent (learned notes)

**Date:** 2026-07-21  
**Status:** Field notes from reading Cursor docs + deciding *not* to use Cloud for an ADHD-skills handoff. Prefer official docs when behavior drifts.

**Naming:** Formerly **Background Agents**; product docs now say **Cloud Agents**. Same feature family.

**Official entry points:**

- [Cloud Agents](https://cursor.com/docs/cloud-agent.md)
- [Help: Cloud Agents](https://cursor.com/help/ai-features/cloud-agents.md)
- [Setup](https://cursor.com/docs/cloud-agent/setup.md) · [Security / network](https://cursor.com/docs/cloud-agent/security-network.md) · [Capabilities](https://cursor.com/docs/cloud-agent/capabilities.md)
- Older name alias: [Background Agents help](https://cursor.com/help/ai-features/background-agents.md)

---

## 1. What Cloud Agents actually are

Same agent fundamentals (tools, models, rules/skills mindset) as a local Agent chat, but they run in an **isolated Ubuntu VM** in Cursor’s cloud (not on your laptop).

| Aspect | Local Agent | Cloud Agent |
| --- | --- | --- |
| Compute | Your machine (or SSH) | Cursor-managed VM |
| Laptop online | Needed for long runs | Not required; many in parallel |
| Working tree | Sees local files, including dirty | Clean clone from SCM; separate branch |
| Shell | Usually approval-gated | Auto-runs commands |
| Local home / user hooks | `~/.cursor`, local MCP | No `~/.cursor/hooks.json`; team/dashboard MCP + **repo** `.cursor/hooks.json` |
| Handoff shape | Edits in place | Branch + **draft PR** + artifacts (screenshots/logs; optional remote desktop) |

**Prerequisites (docs):** paid plan; account admin connects GitHub/GitLab/Bitbucket/Azure DevOps; triggering user has **read-write** on the repo (and deps/submodules).

**How to start:** Desktop Agent input → **Cloud**; [cursor.com/agents](https://cursor.com/agents); CLI prepend `&` to hand off mid-conversation; `@cursor` on PR/issue/Slack/Linear; API / Automations.

**“Move to Cloud” gotcha:** Transfers conversation context, **not** uncommitted local files. Agent starts from a **clean remote** state — commit or stash first if dirty work must be included.

---

## 2. Cost (documented vs confirm-in-dashboard)

From [Cloud Agents docs](https://cursor.com/docs/cloud-agent.md):

- Charged at **API pricing** for the **selected model**
- Larger **context window** → more tokens / cost
- First use asks for a **spend limit**
- Curated model set (explicit picker; not the same as “Auto” local routing narrative)

Local Agent usage is generally framed as plan / included usage + model rates ([pricing help](https://cursor.com/help/account-and-billing/pricing.md)). Whether a Cloud run draws included allowance before on-demand is **not fully spelled out** on the main Cloud page — confirm in the billing dashboard for this account.

**Implication:** Cloud is easy to burn on long auto-run loops. Budget with a spend limit; don’t assume “same as a local chat.”

Related cost tooling in this repo: [cursor-cost-tooling.md](cursor-cost-tooling.md) · [cursor-pricing-snapshot.md](cursor-pricing-snapshot.md).

---

## 3. Limitations and risks vs local

**Environment is the bottleneck.** Without deps, tests, secrets, and startup configured (dashboard snapshot / `.cursor/environment.json` / Dockerfile), the agent cannot close the loop. Docs compare an unset env to “not giving engineers a computer.”

**Security / autonomy:**

- Auto-run + default internet → higher prompt-injection / exfiltration surface than gated local shells
- Prefer network allowlists + **Runtime Secrets** (redacted) over baking `.env` into snapshots
- Draft PRs are the review gate; nothing merges until a human says so (commits are signed / “Verified” in SCM)

**Other gotchas:**

- No access to your local-only tools, VPN, or home-dir MCP unless wired into the cloud env
- Legacy Privacy Mode unsupported; standard Privacy Mode required
- Team follow-ups can let others drive an agent that holds **another user’s** secrets — treat as shared credentials
- Snapshots: retention / not freely deletable like transcripts (see security docs)

**Prefer local when:**

- You need dirty/uncommitted state, interactive approval, or a tight IDE loop
- Task depends on local `just` / global skill trees / machine-only paths without a cloud env yet
- You want maximum human-in-the-loop on every shell step

**Prefer Cloud when:**

- Long unattended work, parallel tasks, laptop-off
- Multi-repo coordinated PRs with artifact demos
- Env + secrets already set up so the agent can build/test for real

---

## 4. Chat / window “handoff” is not teleportation

Separate from Cloud vs local: **one Agent chat cannot take over another open workspace window.**

| Option | What happens |
| --- | --- |
| Same chat, absolute paths | This agent can edit `/Users/me/projects/other-repo` from a `dotfiles/cursor` chat. Filesystem works; **default context** (rules, `AGENTS.md`, indexing) still belongs to the open workspace. |
| New Agent chat in the target window | Correct SoT context. You carry context by pasting a handoff or `@` a plan file. The other chat does **not** inherit this thread automatically. |
| Cloud Agent on a repo | Separate VM run → branch + draft PR. Not “that other Desktop chat continues.” |

**Durable handoff pattern that works:** write a short plan/handoff markdown into the **target repo**, then start a **new** Agent there and `@` that file. Do not expect Cursor to push messages between windows.

---

## 5. Decision log: 2026-07-21 ADHD skills work

Context: comparing community [`ayghri/i-have-adhd`](https://github.com/ayghri/i-have-adhd) (output-shape skill) with our ADHD stack already curated in private [`aculich/agent-skills`](https://github.com/aculich/agent-skills) (`adhd-daily-planner`, `adhdev-engineering-partnership`, `project-management-guru-adhd`).

| Decision | Rationale |
| --- | --- |
| **Do not** use Cloud for this first pass | Needs local inspect/`npx skills`/`just` loops; env not required for a thin companion skill; Cloud would be overkill and cost-noisy |
| Execute in **`~/projects/agent-skills`** (local Agent) | Skills SoT; this Cursor repo should stay out of skills authoring |
| Handoff = plan file or paste into a **new** agent-skills chat | Not Cloud; not “make the other window take over” |
| Optional later: private ADHD **pack** repo | Nice for `npx skills add` of a subset; **not** required for Cloud — monorepo already private on GitHub |
| Thin Cursor rule only after A/B | Prefer skill `assets/` owned by agent-skills; avoid growing rules in this utility repo |

Repo boundary reminder:

| Repo | Owns |
| --- | --- |
| `~/projects/agent-skills` | Author, inspect, install, eval, promote, provenance |
| `~/dotfiles/cursor` | Cursor config, keybindings, observability, **learning docs like this one** |
| `~/ops/dotfiles-cursor-compendium` | Optional private backup / invent dumps |

---

## 6. Related in this repo

- [CURSOR3-worktrees.md](CURSOR3-worktrees.md) — Cursor 3 playbook (includes when Cloud *is* a good default for long runs)
- [MULTIROOT.md](MULTIROOT.md) — multi-root vs cloud checkout caveats
- [MULTIROOT-cursor-lifecycle.md](MULTIROOT-cursor-lifecycle.md) — chats, renames, plans
- [cursor-cost-tooling.md](cursor-cost-tooling.md) · [cursor-pricing-snapshot.md](cursor-pricing-snapshot.md)
- [COMPENDIUM.md](COMPENDIUM.md) — private sibling backup; skills invent shims back to agent-skills
