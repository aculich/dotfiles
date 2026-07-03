# Examples — DeepListening method synthesis (L2)

## Canonical worked example — 2026-04-24 first L2 pass

This skill was derived from the 2026-04-24 first synthesis pass, which ran on a single L1 bundle (the Matt + Aaron session). A single-bundle pass is not the healthy case, but because it was the first, it bootstrapped the L2 body.

### Inputs consumed

| Role | Path |
|---|---|
| L1 bundle | [`nlp-ems-paramedic/docs/deep-listening/`](/Users/me/projects/nlp-ems-paramedic/docs/deep-listening/) |
| Existing methodology (none yet) | — (bootstrap pass) |
| Canonical methodology (read-only) | [`peeq-crb-nexus/meta-methods/METHODS-MAP.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/METHODS-MAP.md) · [`peeq-crb-nexus/meta-methods/OVERVIEW.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/OVERVIEW.md) · [`peeq-crb-nexus/meta-methods/intent-context-engineering/TERMINOLOGY.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/intent-context-engineering/TERMINOLOGY.md) |

### Prior-art JSONs fetched

Five bundles under [`nlp-ems-paramedic/research/deep-listening/`](/Users/me/projects/nlp-ems-paramedic/research/deep-listening/):

| File | Focus |
|---|---|
| `facilitation-priorart.json` | PALEO, Kline, Scharmer, Clean Language, Socratic |
| `ambient-ai-meeting.json` | Granola / Otter / Circleback / Fireflies |
| `ie-elicitation-llm.json` | IE × elicitation × LLM-assisted qualitative analysis |
| `llm-as-interviewer.json` | MIBot, MIcha, CALM-IT, KELE |
| `listening-epistemology.json` | Kline, Scharmer, Ihde |

### Outputs produced

All under [`peeq-crb-nexus/meta-methods/deep-listening/`](/Users/me/projects/peeq-crb-nexus/meta-methods/deep-listening/):

| File | Size-ish |
|---|---|
| [`ROLE-SOUNDBOARD-FACILITATOR.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/deep-listening/ROLE-SOUNDBOARD-FACILITATOR.md) | 274 lines |
| [`AMBIENT-AI-COUPLING.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/deep-listening/AMBIENT-AI-COUPLING.md) | 210 lines |
| [`TERMINOLOGY-DEEPLISTENING.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/deep-listening/TERMINOLOGY-DEEPLISTENING.md) | 266 lines |
| [`METHODS-MAP-EXTENSIONS.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/deep-listening/METHODS-MAP-EXTENSIONS.md) | 211 lines |
| [`ONTOLOGY-EPISTEMOLOGY-DEEPLISTENING.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/deep-listening/ONTOLOGY-EPISTEMOLOGY-DEEPLISTENING.md) | 251 lines |

### What to notice when reading the worked example

1. **Every new named move ("deictic-surface", "recap-instead-of-ask", "landscape-spot", "question-unpack", "live-prompt to ambient AI", etc.) cites at least one prior-art anchor.** No invented vocabulary without grounding.
2. **The three-strata evidence model (G1/G2/G3) is the load-bearing abstraction.** It appears in METHODS-MAP-EXTENSIONS §1, AMBIENT-AI-COUPLING §1, TERMINOLOGY §1.8.
3. **METHODS-MAP-EXTENSIONS §9 "What this extension does NOT propose".** Match this pattern — every extension file should have a section naming non-claims, to keep the proposal honest and reviewable.
4. **No canonical file was edited.** Verify by `git log peeq-crb-nexus/meta-methods/METHODS-MAP.md` — the commit history contains no L2 synthesis entries.
5. **The mermaid diagram in METHODS-MAP-EXTENSIONS §2 is a *proposed* replacement** for the canonical one in `OVERVIEW.md`. Not a replacement edit — a proposal.

## Typical subsequent invocation

After 3+ L1 bundles accumulate:

> "Run L2 on the three latest Matt sessions under `docs/deep-listening/`. Extend the existing methodology under `peeq-crb-nexus/meta-methods/deep-listening/`. Skip a new prior-art scan — use the existing JSONs."

The skill will:
1. Read the three L1 bundles.
2. Read the current methodology (all five files).
3. Cross-check: which patterns appear in 2+ bundles? Those are **confirmed** → promote to methodology.
4. Which patterns appear in only 1? **Candidates** → journal entry only.
5. Extend the existing methodology non-destructively.
6. Write lineage + journal.

## Invocation for a methodology-only update (no new L1)

> "I noticed our METHODS-MAP-EXTENSIONS doesn't mention the new [xyz] pattern from the [day] session. Add it — it's already in the L1 artifact."

The skill will:
1. Read the relevant L1 bundle.
2. Open `METHODS-MAP-EXTENSIONS.md`.
3. Draft the extension section.
4. Append (never edit an existing section destructively).
5. Update lineage.

## What the example does NOT show

- **Multi-bundle confirmation workflow.** 2026-04-24 ran on a single bundle. The aggregation rules in [`reference.md`](reference.md) §4 were designed but not yet exercised. Flag edge cases in journal when first invoked with multiple bundles.
- **Reconciliation of terminology drift.** None surfaced in the 2026-04-24 pass because everything was authored in a single coherent session. Expected to arise when the next L2 pass runs months later with new vocabulary from a new session.
- **Merging extensions into canonical.** Out of scope for this skill entirely — that is a deliberate human step outside any skill invocation.
