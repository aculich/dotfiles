# Decisions

Newest first.

## 2026-07-23 — Full `.context/` + status canvas for Cursor ops

- **Decision:** Scaffold the full 11-file context-engineering set (including `outcomes.md` and `monitor.md`) and an interactive Cursor canvas at the IDE-managed canvases path.
- **Rationale:** No prior `.context/`; ops health was scattered across README, CURRENT_STATE, `just status`, and `observability/`. Agents need a durable map of purpose, resources, and checks.

## 2026-07-23 — Agents Window hygiene is inventory + manual Archive All

- **Decision:** Use `scripts/cursor-agents-inventory.sh` for evidence; cleanup remains **Archive All** in the Agents Window UI (no automated archive).
- **Rationale:** Product constraint; documented in `docs/agents-window-hygiene.md` and parent `AGENTS.md`.

## Ongoing — Skills authoring SoT is `~/projects/agent-skills`

- **Decision:** Do not treat `cursor/` or `compendium/mirrors/` as the place to author skills; mirrors are backup/index.
- **Rationale:** Parent `AGENTS.md` and `docs/SKILLS-MANAGEMENT.md`.

## 2025-01 — Settings/keybindings live → dotfiles; ApplicationSupport reverse

- **Decision:** Symlink live User `settings.json` / `keybindings.json` into this repo; keep `ApplicationSupport` as a convenience symlink **from** this repo **to** the live User directory.
- **Rationale:** Version control editable config; do not pretend the entire User runtime tree is portable. See `SYMLINK_STRATEGY.md` / `CURRENT_STATE.md`.
