---
name: deeplistening-method-synthesis
description: Synthesizes or extends portable DeepListening methodology from one or more L1 session-analysis bundles plus a prior-art web search. Produces or updates the five-file methodology bundle (ROLE · AMBIENT-AI-COUPLING · TERMINOLOGY · METHODS-MAP-EXTENSIONS · ONTOLOGY-EPISTEMOLOGY) as non-destructive sibling files under peeq-crb-nexus/meta-methods/deep-listening/. Never edits canonical METHODS-MAP or TERMINOLOGY in place. Writes lineage + journal entries back to the consumer project's `.metacontext/` shelf. Use when the user says "synthesize methodology", "extend meta-methods/deep-listening", "run L2", "update portable methodology", "add to DeepListening methodology", or is ready to promote patterns from several L1 passes into reusable methodology.
metadata:
  source:
    upstream: https://github.com/aculich/agent-skills
    canonical: https://github.com/aculich/agent-skills
---

# DeepListening method synthesis (L2)

Operationalizes **L2** of the four-level loop in [`peeq-crb-nexus/meta-methods/method-authoring/REFLEXIVE-METHOD-AUTHORING.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/method-authoring/REFLEXIVE-METHOD-AUTHORING.md). Consumes L1 outputs + prior art; produces or updates portable methodology.

## Inputs (required)

- **`l1_bundles`** — list of paths to L1 session-analysis folders (typically `docs/deep-listening/` with session-dated artifacts). At least one bundle required; two or more is the healthy case.
- **`existing_methodology_dir`** — default `/Users/me/projects/peeq-crb-nexus/meta-methods/deep-listening/`. Read in full; extended non-destructively.

## Inputs (optional)

- **`prior_art_root`** — default `research/deep-listening/` in the consumer project. Existing prior-art JSONs. New JSONs will be appended here, not overwritten.
- **`run_new_prior_art_scan`** — default `true` on the first L2 pass, `false` on subsequent passes unless new thematic threads surfaced. When true, runs up to five `parallel-cli` web searches (see [`reference.md`](reference.md) §2).
- **`metacontext_dir`** — default `.metacontext/` in the consumer project. Writes lineage + journal if present.
- **`canonical_methodology_roots`** — default set:
  - `peeq-crb-nexus/meta-methods/METHODS-MAP.md`
  - `peeq-crb-nexus/meta-methods/OVERVIEW.md`
  - `peeq-crb-nexus/meta-methods/intent-context-engineering/TERMINOLOGY.md`
  - `peeq-crb-nexus/meta-methods/institutional-ethnography/ONTOLOGY-EPISTEMOLOGY.md`
  These are **read-only** to this skill. Never edit in place.

## Outputs

All under `existing_methodology_dir` (`peeq-crb-nexus/meta-methods/deep-listening/`):

| File | Default behavior |
|---|---|
| `ROLE-SOUNDBOARD-FACILITATOR.md` | Create if missing; extend `§4. Named moves` if new moves surfaced in L1. Never delete existing moves. |
| `AMBIENT-AI-COUPLING.md` | Create if missing; extend `§11. Coupling checklist` if new metrics are warranted. |
| `TERMINOLOGY-DEEPLISTENING.md` | Create if missing; append new terms in `§1`. Never delete or rename existing terms; if drift needs reconciling, add a `§N — reconciliation` sub-section that names both terms. |
| `METHODS-MAP-EXTENSIONS.md` | Create if missing; extend with new proposed rows. |
| `ONTOLOGY-EPISTEMOLOGY-DEEPLISTENING.md` | Create if missing; extend with new entities/relations. |

Plus:

- **`<prior_art_root>/<new-theme>.json`** — any newly fetched prior-art bundles. Filename uses kebab-case theme slugs (`facilitation-priorart`, `ambient-ai-meeting`, etc.).
- **`<metacontext_dir>/lineage/<YYYY-MM-DD>-l2-synthesis-<topic>.md`** — always.
- **`<metacontext_dir>/journal/<YYYY-MM-DD>-l2-synthesis-<topic>.md`** — only if the pass surfaced method-about-method learning (usually yes, at least to record what prior-art was added).

## The non-destructive rule (load-bearing)

**Never edit canonical files in place.** All additions are sibling `*-EXTENSIONS.md` files or proposed-additions sections. The pattern:

- Canonical file (`METHODS-MAP.md`) stays untouched.
- Extensions file (`meta-methods/deep-listening/METHODS-MAP-EXTENSIONS.md`) names the proposed changes.
- Each extension section carries a *"Merge protocol"* note specifying when/how to fold it into canonical.

A canonical merge only happens **deliberately**, outside this skill, by the methodology owner. This skill's job is to make the proposal legible.

## Other required rules

### Extension, not replacement

If a methodology file already exists and the new L1 bundle introduces a variation on an existing concept — e.g., an already-named facilitator move with a new nuance — **extend** the existing section with an *"as observed in <session_date>..."* qualifier, do not overwrite.

### Prior-art grounding

Every new named move, every new term, every new ontology entity must cite at least one prior-art source (from the prior-art JSON, from the PEEQ methodology body, or from an external link). Unanchored claims get flagged in the journal entry but not committed to methodology.

### Terminology reconciliation before adding

Before introducing a new term, grep the existing DeepListening methodology and the canonical `TERMINOLOGY.md` for synonyms. If a synonym exists, extend that term's definition rather than coining a new one. If the two must coexist (e.g., facilitator vocabulary vs. LLM vocabulary), add a `§N — reconciliation` section naming both.

### Multi-bundle aggregation

When `l1_bundles` contains more than one bundle, identify patterns that appear across bundles. A move observed in only one bundle is a candidate; a move observed across bundles is a confirmed pattern that belongs in the L2 body.

### Mermaid diagrams

If methodology needs a diagram (e.g., updated `OVERVIEW.md` mermaid), include it in the appropriate extension file with the proposed new mermaid in a code block. Do not regenerate the canonical mermaid.

## Phases

1. **Read inputs.** All L1 bundles in full. All current methodology files. All current prior-art JSONs. Canonical methodology files (read-only).
2. **Identify patterns.** For each bundle, what named moves appeared? What terms? What ontology entities? Build a candidate pattern list.
3. **Prior-art scan** if enabled. Run up to five web searches via `parallel-cli`; save each as JSON. See [`reference.md`](reference.md) §2 for the recipe.
4. **Cross-check candidates against prior art.** Some candidates may already have names in adjacent literature — use those names rather than inventing new ones.
5. **Draft extensions.** For each methodology file, draft the proposed additions as diff-style sections (*"to add to §N..."* or *"new §M..."*).
6. **Write or update the five files.** Non-destructive. If a file does not exist yet, bootstrap it with the current canonical proposal; if it exists, append.
7. **Update any cross-refs.** Each extension file names what it now cross-references.
8. **Write `.metacontext/` entries.**

## When to invoke

- After **two or more** L1 bundles have accumulated and the user wants to promote patterns to methodology.
- When a new prior-art thread surfaced in conversation and should be archived to `research/deep-listening/`.
- When the user explicitly asks to update or extend `peeq-crb-nexus/meta-methods/deep-listening/`.

## When NOT to invoke

- After a single L1 bundle (unless the user has explicitly asked). Patterns confirmed across multiple sessions are more trustworthy.
- When the user only wants session analysis — invoke the L1 skill.
- When the user wants to run the reflexive loop — invoke the L3 skill (which may then invoke this one as a subroutine).

## Out of scope

- In-place edits to canonical methodology. Never.
- Analyzing new L0 evidence. That is the L1 skill's job — this skill consumes already-analyzed L1 bundles.
- Authoring new methodology bundles siblings to `deep-listening/` (e.g., a hypothetical `tacit-capture-extensions/`). Those are separate skills.

## Additional resources

- For extension templates, prior-art scan recipe, and cross-ref checklist: [`reference.md`](reference.md).
- For the canonical 2026-04-24 worked run: [`examples.md`](examples.md).
