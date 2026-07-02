# Lock files and stack signals

The perks skill scans these files to infer dependencies, ecosystems, and vendors.

## JavaScript / TypeScript lock files

| File | Package manager |
|------|-----------------|
| `package-lock.json` | npm |
| `yarn.lock` | Yarn Classic |
| `pnpm-lock.yaml` | pnpm |
| `bun.lock` / `bun.lockb` | Bun |

## Other ecosystem lock files

| File | Ecosystem |
|------|-----------|
| `Cargo.lock` | Rust |
| `poetry.lock`, `uv.lock`, `Pipfile.lock` | Python |
| `Gemfile.lock` | Ruby |
| `composer.lock` | PHP |
| `go.sum` | Go (with `go.mod`) |
| `mix.lock` | Elixir |
| `pubspec.lock` | Dart / Flutter |
| `Package.resolved` | Swift |
| `packages.lock.json` | .NET |

## Manifest files (when no lock file)

`package.json`, `pyproject.toml`, `requirements.txt`, `Cargo.toml`, `go.mod`, `Gemfile`, `composer.json`, `pubspec.yaml`

## Config / infra signals

| File / pattern | Inferred signal |
|----------------|-----------------|
| `vercel.json` | Vercel hosting |
| `netlify.toml` | Netlify |
| `firebase.json` | Google Cloud / Firebase |
| `serverless.yml` | AWS Serverless |
| `fly.toml` | Fly.io |
| `railway.json` | Railway |
| `terraform/**/*.tf` | IaC / cloud |
| `.github/workflows/*` | CI/CD |
| `Dockerfile*` | Container deployment |

Directories skipped during scan: `node_modules`, `.git`, `vendor`, `dist`, `build`, `.next`, `.astro`, `target`, `__pycache__`, `.venv`, `venv`.
