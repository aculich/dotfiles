# Prose and markdown version control

Companion to [worktree-vcs-landscape.md](worktree-vcs-landscape.md) §4. Code diffs and **writing diffs** are different review problems — especially when agents edit `.cursor/plans/`, `docs/blog/`, and other committed markdown alongside source code.

For git ignore policy and what travels into worktrees, see [IGNORING.md](IGNORING.md). For parallel code isolation, see [blog/worktrees-second-ledger.md](blog/worktrees-second-ledger.md).

---

## The gap

Git treats markdown as plain text. That is correct for **storage** and wrong for **review** when an agent rewrites a paragraph: line-oriented diffs show churn, not intent. You need both:

- **Code workflow** — worktrees, structural/code diffs, tests, apply discipline.
- **Prose workflow** — word- or paragraph-aware review before merge, especially for agent-generated drafts.

There is no dominant open-source "GitButler for markdown" with virtual prose branches. The practical pattern is git-backed files + prose-aware review tooling.

---

## Three tiers

### Tier A — Git for markdown (default)

Store plans, blog posts, and runbooks in the repo (`.cursor/plans/`, `docs/blog/`, `WORKTREES.md`). Line diffs in PRs and `git log` are enough for small edits.

**Limits:** paragraph moves and rewrites look like delete+add blocks; agents can "fix" prose by rewriting entire sections, hiding the actual change.

**Built-in mitigation:**

```bash
git diff --word-diff=plain path/to/doc.md
git diff --word-diff=color path/to/doc.md
```

### Tier B — Prose-aware diff (still git-backed)

| Tool | Use for | Clone / install |
|------|---------|-----------------|
| **[Difftastic](https://github.com/Wilfred/difftastic)** | Terminal/PR-adjacent review; word highlight fallback for markdown | `github.com/Wilfred/difftastic` |
| **Git word-diff** | Quick CLI check before apply | Built into git |
| **[Nimbalyst](https://nimbalyst.com/blog/the-complete-guide-to-markdown-editors/)** | WYSIWYG markdown + inline diff review (evaluate; OSS per their marketing) | Their repo/site |

**Difftastic as external diff tool** (example — adjust path):

```bash
git config diff.external difft
# or: git -c diff.external=difft diff docs/blog/my-post.md
```

Use when reviewing agent-edited blog posts or long plan files before committing from a worktree apply.

### Tier C — Document collaboration (not canonical VCS)

For real-time co-editing, not replacement for git in agent repos:

| Tool | Notes | OSS |
|------|-------|-----|
| [HedgeDoc](https://github.com/hedgedoc/hedgedoc) | Collaborative markdown server | AGPL |
| [Logseq](https://github.com/logseq/logseq) | Local markdown/org; RTC alpha on DB version | AGPL |
| [Fossil SCM](https://fossil-scm.org/) | Code + wiki in one DB | BSD |
| Obsidian + Git plugin | Personal vault sync; Obsidian itself not OSS | Plugin only |

Do not confuse tier C with worktree isolation — they solve collaboration, not parallel agent file isolation.

---

## Agent + worktree implications

When an agent finishes in a worktree and the diff includes **markdown**:

1. **Separate code review from prose review** — run tests/lint on code; read prose diffs with word-diff or difftastic.
2. **Plans are prose** — `.cursor/plans/*.plan.md` edits need the same discipline as blog posts ([cursor-plans-agents-guide.md](cursor-plans-agents-guide.md)).
3. **Don't trust line-diff alone for Fable/narrative todos** — high token spend on prose deserves human read before apply.

Add to worktree verify loop ([second ledger](blog/worktrees-second-ledger.md)): after re-validate tests, **review markdown changes with prose-aware diff** before apply.

---

## Checklist for prose in git-backed repos

- [ ] Plans and blog posts committed under predictable paths (`.cursor/plans/`, `docs/blog/`)
- [ ] `git diff --word-diff` or difftastic available for pre-merge review of agent prose
- [ ] Worktree apply step includes explicit prose review when diff touches `*.md` outside generated/changelog noise
- [ ] Large binary assets in markdown (images, PDFs) stay out of git or use LFS — see [MULTIROOT.md](MULTIROOT.md) §5–6

---

## Sources

- [worktree-vcs-landscape.md](worktree-vcs-landscape.md) — full landscape and OSS repo list
- [Difftastic](https://github.com/Wilfred/difftastic)
- [Nimbalyst: Best Markdown Editor 2026](https://nimbalyst.com/blog/the-complete-guide-to-markdown-editors/)
- [Logseq](https://github.com/logseq/logseq) · [HedgeDoc](https://github.com/hedgedoc/hedgedoc)

*Last updated: 2026-06-12.*
