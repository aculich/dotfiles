# Stack → MakerPerks tag mapping

Tags on MakerPerks programs are free-form strings (e.g. `cloud`, `ai`, `dev tools`). The scan step infers tags from dependencies and config; match-perks uses tag overlap for tier-2 matches.

## Framework / runtime signals

| Signal | Tags |
|--------|------|
| `next`, `nuxt`, `remix`, `astro`, `sveltekit` | `dev tools`, `cloud` |
| `react`, `vue`, `svelte`, `angular` | `dev tools` |
| `django`, `fastapi`, `flask` | `dev tools`, `api` |
| `rails` | `dev tools` |
| `electron` | `dev tools` |

## Category signals

| Signal | Tags |
|--------|------|
| `@aws-sdk`, `aws-sdk`, `serverless` | `cloud` |
| `@google-cloud`, `firebase` | `cloud`, `ai` |
| `@azure` | `cloud` |
| `openai`, `@anthropic-ai`, `langchain`, `@google/generative-ai` | `ai`, `llm` |
| `@sentry`, `datadog`, `posthog`, `amplitude`, `mixpanel` | `dev tools`, `analytics` |
| `stripe` | `fintech`, `payments` |
| `@temporalio` | `dev tools`, `automation` |
| `hardhat`, `ethers`, `web3`, `@alchemy` | `web3` |
| `@pulumi`, `terraform` | `iac`, `devops` |
| `prisma`, `drizzle-orm`, `typeorm` | `dev tools`, `data` |
| `algoliasearch`, `@pinecone-database` | `ai`, `search` |

## Config signals

| Config file | Tags |
|-------------|------|
| `vercel.json` | `cloud`, `hosting` |
| `terraform/**` | `cloud`, `iac` |
| `.github/workflows/**` | `ci/cd`, `devops` |
