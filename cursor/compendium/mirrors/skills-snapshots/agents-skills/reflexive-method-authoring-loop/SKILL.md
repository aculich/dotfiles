---
name: reflexive-method-authoring-loop
description: Orchestrator for the four-level method-authoring loop (L0 practice → L1 session analysis → L2 method synthesis → L3 reflexive authoring). Identifies the current level, names the loop when it's implicit, bootstraps `.metacontext/` in a new project, invokes the L1 and L2 skills as subroutines, and closes the loop with lineage + journal entries. Can also run in journal-only mode when the user surfaces a reflexive moment in conversation without doing new L1/L2 work. Self-referential — this skill was authored by running itself. Use when the user says "is this meta or meta-meta?", "let's make this repeatable", "name the loop", "bootstrap metacontext", "close the loop", "what did the method learn about itself?", "run the whole thing end to end", or any phrasing that surfaces the authoring-about-authoring layer.
metadata:
  source:
    upstream: https://github.com/aculich/agent-skills
    canonical: https://github.com/aculich/agent-skills
---

# Reflexive method-authoring loop (L3)

Operationalizes **L3** of the four-level loop defined in [`peeq-crb-nexus/meta-methods/method-authoring/REFLEXIVE-METHOD-AUTHORING.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/method-authoring/REFLEXIVE-METHOD-AUTHORING.md). This skill is **the orchestrator** — it doesn't replace the L1 or L2 skills, it coordinates them and captures what the method is learning about itself.

## Self-referential clause

This skill was produced by running the loop it describes. The first recorded invocation was the 2026-04-24 nlp-ems-paramedic case, captured in [`/Users/me/projects/nlp-ems-paramedic/.metacontext/journal/2026-04-24-reflexive-method-authoring.md`](/Users/me/projects/nlp-ems-paramedic/.metacontext/journal/2026-04-24-reflexive-method-authoring.md). Using this skill means invoking a loop that has already been applied to itself.

## Modes

The skill has four modes. Pick the least-invasive mode that fits.

| Mode | When to use |
|---|---|
| **`journal-only`** | User surfaced a reflexive moment in conversation (*"is this meta or meta-meta?"*, *"let's make this repeatable"*) but no new L0/L1/L2 work needs to happen. Writes a journal entry only. |
| **`bootstrap`** | A project has produced L1 artifacts for the first time and has no `.metacontext/` shelf yet. Creates the shelf, writes initial process / conventions / skill-bindings, backfills first lineage + journal entry. |
| **`l1-pass`** | A new session has evidence ready; invoke the L1 skill + write lineage + optional journal. |
| **`full`** | A new session AND enough accumulated L1 bundles to extend methodology. Invokes L1, then L2, then closes the loop. |

## Inputs (by mode)

### `journal-only`

- **`trigger`** — what the user said / what prompted the reflexive moment.
- **`metacontext_dir`** — default `.metacontext/` in current project.
- **`levels_touched`** — which of L0/L1/L2/L3 were active in the conversation.

### `bootstrap`

- **`project_root`** — consumer project path.
- **`l1_outputs_dir`** — where L1 bundles live (usually `docs/deep-listening/`).
- **`l2_methodology_dir`** — absolute path to portable methodology (usually `/Users/me/projects/peeq-crb-nexus/meta-methods/deep-listening/`).
- **`prior_art_root`** — usually `research/deep-listening/`.

### `l1-pass`

- All inputs required by [`deeplistening-session-analysis`](/Users/me/.cursor/skills/deeplistening-session-analysis/SKILL.md).
- `metacontext_dir`.

### `full`

- All inputs required by `l1-pass` and [`deeplistening-method-synthesis`](/Users/me/.cursor/skills/deeplistening-method-synthesis/SKILL.md).
- **`also_update_portable_methodology`** — gate for L2 step. Default `true` if ≥ 2 L1 bundles exist.

## The seven named moves

This skill operationalizes all seven moves from [`REFLEXIVE-METHOD-AUTHORING.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/method-authoring/REFLEXIVE-METHOD-AUTHORING.md) §4. Each can be invoked standalone or composed:

| Move | What the skill does |
|---|---|
| **`identify-level`** | Inspect the conversation / inputs. Name which of L0/L1/L2/L3 is active. Report, do not act, unless user asks for action. |
| **`name-the-loop`** | Explicitly surface the reflexive moment. Phrasing: *"what you're doing right now is an L3 move — let's name it"*. Often triggered by user, but the skill can also surface it proactively when it notices L1 or L2 work happening implicitly. |
| **`bootstrap-metacontext`** | If `.metacontext/` is absent, create it with the six-file + two-subdir schema (see [`reference.md`](reference.md) §1). |
| **`invoke-L1`** | Call the L1 skill as a subroutine. Pass through inputs. Receive back L1 outputs. |
| **`invoke-L2`** | Call the L2 skill as a subroutine. Pass through inputs. Receive back L2 updates. |
| **`close-the-loop`** | After L1 and/or L2 complete, write a journal entry: what did this pass teach the method about itself? (Mandatory for `full` mode; recommended for `l1-pass`.) |
| **`bind-to-deeplistening`** | Note in the journal entry that the L3 loop is also invokable **inside** a live DeepListening session as reflection-on-action — not just during post-processing. |

## Required rules

### Least-invasive mode by default

Do not invoke `full` when `journal-only` would do. The user says *"is this meta or meta-meta?"* → that is almost always `journal-only`. Writing 30 files to answer the question is the wrong response.

### Journal must be honest about what was NOT learned

If a pass produced no new method-learning (sometimes the case for routine L1 passes), say so in the journal entry explicitly. Blank journals are suspicious; say *"this pass surfaced no new method-learning"* with one sentence of rationale.

### Bootstrap is non-destructive

If `.metacontext/` already exists, do not overwrite. Read the existing shelf, extend if appropriate, skip if not.

### Skill composition order is fixed

`full` mode = `identify-level` → `name-the-loop` (if implicit) → `bootstrap-metacontext` (if needed) → `invoke-L1` → (gate) `invoke-L2` → `close-the-loop` → `bind-to-deeplistening` (in journal).

Do not invoke L2 before L1. Do not invoke the L2 skill with only a freshly-created L1 bundle (wait for multi-bundle confirmation per L2 skill's rules).

### Proposed updates to L3 itself

If a pass surfaces that **this skill itself** is insufficient — e.g., a new move should be added, or a rule should change — that goes in the journal under *"Proposed updates to L3 documents"*. Do not edit the L3 methodology in place from inside the skill. Flag it for the user.

### The four-level ceiling

L4 (method-of-method-authoring) is not a recurring practice. If the user asks for L4, explain the anti-pattern §7.6 *meta-vertigo* from [`REFLEXIVE-METHOD-AUTHORING.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/method-authoring/REFLEXIVE-METHOD-AUTHORING.md). Offer a journal-only pass instead.

## When to invoke

- **Always** when the user uses `name-the-loop` phrasing (*"is this meta or meta-meta?"*, *"let's make this repeatable"*).
- **Usually** after an L1 or L2 pass, in `journal-only` mode if nothing else, to close the loop.
- **Sometimes** at the end of a DeepListening session (`bind-to-deeplistening`), as reflection-on-action.
- **Rarely** as `full` — only when the user wants an end-to-end run and has both new evidence and an intent to update portable methodology.

## When NOT to invoke

- When the user is asking an object-level question about the project (*"what's the status of X?"*) — that's `.context/`, not `.metacontext/`.
- When the user just wants a session analyzed — invoke the L1 skill directly.
- When the user wants methodology updated and doesn't care about the reflexive layer — invoke the L2 skill directly.
- When a `.metacontext/` shelf in the current project has not yet been bootstrapped AND no new work is happening — ask the user if bootstrapping is wanted, do not bootstrap silently.

## Out of scope

- Running skills across multiple projects in one invocation. L3 is per-project. A cross-project L3 aggregator is not yet defined.
- Editing canonical `METHODS-MAP.md` or `TERMINOLOGY.md`. Never — L2 skill's non-destructive rule applies here too, even more strictly.
- Authoring other skills. The `skill-as-codification` move is named here, but actually authoring a new skill belongs to the [`create-skill`](/Users/me/.cursor/skills-cursor/create-skill/SKILL.md) flow, invoked separately.

## Dependencies

- [`~/.cursor/skills/deeplistening-session-analysis/`](/Users/me/.cursor/skills/deeplistening-session-analysis/SKILL.md) — invoked as L1 subroutine.
- [`~/.cursor/skills/deeplistening-method-synthesis/`](/Users/me/.cursor/skills/deeplistening-method-synthesis/SKILL.md) — invoked as L2 subroutine.
- [`peeq-crb-nexus/meta-methods/method-authoring/`](/Users/me/projects/peeq-crb-nexus/meta-methods/method-authoring/) — portable L3 methodology (read-only from this skill).

## Additional resources

- For `.metacontext/` shelf schema, journal templates, decision tree: [`reference.md`](reference.md).
- For the 2026-04-24 seed case (this skill's origin): [`examples.md`](examples.md).
