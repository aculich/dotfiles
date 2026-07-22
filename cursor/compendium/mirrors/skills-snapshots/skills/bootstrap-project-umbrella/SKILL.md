---
name: bootstrap-project-umbrella
description: >-
  Incepts a multi-repo product umbrella under ~/projects/<slug> with meta
  controller, inquiry/product/studies lanes, private GitHub remotes, aallc-orbit
  topics, multiroot workspace, and layered justfiles. Use when starting a
  purpose-led project (not a ~/tools quickstart), running /bootstrap-project-umbrella,
  or dogfooding agent-control-tower-style layouts. Distinguishes project umbrellas
  from tools-quickstart-bootstrap and client engagement umbrellas.
disable-model-invocation: true
---

# Bootstrap project umbrella

Incept **our** multi-repo product projects under `~/projects/<slug>/`: thin meta controller + lane repos + private `gh` + house topic `aallc-orbit` + Cursor multiroot workspace + justfiles.

## Not this skill

| Use instead | When |
|-------------|------|
| `tools-quickstart-bootstrap` | Evaluating/wrapping an **upstream tool** under `~/tools/<tool>-quickstart/` |
| `bootstrap-new-project` | Single-repo flat product (no meta/lanes) |
| `bootstrap-umbrella-client-project` | Long-horizon **client** `engagements/` umbrellas |

**Rule:** Tooling quickstarts learn someone else’s tool. Project umbrellas pursue a purpose **we** envision and may ship. Umbrellas may *point at* `~/tools/*-quickstart` via `tools/README.md`; they do not become quickstarts.

## Execution contract

Same gate as `bootstrap-new-project`:

1. **Existing** tree → dry-run first (`[plan]` actions → `NO FILES WRITTEN — DRY RUN ONLY`).
2. **Apply** only on `bootstrap apply` / `approve bootstrap` / `execute the bootstrap plan` / same-message `apply`|`execute`|`go ahead`, or greenfield + apply.
3. Append one analytics line to `~/.local/share/aallc-orbit/skill-usage.jsonl` on successful apply (create dir if needed).

## Hard gate (gstack-inspired)

**Do not** create an `apps/` git remote or implementation scaffold until:

- meta `.context/intent.md` exists **and**
- intent is APPROVED via envisioning-suite handoff, gstack `/office-hours` design doc, **or** explicit user skip with recorded prior art (e.g. existing SuperPRD).

`apps/` may exist as a **README-only stub** (no nested `.git`) before the gate.

**Lake vs ocean:** Full lane set (inquiry + product + studies + apps stub) is a boilable lake. Implementing the product app during bootstrap is an ocean — out of scope.

## Lifecycle

```text
[optional] envisioning-suite OR gstack /office-hours → APPROVED intent
[optional] plan CEO/eng/design reviews (gstack or product/reviews checklists)
bootstrap-project-umbrella apply → meta + lanes + workspace + private gh
inquiry (little-r) → product (PRDs) → [later] apps monorepo
```

Prefer **one** of envisioning-suite or gstack office-hours, not both, unless the user asks.

### AskUserQuestion format (when choosing)

1. **Re-ground:** project slug, task (scaffold / migrate / remotes).
2. **Simplify:** plain English; no jargon pile-up.
3. **Recommend:** `RECOMMENDATION: Choose [X] because …` + Completeness X/10 per option.
4. **Options:** `A) … B) … C) …`

## Default lanes (never research/ vs Research/)

| Lane | Role |
|------|------|
| `inquiry/` | little-r scouting (parallel-cli dumps, landscape, feedstock) |
| `product/` | PRDs, SuperPRD, crosswalk, curated deliverables |
| `studies/` | capital-R academic / preprint programs |
| `apps/` | implementation later (inner monorepo when coding starts) |

## Workflow checklist

```text
Task Progress:
- [ ] 1. Classify greenfield vs existing; dry-run if existing
- [ ] 2. Envisioning / prior-art gate → .context/intent.md
- [ ] 3. Scaffold meta at ~/projects/<slug>/
- [ ] 4. Init nested git repos: inquiry, product, studies; apps README stub
- [ ] 5. Layered justfiles (meta fan-out + child minimal)
- [ ] 6. ~/projects/workspaces/<slug>.code-workspace
- [ ] 7. Private gh repo create ×N; topics incl. aallc-orbit; push
- [ ] 8. Migrate litter paths if named
- [ ] 9. just / just doctor / child status; report remotes
```

Details, templates, topics, and gh commands: [reference.md](reference.md).

## Downstream

After apply: continue little-r in `inquiry/`, promote to `product/`, optional reviews in `product/reviews/`. When code starts, convert `apps/` to an inner monorepo (ADR `002-apps-monorepo-when.md`).
