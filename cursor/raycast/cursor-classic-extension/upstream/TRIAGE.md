# Upstream triage — Store Cursor / cursor-recent-projects

Snapshot from `just fetch-cursor-github` on **2026-09-20**.
Raw JSON (gitignored): `upstream/raw/index.json`.
Searches: `just open-cursor-github`.

Two Store slugs are the same lineage: `cursor-recent-projects` (degouville) and
`cursor` (later commands such as Show Active Workspaces). GitHub's label picker
ANDs labels; use OR. `gh search issues` mishandles `label:"extension: cursor"`
— `fetch.sh` uses `gh api search/issues`.

## Verdict

Keep **Cursor Classic local**. Do not open a Store PR this pass.

- `--classic` is a Cursor 3 Agents Window workaround. Store users may want glass.
- Nobody asked for a **Folders + Workspaces** filter. Closest request ([#19738](https://github.com/raycast/extensions/issues/19738), named workspace picker) was stalled and closed `not_planned`.
- The live Store bug ([#26389](https://github.com/raycast/extensions/issues/26389)) is “open project B while A is focused does nothing.” Our wrapper already opens via CLI; we did not reproduce that as a Store PR.

## Search counts (this fetch)

| Query | Total | Fetched |
| --- | ---: | ---: |
| labeled issues (cursor OR cursor-recent-projects) | 6 | 6 |
| labeled PRs | 0* | 0 |
| keyword issues open (`cursor`) | 12 | 12 |
| keyword PRs open | 16 | 16 |
| keyword issues closed since 2025-01-01 | 28 | 28 |
| keyword PRs closed since 2025-01-01 | 432 | 200 (cap) |
| unique items + timelines | | 256 |

\* Label search missed merged PRs [#26260](https://github.com/raycast/extensions/pull/26260) and [#27958](https://github.com/raycast/extensions/pull/27958); keyword search found them. Both carry the product labels.

Keyword hits are mostly other extensions (VS Code, Color Picker, new-extension PRs). Precision set is the eight product items below.

## Product issues

### Open

**[#26389](https://github.com/raycast/extensions/issues/26389)** — bug — opened 2026-03-17, 1 comment, still open.
Search Recent Projects / Open in Cursor: with project A focused, choosing project B does not open B (no new window). Raycast 1.104.3. Labels: `bug`, `extension: cursor-recent-projects`.
Local: we open through `cursor-classic-wrapper.sh --classic <path>`, which is a different mechanism than Store `open(path, "Cursor")`. Not filing a Store fix unless we reproduce on the Store copy.

**[#23860](https://github.com/raycast/extensions/issues/23860)** — feature — opened 2025-12-21, still open.
Windows support. Out of scope for this Mac fork.

### Closed, ignored / stalled (`not_planned`)

**[#20714](https://github.com/raycast/extensions/issues/20714)** — bug — opened 2025-07-31, stalled 2025-09-19, closed 2025-09-29 by raycastbot (`not_planned`).
“Could not find extension's manifest file.” Reinstall-class. Similar class of failure to our Raycast v2 “Missing executable” stub; Store fix is reinstall, local fix is `just develop-raycast-classic`.

**[#19738](https://github.com/raycast/extensions/issues/19738)** — feature — opened 2025-06-11, stalled 2025-07-31, closed 2025-08-10 (`not_planned`).
Asked for a separate **Open Workspace…** command listing named `.code-workspace` files. Not the Folders + Workspaces dropdown combo. Bot-closed; no author engagement. Do not revive as a Store PR unless we want a named-workspace picker (we do not).

**[#18232](https://github.com/raycast/extensions/issues/18232)** — bug — opened 2025-03-29 by degouville, stalled, closed 2025-08-02 (`not_planned`).
Store listing title/meta stale vs package.json. Store-page only.

### Closed, completed

**[#17045](https://github.com/raycast/extensions/issues/17045)** — feature — opened and closed 2025-02-14 (`completed`).
Show git branch on recent projects (VS Code extension parity). Already in this fork (`showGitBranch`).

## Product PRs (from keyword + labels)

No open PRs on this lineage.

**[#26260](https://github.com/raycast/extensions/pull/26260)** — merged 2026-06-15.
Show Active Workspaces: AppleScript list + `AXRaise` to focus an existing window. In this fork as `src/active-workspaces.tsx`. Focusing is not an open; `--classic` does not apply.

**[#27958](https://github.com/raycast/extensions/pull/27958)** — merged 2026-05-16.
Cursor icon asset + uninstall shortcut. Already in this tree (`CHANGELOG` 2026-05-16).

Older Store history (before this fetch window): [#14439](https://github.com/raycast/extensions/pull/14439) (2024-09, add recent-projects commands), [#14228](https://github.com/raycast/extensions/pull/14228) (2024-08, cursor extension update).

## Keyword recall (not this product)

Open `cursor` issues that are **not** the Store Cursor extension: GitHub clone-into-Cursor ([#24909](https://github.com/raycast/extensions/issues/24909)), Cursor Costs ([#29406](https://github.com/raycast/extensions/issues/29406)), VS Code recent-projects PATH ([#16806](https://github.com/raycast/extensions/issues/16806)), plus Color Picker / ScreenOCR / Bear noise.

Sibling Store labels (`cursor-directory`, `cursor-agents`, `cursor-costs`, `open-in-cursor`, `cursors`, `where-is-my-cursor`) had no extra open issues in this dump. Subtract them in the “minus siblings” URL from `open-github-searches.sh`.

Open keyword PRs are new unrelated extensions (ide-recents, skills-manager, …). Ignore.

## What we implemented vs upstream

| Local change | Upstream overlap | PR? |
| --- | --- | --- |
| `--classic` wrapper on Search / Open with / New Window | none | no |
| Default filter **Folders + Workspaces** | none; [#19738](https://github.com/raycast/extensions/issues/19738) was a different workspace picker and died stalled | no (keep local) |
| Show Active Workspaces | [#26260](https://github.com/raycast/extensions/pull/26260) already merged | already upstream |
| Git branch accessory | [#17045](https://github.com/raycast/extensions/issues/17045) completed | already upstream |
| Raycast v2 rebuild (`ray develop`) | [#20714](https://github.com/raycast/extensions/issues/20714) is the Store analog | no |

## Refresh

```bash
cd ~/dotfiles/cursor
just fetch-cursor-github
just open-cursor-github
```
