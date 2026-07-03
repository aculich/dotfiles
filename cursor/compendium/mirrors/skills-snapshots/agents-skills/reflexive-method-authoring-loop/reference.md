# Reference — reflexive method-authoring loop (L3)

Decision tree, `.metacontext/` schema, journal templates. Read this only when running non-routine L3 work; `SKILL.md` has the routine path.

---

## 1. `.metacontext/` shelf schema (used by `bootstrap` mode)

```
<project-root>/.metacontext/
├── README.md               # purpose; distinction from .context/
├── process.md              # L0→L1→L2→L3 model named for this project
├── conventions.md          # paths: L0 evidence, L1 outputs, L2 outputs, prior-art, L3 shelf
├── skill-bindings.md       # phase → skill map with invocation examples
├── lineage/
│   ├── README.md           # what goes here vs. journal
│   └── <YYYY-MM-DD>-<slug>.md
└── journal/
    ├── README.md           # what goes here vs. lineage
    └── <YYYY-MM-DD>-<slug>.md
```

Canonical reference implementation: [`/Users/me/projects/nlp-ems-paramedic/.metacontext/`](/Users/me/projects/nlp-ems-paramedic/.metacontext/).

When bootstrapping a new project's shelf, the initial six text files should be authored by reading that project's existing `.context/conventions.md` and `README.md` and adapting the nlp-ems-paramedic templates. Never dump-copy — paths and named moves are project-specific.

---

## 2. Decision tree — which mode

```
user's latest message or inputs
            │
            ▼
  Does the user or the context
  name a reflexive moment?
  (e.g., "is this meta or meta-meta?",
   "make this repeatable")
            │
   ┌────────┴─────────┐
  yes                 no
   │                   │
   ▼                   ▼
 Is new L0            Is there new L0
 evidence also        evidence to analyze?
 being supplied?      
   │                   │
 ┌─┴──┐             ┌──┴──┐
 yes  no           yes   no
  │    │            │     │
  ▼    ▼            ▼     ▼
 full journal-    l1-    only
      only       pass   offer to
                        bootstrap
                        if shelf
                        missing
```

The skill should ask the user before escalating modes. *"You've named a reflexive moment — want me to just journal it, or also bootstrap `.metacontext/`, or run a full pass?"* is healthy.

---

## 3. `identify-level` checklist

For the current inputs / conversation, check each layer:

- **L0 active?** Is there a live session happening, or was one recently recorded?
- **L1 active?** Is there work analyzing a single session — trace tables, standpoint readings, counterfactuals?
- **L2 active?** Is the conversation naming patterns across sessions, extending methodology, proposing new terms?
- **L3 active?** Is the conversation naming the authoring process itself, asking meta-questions, naming levels?

A conversation can be at multiple levels simultaneously. Report all active levels.

---

## 4. `name-the-loop` phrasings

If the user has already used one of these phrasings, L3 is already surfaced — proceed to the right mode. If the skill is proactively surfacing L3 (uncommon), use a phrasing like:

- *"What we're doing right now is an L3 move. Want me to journal it?"*
- *"This is the authoring layer — we're naming the method, not applying it. Should I make this repeatable?"*
- *"I notice we've accumulated three session analyses. Are we ready for a method-synthesis pass?"*

Avoid jargon when first surfacing. *"Meta-meta"* is fine in reply, but lead with the plain-English version.

---

## 5. `bootstrap-metacontext` sequence

1. Check that `<project_root>/.metacontext/` does not exist. If it does, bail or extend only.
2. Create the six files + two subdirectories.
3. Fill `README.md`, `process.md`, `conventions.md`, `skill-bindings.md` with project-specific content — reference the canonical templates at [`/Users/me/projects/nlp-ems-paramedic/.metacontext/`](/Users/me/projects/nlp-ems-paramedic/.metacontext/) but adapt paths, session history, skill list.
4. Write initial `lineage/README.md` and `journal/README.md` with purpose + schema (these can be copied near-verbatim).
5. Backfill the first lineage entry from the existing L1 (and L2 if applicable) work that triggered the bootstrap.
6. Write the first journal entry naming this bootstrap as a method-learning moment.

---

## 6. Journal entry schema (L3-specific)

```markdown
# Journal — <YYYY-MM-DD> <headline>

**Trigger.** <what caused this reflexive pass — usually a user utterance or a completed L1/L2 pass>
**Levels touched.** L3 (+ any others active in the conversation)

## 1. What the method learned about itself this pass
- <named observations>

## 2. Anti-patterns surfaced (or avoided)
- <items>

## 3. New moves discovered
- <candidate moves to promote to REFLEXIVE-METHOD-AUTHORING.md §4>

## 4. Terminology drift to reconcile
- <drifts between L1, L2, metacontext texts>

## 5. Proposed updates to L2 / L3 documents
- <specific file + section + proposed change>

## 6. Open self-referential questions
- <ways the method may still be blind to itself>

## 7. Close-the-loop summary
Moves fired this pass:
- <list>

Moves not fired this pass:
- <list>
```

---

## 7. `close-the-loop` checklist

Before declaring a pass done:

- [ ] Lineage entry written?
- [ ] Journal entry written (or explicitly skipped with rationale)?
- [ ] Did any L2 or L3 document gain a *proposed update*? If so, is that update spelled out concretely (file + section + change)?
- [ ] Did any new skill become warranted? If so, did you note it without authoring it? (Skill authoring is a separate `create-skill` flow.)
- [ ] Did you bind to DeepListening — note that L3 can also run as reflection-on-action during a live session, not just in post-processing?

---

## 8. `bind-to-deeplistening` boilerplate

When closing the loop, include a short section noting:

> This pass also confirms / refines / complicates the `bind-to-deeplistening` stance: the L3 loop is invokable inside a live DeepListening session as a reflection-on-action move, feeding a short journal entry that the next L2 round folds in.

If the current pass was inside a live session, name that explicitly. If it was post-session, note whether the next session should try in-session L3.

---

## 9. Interaction with `create-skill`

The `skill-as-codification` move (defined in [`TERMINOLOGY-METHOD-AUTHORING.md`](/Users/me/projects/peeq-crb-nexus/meta-methods/method-authoring/TERMINOLOGY-METHOD-AUTHORING.md) §2.6) says: *authoring a skill is the terminal codification step of a methodology move-set*.

This skill itself does **not** author new skills. When an L3 pass surfaces that a new skill is warranted:

1. Note it in the journal under *"New skills warranted"*.
2. Offer to invoke [`create-skill`](/Users/me/.cursor/skills-cursor/create-skill/SKILL.md) separately.
3. Only after `create-skill` has run, add the new skill to the project's `.metacontext/skill-bindings.md`.

This preserves the separation of concerns: L3 identifies the need; `create-skill` authors; `.metacontext/` records.

---

## 10. Do-not-do list

- Do not escalate modes without user confirmation.
- Do not overwrite `.metacontext/` files on bootstrap.
- Do not write empty journal entries silently — be explicit about "no method-learning this pass" when applicable.
- Do not invoke L2 before L1 has completed in the same pass.
- Do not claim L4; redirect to journal-only.
- Do not author new skills inline; delegate to `create-skill`.
- Do not edit the portable L3 methodology in place; propose changes via journal entry.
