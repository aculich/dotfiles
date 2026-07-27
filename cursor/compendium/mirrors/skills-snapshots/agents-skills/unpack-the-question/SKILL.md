---
name: unpack-the-question
description: "Reframes underspecified prompts into decision-ready problem statements: separates facts from assumptions, names the decision type (learn, choose, optimize, align), and drafts falsifying observations. Use when the user pastes a vague goal or before planning. Invokes clarify-audience-purpose when stakeholders or success signals are unclear; otherwise leads into survey-creative-landscape or envision-end-state per task shape."
disable-model-invocation: true
---

# Unpack the question

Turn a **seed** (sentence, ticket, pain report) into a crisp problem statement others can execute against.

## When to Use

- The prompt mixes solution language (“use Kubernetes”) with missing outcome language.
- Multiple incompatible goals appear in one message.
- The user asks “what should I do?” without naming who decides “good.”
- Before loading heavy planning skills so their inputs are cleaner.

## Workflow

1. **Quote the seed** verbatim in the reply (one short block), then restate it in neutral language.
2. **Tag facts** the user or repo provided versus **assumptions** the model or human inferred. Mark each assumption with “assumption — confirm?”
3. **Classify the decision**: learning spike vs option pick vs optimization vs stakeholder alignment. If unclear, default to “learn” and propose the smallest experiment.
4. **Falsifiers**: list two concrete observations in the next timebox that would prove the current framing wrong.
5. **Route**: if audience or success is unknown, go to [clarify-audience-purpose](../clarify-audience-purpose/SKILL.md). If context is novel or competitive, go to [survey-creative-landscape](../survey-creative-landscape/SKILL.md). If the seed is already an option set, skip to [divergent-explore](../divergent-explore/SKILL.md) or [converge-articulate](../converge-articulate/SKILL.md).

## Principles

- Prefer **testable** statements over slogans; “world-class” is not a requirement.
- Do not treat a **symptom chain** (five-whys style) as a moral verdict; use it to widen hypotheses, not to shut down discussion.
- If external claims enter, cite URLs from a fresh search export—do not free-associate “industry truth.”

## Suite chain

Default position: **first** in the suite. Full order and escape hatches live in [SUITE-MAP.md](../references/SUITE-MAP.md).

## Downstream

After this skill, sibling skills complete the arc ending at [converge-articulate](../converge-articulate/SKILL.md), then external planners per [SKILL-LANDSCAPE-PLANNING-CANDIDATES.md](../../../../docs/research/SKILL-LANDSCAPE-PLANNING-CANDIDATES.md).
