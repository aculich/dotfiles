# Examples — reflexive method-authoring loop (L3)

## Canonical worked example — 2026-04-24 seed case

This skill's first invocation was the authoring of the skill itself, inside the conversation that produced:

1. The L1 bundle — [`nlp-ems-paramedic/docs/deep-listening/`](/Users/me/projects/nlp-ems-paramedic/docs/deep-listening/) (four analytical artifacts + README).
2. The L2 bundle — [`peeq-crb-nexus/meta-methods/deep-listening/`](/Users/me/projects/peeq-crb-nexus/meta-methods/deep-listening/) (five portable methodology files).
3. The L3 bundle — [`peeq-crb-nexus/meta-methods/method-authoring/`](/Users/me/projects/peeq-crb-nexus/meta-methods/method-authoring/) (four portable method-authoring files).
4. The project-local `.metacontext/` shelf — [`nlp-ems-paramedic/.metacontext/`](/Users/me/projects/nlp-ems-paramedic/.metacontext/).
5. Three operationalizing skills (including this one).

### What triggered the pass

The user asked, mid-conversation:

> *"is what we're doing a 'meta-analysis' or a 'meta-meta-analysis'? I'd like to know how to best think of/describe what it is you and I are doing in this moment..."*

That is the canonical `name-the-loop` phrasing. Before the question, the L3 layer was implicit — the L1 and L2 work was already happening but was not yet surfaced as a named practice.

### Mode used

`bootstrap` (because no `.metacontext/` shelf existed) + `skill-as-codification` (because no skills existed yet for L1/L2/L3). This was the most aggressive escalation possible and is the expected shape of a **first-ever** L3 pass for a project.

### Outputs produced by that pass

- Portable L3 methodology (4 files): [`method-authoring/`](/Users/me/projects/peeq-crb-nexus/meta-methods/method-authoring/).
- Project `.metacontext/` shelf bootstrapped: [`nlp-ems-paramedic/.metacontext/`](/Users/me/projects/nlp-ems-paramedic/.metacontext/).
- Lineage back-fill: [`lineage/2026-04-24-nlp-ems-matt-session.md`](/Users/me/projects/nlp-ems-paramedic/.metacontext/lineage/2026-04-24-nlp-ems-matt-session.md).
- Journal entry: [`journal/2026-04-24-reflexive-method-authoring.md`](/Users/me/projects/nlp-ems-paramedic/.metacontext/journal/2026-04-24-reflexive-method-authoring.md).
- Three skills authored: this one plus [`deeplistening-session-analysis`](/Users/me/.cursor/skills/deeplistening-session-analysis/SKILL.md) and [`deeplistening-method-synthesis`](/Users/me/.cursor/skills/deeplistening-method-synthesis/SKILL.md).
- Cross-links added: [`peeq-crb-nexus/meta-methods/OVERVIEW.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/OVERVIEW.md) directory-map row; [`peeq-crb-nexus/meta-methods/deep-listening/METHODS-MAP-EXTENSIONS.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/deep-listening/METHODS-MAP-EXTENSIONS.md) up-pointer; [`nlp-ems-paramedic/docs/deep-listening/README.md`](/Users/me/projects/nlp-ems-paramedic/docs/deep-listening/README.md) "See also" block.

### What to notice

1. **The self-referential clause is in the L3 methodology's masthead.** [`REFLEXIVE-METHOD-AUTHORING.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/method-authoring/REFLEXIVE-METHOD-AUTHORING.md) top block declares the document was authored by running itself. This is load-bearing.
2. **The journal entry names what was learned.** Not every journal entry has to contain new moves — this one did (`skill-as-codification` was promoted to a named move). Future entries often will not, and that's fine.
3. **The `.metacontext/` shelf separates lineage (the work) from journal (the method-learning).** Anti-pattern §7.4 from [`REFLEXIVE-METHOD-AUTHORING.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/method-authoring/REFLEXIVE-METHOD-AUTHORING.md) — journaling without closing the loop — was avoided by having the journal explicitly propose updates to the L3 documents.

## Typical subsequent invocation — `journal-only`

> User: *"We just ran the L1 skill on the May 15 Matt session. Anything we should journal?"*
>
> L3 skill: *"`journal-only` mode. Reading `docs/deep-listening/2026-05-15-*.md` and the lineage entry. Looking for: (a) new named moves observed, (b) terminology drift, (c) proposed updates to L2 / L3."*
>
> *"Nothing substantive this pass — the session applied existing named moves cleanly. Writing a minimal journal entry noting 'no method-learning surfaced; existing methodology held up'."*

Good. Blank-but-honest journal entries are healthy rhythm.

## Typical subsequent invocation — `bind-to-deeplistening`

> User: *"End of the May 15 session. What does the method say to do now?"*
>
> L3 skill: *"Running a `bind-to-deeplistening` pass. This is the L3 move of reflection-on-action during (or just after) a live DeepListening session. Writing a short journal entry naming any in-session observations that should inform the next L2 pass. Not invoking L1 or L2 yet — that happens in post-processing when the VTT is available."*

Good — L3 is usable *inside* DeepListening practice, not just after it.

## Invocation that should NOT happen — meta-vertigo

> User: *"Let's run an L4 analysis of our L3 pass."*
>
> L3 skill: *"That's the meta-vertigo anti-pattern from REFLEXIVE-METHOD-AUTHORING.md §7.6. The four-level model deliberately stops at L3. A journal entry about the L3 pass is the correct move — L4 is a philosophy seminar, not a practice. Want me to run journal-only on what the last L3 pass might be blind to?"*

Redirect, don't escalate.

## Invocation that should NOT happen — silent escalation

> User: *"Is what we're doing a meta-analysis or a meta-meta-analysis?"*
>
> BAD L3 skill response: *"<30 files later>... done!"*
>
> GOOD L3 skill response: *"That question is the `name-the-loop` move — we're at the authoring layer. Want me to journal the moment, or also bootstrap `.metacontext/` and author operationalizing skills?"*

Ask before escalating. The 2026-04-24 pass did escalate to `full + bootstrap + skill-as-codification`, but only after explicit user confirmation via a structured question answered with clear preferences.

## What the example does NOT show

- **`full` mode on a stable project** — every use of the skill so far has been on the first pass, which is inherently bootstrap-shaped. The healthy steady-state `full` pass (read existing `.metacontext/`, invoke L1 on a new session, decide whether to run L2, close the loop) has not yet been exercised.
- **Cross-project aggregation** — L3 is per-project. A method-author working across several projects may want aggregate lineage. Not yet supported.
- **L3 during live session** — the `bind-to-deeplistening` move was named but has not yet been invoked inside an actual live session. First exercise is a candidate for the next Matt session.
