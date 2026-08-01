---
name: bootstrap-aar
description: Write an After Action Report for a tool-quickstart metarepo bootstrap or SideQuest/WorkHorse regen. Use when the user runs /bootstrap-aar, asks for an AAR, after-action report, regen retrospective, or handoff writeup after phases B–D–R.
---

# Bootstrap AAR

Produce a durable After Action Report for a metarepo bootstrap / regen, commit it, and publish GitHub Issue + Discussions (and update the regen PR).

## When to run

- End of SideQuest or WorkHorse regen (`regen/*`)
- After a blocked-then-recovered bootstrap (Xcode, doctor, TCC, etc.)
- User invokes `/bootstrap-aar` or asks for an AAR / retrospective / WH handoff package

## Inputs (gather if missing)

1. Laptop role: SideQuest | WorkHorse | singleton
2. Branch tip + base (`main` / peer regen branch)
3. Open PR number(s) and related issues
4. What was expected vs what broke
5. Proof notes (install path, dictation, flavors)

## Workflow

Copy and track:

```
AAR Progress:
- [ ] 1. Inventory repo + local state
- [ ] 2. Draft AAR markdown
- [ ] 3. Commit on current regen branch
- [ ] 4. GitHub Issue
- [ ] 5. GitHub Discussions (enable if needed)
- [ ] 6. Update regen PR body + comment with links
- [ ] 7. Point COMPARE_REGEN / PLAYBOOK at the AAR if useful
```

### 1. Inventory

Run in the metarepo root:

```bash
git status -sb
git log --oneline -15
git fetch origin
git rev-parse --short HEAD
just status 2>/dev/null || true
just doctor 2>/dev/null || true
```

Note gitignored trees (`upstream/`, `forks/`), installed apps, pin files, and whether `runtime.justfile` / `xcode-ready` exist.

Peer compare (when both remotes exist):

```bash
git diff --stat origin/regen/workhorse...origin/regen/sidequest
```

### 2. Draft AAR

Write `dossier/AAR-YYYY-MM-DD-<role>.md` (UTC or local date; role = `sidequest` | `workhorse` | `bootstrap`).

Required sections (use these headings):

1. **Expected at the outset**
2. **What we see in the repo** (committed vs gitignored vs private remotes)
3. **Session narrative** (timeline table)
4. **What we discovered**
5. **What we fixed / generated**
6. **Key outputs and outcomes** (+ residual risks)
7. **Commands for the peer laptop / reviewer**
8. **Chat-history index** (topic bullets, not a full transcript dump)

Template and VoiceInk example: [reference.md](reference.md).

Keep the AAR under ~400 lines. Link SIDEQUEST Lessons, COMPARE_REGEN, PLAYBOOK, PRAXIS instead of duplicating.

### 3. Commit

On the active regen branch (do not commit secrets / `.env`):

```bash
git add dossier/AAR-*.md .cursor/skills/bootstrap-aar .cursor/commands/bootstrap-aar.md
git commit -m "$(cat <<'EOF'
Add bootstrap AAR and /bootstrap-aar skill.

EOF
)"
git push -u origin HEAD
```

Only commit when the user wants the AAR on the remote (default: yes for regen handoff).

### 4. GitHub Issue

```bash
gh issue create --title "AAR: <role> regen YYYY-MM-DD" --body "$(cat <<'EOF'
## AAR
Link: dossier/AAR-….md on branch `<branch>` (blob URL after push).

## Peer ask
WorkHorse/SideQuest: review COMPARE_REGEN + this AAR; decide merge to main.

## Related
- PR #N
- Prior issues
EOF
)"
```

### 5. GitHub Discussions

If Discussions disabled:

```bash
gh api repos/:owner/:repo -X PATCH -f has_discussions=true
```

Fetch category IDs:

```bash
gh api graphql -f query='query($o:String!,$n:String!){
  repository(owner:$o,name:$n){
    id
    discussionCategories(first:20){nodes{id name slug}}
  }
}' -f o=OWNER -f n=REPO
```

Create **2–3** threads (not one mega-thread):

| Category | Topic |
|----------|--------|
| Show and tell | Full AAR summary + links |
| Q&A | Sticky failure mode (e.g. Xcode first-launch, doctor/ensure-upstream) |
| Ideas (optional) | Merge/cherry-pick asks for the peer laptop |

Mutation:

```bash
gh api graphql -f query='mutation($id:ID!,$cat:ID!,$title:String!,$body:String!){
  createDiscussion(input:{repositoryId:$id,categoryId:$cat,title:$title,body:$body}){
    discussion{url}
  }
}' -f id=REPO_NODE_ID -f cat=CATEGORY_ID -f title='...' -f body='...'
```

### 6. Update PR

Edit the regen PR body: link AAR path, issue, discussion URLs. Add a short PR comment with the same links.

### 7. VoiceInk-specific checks (this metarepo)

When slug is VoiceInk / LOCAL_BUILD:

- Record `just xcode-ready` / first-launch status if build was blocked
- Note codesign: Apple Development vs ad-hoc + TCC risk
- Note FluidAudio models are **shared** under `~/Library/Application Support/FluidAudio/Models/`; prefs are per bundle
- Soft-fork branding lives on `voiceink-personal` / `voiceink-team` remotes, not only the metarepo

## Do not

- Dump the entire chat transcript into the AAR (use the index + timeline)
- Commit `upstream/`, `forks/`, or Application Support trees
- Force-push or merge to `main` unless the user asks
- Create Discussions spam — prefer ≤3 focused threads

## Done when

- AAR file committed + pushed
- Issue + ≥1 Discussion exist with links
- Regen PR references the AAR
- User receives the URLs in the reply


## Definition of done (required in AAR outcomes)

Do **not** claim bootstrap/regen success if any of these are missing:

1. `runtime.justfile` with recipe `runtime-doit`
2. `just status` shows forks OK (or `WITHOUT_TEAM=1` and team intentionally skipped)
3. Upstream install path works via `just doit` (brew and/or LOCAL_BUILD)

Markdown-only Phase C/D is **not** done.
