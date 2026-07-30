# SIDEQUEST — regenerate on a second laptop

Same phase oracle as WorkHorse after `git pull origin main`. Use branch **`regen/sidequest`**. No `*-quickstart` trees required.

## Prereqs

- `git`, `just`, `gh` (`gh auth login` — private personal/team access)
- OpenOats Upstream: Homebrew
- VoiceInk LOCAL_BUILD: Xcode + Apple Development cert for your Apple ID

## Per metarepo

```bash
git clone git@github.com:aculich/<slug>-metarepo.git ~/tools/<slug>-metarepo
cd ~/tools/<slug>-metarepo
git pull origin main
git checkout -b regen/sidequest

just phase B
just phase C          # paste brief into Cursor; agent writes dossier+PRD
just scaffold-lineages
just phase D          # FORKS + PLAYBOOK
just scaffold-runtime
just phase R          # agent: runtime recipes + flavors + install
just bootstrap-machine

# prove one key function (PRAXIS)
git add -A
git commit -m "regen/sidequest: phases B-D-R"
git push -u origin regen/sidequest
```

Slugs: `openoats-metarepo`, `voiceink-metarepo`.

## Compare

On either laptop: fill [COMPARE_REGEN.md](COMPARE_REGEN.md) using  
`git diff --stat origin/regen/workhorse...origin/regen/sidequest`.
