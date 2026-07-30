# Reference — VoiceInk exemplar

Quickstart metarepo: `~/tools/voiceink-quickstart`

## Repos

| Lineage | GitHub | Local |
|---------|--------|-------|
| Upstream pin | Beingpax/VoiceInk (fetch-only) | `upstream/Beingpax__VoiceInk` |
| Public GitHub fork | aculich/VoiceInk | `forks/public` |
| Personal private fork | aculich/voiceink-personal (private) | `forks/personal` |
| Team private fork | aculich/voiceink-team (private) | `forks/team` |

## Bundle / install matrix

| Lineage | Display | Bundle ID | Path |
|---------|---------|-----------|------|
| Upstream | VoiceInk | `com.prakashjoshipax.VoiceInk` | `/Applications/VoiceInk.app` |
| Personal | VoiceInk Personal | `io.github.aculich.VoiceInkPersonal` | `/Applications/VoiceInk Personal.app` |
| Team | VoiceInk Team | `io.github.aculich.VoiceInkTeam` | `/Applications/VoiceInk Team.app` |

## Flavor xcconfigs

Templates in quickstart `overlays/`; committed into private forks as:

- `forks/personal/PersonalBuild.xcconfig` (`#include "LocalBuild.xcconfig"`)
- `forks/team/TeamBuild.xcconfig`

Override bundle id + `INFOPLIST_KEY_CFBundleDisplayName` only. Keep `PRODUCT_NAME=VoiceInk` (spaces break SPM resource bundles). `just install-flavor` copies `VoiceInk.app` → `/Applications/VoiceInk Personal.app` (or Team).

Build via control plane: `just build-flavor personal|team` (xcodebuild `-xcconfig`, LOCAL_BUILD from included LocalBuild.xcconfig, ad-hoc then re-sign Apple Development).

## Key recipes

| Recipe | Role |
|--------|------|
| `just refresh-lineage` | Fetch + sync public + analyze private forks → `LINEAGE_STATUS.json` |
| `just watch-upstream` | Branches + tags + releases + appcast vs pin |
| `just sync-upstream` / `use-upstream` | Preferred; aliases `sync-local` / `use-local` |
| `just quit-voiceink-all` | Quit all VoiceInk* |
| `just scaffold-forks` | Idempotent clone/remotes |
| `just dev-personal` / `dev-team` | Build → install → launch flavor |
| `just release-team` | DMG under `background/team-releases/` + draft GH release |

## Codesign

- Identity: `Apple Development: aculich@gmail.com (JW5PY3LJQ3)`
- Reject Upstream commercial team: `V6J6A3VWY2`
- Team v1: Apple Development + Gatekeeper right-click Open (no notarization)

## Docs

- [FORKS.md](file:///Users/me/tools/voiceink-quickstart/FORKS.md)
- [GLOSSARY.md](file:///Users/me/tools/voiceink-quickstart/GLOSSARY.md)
- [READING.md](file:///Users/me/tools/voiceink-quickstart/READING.md)
- [TOOLBOX.md](file:///Users/me/tools/voiceink-quickstart/TOOLBOX.md)
- [PRAXIS.md](file:///Users/me/tools/voiceink-quickstart/PRAXIS.md)
- [TEAM_INSTALL.md](file:///Users/me/tools/voiceink-quickstart/background/TEAM_INSTALL.md)

## Upstream release tooling

Beingpax `main` (PR #847): `make release` / `scripts/release.sh` — Developer ID, notarize, DMG, Sparkle appcast; does not tag/publish. Private forks study then adapt; Team v1 uses simpler `release-team`.
