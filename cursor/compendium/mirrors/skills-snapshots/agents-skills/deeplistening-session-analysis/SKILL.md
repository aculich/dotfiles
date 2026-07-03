---
name: deeplistening-session-analysis
description: Produces the four-artifact session meta-analysis bundle (facilitator critique · subject standpoint · LLM-as-facilitator counterfactual · imagined LLM dialog) from a single DeepListening practice session's evidence set (Zoom VTT + Granola notes + screenshare frames). Anchors every claim to cue numbers or line ranges; respects the three-strata evidence model (G1 auto-notes / G2 live-prompts / G3 LLM responses). Writes lineage + journal entries back to the project's `.metacontext/` shelf if present. Use when the user says "analyze this session", "L1 analysis", "soundboard critique", "standpoint analysis", "imagined LLM dialog", or gives evidence paths for a single Matt / Aaron / DeepListening / paramedic / ambient-AI session.
---

# DeepListening session meta-analysis (L1)

Operationalizes **L1** of the four-level method-authoring loop defined in [`peeq-crb-nexus/meta-methods/method-authoring/REFLEXIVE-METHOD-AUTHORING.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/method-authoring/REFLEXIVE-METHOD-AUTHORING.md). Consumes L0 evidence; produces session-specific analytical artifacts; hands off to L2 (method synthesis) when enough sessions accumulate.

## Inputs (required)

- **`vtt`** — path to a Zoom VTT transcript (diarized, verbatim). Source of truth for all cue-anchored claims.
- **`granola_dir`** — path to a Granola notes folder containing `granola_private_notes_excerpt.xml` (or equivalent). Contains the three strata.
- **`subject`** — name of the expert being facilitated (e.g., `matt`).
- **`facilitator`** — name of the soundboard facilitator (e.g., `aaron`).

## Inputs (optional)

- **`screenshare_dir`** — screenshare frames + manifest, if the session included live demo.
- **`gallery_preview`** — a flattering both-speakers gallery still (pre-share).
- **`output_dir`** — default `docs/deep-listening/` in the consumer project.
- **`metacontext_dir`** — default `.metacontext/` in the consumer project. If present, the skill appends lineage + journal entries.
- **`session_date`** — `<YYYY-MM-DD>`. Auto-derived from evidence paths if omitted.

## Outputs (four artifacts + index)

All under `<output_dir>/`, filenames prefixed `<session_date>-`:

| # | Filename suffix | Purpose |
|---|---|---|
| A1 | `-<facilitator>-soundboard-critique.md` | Three-column trace table (cue · verbatim quote · named move) + three-strata evidence model intro + strengths + misses + weaknesses |
| A2 | `-<subject>-standpoint-analysis.md` | Subject-only reading: problem/solution framing, expertise edges, hedge-vs-claim patterns, deictic debt, negative-space findings |
| A3 | `-llm-as-soundboard-advice.md` | Counterfactual: what an LLM-as-facilitator would advise; points of contention with facilitator's moves; gaps missed |
| A4 | `-imagined-llm-dialog-with-<subject>.md` | Simulated annotated dialog with a rationale column + side-by-side compare-to-actual table |
| R | `README.md` (updated, not overwritten) | Index of analytical artifacts in this folder; appends a row when run on a new session |

Plus if `metacontext_dir` exists:

- **`<metacontext_dir>/lineage/<session_date>-<repo-slug>-<subject>-session.md`** — provenance of this pass (see [`reference.md`](reference.md) §3 for schema).
- **`<metacontext_dir>/journal/<session_date>-<subject>-session.md`** — only written if the pass surfaced method-learning (see §5 below); blank entries are not written.

## Required rules

### Three-strata evidence model (G1 / G2 / G3) is the analysis frame

When reading the Granola notes:

- **G1** = Granola-automated structured notes (project briefs, action-item lists Granola produced on its own).
- **G2** = the facilitator's **live-prompts typed into the Granola chat** during the session. These are separate from spoken utterances and deserve their own stratum.
- **G3** = the LLM's responses (search packs, roadmaps, structured outputs) generated from G1 + G2.

The critique artifact (A1) must explicitly introduce this model and attribute actions to the correct stratum. Never conflate *the facilitator said it* (G1-adjacent, from the VTT) with *the facilitator typed it* (G2).

### Cite everything

Every claim in every artifact anchors to either:

- A VTT cue number (e.g., `cue 283`) plus timestamp (e.g., `00:39:32`), or
- A Granola line range (e.g., `granola L1425-L1460`), or
- A screenshare frame ID.

If a claim cannot be anchored, it is a vibe, not a finding — remove it.

### Soundboard facilitator move vocabulary

Use the named moves from [`peeq-crb-nexus/meta-methods/deep-listening/ROLE-SOUNDBOARD-FACILITATOR.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/deep-listening/ROLE-SOUNDBOARD-FACILITATOR.md) §4. Do not invent new move names in an L1 pass — if an unnamed move is observed, note it in §5 "method-learning" and defer naming to the L2 layer.

### Deictic debt

During screenshare, the subject often says *"here", "this", "when I click"*. The ambient AI cannot resolve these. A1 must include a **deictic debt table** (cue · utterance · resolved referent · whether the facilitator resolved it live).

### Non-destructive README update

Never overwrite `<output_dir>/README.md`. Read the existing file, append a new row to the analytical-artifacts table (or add a new session-dated section), preserve the rest verbatim.

## Phases

1. **Read evidence.** VTT in full. Granola excerpt in full. Screenshare manifest if present.
2. **Build the trace table.** For every facilitator utterance that looks like a named move, emit one row: cue · verbatim quote · move label.
3. **Draft A1** (facilitator critique). Start with the three-strata model paragraph. Then trace table. Then strengths (with cue anchors). Then misses (with cue anchors). Keep the author-name placeholder throughout so the file works for other facilitators.
4. **Draft A2** (subject standpoint). Put the facilitator's voice aside. Read only what the subject said. Identify: (a) problem framing, (b) solution framing, (c) domain expertise shown, (d) knowledge edges explicitly admitted, (e) hedging patterns, (f) deictic debt.
5. **Draft A3** (LLM counterfactual advice). What would an LLM-as-facilitator advise the subject, unprompted? What did the human facilitator miss? Where would the LLM contest something the human said? Tone: collegial, not smug.
6. **Draft A4** (imagined LLM dialog). Simulate a new conversation over the same arc with the subject, but the facilitator is an LLM. Each turn gets a rationale column. At the end, a side-by-side compare-to-actual table.
7. **Update README index.**
8. **Write `.metacontext/` entries** if the shelf exists. Lineage always. Journal only if §5 of this skill's work surfaced method-learning.

## When to invoke

- After a session's evidence is mirrored into the project repo.
- When re-analyzing an older session with new eyes (rare).
- **Not** when only one of the four artifacts is needed — those are tightly coupled by the three-strata model and shared cue anchors.

## Out of scope

- Extending portable methodology (that is the L2 skill: [`~/.cursor/skills/deeplistening-method-synthesis/`](/Users/me/.cursor/skills/deeplistening-method-synthesis/SKILL.md)).
- Running the reflexive authoring loop (that is the L3 skill: [`~/.cursor/skills/reflexive-method-authoring-loop/`](/Users/me/.cursor/skills/reflexive-method-authoring-loop/SKILL.md)).
- Editing canonical methodology docs. Never.

## Additional resources

- For artifact skeletons and trace table templates: [`reference.md`](reference.md).
- For the canonical worked example (2026-04-24): [`examples.md`](examples.md).
