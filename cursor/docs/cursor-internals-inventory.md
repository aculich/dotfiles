# Cursor internals inventory (bottom-up)

**Version pin:** [cursor-internals-VERSION.md](cursor-internals-VERSION.md).  
**Top-down:** [cursor-architecture.md](cursor-architecture.md) · **Paths:** [cursor-storage-map.md](cursor-storage-map.md)

Component list aligned with Settings UI categories (screenshots in `assets/settings-*.png`).

## Agents / Conversation

| Component | Role | Config / docs |
|-----------|------|----------------|
| Text size | Chat UI density | Settings → Agents → Conversation |
| Submit with ⌘Enter | Submit vs newline | Settings |
| Max Tab Count | Cap open agent tabs | Settings (yours: custom 6) |
| Default Model | New agent default | Settings / Models |
| Queue Messages | Behavior while agent running | [Agent overview](https://cursor.com/docs/agent/overview) |
| Code Block Word Wrap | Chat code blocks | Settings |
| Usage Summary | Show usage footer | Settings |
| Agent Autocomplete | Prompt suggestions | Settings |
| Auto-Approve Mode Transitions | Agent↔Plan↔Debug without prompt | Settings |
| Voice Submit Keywords | Voice prompt submit words | Settings |

## Agent Review

| Component | Role |
|-----------|------|
| Start Agent Review on Commit | Post-commit review |
| Include Submodules / Untracked | Review scope |
| Default Approach | Quick vs thorough |

## Composer / Context & Tools / Execution

| Component | Role | Docs |
|-----------|------|------|
| Web Search / Web Fetch | Agent tools | [Tools](https://cursor.com/docs/agent/tools) |
| Auto-Accept Web Search | Tied to Run Mode | [Run modes](https://cursor.com/docs/agent/security/run-modes) |
| Run Mode | Sandbox / approvals | Run modes |
| MCP Tools Protection | Gate MCP auto-run | Settings + [MCP](https://cursor.com/docs/mcp) |
| Inline Diffs / Jump Next / Auto Format | Apply UX | Settings |
| Legacy Terminal Tool | Fallback shell tool | Settings |
| Toolbar on Selection / Auto-Parse Links | Editor UX | Settings |
| Themed Diff Backgrounds / Terminal Hint / Preview Box | Terminal ⌘K | Settings |

## Models & API Keys

| Component | Role |
|-----------|------|
| Cursor Default / Ultra pools | Hosted models |
| BYOK OpenAI / Anthropic / Google / Azure / Bedrock | At-cost keys |

## Git & PRs

| Component | Role |
|-----------|------|
| Review Provider | GitHub vs Graphite |
| PR Link Destination | Inside Cursor vs browser |
| Commit / PR Attribution | “Made with Cursor” |
| Branch Prefix | Agent branches (e.g. `cursor/`) |

## Plugins / Customize

| Component | Role | Docs |
|-----------|------|------|
| Plugins | Skills, Rules, Agents, Hooks, MCPs bundles | [Customize](https://cursor.com/docs/customize-cursor) / [Plugins](https://cursor.com/docs/plugins) |
| Rules | Always / globs / manual `.mdc` | [Rules](https://cursor.com/docs/rules) |
| Skills | Dynamic `SKILL.md` | [Skills](https://cursor.com/docs/skills) |
| Subagents | Delegated Task agents | [Subagents](https://cursor.com/docs/subagents) |
| Commands | `/` workflows | Customize |
| Hooks | Lifecycle scripts | [Hooks](https://cursor.com/docs/hooks) |
| MCP | External tools | [MCP](https://cursor.com/docs/mcp) |

## Browser & Network

| Component | Role |
|-----------|------|
| Browser Automation | Browser Tab vs other |
| Browser Protection | Gate browser tools |
| Show Localhost Links | Auto-open in Browser Tab |
| HTTP Compatibility Mode | HTTP/2 vs compat |
| Required Domains / Diagnostics | Connectivity |

## Tab Completion

| Component | Role |
|-----------|------|
| Cursor Tab | Multi-line completions |
| Partial Accepts / Comments / Whitespace / Imports | Tab behavior |

## Indexing & Docs

| Component | Role |
|-----------|------|
| `.cursorignore` | Index excludes |
| Instant Grep index | Local repo index |
| Hierarchical / symlink ignore | Ignore discovery |
| Docs | Crawled doc sources |

## Plans & Canvases (product surfaces)

| Component | Role | Detail |
|-----------|------|--------|
| Plan Mode | Spec before code | [Plan Mode](https://cursor.com/docs/agent/plan-mode) · [cursor-home-and-plans.md](cursor-home-and-plans.md) |
| Canvases | Interactive React artifacts | [Canvases](https://cursor.com/docs/agent/tools/canvas) · [cursor-canvases.md](cursor-canvases.md) |
| Agents Window | Multi-agent orchestration UI | [Agents Window](https://cursor.com/docs/agent/agents-window) |

## Beta

| Component | Role |
|-----------|------|
| Update Access | Stable / Early Access / Nightly |
