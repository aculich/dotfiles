# SIDEQUEST — optional dual-laptop regen

**Optional.** Standard bootstrap is singleton on one laptop. Use this only for generate-and-compare experiments, or invoke `/bootstrap-regen [stage]`.

Prefer annotated tags (`just tag-phase A|B|C|D|R` → `metarepo/phase-*-done`) so the second laptop can fork from a known stage, not only from current `main` tip.

## Prereqs

- `git`, `just`, `gh` (`gh auth login` — private personal/team access)
- Tags pushed from the inception laptop
- OpenOats Upstream: Homebrew; VoiceInk LOCAL_BUILD: Xcode (`just xcode-ready`)

## Per metarepo

```bash
git clone git@github.com:aculich/<slug>-metarepo.git ~/tools/<slug>-metarepo
cd ~/tools/<slug>-metarepo
git fetch origin --tags
git checkout main && git pull --ff-only origin main

# Preferred: start from a phase tag (default A)
git checkout -b regen/sidequest metarepo/phase-A-done
# Or from a later stage: metarepo/phase-C-done etc.

# Confirm envelope:
rg -n "import\\?|runtime-doit|tr ' '" justfile

just phase B   # or continue from chosen stage
# … through R; prove PRAXIS; /bootstrap-aar; push
```

If `regen/sidequest` already exists and predates envelope fixes: `git merge origin/main` before continuing.

Slugs: `openoats-metarepo`, `voiceink-metarepo`.

## Compare

Fill [COMPARE_REGEN.md](COMPARE_REGEN.md) using  
`git diff --stat origin/regen/workhorse...origin/regen/sidequest` (or whatever laptop names you used).
