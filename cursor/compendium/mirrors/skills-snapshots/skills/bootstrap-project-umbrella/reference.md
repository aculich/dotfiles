# bootstrap-project-umbrella — reference

## Paths

| Piece | Path |
|-------|------|
| Meta root | `~/projects/<slug>/` |
| Workspace | `~/projects/workspaces/<slug>.code-workspace` |
| Analytics | `~/.local/share/aallc-orbit/skill-usage.jsonl` |
| Templates | `templates/` beside this file |

Nested lane dirs are **independent git repos**, gitignored from the meta repo (catalog style). Meta tracks coordination only.

## House topic

**`aallc-orbit`** — apply to every repo this skill creates. Filters our incepted umbrellas on GitHub.

| Role | Topics |
|------|--------|
| Meta | `aallc-orbit`, `meta-umbrella`, `cursor-multiroot`, `justfile` |
| inquiry | `aallc-orbit`, `inquiry`, `landscape-scout`, `little-r-research` |
| product | `aallc-orbit`, `prd`, `superprd`, `product-spec` |
| studies | `aallc-orbit`, `studies`, `capital-r-research`, `academic` |
| apps (when remoted) | `aallc-orbit`, `application`, `monorepo` |

```bash
OWNER="${GH_OWNER:-aculich}"
gh repo create "$OWNER/<name>" --private --source=. --remote=origin --push
gh repo edit "$OWNER/<name>" --add-topic aallc-orbit --add-topic <more...>
```

Default owner: `aculich` unless user overrides.

## Repo naming

| Local | GitHub name |
|-------|-------------|
| `~/projects/<slug>` | `<slug>` |
| `…/inquiry` | `<slug>-inquiry` |
| `…/product` | `<slug>-product` |
| `…/studies` | `<slug>-studies` |

## Meta `.gitignore` (lanes)

```gitignore
inquiry/
product/
studies/
# apps/ tracked as stub until it gets its own remote; then ignore apps/* packages if nested remotes
```

Track `apps/README.md` in meta until `apps/` becomes its own repo.

## Multiroot workspace

```json
{
  "folders": [
    { "name": "<slug> (meta)", "path": "../<slug>" },
    { "name": "inquiry", "path": "../<slug>/inquiry" },
    { "name": "product", "path": "../<slug>/product" },
    { "name": "studies", "path": "../<slug>/studies" }
  ],
  "settings": {
    "files.exclude": { "**/node_modules": true, "**/.venv": true }
  }
}
```

Paths are relative to `~/projects/workspaces/`.

## Justfile fan-out

Never bare `cd` then `just`. Prefer:

```bash
just --justfile inquiry/justfile --working-directory inquiry status
```

See `templates/meta.justfile` and `templates/child.justfile`.

## Envisioning hook

1. Prefer `envisioning-skills-suite` → write `.context/intent.md`.
2. Or gstack `/office-hours` if installed → copy approved design into `.context/`.
3. Or user skip with prior art recorded in intent.

Install suite: `~/projects/envisioning-skills-suite/docs/INSTALL.md` or https://github.com/aculich/envisioning-skills-suite

## gstack patterns we adopt (not clone)

Canonical upstream: https://github.com/garrytan/gstack  
Local mirror (if present): `~/tools/skills-quickstart/upstream/gstack__garrytan`

Adopt: sprint chain, hard gate, AskUserQuestion format, completeness, in-repo artifact lineage, optional review checklists.  
Reject: Bun browse daemon vendoring, multi-root skill duplication, SKILL.md.tmpl codegen for v1.

## ADR stubs to write in meta

1. `001-inquiry-vs-studies.md` — little-r vs capital-R naming
2. `002-apps-monorepo-when.md` — when apps becomes inner monorepo
3. `003-github-topics.md` — aallc-orbit + lane topics

## Analytics line (apply)

```bash
mkdir -p ~/.local/share/aallc-orbit
echo '{"skill":"bootstrap-project-umbrella","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","slug":"<slug>"}' \
  >> ~/.local/share/aallc-orbit/skill-usage.jsonl
```
