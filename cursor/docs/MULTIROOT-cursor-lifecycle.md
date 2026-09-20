# Cursor workspaces, chat history, plans, and archival tools

Companion to [MULTIROOT.md](MULTIROOT.md). That page covers **layout** (multi-root vs monorepo), VS Code mechanics, and indexing at a high level. This page covers **day-to-day Cursor operations**: opening workspaces, **what happens when paths change**, **where agent plans live**, and **how to keep a durable record** of chats (Cursor-native patterns plus open-source and adjacent tools).

**Disclaimer:** Cursor behavior changes across versions. Prefer **official** Cursor docs, changelog, and blog posts; treat **forum threads** and third-party tools as corroboration—validate on your build before relying on them.

---

## 1. Single-folder window vs multi-root workspace

- **Single folder** — You open one directory; VS Code/Cursor treat it as one workspace root. Simplest mental model for agents and search.
- **Multi-root** — A `*.code-workspace` file lists multiple roots in one window. Mechanics follow VS Code; see [VS Code: Multi-root Workspaces](https://code.visualstudio.com/docs/editor/multi-root-workspaces) and [MULTIROOT.md §1–3](MULTIROOT.md).

**Cursor-specific:** The product changelog describes **multi-root workspaces** in the **Agents** flow so one session can span more than one folder (e.g. frontend + backend) without re-adding folders each turn: [Cursor changelog: Multitask, Worktrees, and Multi-root Workspaces (2024-04-26)](https://cursor.com/changelog/04-24-26).

**Friction to validate locally:** Community threads report uneven behavior (e.g. chat context favoring the first folder, repeated re-indexing when adding roots). Treat those as **signals to test**, not guarantees—see [MULTIROOT.md §2](MULTIROOT.md) for links.

**Opening a workspace file:** Cursor 3 may send `.code-workspace` opens to the Agents Window. This repo wraps `cursor` so it injects `--classic` (classic IDE). See [cursor-classic-ide.md](cursor-classic-ide.md). Prefer `cursor path/to/file.code-workspace` over `open -a Cursor …`.

---

## 2. Renaming or moving a project directory

### What users observe

Several forum threads describe **chat history missing or inaccessible** after **renaming** or **moving** the project folder, or wanting a **safe migration** path:

- [How can you safely rename a project root folder without losing chat history?](https://forum.cursor.com/t/how-can-you-safely-rename-a-project-root-folder-without-losing-chat-history/131495)
- [Change project folder name without losing chats](https://forum.cursor.com/t/change-project-folder-name-without-losing-chats/18387)
- [Chat history inaccessible after renaming or moving a Cursor project directory](https://forum.cursor.com/t/chat-history-inaccessible-after-renaming-or-moving-a-cursor-project-directory/76686)
- [Preserve / migrate agent chat history when renaming or moving the project folder](https://forum.cursor.com/t/preserve-migrate-agent-chat-history-when-renaming-or-moving-the-project-folder/157185) (feature request)

### Practical guidance (conservative)

1. **Prefer stable paths** for long-running work—especially if you care about **in-app** chat continuity.
2. **Before** a rename or move, **export or back up** chats using a tool you trust (see §5) so you retain a Markdown or JSON artifact even if the IDE associates a new workspace identity with the new path.
3. **After** a move, open the project from its **final** path and re-verify rules, indexing, and `.cursorignore`—see [Cursor: Ignore file](https://cursor.com/docs/reference/ignore-file) and [MULTIROOT.md §7](MULTIROOT.md).

### Community-maintained migration helpers (use at your own risk)

These are **not** official Cursor products. Read each README, take backups, and avoid hand-editing SQLite unless you know what you are doing:

- **cursor-helper** (Rust CLI)—described in community discussions as assisting **rename** / **copy** workflows while preserving history; see the project README on GitHub: [lucifer1004/cursor-helper](https://github.com/lucifer1004/cursor-helper).
- **cursor-chat-recovery-kit**—migration / export utilities referenced in community threads; see [vitalyis/cursor-chat-recovery-kit](https://github.com/vitalyis/cursor-chat-recovery-kit).

Official **native** “migrate workspace id on rename” behavior may still be incomplete; track the feature request above for product updates.

---

## 3. Plans: workspace vs “everything feels global”

### What Cursor documents

Cursor’s [Best practices for coding with agents](https://www.cursor.com/blog/agent-best-practices) describes **Plan Mode** (research, clarifying questions, implementation plan, approval before coding). Plans open as **Markdown** you can edit.

**Important for repo hygiene:** The same post recommends clicking **“Save to workspace”** so plans are stored under **`.cursor/plans/`**—team-visible documentation, easier resume, and context for future agents on the same feature.

Intro to Plan Mode as a product feature: [Introducing Plan Mode](https://www.cursor.com/blog/plan-mode) (Cursor blog).

### Why plans feel “global” or mixed

- **Unsaved plans** live as editor tabs / ephemeral UI state—they are easy to lose track of and do not automatically organize per repo.
- **Saved plans** land in **`.cursor/plans/`** when you use **“Save to workspace”** (per the [agent best-practices](https://www.cursor.com/blog/agent-best-practices) post).
- **Forum-reported default location:** threads state that plans may live under the **user** directory (e.g. `~/.cursor/plans` on macOS/Linux) until moved—**“Save to workspace”** is described as the way to tie a plan to the project tree. See [Plan files location](https://forum.cursor.com/t/plan-files-location/156476/6) and [What happens when plan file is saved](https://forum.cursor.com/t/what-happens-when-plan-file-is-saved/135261). Treat this as **community-sourced behavior** that can change between releases; validate on your machine.
- Opening **many different folders** in succession can make the **Plan** or agent UI feel like one pile of work unless you **namespace** saved files and commit them to the right repo.

### Mitigations that work well in practice

| Practice | Rationale |
| --- | --- |
| **Always save** substantial plans to **`.cursor/plans/`** and commit | Survives reinstall; teammates and future agents see the same intent |
| **Filename convention** e.g. `YYYYMMDD-short-slug.md` | Sortable, grep-friendly |
| **One primary window per feature slice** | Reduces cross-talk between unrelated plans |
| **Dotfiles / personal notes** outside the repo | If you keep personal plans, store them in a dedicated notes repo or `~/docs/`—do not confuse with committed `.cursor/plans/` |

For static always-on instructions (different from ephemeral plans), Cursor documents **Rules** under `.cursor/rules/`. See [Rules | Cursor Docs](https://cursor.com/docs/context/rules) (use in-app **Docs** if the URL moves).

**Plan agents and cost-aware Build:** Official docs cover Plan Mode and pricing pools, not the plan editor **Agents** panel, per-todo assignment, or mixed-model execution. See [cursor-plans-agents-guide.md](cursor-plans-agents-guide.md) for referenced agents, Auto vs pinned models, estimation, and usage reconciliation; [blog/cursor-plans-hands-on.md](blog/cursor-plans-hands-on.md) for a hands-on walkthrough.

---

## 4. Long-term chat history (Cursor-native)

From [Best practices for coding with agents](https://www.cursor.com/blog/agent-best-practices):

- Start a **new** conversation when the task or feature changes; **continue** when iterating on the same unit of work.
- Long threads accumulate noise; the agent’s effectiveness can drop after many turns.
- Use **`@Past Chats`** so a **new** thread can **selectively** pull context from prior conversations instead of pasting entire transcripts.

That pattern reduces reliance on a single infinitely long thread while staying inside Cursor’s supported context model.

---

## 5. Archival and export tools (landscape)

### Where Cursor stores chats (for tooling authors)

Community tools agree that workspace-scoped history lives in **SQLite** (`state.vscdb`) under Cursor/VS Code application storage layouts; see for example [somogyijanos/cursor-chat-export](https://github.com/somogyijanos/cursor-chat-export) README (“one `state.vscdb` per workspace”). A forum walkthrough is linked from that README: [Guide: exporting chats from Cursor](https://forum.cursor.com/t/guide-5-steps-exporting-chats-prompts-from-cursor/2825).

### Comparison matrix (high level)

| Project | Role | License / source | Typical inputs | Outputs / notes |
| --- | --- | --- | --- | --- |
| [SpecStory](https://github.com/specstoryai/getspecstory) (`getspecstory`) | Extension + CLI; local-first history dir; optional cloud | **Extension:** closed product in marketplace; **CLI:** open components per their README table | Cursor IDE, Copilot IDE, several CLIs via `specstory run` | `.specstory/history/` locally; optional [SpecStory Cloud](https://cloud.specstory.com) with explicit login |
| [cursor-history](https://github.com/S2thend/cursor-history) | POSIX-style CLI: list, search, export, backup | **MIT** (per repo badge/README) | Cursor `state.vscdb` / workspace DBs | Markdown export, JSON pipes for `jq` |
| [cursor-chat-export](https://github.com/somogyijanos/cursor-chat-export) | Python CLI discover/export | See repo `LICENSE` | Configured workspace path → `state.vscdb` | Markdown / stdout; discover across workspaces |
| [cursor-chat-transfer](https://github.com/ibrahim317/cursor-chat-transfer) | Transfer between workspaces / devices | See repo | Cursor workspace chat JSON | `.cursor-chat.json` interchange |
| [anyspecs-cli](https://github.com/anyspecs/anyspecs-cli) | Multi-assistant export | See repo | Cursor, Claude Code, Codex CLI, etc. | Markdown, HTML, JSON (per project marketing/README) |
| [vscode-chat-export](https://github.com/ChrisMayfield/vscode-chat-export) | Read VS Code JSONL chat storage → Markdown | See repo | VS Code Copilot chat logs on disk | Useful **pattern** for “DB/JSONL → commit-friendly Markdown” |
| [copilot-chat-to-markdown](https://github.com/peckjon/copilot-chat-to-markdown) | Convert exported Copilot JSON | See repo | Exported Copilot chat JSON | Markdown with TOC |

**Not a drop-in exporter—analytics:** [tribecode](https://tribecode.ai/docs) positions itself as **AI learning analytics** (usage patterns, dashboard, privacy-scrubbed telemetry). As of the documentation captured for this note, **Cursor** appears in the **Supported Platforms** table as **“Coming Soon”** on all listed OS rows—verify the live [tribecode Documentation](https://tribecode.ai/docs) before planning an integration. Claude Code, Codex, and Gemini show **Beta** tiers there instead.

### How to choose

- **Want continuous capture into the repo** → SpecStory-style workflow (local folder + optional cloud) or disciplined manual export.
- **Want ad hoc search and backup from the shell** → `cursor-history` or `cursor-chat-export`.
- **Need multi-tool normalization** → `anyspecs-cli` if its supported tools match yours.

Always confirm **license**, **data paths**, and **privacy** (what leaves the machine) in each project’s README before adopting.

---

## 6. Sources

Official and primary references:

- [Cursor: Best practices for coding with agents](https://www.cursor.com/blog/agent-best-practices) (Plan Mode, `.cursor/plans/`, `@Past Chats`, rules, skills)
- [Cursor: Introducing Plan Mode](https://www.cursor.com/blog/plan-mode)
- [Cursor changelog: Multitask, Worktrees, and Multi-root Workspaces (2024-04-26)](https://cursor.com/changelog/04-24-26)
- [Cursor: Ignore file](https://cursor.com/docs/reference/ignore-file)
- [VS Code: Multi-root Workspaces](https://code.visualstudio.com/docs/editor/multi-root-workspaces)

Forum and migration context:

- [forum.cursor.com: safely rename project root without losing chat history](https://forum.cursor.com/t/how-can-you-safely-rename-a-project-root-folder-without-losing-chat-history/131495)
- [forum.cursor.com: change folder without losing chats](https://forum.cursor.com/t/change-project-folder-name-without-losing-chats/18387)
- [forum.cursor.com: chat inaccessible after rename/move](https://forum.cursor.com/t/chat-history-inaccessible-after-renaming-or-moving-a-cursor-project-directory/76686)
- [forum.cursor.com: preserve/migrate history on rename](https://forum.cursor.com/t/preserve-migrate-agent-chat-history-when-renaming-or-moving-the-project-folder/157185)
- [forum.cursor.com: plan files location (~/.cursor/plans vs workspace)](https://forum.cursor.com/t/plan-files-location/156476/6)
- [forum.cursor.com: what happens when plan file is saved](https://forum.cursor.com/t/what-happens-when-plan-file-is-saved/135261)
- [forum.cursor.com: plan mode save to workspace workaround](https://forum.cursor.com/t/plan-mode-save-to-workspace-workaround/136968)
- [forum.cursor.com: multi-root support in Agents window](https://forum.cursor.com/t/multi-root-support-in-agents-window/158957)
- [forum.cursor.com: guide exporting chats](https://forum.cursor.com/t/guide-5-steps-exporting-chats-prompts-from-cursor/2825)
- [forum.cursor.com: chat history folder](https://forum.cursor.com/t/chat-history-folder/7653)

Tools and adjacent products:

- [github.com/specstoryai/getspecstory](https://github.com/specstoryai/getspecstory)
- [github.com/S2thend/cursor-history](https://github.com/S2thend/cursor-history)
- [github.com/somogyijanos/cursor-chat-export](https://github.com/somogyijanos/cursor-chat-export)
- [github.com/ibrahim317/cursor-chat-transfer](https://github.com/ibrahim317/cursor-chat-transfer)
- [github.com/anyspecs/anyspecs-cli](https://github.com/anyspecs/anyspecs-cli)
- [github.com/lucifer1004/cursor-helper](https://github.com/lucifer1004/cursor-helper)
- [github.com/vitalyis/cursor-chat-recovery-kit](https://github.com/vitalyis/cursor-chat-recovery-kit)
- [github.com/ChrisMayfield/vscode-chat-export](https://github.com/ChrisMayfield/vscode-chat-export)
- [github.com/peckjon/copilot-chat-to-markdown](https://github.com/peckjon/copilot-chat-to-markdown)
- [tribecode.ai/docs](https://tribecode.ai/docs)

**Research capture (parallel-cli):** raw search JSON for follow-up questions is saved at [cursor-workspace-lifecycle-parallel-search.json](cursor-workspace-lifecycle-parallel-search.json) in this directory.

**Related in this repo:** [MULTIROOT.md](MULTIROOT.md) · [IGNORING.md](IGNORING.md) · [cursor-cloud-agents-vs-local.md](cursor-cloud-agents-vs-local.md) (Cloud Agents vs local; why one chat cannot take over another window) · [COMPENDIUM.md](COMPENDIUM.md) · [CURRENT_STATE.md](../CURRENT_STATE.md)
