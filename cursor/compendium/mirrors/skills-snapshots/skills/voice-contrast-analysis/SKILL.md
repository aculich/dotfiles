---
name: voice-contrast-analysis
description: Contrastive structural, semantic, rhetorical, and standpoint analysis of how a colleague's final/sent text differs from our draft — producing voice hallmarks, a kept/softened/reframed/rejected ledger, and a VOICE_LEXICON for future drafting in their voice. Use when comparing a draft against what was actually sent, when someone asks "what changed and why," or when building a reusable voice profile of a teammate's partner-facing writing.
disable-model-invocation: true
---

# Voice contrast analysis (draft vs final)

Compare our draft (A1) against the colleague's final (R1), tracing back to any original stub
(R0). The goal is operational: hallmarks precise enough that someone could **imitate the voice**,
plus a feed-forward lexicon so future drafts need less conversion.

Part of a 3-skill suite: run `email-send-verify` first (is R1 actually sent?), this skill second,
`standpoint-scenario-forecast` third.

Methods spine: `~/projects/peeq-crb-nexus/meta-methods/` — esp.
`institutional-ethnography/TERMINOLOGY.md` (standpoint, textual mediation, institutional capture),
`intent-context-engineering/TERMINOLOGY.md` (CIV), `METHODS-MAP.md` (contrastive rhetorical
analysis lineage). Full prompt: `meta-methods/standpoint-perspectivetaking-and-voice-analysis.md`.

## Workflow

1. **Assemble corpus** with labels and canonical sources: R0 (original stub), A1 (our draft),
   R1 (their final), Sent (if verified), Ctx (meetings/briefings that coordinate the ask).
2. **Open with a CIV block** (intent · context · values): what *our* draft optimized for vs what
   *their* final optimizes for — name the gap explicitly.
3. **Build the comparison matrix** — rows are the six dimensions, columns R0 | A1 | R1:
   1. **Structural** — layout, labels/bold, paragraph count, what was cut/added/reordered
   2. **Semantic** — ask scope, commitments, names vs roles, deadline framing (quote exact phrases)
   3. **Rhetorical** — ethos/logos/pathos, hedges vs directives, blame/face-threat, statistics as leverage
   4. **Pragmatic / speech-act** — request, reminder, commissive, directive; the email's primary act
   5. **Textual mediation (IE)** — which institutional texts each version *activates* (ToS,
      deadlines, SOW) and which A1 texts the final *deactivated*
   6. **Standpoint encoding** — whose knowledge/comfort is centered
4. **Voice hallmarks** — 3–8 bullets per voice, each with **quoted evidence**. Then the ledger:
   **kept / softened / reframed / rejected / added** (A1 → R1). Quotes, not vibes.
5. **Institutional-capture check** — where our draft's analyst register (jargon, stats, bold
   stakes) would trigger defensive routing in the recipient institution; note what the final
   removed and what it conceded (usually: register, not substance).
6. **Perspective-taking warm-up** (≤1 page) — "If I am <recipient> opening this…" for each
   recipient; feeds the sibling scenario skill.
7. **VOICE_LEXICON** — 5–8 do/don't bullets for future drafting in their voice.
8. **Methods checklist footer** — tick only what was actually used, pointing at concrete
   `meta-methods/` files.

## Key analytical moves (learned)

- Watch for **substance kept, register stripped** — the most common expert edit.
- Watch for the ask quietly getting **bigger while the tone gets softer** (scope expansions
  slipped in mid-sentence).
- Depersonalized rationale ("providing only X prevents seeing Y") vs agent-blaming conditionals
  ("when partners hand over only X…") — same logic, opposite reception.
- Volunteer-a-constraint commissives (ToS compliance offers) are trust moves, not concessions.
- Roles over names in written asks protects individuals from record exposure.

## Worked example

`~/projects/cidr-san-mateo-21elements/notes/2026-08-12-reily-vs-aaron-costar-voice-analysis.md`
(CoStar #86: Reily kept the full-export substance verbatim, rejected all consultant register,
added a ToS commissive, and expanded RWC → county in the same edit that removed all pressure).
