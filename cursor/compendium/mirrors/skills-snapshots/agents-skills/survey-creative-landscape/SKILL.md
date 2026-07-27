---
name: survey-creative-landscape
description: "Maps adjacent domains, analogies, and hard constraints before ideation volume. Optionally directs a cited parallel-cli search batch when the open web is in scope. Use when the problem is novel, cross-industry, or competitive; feeds divergent-explore. Pair with clarify-audience-purpose outputs; defer to unpack-the-question if the framing still mixes facts and wishes."
disable-model-invocation: true
---

# Survey creative landscape

Collect **inputs** to divergence, not solutions.

## When to Use

- The team keeps arguing solutions without a shared map of constraints.
- Competitors, substitutes, or regulatory context matter.
- Analogies are invoked without explicit mapping (“we are the Uber of …”).

## Workflow

1. **Constraint inventory** — time, budget, tech, policy, brand, team skills. Tag each as hard or soft.
2. **Adjacency map** — list domains that solved structurally similar problems (with the mapping: similar **what**, not similar buzzwords).
3. **Analogies** — at most three; for each, write “borrow” vs “reject” with one sentence.
4. **Optional web sweep** — if needed, run `parallel-cli search` with a dated `-o` JSON file under `docs/research/parallel-search/`, `--json --max-results 10`, and cite **only** URLs from that JSON in notes to the user. Update the directory README when adding a new batch file.
5. **Handoff list** — bullet “ideas to stress-test” without ranking yet; send to [divergent-explore](../divergent-explore/SKILL.md).

## Principles

- **No orphan analogies** — if you cannot map the analogy to a mechanism, drop it.
- Prefer **primary** sources (docs, standards) over hot takes when legality or safety matters.
- Quantity of tabs is not depth; structure beats bookmark sprawl.

## Suite chain

Typically **third**; can be skipped for in-repo well-known problems. Order in [SUITE-MAP.md](../references/SUITE-MAP.md).

## Downstream

Feeds [divergent-explore](../divergent-explore/SKILL.md); risky visions go through [envision-end-state](../envision-end-state/SKILL.md) before [converge-articulate](../converge-articulate/SKILL.md).
