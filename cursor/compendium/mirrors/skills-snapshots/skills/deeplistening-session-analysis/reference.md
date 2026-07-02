# Reference — DeepListening session meta-analysis (L1)

Artifact skeletons, trace-table templates, and schemas. Read this only when authoring artifacts; `SKILL.md` has everything you need for routine invocation.

---

## 1. A1 — facilitator critique skeleton

```markdown
# <Facilitator> soundboard critique — <session title> (<YYYY-MM-DD>)

**Source.** Grounded in [VTT](<path>) + [Granola notes](<path>) three strata. Every claim anchors to a cue or line range.

## 0. The three evidence strata

- **G1** — Granola auto-structured notes (§1.1 below)
- **G2** — <Facilitator>'s typed live-prompts into Granola (§1.2)
- **G3** — LLM responses generated from G1 + G2 (§1.3)

These three strata are the substrate of the critique. Attribute every observed action to the correct stratum.

## 1. Trace table

| Cue | Timestamp | Verbatim quote (facilitator) | Named move | Stratum |
|---|---|---|---|---|
| ... | ... | "..." | <move> | G1 / G2 |

(Move vocabulary from peeq-crb-nexus/meta-methods/deep-listening/ROLE-SOUNDBOARD-FACILITATOR.md §4.)

## 2. Strengths

- **<Move name> at cue N** — what happened, why it worked, citation.
- ...

## 3. Misses

- **<What was missed> at cue N** — what should have happened, citation, proposed alternative.
- ...

## 4. Ambient-AI coupling lens

How well did the facilitator couple the AI to the session?

- Deictic-surface count: N moves over M possible moments.
- Recap-instead-of-ask count: N instances.
- G2 live-prompt count: N prompts.
- Coupling checklist from AMBIENT-AI-COUPLING.md §11: <score / notes>.

## 5. Method-learning (for journal)

*Only fill in if this pass surfaced something the current L2 methodology does not yet name. Otherwise omit this section from the artifact and skip the journal entry.*

- Observed but unnamed move at cue N: <description>.
- Terminology drift between X and Y: <description>.
- ...

## 6. Deictic debt (if screenshare)

| Cue | Utterance | Referent (resolved) | Resolved live? |
|---|---|---|---|
| ... | "when I click here" | <what "here" was> | ✅ / ❌ |

## 7. Headline findings

1. ...
2. ...
3. ...
```

---

## 2. A2 — subject standpoint skeleton

```markdown
# <Subject> standpoint analysis — <session title> (<YYYY-MM-DD>)

**Method.** Facilitator's voice set aside. Reading only what <Subject> said, in order to infer what <Subject> brought to the table.

## 1. How <Subject> framed the problem

<In their own words, with cue anchors.>

## 2. How <Subject> framed the solution space

<Tools they named, approaches they considered, constraints they treated as hard vs. soft.>

## 3. Domain expertise shown

| Evidence | Cue | What it tells us about <Subject>'s expertise |
|---|---|---|
| ... | ... | ... |

## 4. Knowledge edges (what <Subject> explicitly admitted not knowing)

<Direct quotes, with cue anchors.>

## 5. Hedge vs. claim patterns

| Domain | Hedging pattern | Confident claim pattern |
|---|---|---|
| Clinical / medical | ... | ... |
| ML / NLP | ... | ... |
| Tooling | ... | ... |

## 6. Deictic debt from <Subject>'s side

<What did <Subject> say that the ambient AI could not resolve? What did the facilitator surface vs. let slide?>

## 7. Negative-space findings

<What did <Subject> NOT say that a well-versed domain expert would have said? What gaps are interesting?>

## 8. How the ambient AI record should remember <Subject>

<If a future agent reads this transcript cold, what should they know about <Subject>?>
```

---

## 3. A3 — LLM counterfactual advice skeleton

```markdown
# LLM-as-soundboard — counterfactual advice brief — <session title> (<YYYY-MM-DD>)

**Stance.** A grounded counterfactual. What would an LLM-as-facilitator have advised <Subject>, unprompted, given only what <Subject> said?

## 1. How the LLM would describe the problem space

<Framing with cue anchors — what the LLM would say back to <Subject> to confirm understanding.>

## 2. How the LLM would describe the solution space

<Tools, approaches, tradeoffs — including options the facilitator did NOT surface.>

## 3. Where the human facilitator did better

<Be explicit. Don't make this brief one-sided.>

## 4. Where the LLM would have gone further

<Gaps the facilitator missed. Citations from A2.>

## 5. Points of contention

| What the facilitator said at cue N | What the LLM would push back on | Why |
|---|---|---|
| ... | ... | ... |

## 6. One-page concrete brief <Subject> would receive

<A synthesized, actionable brief — the outcome the LLM would have produced.>
```

---

## 4. A4 — imagined LLM dialog skeleton

```markdown
# Imagined LLM-as-soundboard dialog with <Subject> — <session title> (<YYYY-MM-DD>)

**Stance.** Simulated. What would the same ~60-90 minute conversation look like if the facilitator were an LLM?

## Setup

<Brief scene-setting: same starting context as the actual session.>

## Dialog

| Turn | Speaker | Utterance | LLM's internal rationale |
|---|---|---|---|
| 1 | LLM | "..." | <Why this opening move; which named facilitator move it is> |
| 2 | <Subject> | <inferred response based on actual session> | — |
| 3 | LLM | "..." | <rationale> |
| ... | | | |

## Side-by-side: Aaron actual vs. LLM simulated

| Moment | Facilitator actual (cue) | LLM simulated | Delta |
|---|---|---|---|
| Opening | ... | ... | ... |
| Deictic resolution | ... | ... | ... |
| Landscape-spot moment | ... | ... | ... |
| Closing | ... | ... | ... |

## What the LLM could not do

<Honest limits of the simulation. Things only the human facilitator can do.>
```

---

## 5. Lineage entry schema (for `.metacontext/lineage/`)

```markdown
# Lineage — <session_date> <repo-slug> / <subject> session

**Pass type.** L1 session meta-analysis
**Date.** <session_date>
**Scope summary.** <1-2 sentences>

## 1. Seed evidence
- VTT: <path>
- Granola: <path>
- Screenshare: <path or "none">

## 2. L1 outputs written
- <path/A1> · <path/A2> · <path/A3> · <path/A4> · <path/README updated>

## 3. Commits
- <SHA>: <message>

## 4. Open questions
- ...
```

---

## 6. Journal entry schema (for `.metacontext/journal/`) — only if method-learning surfaced

```markdown
# Journal — <session_date> <subject> session — <headline>

**Trigger.** <What surfaced method-learning this pass>
**Levels touched.** L1 (+ any others)

## 1. What the method learned about itself this pass
- ...

## 2. Anti-patterns surfaced
- ...

## 3. New moves discovered
- ...

## 4. Terminology drift to reconcile
- ...

## 5. Proposed updates to L2 / L3 documents
- ...

## 6. Open self-referential questions
- ...
```

---

## 7. Do-not-do list

- Do not invent new facilitator move names in an L1 pass; defer to L2.
- Do not overwrite `README.md` — append only.
- Do not write journal entries with nothing in them.
- Do not claim anything you cannot cite.
- Do not conflate G1 and G2. The three strata is the whole point.
