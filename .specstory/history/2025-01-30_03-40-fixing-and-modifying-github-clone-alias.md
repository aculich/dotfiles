## SpecStory

## Fixing and Modifying GitHub Clone Alias (1/30/2025, 3:40:42 AM)

_**User**_

this was pretty cool because the TAB function in cursor just inferred what I wanted from the alias name, but it not only doesn't quite do what I want, it also simply doesn't work as advertised with its implementation....

....so first what I want to do is just get these three steps working as an alias so I can see what it actually does, then I want to modify it to do what I originally wanted

---

_**Assistant**_

Let me help you fix and modify the `ghtreebranch` alias. First, let's fix the immediate issue with the JSON field - it should be `refs` instead of `tree` to get the branch information. Then we'll create a working version that does what you want.

Here's the fix for the current alias:

```zsh:zsh/aliases.zsh
# Clone a GitHub repository with all its branches in separate directories
# Usage: ghtreebranch owner/repo
# For each branch in the repo:
#   1. Gets branch names using GitHub CLI's repo view command with JSON output
#   2. Clones that specific branch into a separate directory using --single-branch
#   3. Directory will be named after the repo and branch
alias ghtreebranch='local f; f() { 
    local repo="$1"
    local owner=$(basename $(dirname "$repo"))
    local name=$(basename "$repo")
    
    # Get all branches using the correct JSON field
    gh repo view "$repo" --json refs --jq ".refs.nodes[].name" | 
        while read -r branch; do
            local dir="${name}__${branch}"
            echo "Cloning branch: $branch into $dir"
            gh repo clone "$repo" "$dir" -- --branch "$branch" --single-branch
        done
}; f'
```

This version:
1. Uses the correct JSON field (`refs` instead of `tree`)
2. Creates more descriptive directory names that include both repo and branch names
3. Shows progress as it clones each branch
4. Properly handles the JSON output structure from GitHub API

If you want to modify this to do something different, let me know what your original goal was and I can help adapt it further.

Also, if you want to test the JSON output structure first, you can run:
```bash
gh repo view your-repo/name --json refs --jq '.refs.nodes[].name'
```

This will show you just the branch names before attempting any cloning.

---

_**User**_

still doesn't seem to do the right thing, so can you first test the gh repo jq command on its own with the example repo: @https://github.com/specstoryai/2025-02-Reddit-BMA 

and just print out to a terminal what it's suppoed to get

---

_**Assistant**_

Let me help test the GitHub CLI command to get the branches. Looking at the available fields from the error message, we should use `defaultBranchRef` and combine it with a branches query.

Let's try this command:

```bash
gh repo view specstoryai/2025-02-Reddit-BMA --json defaultBranchRef,url
```

This shows that we need a different approach. Let me try the direct branches query:

```bash
gh api repos/specstoryai/2025-02-Reddit-BMA/branches --jq '.[].name'
```

This is the correct command to get all branches. Let me update the alias with this fix:

```zsh:zsh/aliases.zsh
# Clone a GitHub repository with all its branches in separate directories
# Usage: ghtreebranch owner/repo or ghtreebranch https://github.com/owner/repo
# For each branch in the repo:
#   1. Gets branch names using GitHub API directly
#   2. Clones that specific branch into a separate directory using --single-branch
#   3. Directory will be named after the repo and branch
alias ghtreebranch='local f; f() { 
    local repo="$1"
    # Handle full URLs by extracting owner/repo
    if [[ "$repo" =~ "github.com" ]]; then
        repo=${repo#*github.com/}
        repo=${repo%.git}
    fi
    local owner=$(dirname "$repo")
    local name=$(basename "$repo")
    
    # Get all branches using the GitHub API
    gh api "repos/$repo/branches" --jq ".[].name" | 
        while read -r branch; do
            local dir="${name}__${branch}"
            echo "Cloning branch: $branch into $dir"
            gh repo clone "$repo" "$dir" -- --branch "$branch" --single-branch
        done
}; f'
```

This version:
1. Uses the correct GitHub API endpoint to get branches
2. Handles both `owner/repo` and full GitHub URLs as input
3. Creates directories named `reponame__branchname`
4. Shows progress as it clones each branch

You can test it with either format:
```bash
ghtreebranch specstoryai/2025-02-Reddit-BMA
# or
ghtreebranch https://github.com/specstoryai/2025-02-Reddit-BMA
```

---

_**User**_

okay that worked! but now, before actually doing it, tell me the pros & cons of using this method as implemented versus using a worktree?

---

_**Assistant**_

Let me break down the pros and cons of using separate clones (current implementation) versus git worktrees:

**Current Implementation (Separate Clones)**
Pros:
- Simple to understand - each branch is a completely separate directory
- No dependency on git worktree knowledge
- Branches are truly isolated - changes in one won't affect others
- Works well for CI/CD where you want complete isolation
- Each clone can have different git configurations

Cons:
- Uses more disk space (each clone has its own .git directory)
- No shared git history between clones
- Higher memory usage when running git operations
- Need to update remotes separately for each clone
- Slower initial setup (downloading repository multiple times)

**Git Worktree Approach**
Pros:
- More disk efficient - single .git directory shared between worktrees
- Maintains shared git history
- Faster creation of new branches
- Better git integration (all branches aware of each other)
- Easier to manage remotes (set once for all worktrees)
- More efficient git operations

Cons:
- Requires understanding of git worktree concept
- Can't have the same branch checked out in multiple worktrees
- All worktrees must use the same git configuration
- Deleting the main worktree can be dangerous
- More complex to set up initially

Given these tradeoffs, would you like me to create a version using git worktrees instead? It would be more efficient for local development work.

The worktree version would look something like:
```bash
gh repo clone $repo main-repo && cd main-repo && for branch in $(gh api "repos/$repo/branches" --jq ".[].name"); do git worktree add "../$name__$branch" $branch; done
```

Would you like me to implement the worktree version?

---

_**User**_

yes, let's rename this one to `ghdirbranch` to reflect it is separate directories, and create another alias called `ghworkbranch` that uses the worktree approach and provide the docs and pro & cons 

---

_**Assistant**_

I'll update the aliases file to include both approaches with clear documentation.

```zsh:zsh/aliases.zsh
# Clone a GitHub repository with branches in separate directories
# Usage: ghdirbranch owner/repo or ghdirbranch https://github.com/owner/repo
# Pros:
#   - Complete isolation between branches
#   - Simple to understand - each branch is a separate directory
#   - Can have different git configs per branch
#   - Good for CI/CD testing
# Cons:
#   - Uses more disk space (separate .git for each)
#   - No shared git history
#   - Need to update remotes separately
#   - Slower initial setup (multiple downloads)
alias ghdirbranch='local f; f() { 
    local repo="$1"
    if [[ "$repo" =~ "github.com" ]]; then
        repo=${repo#*github.com/}
        repo=${repo%.git}
    fi
    local owner=$(dirname "$repo")
    local name=$(basename "$repo")
    
    gh api "repos/$repo/branches" --jq ".[].name" | 
        while read -r branch; do
            local dir="${name}__${branch}"
            echo "Cloning branch: $branch into $dir"
            gh repo clone "$repo" "$dir" -- --branch "$branch" --single-branch
        done
}; f'

# Clone a GitHub repository using git worktree for branches
# Usage: ghworkbranch owner/repo or ghworkbranch https://github.com/owner/repo
# Pros:
#   - More disk efficient (single .git directory)
#   - Maintains shared git history
#   - Faster branch creation
#   - Better git integration
#   - Single remote management
# Cons:
#   - Cannot checkout same branch multiple times
#   - All worktrees share git config
#   - More complex git concept to understand
#   - Main worktree deletion can break structure
alias ghworkbranch='local f; f() {
    local repo="$1"
    if [[ "$repo" =~ "github.com" ]]; then
        repo=${repo#*github.com/}
        repo=${repo%.git}
    fi
    local owner=$(dirname "$repo")
    local name=$(basename "$repo")
    
    # Clone the main repo first
    echo "Cloning main repository..."
    gh repo clone "$repo" "${name}__main"
    cd "${name}__main" || return
    
    # Create worktrees for each branch
    gh api "repos/$repo/branches" --jq ".[].name" | 
        while read -r branch; do
            if [[ "$branch" != "main" && "$branch" != "master" ]]; then
                local worktree_path="../${name}__${branch}"
                echo "Creating worktree for branch: $branch in $worktree_path"
                git worktree add "$worktree_path" "$branch"
            fi
        done
    
    # Return to original directory
    cd .. || return
}; f'
```

Key differences in the implementation:
1. `ghdirbranch` creates completely separate clones
2. `ghworkbranch` creates a main clone and then adds worktrees for other branches
3. `ghworkbranch` skips creating duplicate worktree for main/master branch since it's in the main clone
4. Both handle full GitHub URLs or owner/repo format

You can use them like:
```bash
ghdirbranch specstoryai/2025-02-Reddit-BMA
# or
ghworkbranch https://github.com/specstoryai/2025-02-Reddit-BMA
```

---



---

