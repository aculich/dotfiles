<!-- Merge into repo-root README.md (umbrella client repos).
     Fill Track labels from .context/engagements.md (label field).
     Last activity: ISO YYYY-MM-DD from conventions.md sourcing rules.
     Status: Active / Recent / Quiet from workspace_activity_*_days.
-->

## Workspace activity

**Repo last update:** YYYY-MM-DD (set to **today** whenever any row below changes.)

_Status — **Active** = last touch within **active_days**; **Recent** = within **recent_days** but not Active; **Quiet** = older than **recent_days**. Copy the numeric thresholds from **`.context/conventions.md`** (*Workspace activity*) into this italic line when bootstrapping._

| Track | Scope | Last activity | Status |
|-------|--------|----------------|--------|
| Umbrella incoming | `incoming/` | YYYY-MM-DD | Active |
| _One row per `slug` in `.context/engagements.md` — use `label` in Track column_ | `engagements/<slug>/` | YYYY-MM-DD | Active |
| Client context | `.context/` | YYYY-MM-DD | Active |
| Programs | `programs/` | YYYY-MM-DD | Active |
| Procurement | `procurement/` | YYYY-MM-DD | Active |
| Client-shared | `client-shared/` | YYYY-MM-DD | Active |
| Compliance | `compliance/` | YYYY-MM-DD | Active |
| Partners | `partners/` | YYYY-MM-DD | Active |
| Tools | `tools/` | YYYY-MM-DD | Active |

_Add or remove directory rows so the table mirrors the repo’s “where things live” map; keep one row per engagement slug in **`.context/engagements.md`**._
