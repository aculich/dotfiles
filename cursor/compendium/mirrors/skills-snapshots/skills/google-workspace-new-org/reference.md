# OfficialsPay → Emerging Patterns diff

Use when cloning org wiring.

| OfficialsPay | Emerging Patterns |
|--------------|-------------------|
| `officialspay.com` | `emergingpatterns.ai` |
| `admin@officialspay.com` | `admin@emergingpatterns.ai` |
| Vault `OfficialsPay` | Vault `emergingpatterns.ai` |
| Namecheap DNS | DNSimple DNS |
| Firebase webapp only | Render runtime + Firebase `emergingpatterns-prod` |

## sed template for setup-check

Run replacements **longest-first** (domain before slug) to avoid `admin@emergingpatterns.com`:

```bash
sed -e 's/OfficialsPay/Emerging Patterns/g' \
    -e 's/officialspay-admin/emergingpatterns-admin/g' \
    -e 's/admin@officialspay.com/admin@emergingpatterns.ai/g' \
    -e 's/officialspay.com/emergingpatterns.ai/g' \
    -e 's/officialspay/emergingpatterns/g' \
    officialspay-setup-check.sh > emergingpatterns-setup-check.sh
```

## 1Password field layout (Render item)

- `service hostname` — DNS ALIAS target
- `credential` — API token (convention)
- `username` — service id (optional)
