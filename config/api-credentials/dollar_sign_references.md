# Dollar-Sign Variable References Report

This document lists all API Credentials that have values starting with a dollar sign (`$`), indicating they are variable references to other credentials.

## Found References

| Credential Name | Current Value | References |
|----------------|---------------|------------|
| `ANTHROPIC_API_KEY` | `$CLAUDE_API_KEY` | References the CLAUDE_API_KEY credential |
| `NOTION_API_KEY` | `\$NOTION_TOKEN` | References the NOTION_TOKEN credential |
| `NOTION_INTEGRATION_TOKEN` | `\$NOTION_TOKEN` | References the NOTION_TOKEN credential |
| `PERPLEXITY_API_KEY` | `\$PERPLEXITY_API_KEY_CRB` | References the PERPLEXITY_API_KEY_CRB credential |
| `PPLX_API_KEY` | `\$PERPLEXITY_API_KEY` | References the PERPLEXITY_API_KEY credential |

## Notes

- These are environment variable-style references that may be used for aliasing or environment variable expansion
- The referenced credentials exist in the vault and contain the actual API key values
- These references are left as-is per the plan (not resolved to actual values)

## Total Count

**5 credentials** out of 81 have dollar-sign variable references.

