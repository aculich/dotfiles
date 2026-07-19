# Exclude globs (gitleaks config)

Use with: `gitleaks dir -c exclude-globs.toml …`

```toml
title = "hot-livewires exclude build caches"

[allowlist]
description = "Regenerable build/tooling caches — never the secret home"
paths = [
  '''(^|/)\.git/''',
  '''(^|/)target/''',
  '''(^|/)\.devbox/''',
  '''(^|/)node_modules/''',
  '''(^|/)\.next/''',
  '''(^|/)dist/''',
  '''(^|/)build/''',
  '''(^|/)vendor/bundle/''',
  '''(^|/)\.venv/''',
  '''(^|/)__pycache__/''',
]
```

For trufflehog on multi-GB trees, scan source subtrees (`api/`, `web/src/`, wrapper root) instead of the whole tree including `target/`.
