# Northstar examples

## Example 1 — AeroSpace sync (tools-only)

**User:** Keep AeroSpace current and summarize what changed since last time.

### Phase 0

```markdown
## North star

**Purpose:** Stay current with upstream AeroSpace and understand the delta since last sync.
**Objective:** Fetch origin, fast-forward main when safe, summarize with git log / git-cliff.
**Desired outcomes:** On latest origin/main if ff-only; readable delta; no conflict skill unless needed.
**Grounding facts:** origin = nikitabobko/AeroSpace; branch main; no separate upstream remote; git-cliff installed.
**Non-goals:** Force-push; installing sync skills for a clean ff-only tree.
```

### Phase 1

Tools cover the purpose: `git fetch`, `git pull --ff-only`, `git log`, `git-cliff`.

Decision: **tools-only**.

### Phase 3 (abbreviated)

Fast-forwarded 192 commits `85f80bda` → `d56e1637`; cliff showed 0.21.0–0.21.3 Beta release notes; no conflicts.

See `research/northstar-tool-first/02-aerospace-prototype.md`.

## Example 2 — Non-git (changelog narrative)

**User:** Explain what shipped this month for stakeholders who do not read git.

### Phase 0

```markdown
## North star

**Purpose:** Communicate monthly product change to non-engineering stakeholders.
**Objective:** Produce a short narrative from release notes / commits.
**Desired outcomes:** One page of prose; accurate; no invented features.
**Grounding facts:** Repo has conventional commits / tags; git-cliff available.
**Non-goals:** Rewriting history; full engineering changelog dump.
```

### Phase 1

- Mechanical: `git-cliff` (or release notes) for structured facts.
- Gap: stakeholder tone / prioritization → thin skill or one-shot agent prose **augmenting** cliff output, not replacing it.

Decision: **tools + light augmentation** (not a wholesale “changelog skill” instead of cliff).
