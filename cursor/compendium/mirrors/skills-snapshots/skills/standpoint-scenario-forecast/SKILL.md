---
name: standpoint-scenario-forecast
description: Institutional-ethnography perspective-taking on an outbound ask (email, data request, proposal) — inhabit each recipient's standpoint, dissect the ask into rated atomic components, identify the unlock, and forecast the conversation as probability-weighted scenarios with an exchange map. Use when anticipating how civil servants or partner-org staff will receive a request, where resistance will surface, and how to secure the full outcome without burning the relationship.
disable-model-invocation: true
---

# Standpoint scenario forecast (how the ask will land)

Predict the series of email/meeting exchanges an ask will trigger, from the **standpoint**
(Dorothy Smith, IE) of the people receiving it — their work knowledge, ruling relations, and the
texts that coordinate their action — then plan counter-moves that stay in the sender's voice.

Part of a 3-skill suite: run `email-send-verify` first, `voice-contrast-analysis` second (its
perspective warm-up and VOICE_LEXICON feed this skill), this skill third.

Methods spine: `~/projects/peeq-crb-nexus/meta-methods/` — esp.
`institutional-ethnography/TERMINOLOGY.md` (standpoint, ruling relations, work knowledge,
problematic), `deep-listening/PUSHBACK-AS-SENSEMAKING.md` (resistance as a map of constraints).
Full prompt: `meta-methods/standpoint-perspectivetaking-and-voice-analysis.md`.

## Workflow

1. **Standpoints to inhabit** — one subsection per actor (recipients, delegates/stewards,
   background allies, our side for symmetry, and the extralocal governor e.g. vendor/license).
   For each: **work knowledge · ruling relations · coordinating texts · problematic** (the
   disjuncture they live). Start from *their* everyday work, not our project diagram.
2. **Dissect the ask** into atomic components; rate each High/Med/Low on: clarity to recipient,
   face threat, institutional friction, necessity for us. Then classify: **the unlock** (the one
   move that unlocks everything downstream), **hygiene asks**, **nice-to-haves** (acceptable
   casualties — but only if scoped down *deliberately*, never silently).
3. **Scenario set (≥4)** — fixed schema per scenario:

   ```text
   Scenario ID / Name / Probability (rough):
   Trigger / first reply:
   Email sequence (numbered turns; who → who; speech-act):
   Other channels (Zoom, internal forwards, vendor support):
   Resistance loci (standpoint + ruling relation + text):
   Unlock moment (if any):
   Data/outcome (full / partial / delayed / refused / mis-scoped):
   What puts it at risk:
   Counter-moves in the sender's voice (use the sibling VOICE_LEXICON):
   Early signals we're on this path:
   ```

   Standard seeds to adapt: happy-path delegation · institution answers with its habitual
   slice · legal/ToS freeze · scope drift (they heard X, we wrote Y) · calendar stall past our
   deadline · delegate gated without principal air cover.
4. **Exchange map** — mermaid flowchart of the most-likely composite path with branch points
   into the scenarios; forecast how many meetings the ask *should* need (extra meetings = a
   scenario signal).
5. **Where we might not get what we need** — table of gaps, distinguishing **analytical failure**
   (missing fields, coverage limits) from **relational failure** (trust spent) from **timing
   failure**; flag which failures are self-inflicted and avoidable.
6. **Methods checklist footer** — tick what was used, pointing at concrete `meta-methods/` files.

## Key analytical moves (learned)

- **Delegation, not resistance, is the default** first response of a principal — design the ask
  so forwarding it is safe.
- The first objection is a **map of their ruling relations** (pushback-as-sensemaking) — organize
  scenarios around it rather than treating it as an obstacle.
- Delegates/stewards need **visible authorization**, not persuasion; a bare forward is not air
  cover. Re-CC principals when replying to a delegate.
- Deadline leverage **decays to zero** once passed — one bump maximum, then decouple the
  deliverable from the data (design the slot empty).
- "Give us the data" can usually degrade gracefully to "show us the data" (screen-share,
  view-only) — a floor, not a failure.

## Worked example

`~/projects/cidr-san-mateo-21elements/notes/2026-08-12-costar-ask-standpoint-scenarios.md`
(CoStar #86: six standpoints incl. CoStar-as-vendor; unlock = ToS + 15-min steward screen-share;
six scenarios; mermaid exchange map; county-vs-RWC silent scope-down flagged as top risk).
