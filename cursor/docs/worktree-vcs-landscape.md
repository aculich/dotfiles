# Worktree, parallel-agent, and document-VCS landscape (June 2026)

Research synthesis from parallel-web-search across frontier provider docs, OSS harnesses, Git alternatives, and markdown/prose version-control tooling. Captures what to evaluate, clone, and document — without losing the writeup to chat history.

**Related in this repo:** [CURSOR3-worktrees.md](CURSOR3-worktrees.md) · [blog/worktrees-second-ledger.md](blog/worktrees-second-ledger.md) · [blog/worktrees-isolation-spectrum.md](blog/worktrees-isolation-spectrum.md) · [PROSE-VCS.md](PROSE-VCS.md)

**Raw search JSON** (for follow-up queries): `worktree-vcs-landscape-search.json`, `worktree-frontier-providers-search.json`, `worktree-ade-tools-search.json`, `markdown-vcs-tools-search.json`, `markdown-prose-vcs-repos-search.json`, `markdown-doc-vcs-tools-search.json`, `frontier-worktree-official-search.json` (all in this directory).

---

## Executive summary

The major coding-agent vendors have converged on **worktrees** (or workspace isolation) as the default parallel-agent primitive, but with different packaging. Alongside that, a 2026 ecosystem of **Agentic Development Environments (ADEs)** and CLIs automates worktree lifecycle — and a separate **prose-diff gap** exists for markdown/plans/blog content where line-oriented `git diff` is the wrong review semantics.

Three layers:

1. **Frontier providers** productizing worktrees (Codex, Claude Code, Cursor).
2. **OSS harnesses** automating create → setup → merge → teardown.
3. **Document VCS** — git-backed markdown plus prose-aware review tooling; no dominant "GitButler for writing" yet.

---

## 1. Frontier model providers on worktrees

| Provider | Official stance | Notable detail |
|----------|-----------------|----------------|
| **OpenAI Codex** | Built-in worktree support in the Codex app | [Features](https://developers.openai.com/codex/app/features): parallel threads with worktrees. [Worktrees docs](https://developers.openai.com/codex/app/worktrees): Local vs Worktree, **Handoff** between them, optional local-environment setup scripts. [Local environments](https://developers.openai.com/codex/app/local-environments): worktrees may miss dependencies not checked into the repo. [Best practices](https://developers.openai.com/codex/learn/best-practices): pin threads, use worktrees in UI. |
| **Anthropic Claude Code** | First-class `--worktree` / `-w` | [Run parallel sessions with worktrees](https://code.claude.com/docs/en/worktrees): `.worktreeinclude`, `WorktreeCreate`/`WorktreeRemove` hooks, subagent `isolation: worktree`, `worktree.baseRef` (`origin/HEAD` vs local `HEAD`). Desktop app creates a worktree per session automatically. |
| **Cursor** | `/worktree`, `/best-of-n`, Agents Window | [Cursor 3 changelog](https://cursor.com/changelog/3-0), [Parallel Agents docs](https://cursor.com/docs/configuration/worktrees) (`.cursor/worktrees.json`), [agent best practices](https://cursor.com/blog/agent-best-practices) (worktree dropdown → Apply). See [CURSOR3-worktrees.md](CURSOR3-worktrees.md) for caveats. |
| **Google** | No worktree-specific parallel-agent docs in this search | Only a [Gemini API dev skill](http://officialskills.sh/google-gemini/skills/gemini-api-dev) surfaced — not a parallel-workspace product story. |

### Cross-vendor setup mechanisms

Everyone has a "who runs your worktree setup?" story; the mechanisms differ:

| Harness | Mechanism | Character |
|---------|-----------|-----------|
| **Cursor** | `.cursor/worktrees.json` setup commands | Imperative shell steps, committed; verify they ran |
| **Claude Code** | `.worktreeinclude` + `WorktreeCreate`/`WorktreeRemove` hooks | Declarative copy list; full programmatic override (even SVN/Perforce) |
| **Codex** | Local-environment setup scripts | Per [local environments](https://developers.openai.com/codex/app/local-environments); select when starting a worktree thread |
| **Slash command / skill** | Session-start fallback | e.g. forum author's `/worktree-dev-env` — portable, relies on remembering to run it |

**Merge-back semantics differ too:** Cursor **Apply** / `/apply-worktree`; Codex **Handoff** (moves thread + code between Local and Worktree); Claude prompts cleanup on exit. Treat merge-back as the highest-risk step ([forum reports](https://forum.cursor.com/t/cursor-3-worktrees-best-of-n/156507/34) include a production incident from non-deterministic agentic merge).

---

## 2. Open-source worktree harnesses (clone candidates)

Beyond raw `git worktree`, evaluable under `upstream/` per repo convention.

### Full ADEs (orchestration + worktrees)

| Project | License / notes | URL |
|---------|-----------------|-----|
| **Emdash** | Apache 2.0, YC W26 | [github.com/generalaction/emdash](https://github.com/generalaction/emdash) — parallel agents in isolated worktrees, issue integration, diff/PR/CI; [docs](https://emdash.sh/docs) |
| **Conductor** | Commercial; docs OSS-readable | [conductor.build/docs/concepts/parallel-agents](https://www.conductor.build/docs/concepts/parallel-agents) — **multiple workspaces** (separate branches/trees) vs one workspace with multiple agents; decision guide worth citing |

### Worktree CLIs and agent integrations

| Repo | What it does |
|------|--------------|
| [DanHenton/opencode-worktree](https://github.com/DanHenton/opencode-worktree) | Go CLI: `agent/<task>` branch in sibling worktree, copy OpenCode config, auto-merge on exit |
| [kdcokenny/opencode-worktree](https://github.com/kdcokenny/opencode-worktree) | Zero-friction OpenCode worktrees + terminal spawn + cleanup |
| [calebrosario/opencode-plugin-worktree](https://github.com/calebrosario/opencode-plugin-worktree) | OpenCode plugin with lifecycle hooks |
| [felixAnhalt/opencode-worktree-session](https://github.com/felixAnhalt/opencode-worktree-session) | Automatic worktree per OpenCode session |
| [AryaLabsHQ/agentree](https://github.com/AryaLabsHQ/agentree) | Create/manage isolated worktrees for AI agents |
| [agenttools/worktree](https://github.com/agenttools/worktree) | Worktrees + GitHub issues + Claude Code |
| [jarredkenny/worktree-manager](https://github.com/jarredkenny/worktree-manager) | Bare-repo `wtm` layout with hooks on create |
| [chmouel/lazyworktree](https://github.com/chmouel/lazyworktree) | TUI worktree manager |
| [JoshYG-TheKey/git-worktree-manager](https://github.com/JoshYG-TheKey/git-worktree-manager) | Rich interactive CLI with diff summaries |
| [AntJanus/skillbox](https://github.com/AntJanus/skillbox) | `/git-worktree` skill — [walkthrough](https://antjanus.com/ai/using-git-worktrees-for-better-agents) |

### Reference writing (not repos)

- [Upsun: Git worktrees for parallel AI coding agents](https://devcenter.upsun.com/posts/git-worktrees-for-parallel-ai-coding-agents/) — systems framing; **branch-preview environments** on platform (deploy-time parallel to local portless/worktrees).
- [gitworktree.org: Parallel AI Agents](https://www.gitworktree.org/ai-tools/parallel-agents) — architecture + orchestration layer.
- [Medium: Git Worktrees secret weapon](https://medium.com/@mabd.dev/git-worktrees-the-secret-weapon-for-running-multiple-ai-coding-agents-in-parallel-e9046451eb96) (Dec 2025).
- [Dan Does Code: Parallel Vibe Coding with Git Worktrees](https://www.dandoescode.com/blog/parallel-vibe-coding-with-git-worktrees) (Feb 2026).
- [Brailsford: WorktreeCreate hooks + `.worktreeinclude`](https://github.com/mattbrailsford/mattbrailsford.dev/discussions/54) (Feb 2026).

**Suggested `upstream/` clones to evaluate:** `gitbutlerapp/gitbutler`, `generalaction/emdash`, `DanHenton/opencode-worktree`, `abhinav/git-spice`, `jj-vcs/jj`, `Wilfred/difftastic`.

---

## 3. Beyond worktrees: virtual branches and native workspaces

| Tool | Model | Clone |
|------|-------|-------|
| **[GitButler](https://gitbutler.com/)** | Virtual branches — multiple branches on one working directory; `but commit --changes` routes files to branches | `github.com/gitbutlerapp/gitbutler` |
| **[git-spice](https://github.com/abhinav/git-spice)** | Stacked branches on plain Git (`gs branch`, `gs stack restack`) — GPL | `github.com/abhinav/git-spice` |
| **[Jujutsu (jj)](https://docs.jj-vcs.dev/latest/git-compatibility)** | Native `jj workspace` instead of `git-worktree`; explicitly no `git-worktree` but equivalent multi-checkout | `github.com/jj-vcs/jj` |

[Trigger.dev: We ditched worktrees](https://trigger.dev/blog/parallel-agents-gitbutler) — strongest counter-argument for heavy-service monorepos. Covered in [blog/worktrees-isolation-spectrum.md](blog/worktrees-isolation-spectrum.md).

**Stacked branches for fork maintenance:** GitButler [stacked branches](https://docs.gitbutler.com/features/branch-management/stacked-branches) and git-spice [local stack workflow](https://abhinav.github.io/git-spice/guide/branch/) — relevant for ignored `upstream/` forks ([IGNORING.md](IGNORING.md)).

### Extended isolation spectrum (including deploy-time)

| Position | Working dirs | Services | Branch mechanism | Who it fits |
|----------|-------------|----------|------------------|-------------|
| **0** | 1 | 1 | Sequential branches | Solo, no parallelism |
| **1** | N | N (offset ports, per-tree accounts) | Worktrees | Light full-stack; [forum author](https://community.theaiautomators.com/c/discussions/anyone-here-using-git-worktrees) |
| **2** | N | 1 shared (portless, shared DB) | Worktrees | Our default — [second ledger](blog/worktrees-second-ledger.md) |
| **2b** | N (platform) | N per branch preview | Branch deploy URLs | Upsun / Cloudflare Pages / Vercel previews — validate in deployed env, not just local |
| **3** | 1 | 1 | GitButler virtual branches | Heavy monorepo; disjoint file tasks |
| **3b** | N (`jj workspace`) | 1 or N | Jujutsu workspaces | Git-interop shops wanting native multi-checkout without `git worktree` |

[Conductor](https://www.conductor.build/docs/concepts/parallel-agents) adds a orthogonal axis: **multiple workspaces** (like worktrees) vs **multiple agents in one workspace** (shared branch — good for implement + test repair on same diff).

---

## 4. Markdown and document version control — the prose-diff gap

Code diffs and writing diffs are different problems. Three tiers:

### Tier A: Git for markdown (line-oriented)

Plain markdown in git is the default. [Nimbalyst's 2026 editor guide](https://nimbalyst.com/blog/the-complete-guide-to-markdown-editors/) notes git diffs work well for plain text — standard developer answer.

**Limitation:** paragraph rewrites show as noisy line churn. `git diff --word-diff` helps but isn't review-UI-friendly.

**Our repos:** `.cursor/plans/`, `docs/blog/`, committed runbooks — all tier A.

### Tier B: Better diffs for prose (still git-backed)

| Tool | Role |
|------|------|
| **[Difftastic](https://github.com/Wilfred/difftastic)** | MIT; structural diff; falls back to line + **word highlighting** for unknown extensions; git diff driver |
| **[Nimbalyst](https://nimbalyst.com/blog/the-complete-guide-to-markdown-editors/)** | OSS WYSIWYG markdown + **inline diff review** (marketing claims; evaluate for agent-edited docs) |

See [PROSE-VCS.md](PROSE-VCS.md) for toolchain recommendations.

### Tier C: Document-native VCS / collaboration

| Tool | Role | OSS? |
|------|------|------|
| [Logseq](https://github.com/logseq/logseq) | Knowledge platform; markdown/org locally; DB+RTC alpha | AGPL |
| [HedgeDoc](https://github.com/hedgedoc/hedgedoc) | Real-time collaborative markdown; v2 rewrite in progress | AGPL |
| [Fossil SCM](https://fossil-scm.org/) | DVCS + integrated wiki + bugs in one SQLite DB | BSD |
| Obsidian + Git plugin | De facto personal markdown VCS; Obsidian not OSS | Plugin ecosystem — [ITSFOSS](https://itsfoss.com/git-with-obsidian) (Oct 2025) |

**Honest gap:** No widely adopted "GitButler for markdown" with virtual branches on prose and paragraph-level merge. Emerging pattern for agent-heavy doc workflows:

1. **Store** markdown in git.
2. **Review** with word/structural diff (difftastic, inline review UI).
3. **Collaborate** via HedgeDoc/Logseq RTC when needed — not as canonical VCS.

**Worktree angle:** Agent-generated blog posts and plans need **prose-aware review before apply/merge**, not just `git diff` in the PR UI. Add to verify loop in [second ledger](blog/worktrees-second-ledger.md).

---

## 5. What we incorporated into existing docs

| Addition | Where |
|----------|-------|
| Cross-vendor setup + merge-back table | [CURSOR3-worktrees.md](CURSOR3-worktrees.md) §4C |
| Extended spectrum (2b deploy, 3b jj, Conductor) | [blog/worktrees-isolation-spectrum.md](blog/worktrees-isolation-spectrum.md) |
| Prose review in verify loop | [blog/worktrees-second-ledger.md](blog/worktrees-second-ledger.md) |
| Prose vs code diff toolchain | [PROSE-VCS.md](PROSE-VCS.md) |
| Landscape pointer | All of the above + this file |

---

## Sources

- [Run parallel sessions with worktrees — Claude Code](https://code.claude.com/docs/en/worktrees)
- [Worktrees — Codex app](https://developers.openai.com/codex/app/worktrees)
- [Local environments — Codex app](https://developers.openai.com/codex/app/local-environments)
- [Cursor 3 changelog](https://cursor.com/changelog/3-0)
- [Parallel Agents — Cursor Docs](https://cursor.com/docs/configuration/worktrees)
- [Best practices for coding with agents — Cursor](https://cursor.com/blog/agent-best-practices)
- [We ditched worktrees — Trigger.dev](https://trigger.dev/blog/parallel-agents-gitbutler)
- [GitButler](https://gitbutler.com/) · [Virtual branches docs](https://docs.gitbutler.com/features/branch-management/virtual-branches)
- [Emdash](https://github.com/generalaction/emdash) · [Docs](https://emdash.sh/docs)
- [Parallel agents — Conductor](https://www.conductor.build/docs/concepts/parallel-agents)
- [git-spice](https://github.com/abhinav/git-spice)
- [Jujutsu git compatibility](https://docs.jj-vcs.dev/latest/git-compatibility)
- [Upsun worktrees guide](https://devcenter.upsun.com/posts/git-worktrees-for-parallel-ai-coding-agents/)
- [Parallel agents — gitworktree.org](https://www.gitworktree.org/ai-tools/parallel-agents)
- [Difftastic](https://github.com/Wilfred/difftastic)
- [Nimbalyst markdown editors 2026](https://nimbalyst.com/blog/the-complete-guide-to-markdown-editors/)
- [Logseq](https://github.com/logseq/logseq) · [HedgeDoc](https://github.com/hedgedoc/hedgedoc)
- [Brailsford worktree hooks](https://github.com/mattbrailsford/mattbrailsford.dev/discussions/54)

*Last updated: 2026-06-12.*
