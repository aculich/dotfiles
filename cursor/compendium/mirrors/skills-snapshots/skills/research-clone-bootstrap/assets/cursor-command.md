# Research-clone bootstrap

Scaffold a dual Cursor workspace lab (product + peer research) from a seed URL.

## Usage

```
/research-clone-bootstrap https://www.raycast.com/
/research-clone-bootstrap https://github.com/ianyh/amethyst
/research-clone-bootstrap https://www.raycast.com/ --slug raycast
```

## Slug vs product name

- **`--slug`** = lab folder / workspace id (usually from the seed: `raycast`, `amethyst`). **Not** the shipped product name.
- **Product name** is brainstormed every run in `product/research/NAMING.md` (GitHub + `.com`/`.app` namespace checks), even if you already have a favorite.

## Implementation

1. Read and follow this skill's `SKILL.md` (installed under `~/.cursor/skills/research-clone-bootstrap/` or via `npx skills`)
2. Run:

```bash
# Prefer the installed skill path
"$(dirname "$(readlink -f ~/.cursor/skills/research-clone-bootstrap/SKILL.md 2>/dev/null || echo ~/.cursor/skills/research-clone-bootstrap/SKILL.md)")"/scripts/bootstrap.sh '<SEED_URL>' [--slug SLUG] [--root DIR]
# Or, from a clone of this repo:
./scripts/bootstrap.sh '<SEED_URL>' [--slug SLUG] [--root DIR]
```

Default root: `~/tools/macosx-tools/labs/<slug>/`

3. Complete landscape phases in the skill checklist:
   - SEARCH_TERMS → **dual search (Parallel CLI + Exa)** → SEARCH_COMPARE
   - **NAMING.md** (brainstorm + namespace)
   - alternatives-matrix → package PRDs → SUPER_PRD → `peers/sync.sh`
4. Tell the user which workspace to open:
   - **Product:** `labs/<slug>/product/<slug>.code-workspace`
   - **Research:** `labs/<slug>/peers/<slug>-research.code-workspace`
5. Do **not** index `peers/clones` into the product workspace
6. Stop until user picks SUPER_PRD scope **and** a naming shortlist pick

## Search engines

Use **both** by default on the same core queries; archive under `product/research/search-archives/`.

| Engine | Invocation |
|--------|------------|
| Parallel | `parallel-cli search "…" -q "…" --json -o search-archives/parallel-….json` |
| Exa | MCP `web_search_exa` / `web_fetch_exa` |

Merge hits in `SEARCH_COMPARE.md` before writing the matrix.

## Examples

| Seed | Intent |
|------|--------|
| `https://www.raycast.com/` | Fully OSS Raycast-like launcher landscape |
| `https://github.com/ianyh/amethyst` | Tiling WM peers + your fork/product |
| Jumpkey precedent | `apps/jumpkey` + `research-clones/` (first manual instance) |
