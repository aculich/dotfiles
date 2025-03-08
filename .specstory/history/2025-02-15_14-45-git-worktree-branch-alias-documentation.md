## SpecStory

## Git Worktree Branch Alias Documentation (2/15/2025, 2:45:11 PM)

_**User**_

describe and document what this does

---

_**Assistant**_

I'll analyze and document the `gwtb` (git worktree branch) alias function. Here's a detailed explanation:

# Git Worktree Branch Alias Documentation

The `gwtb` alias creates a new git worktree for a specified branch in a sibling directory. This is useful for working on multiple branches simultaneously without switching branches in your main working directory.

## Syntax

```zsh
gwtb [branch_name] [base_directory_name]
```

## Parameters

- `branch_name` (optional): The branch to create a worktree for. Defaults to current branch if not specified.
- `base_directory_name` (optional): Base name for the new directory. Defaults to current directory name if not specified.

## How it Works

1. The function creates a new worktree directory named `{base_dir}__{branch}`
2. The new directory is created as a sibling to the current directory (using `../`)
3. The specified branch is checked out in the new worktree

## Examples

```bash
# In directory "myproject", on branch "feature/login"
gwtb                           # Creates ../myproject__feature/login

# Specify branch explicitly
gwtb feature/signup           # Creates ../myproject__feature/signup

# Specify both branch and base directory name
gwtb feature/auth webapp      # Creates ../webapp__feature/auth
```

## Benefits

- Work on multiple branches simultaneously
- Each branch gets its own working directory
- Avoid constant branch switching
- Keep separate build artifacts for different branches
- Ideal for reviewing PRs or working on multiple features

## Related Commands

- `git worktree list` - Show all worktrees
- `git worktree remove` - Remove a worktree
- `git worktree prune` - Cleanup stale worktree administrative files

---

_**User**_

if the branch name has a slash in it translate it to _

---

_**Assistant**_

I'll modify the `gwtb` alias to translate slashes in branch names to underscores. This will prevent issues with directory creation and make the paths cleaner.

```zsh:zsh/aliases.zsh
// ... existing code ...
alias gwtb='local f; f() {
    local branch="${1:-$(current_branch)}"
    local base_dir="${2:-${PWD:t}}"
    # Replace slashes with underscores in branch name
    local safe_branch="${branch//\//_}"
    git worktree add "../${base_dir}__${safe_branch}" "${branch}"
}; f'
// ... existing code ...
```

This updated version:

1. Captures the branch name as before
2. Creates a `safe_branch` variable where all `/` are replaced with `_`
3. Uses the `safe_branch` for directory naming but the original `branch` for git operations

## Examples

```bash
# Before:
gwtb feature/login     # Created: ../myproject__feature/login

# After:
gwtb feature/login     # Creates: ../myproject__feature_login
gwtb bug/fix/123      # Creates: ../myproject__bug_fix_123
```

This change makes the worktree directories easier to work with in the shell and avoids potential issues with nested directory creation.

---

_**User**_

we can't use the current branch unles.... maybe we can "uncheck" it out and turn it into a bare repository and then what was the current branch we can use in a worktree?

also, when i tried feature and feature/upgrade as a new branch name, neither of those worked

---

_**Assistant**_

Let me help with both issues. First, for creating new branches with worktrees, we need to add the `-b` flag. Second, for handling the current branch, we can indeed convert to a bare repository approach.

Here's the improved version:

```zsh:zsh/aliases.zsh
alias gwtb='local f; f() {
    local branch="${1:-$(current_branch)}"
    local base_dir="${2:-${PWD:t}}"
    local safe_branch="${branch//\//_}"
    
    # If creating a new branch
    if ! git show-ref --verify --quiet "refs/heads/$branch"; then
        git worktree add -b "$branch" "../${base_dir}__${safe_branch}"
    else
        # For existing branches
        git worktree add "../${base_dir}__${safe_branch}" "$branch"
    fi
}; f'

# Convert current repo to bare and move working files to a worktree
alias gwtbare='local f; f() {
    local current_branch=$(current_branch)
    local base_dir=${PWD:t}
    local safe_branch="${current_branch//\//_}"
    
    # Store current state
    git add -A
    git stash push -u -m "Stashing before bare conversion"
    
    # Move .git up one level and make it bare
    mv .git "../${base_dir}.git"
    git -C "../${base_dir}.git" config --bool core.bare true
    
    # Remove current directory and create new worktree
    cd ..
    rm -rf "$base_dir"
    git -C "${base_dir}.git" worktree add "${base_dir}__${safe_branch}" "$current_branch"
    
    # Apply stashed changes if any
    cd "${base_dir}__${safe_branch}"
    git stash pop 2>/dev/null || true
}; f'
```

Now you can:

1. Create new branches with worktrees:
```bash
gwtb feature/upgrade    # Creates new branch and worktree
```

2. Convert existing repository to bare and move current work to a worktree:
```bash
gwtbare    # Converts current repo to bare and creates worktree
```

After running `gwtbare`:
- Your `.git` directory becomes a bare repository in the parent directory
- Your working files move to a new worktree directory
- You can then create additional worktrees without conflicts

Example workflow:
```bash
# Starting in ~/projects/myapp
cd ~/projects/myapp
gwtbare                    # Converts to bare repo
cd ../myapp__main         # Your files are now here
gwtb feature/upgrade      # Create new branch worktree
cd ../myapp__feature_upgrade  # Switch to new worktree
```

The directory structure will look like:
```
~/projects/
  ├── myapp.git/          # Bare repository
  ├── myapp__main/        # Original branch worktree
  └── myapp__feature_upgrade/  # New feature branch worktree
```

This setup gives you a clean way to work with multiple branches simultaneously while avoiding the "already checked out" conflicts.

---

_**User**_

instead of assuming we're inside of the current repo, let's instead make gwtb take the path to the repo we want to create a worktree from instead let's let the location we're currently in be where we'll create the worktree directory (and its associated branch) and the first argument is the repo we're starting with 

---

_**Assistant**_

I'll modify `gwtb` to work with a repository path as the first argument. Here's the updated version:

```zsh:zsh/aliases.zsh
alias gwtb='local f; f() {
    local repo_path="${1:?Must provide path to repository}"
    local branch="${2:-master}"  # Default to master if no branch specified
    local base_dir="${3:-${repo_path:t}}"  # Use repo name as default base_dir
    local safe_branch="${branch//\//_}"
    
    # Ensure repo_path is a git repository
    if [[ ! -d "$repo_path/.git" ]]; then
        echo "Error: $repo_path is not a git repository" >&2
        return 1
    }
    
    # If creating a new branch
    if ! git -C "$repo_path" show-ref --verify --quiet "refs/heads/$branch"; then
        git -C "$repo_path" worktree add -b "$branch" "${PWD}/${base_dir}__${safe_branch}"
    else
        # For existing branches
        git -C "$repo_path" worktree add "${PWD}/${base_dir}__${safe_branch}" "$branch"
    fi
}; f'
```

Now the usage is:
```bash
# Basic usage
gwtb ~/projects/myrepo                    # Creates worktree from myrepo in current directory
gwtb ~/projects/myrepo feature/new        # Creates new feature branch worktree
gwtb ~/projects/myrepo main custom_name   # Uses custom base name for the worktree directory

# Examples
cd ~/workspace
gwtb ~/projects/myrepo                    # Creates ./myrepo__master/
gwtb ~/projects/myrepo feature/auth       # Creates ./myrepo__feature_auth/
gwtb ~/projects/myrepo main webapp        # Creates ./webapp__main/
```

Key changes:
1. First argument is now the path to the source repository
2. Uses `git -C` to run git commands in the context of the source repository
3. Creates worktree directories in the current working directory
4. Added error checking for valid git repository
5. Made the repository path argument required using `:?` parameter expansion

---

_**User**_

and it must take two args so that the second one is a new or existing branch

---

_**Assistant**_

I'll modify the `gwtb` alias to require both the repository path and branch name, and handle both new and existing branches:

```zsh:zsh/aliases.zsh
alias gwtb='local f; f() {
    # Require both arguments
    local repo_path="${1:?Must provide path to repository}"
    local branch="${2:?Must provide branch name}"
    local base_dir="${3:-${repo_path:t}}"  # Use repo name as default base_dir
    local safe_branch="${branch//\//_}"
    
    # Ensure repo_path is a git repository
    if [[ ! -d "$repo_path/.git" ]]; then
        echo "Error: $repo_path is not a git repository" >&2
        return 1
    }
    
    # If creating a new branch
    if ! git -C "$repo_path" show-ref --verify --quiet "refs/heads/$branch"; then
        echo "Creating new branch: $branch"
        git -C "$repo_path" worktree add -b "$branch" "${PWD}/${base_dir}__${safe_branch}"
    else
        # For existing branches
        echo "Using existing branch: $branch"
        git -C "$repo_path" worktree add "${PWD}/${base_dir}__${safe_branch}" "$branch"
    fi
}; f'
```

Now the usage is:
```bash
# Must provide both repository path and branch name
gwtb ~/projects/myrepo feature/new-branch     # Creates worktree with new branch
gwtb ~/projects/myrepo existing-branch        # Creates worktree with existing branch
gwtb ~/projects/myrepo main custom_name       # Uses custom base name for the worktree directory

# Examples in practice
cd ~/workspace
gwtb ~/projects/myrepo feature/auth          # Creates ./myrepo__feature_auth/ with new branch
gwtb ~/projects/myrepo main                  # Creates ./myrepo__main/ using existing branch
gwtb ~/projects/myrepo dev webapp            # Creates ./webapp__dev/ using custom base name
```

Key changes:
1. Made both repository path and branch name required arguments
2. Added error messages for missing arguments
3. Added informative messages about branch creation/usage
4. Maintains the safe branch name conversion for directory naming
5. Still allows optional custom base directory name as third argument

---

_**User**_

oops

---

_**Assistant**_



Ah yes, there's a syntax error with the `}` after the if statement. In zsh, we need to use `then` and `fi`. Let me fix that:

```zsh:zsh/aliases.zsh
alias gwtb='local f; f() {
    # Require both arguments
    local repo_path="${1:?Must provide path to repository}"
    local branch="${2:?Must provide branch name}"
    local base_dir="${3:-${repo_path:t}}"  # Use repo name as default base_dir
    local safe_branch="${branch//\//_}"
    
    # Ensure repo_path is a git repository
    if [[ ! -d "$repo_path/.git" ]]; then
        echo "Error: $repo_path is not a git repository" >&2
        return 1
    fi
    
    # If creating a new branch
    if ! git -C "$repo_path" show-ref --verify --quiet "refs/heads/$branch"; then
        echo "Creating new branch: $branch"
        git -C "$repo_path" worktree add -b "$branch" "${PWD}/${base_dir}__${safe_branch}"
    else
        # For existing branches
        echo "Using existing branch: $branch"
        git -C "$repo_path" worktree add "${PWD}/${base_dir}__${safe_branch}" "$branch"
    fi
}; f'
```

The changes:
1. Changed `}` to `fi` after the repository check
2. Fixed zsh syntax for the if statements
3. Kept all other functionality the same

This should now work without any syntax errors.

---



---

