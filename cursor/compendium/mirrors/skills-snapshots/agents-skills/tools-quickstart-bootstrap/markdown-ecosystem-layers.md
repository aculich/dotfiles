# Markdown Ecosystem — Layer Bootstrap Variant

Variant of [tools-quickstart-bootstrap](SKILL.md) for **multi-tool, layer-organized** repos such as `~/tools/markdown-ecosystem/`.

Process narrative for this repo: [`META.md`](file:///Users/me/tools/markdown-ecosystem/META.md).

## When to use

- Bootstrapping a tool under `~/tools/markdown-ecosystem/layers/<layer>/<tool>/`
- Adding quickstarts for editors, vaults, publishing stacks, etc. in one repo
- Selective clone via git submodules + `just clone-tool`

Do **not** create `~/tools/<tool>-quickstart/` unless the user asks for a separate repo.

## Layer placement

See [`layers/LAYERS.md`](file:///Users/me/tools/markdown-ecosystem/layers/LAYERS.md). One **primary** layer per tool; document cross-layer tags in `INDEX.md`.

| Layer | Examples |
|-------|----------|
| `vault` | Tolaria, Karpathy wiki patterns, OKF |
| `editor` | BlockNote, Tiptap, Milkdown |
| `publishing` | mystmd, Jupyter Book |
| `delivery` | Streamdown |
| `collab` | Yjs, blocknote-electric-example |
| `parser` | remark, markdown-it |
| `apps` | Rowboat, TypeCell, Displacement (shipped products) |
| `instructions` | AGENTS.md, gh-aw (conventions) |

## Per-tool directory template

```text
layers/<layer>/<tool>/
├── INDEX.md
├── upstream/              # git submodule → canonical repo
├── fork/                  # optional; only when actively developing a fork
├── quickstart/
│   ├── EXECSUMMARY.md
│   ├── PRAXIS.md
│   ├── background/
│   │   ├── TECHSTACK.md
│   │   ├── ARCHITECTURE.md
│   │   ├── RESEARCH_KEYWORDS.md
│   │   ├── LANDSCAPE.md
│   │   ├── USECASES.md
│   │   ├── UPSTREAM_PIN.txt
│   │   └── parallel-cache/
│   └── justfile
├── experiments/
├── analysis/
└── posts/                 # Willison-style drafts; see layers/posts/STYLE.md
```

## Checklist (layer variant)

```markdown
Layer Bootstrap Progress:
- [ ] 1. Choose primary layer + cross-layer tags; write INDEX.md
- [ ] 2. Add git submodule at upstream/; write UPSTREAM_PIN.txt
- [ ] 3. Tool-local justfile (smoke, pin, verify-upstream)
- [ ] 4. Smoke test (binary install and/or dev build)
- [ ] 5. EXECSUMMARY, PRAXIS, TECHSTACK, ARCHITECTURE
- [ ] 6. Layer-scoped LANDSCAPE.md + parallel-cli cache
- [ ] 6a. gh api canonical upstream verification
- [ ] 7. Optional first post draft in posts/
- [ ] 8. Update layers/README.md status table
- [ ] 9. Root just clone-tool / status picks up new submodule
```

## Submodule vs fork

| Path | Use |
|------|-----|
| `upstream/` | Read-only pin of canonical repo; submodule for selective clone |
| `fork/` | Your fork when developing features or long-running patches |

**Contribute upstream:** branch on fork, PR to canonical; keep `upstream/` tracking main.

**Integrate in new apps:** experiments/ for spikes against vanilla upstream; apps layer for shipped products.

## Landscape scope

- **Per-layer** `LANDSCAPE.md` — peers at that layer only (vault peers for Tolaria, editor peers for BlockNote)
- **Cross-layer** [`LANDSCAPE-SYNTHESIS.md`](file:///Users/me/tools/markdown-ecosystem/LANDSCAPE-SYNTHESIS.md) — thesis updates only when the stack shifts
- **Apps discovery** — `just discover-apps editor` → [`layers/apps/BUILT-ON-EDITORS.md`](file:///Users/me/tools/markdown-ecosystem/layers/apps/BUILT-ON-EDITORS.md)
- Keywords: [`layers/RESEARCH_KEYWORDS.md`](file:///Users/me/tools/markdown-ecosystem/layers/RESEARCH_KEYWORDS.md)

## Root repo outputs (once per ecosystem)

At `markdown-ecosystem/` root (not per tool):

- `META.md`, `justfile`, `CLONE.md`, `.gitmodules`
- `layers/LAYERS.md`, `layers/README.md`
- `LANDSCAPE-SYNTHESIS.md` (narrative index)
- `TOOLBOX.md` (agent skills; find-skills step)
- `parallel/` (cross-layer search JSON)

Legacy product bundles (`blocknote-analysis/`, `rowboat-analysis/`) stay as case studies; link from `layers/apps/` — do not migrate unless asked.

## Posts

Drafts in `layers/<layer>/<tool>/posts/YYYY-MM-DD-<slug>.md`. Style: [`layers/posts/STYLE.md`](file:///Users/me/tools/markdown-ecosystem/layers/posts/STYLE.md).

## Clone on another machine

```bash
git clone <markdown-ecosystem-url>
cd markdown-ecosystem
just clone-tool vault/tolaria    # one tool
just clone-layer editor          # whole layer
just clone-all                   # all submodules
```

See [`CLONE.md`](file:///Users/me/tools/markdown-ecosystem/CLONE.md).
