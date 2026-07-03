# Reference — DeepListening method synthesis (L2)

Templates, prior-art scan recipes, and schemas. Read this only when authoring extensions; `SKILL.md` has enough for routine invocation.

---

## 1. Extension file templates

### 1.1 `ROLE-SOUNDBOARD-FACILITATOR.md` — adding a new named move

If L1 bundles surface a new move, extend §4:

```markdown
### 4.<N> <move-kebab-name>

**What.** <one-sentence definition>

**When to use.** <trigger conditions>

**Example.** *"..."* (cue <N>, <session_date>).

**Distinct from.** <existing move that could be confused>

**Anti-pattern.** <misuse>

**Source.** Observed across sessions: <list of sessions>. Lineage: <prior-art citation>.
```

### 1.2 `TERMINOLOGY-DEEPLISTENING.md` — adding a new term

```markdown
### 1.<N> <term>

**What.** <definition>

**Why.** <what gap it fills that existing vocabulary does not>

**Cross-refs.** <links to PEEQ, IE, Tacit Capture, adjacent literature>
```

If reconciling drift between two terms that mean the same thing:

```markdown
### <§>.<N> Reconciliation: <term-A> ↔ <term-B>

**What.** Both terms have been used for <the same concept>.

**Recommended canonical.** <term-A> for <context>; <term-B> for <other context>.

**Why both kept.** <if applicable — e.g., facilitator vocabulary vs. LLM vocabulary>
```

### 1.3 `METHODS-MAP-EXTENSIONS.md` — adding a cross-layer mapping row

```markdown
Add a row to the cross-layer mapping table:

| IE concept | Deep Listening equivalent | Tacit Capture equivalent | Intent/Context Engineering equivalent |
|---|---|---|---|
| <IE term> | **<DL move / concept>** | <TK equivalent> | <CIV equivalent> |

Rationale: <why this row is needed; cite the L1 bundle that surfaced it>.
```

### 1.4 `AMBIENT-AI-COUPLING.md` — adding a coupling-checklist metric

```markdown
### <§>.<N> <metric-name>

**What it counts.** <definition>

**Why it matters.** <coupling quality it reflects>

**Target.** <healthy range, e.g., "2-5 per 60-minute session">

**How observed.** <where in evidence to count>
```

### 1.5 `ONTOLOGY-EPISTEMOLOGY-DEEPLISTENING.md` — adding an entity

```markdown
### <§>.<N> <entity-name>

**Entity.** <definition>

**Relations.** <to other entities in the ontology>

**Epistemic status.** <what kind of knowledge it encodes; how it's warranted>

**Grounded in.** <L1 bundle citation + session_date>
```

---

## 2. Prior-art scan recipe

When `run_new_prior_art_scan: true`, run up to five `parallel-cli` web searches. Save each to `<prior_art_root>/<theme-slug>.json`.

### Canonical themes (used 2026-04-24)

| Theme | Query focus |
|---|---|
| `facilitation-priorart` | PALEO, Nancy Kline, Scharmer Theory U, Clean Language, Socratic coaching |
| `ambient-ai-meeting` | Granola, Otter, Circleback, Fireflies — ambient meeting AI capture + synthesis |
| `ie-elicitation-llm` | Institutional ethnography × knowledge elicitation × LLM-assisted qualitative analysis |
| `llm-as-interviewer` | MIBot, MIcha, CALM-IT, KELE Socratic multi-agent, LLM-as-interviewer |
| `listening-epistemology` | Kline Thinking Environment, Scharmer Theory U, Ihde phenomenology of listening |

### New thematic thread

If the user surfaces a new thread — e.g., *"can you scan for literature on live prompting as a facilitator technique?"* — create a new theme slug and run the search. Never overwrite an existing JSON.

### Invocation pattern

```
parallel-cli search "<focused query>" --output <prior_art_root>/<theme-slug>.json
```

Adjust flags per the user's `parallel-cli` install. See canonical example outputs at [`/Users/me/projects/nlp-ems-paramedic/research/deep-listening/`](/Users/me/projects/nlp-ems-paramedic/research/deep-listening/).

---

## 3. Cross-reference checklist (before commit)

For each methodology file that was extended:

- [ ] Every new claim cites either a L1 bundle, a prior-art JSON, or an external URL.
- [ ] Every new term cross-refs adjacent existing terms (PEEQ, IE, Tacit Capture, Intent/Context Engineering).
- [ ] No canonical file is edited in place.
- [ ] `METHODS-MAP-EXTENSIONS.md` has an updated *"Merge protocol"* section if the extension changes what canonical file(s) should be edited at merge time.
- [ ] `OVERVIEW.md` directory-map row (for `deep-listening/`) is still accurate.

---

## 4. Multi-bundle aggregation rules

When `l1_bundles` has N ≥ 2:

- **Confirmed pattern** — a named move observed in ≥ 2 bundles → add to `ROLE-SOUNDBOARD-FACILITATOR.md`.
- **Candidate pattern** — a named move observed in 1 bundle only → note in journal; do not promote yet.
- **Contested pattern** — a named move whose definition varies across bundles → add a reconciliation subsection naming both variants; do not collapse.
- **Terminology drift** — same concept, different words across bundles → add reconciliation per §1.2 above.

---

## 5. Lineage entry schema (for `.metacontext/lineage/`)

```markdown
# Lineage — <YYYY-MM-DD> L2 synthesis — <topic>

**Pass type.** L2 method synthesis
**Date.** <YYYY-MM-DD>
**Scope summary.** <1-2 sentences>

## 1. L1 bundles consumed
- <path/A1-set-1> · <path/A1-set-2> · ...

## 2. Methodology files updated (non-destructively)
- <path/ROLE ...> · ...

## 3. Prior-art JSONs added
- <path/new-theme.json>

## 4. Commits
- <SHA>: <message>

## 5. Open questions
- ...
```

---

## 6. Journal entry schema

```markdown
# Journal — <YYYY-MM-DD> L2 synthesis — <topic>

**Trigger.** <why this synthesis pass ran>
**Levels touched.** L2 (+ L3 if synthesis pass itself taught the method about itself)

## 1. What the method learned about itself this pass
- ...

## 2. Anti-patterns surfaced (or avoided)
- ...

## 3. New patterns promoted to confirmed
- <move-kebab-name>: <bundles where confirmed>

## 4. Candidate patterns held for future
- <move-kebab-name>: observed in <N> bundle(s) — waiting for confirmation

## 5. Terminology drift reconciled
- <term-A> / <term-B> → <chosen canonical>; both retained with reconciliation note

## 6. Proposed updates to L3 documents (if any)
- ...

## 7. Open self-referential questions
- ...
```

---

## 7. Do-not-do list

- Do not edit canonical methodology in place.
- Do not remove or rename existing named moves or terms. Extend or reconcile.
- Do not coin a new term when a synonym exists. Grep first.
- Do not promote a candidate pattern to the L2 body based on a single session.
- Do not overwrite prior-art JSONs; add new theme slugs.
- Do not run the reflexive loop inside this skill; that is L3's job. This skill's journal entry is a **product**, not a loop.
