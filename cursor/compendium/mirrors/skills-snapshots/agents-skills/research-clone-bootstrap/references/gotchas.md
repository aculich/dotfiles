# Gotchas

- **Huge monorepos:** Do not shallow-clone pathological trees (e.g. `raycast/extensions`) by default — note “browse on GitHub” in the matrix.
- **Slug ≠ product name:** `--slug` is the lab folder only. Trademark risk if shipping under the seed brand.
- **Product workspace pollution:** Never add `peers/clones` as a folder in the product `.code-workspace`.
- **License forks:** GPL/AGPL peers are pattern-only unless the product intentionally goes copyleft.
- **Dual search:** Exa often wins GitHub peer breadth; Parallel often wins community/product-site context. Matrix = **union**.
- **bootstrap.sh path:** Run from the skill package `scripts/bootstrap.sh`, not a hardcoded `~/.cursor/skills/...` path after install via `npx skills`.
- **Existing lab:** `bootstrap.sh` exits 0 without overwriting if `labs/<slug>/` already exists.
