# Alias Management and ZSH Configuration
alias adump='alias | tee $ZSH_CUSTOM/aliases.dump; ls -lah $ZSH_CUSTOM/aliases.dump'                   # Dump all aliases to file and show it
alias al='alias | perl -pe "s/=/\x23/" | column -x -s$(printf "\x23") -t | cut -c-$(tput cols) | fzf'  # Fuzzy find aliases
#alias als='less -C $ZSH_CUSTOM/aliases.zsh'                                                           # View aliases file
alias ag='alias | grep'                                                                                # Search aliases

# ZSH Custom Directory Management
alias zc='cd $ZSH_CUSTOM/'                                                                             # Go to ZSH custom dir
alias zcc='z=$ZSH_CUSTOM/aliases.zsh; echo Sourcing $z; source $z'                                     # Source aliases file
alias zca='echo "Add custom alias: Ctrl-C to cancel, or copy and paste, then Ctrl-D when done."; cat >> $ZSH_CUSTOM/aliases.zsh; zcc'  # Add new alias interactively
alias zcv='vi $ZSH_CUSTOM/aliases.zsh; zcc; (cd ~/dotfiles/zsh; git add aliases.zsh; gcom)'            # Edit and source aliases
alias zcvc='cursor $ZSH_CUSTOM/aliases.zsh'                                                            # Edit and source aliases
alias zrc='vi $HOME/.zshrc; source $HOME/.zshrc'                                                       # Edit and source zshrc
alias zrcc='cursor $HOME/.zshrc'                                                                       # Edit and source zshrc
alias ee='vi $HOME/.envrc'
alias eec='cursor $HOME/.envrc'

# Directory Stack Operations
alias po='popd; dirs -v'       # Pop directory from stack
alias pu='pushd'               # Push directory to stack
alias dro='pushd -1; dirs -v'  # Rotate directory stack and show

# File Listing Enhancements
alias ll=la				       # Always show all files
alias llt='ll -tr'             # List by time, reversed
alias lls='ll -sr'             # List by size, reversed
alias t='local f; f(){ tree -a -I .git -C $* | less -FRX }; f'  # Tree view with color in less
# alias t='tree'

# File Finding and Searching
alias find=gfind               # Use GNU find
unalias fd 2>/dev/null         # brew install fd
alias fdi="fd -HI"             # fd ignore gitignore
alias fda="fd -H"              # fd show all hidden files
alias jg="rg -t js -g '*.gs'"  # Search in Google Apps Script files

# Homebrew
alias bd='local f; f() { brew search . | xargs brew desc 2>/dev/null | grep -i -E "$1" | fzf };f'  # Fuzzy search brew packages with descriptions

# Development Tools
alias clp='clear; clasp pull; git diff; gst'  # Clear, pull Google Apps Script, show git changes

# Dotbare Management
alias dots='dotbare'          # Dotbare shortcut
alias dotss='dotbare status'  # Dotbare status
alias dbs='dotbare status'    # Dotbare status (short)
alias dbh='dotbare --help'    # Dotbare help
#alias dbu='find $HOME -maxdepth 1 -name .\* -type d \! -name .  -exec tree -L 2 -C {} \; | less -C'
alias dbu='find $HOME -maxdepth 1 -name .\* \! -name .  -exec tree -L 2 -C {} \; | less -C'  # Show dotfile tree
alias dbls='dotbare ls-files' # List dotbare tracked files

# Timestamp Functions
alias ts='local f; f() { base="${1%%.*}"; ext="${1#*.}"; delimiter="${2:-__}"; if [ "$base" = "$ext" ]; then echo "${base}${delimiter}$(date +%Y%m%dT%H%M)"; else echo "${base}${delimiter}$(date +%Y%m%dT%H%M).${ext}"; fi; }; f'       # Add timestamp (HHMM) to filename
alias tss='local f; f() { base="${1%%.*}"; ext="${1#*.}"; delimiter="${2:-__}"; if [ "$base" = "$ext" ]; then echo "${base}${delimiter}$(date +%Y%m%dT%H%M%S)"; else echo "${base}${delimiter}$(date +%Y%m%dT%H%M%S).${ext}"; fi; }; f'  # Add timestamp with seconds to filename
alias tsd='local f; f() { base="${1%%.*}"; ext="${1#*.}"; delimiter="${2:-__}"; if [ "$base" = "$ext" ]; then echo "${base}${delimiter}$(date +%Y%m%d)"; else echo "${base}${delimiter}$(date +%Y%m%d).${ext}"; fi; }; f'                # Add date to filename

# Image Processing
alias extract_images='local f; f() { grep -oP "\[image\d+\]: <data:image/\w+;base64,\K[^>]*" "$1" | nl | while read -r num img_data; do echo $img_data | base64 --decode > image${num}.png; done }; f'  # Extract base64 encoded images from file
alias extract_images_py='local f; f() { python -c "import re, base64; [open(f\"{m[0]}.png\", \"wb\").write(base64.b64decode(m[1])) for m in re.findall(r\"\\[(image\\d+)\\]: <data:image/\\w+;base64,([A-Za-z0-9+/=]+)>\", open(\"$1\").read())]" }; f'  # Python version of image extraction

# Misc
alias dotopen='local f; f() { dot -Tpng "$1" -o "${1%.dot}.png" && open "${1%.dot}.png"; }; f'     # Convert and open dot file
alias cl='chrome-cli list links'
# Sample filename output: filename__20220101T1200
# If the file has an extension, the timestamp will be added before the extension
# For example, if the file is 'filename.txt', the output will be 'filename__20220101T1200.txt'
alias cptime='local f; f() { base="${1%%.*}"; ext="${1#*.}"; delimiter="${2:-__}"; if [ "$base" = "$ext" ]; then cp $1 "${base}${delimiter}$(date -r $1 +%Y%m%dT%H%M)"; else cp $1 "${base}${delimiter}$(date -r $1 +%Y%m%dT%H%M).${ext}"; fi; }; f' # copy file to same name with timestamp
alias cpnow='local f; f() { base="${1%%.*}"; ext="${1#*.}"; delimiter="${2:-__}"; if [ "$base" = "$ext" ]; then cp $1 "${base}${delimiter}$(date +%Y%m%dT%H%M)"; else cp $1 "${base}${delimiter}$(date +%Y%m%dT%H%M).${ext}"; fi; }; f' # copy file to same name with current time as timestamp
# Git and Github Repository Management
#alias gro='open $(git remote get-url origin)'                                                         # Open repo in browser
alias gro='open ${$(git remote get-url origin):gs/git@github.com:/https:\/\/github.com\//}'           # Open repo in browser and ensure https url
alias grp='git remote get-url origin | pbcopy; pbpaste'                                               # Copy git remote to paste buffer
alias gitpullall='for d in */; do echo -n "$d..."; (cd "$d" && git pull --all); done'                 # Pull all repos in current dir
alias gclones='for url in $(<urls.list); do echo $i; git clone "$url" "${url:t}__${url:h:t}" ; done'  # Clone repos from urls.list with namespaced dirs

# Clone or update all repositories for a GitHub user/organization
# Usage: ghrepos USERNAME or ghrepos https://github.com/USERNAME
#        ghrepos git@github.com:USERNAME/REPO.git
# 
# This command will:
# 1. Create a directory named after the GitHub user/org
# 2. Get a list of all their public repositories (up to 100)
# 3. For each repository:
#    - If it doesn't exist locally: clone it
#    - If it exists: pull latest changes
#
# Example:
#   ghrepos microsoft      # Clone/update Microsoft's repos
#   ghrepos https://github.com/google  # Clone/update Google's repos
#   ghrepos git@github.com:owner/repo.git  # Clone/update from SSH URL
#
# Note: Requires GitHub CLI (gh) and jq to be installed
alias ghrepos='
f() {
  # Require an argument
  if [[ -z "$1" ]]; then
    echo "Error: Please provide a GitHub username or organization"
    echo "Usage: ghrepos USERNAME or ghrepos https://github.com/USERNAME"
    return 1
  fi

  # Extract the owner name if the argument is a URL
  local OWNER="$1"
  # Remove any @ prefix if it exists as a standalone
  OWNER="${OWNER#@}"
  
  # Debug output
  echo "Processing input: $OWNER"
  
  # Extract owner from HTTPS URL if present
  if [[ "$OWNER" =~ "^https?://(www\.)?github\.com/([^/]+)(/.*)?$" ]]; then
    OWNER="$match[2]"
    echo "Extracted from HTTPS URL: $OWNER"
  # Extract owner from SSH URL if present
  elif [[ "$OWNER" =~ "^git@github\.com:([^/]+)(/.*)?\.git$" ]]; then
    OWNER="$match[1]"
    echo "Extracted from SSH URL: $OWNER"
  fi

  # Debug output
  echo "Final owner: $OWNER"

  # Validate owner name
  if [[ -z "$OWNER" || ! "$OWNER" =~ "^[A-Za-z0-9][A-Za-z0-9-]*$" ]]; then
    echo "Error: Invalid GitHub username or organization: $OWNER"
    echo "Username must contain only alphanumeric characters or hyphens, and cannot begin with a hyphen"
    return 1
  fi
  
  # Use subshell to avoid changing current directory for the user
  (
    # Create and enter directory for the owner
    mkdir -p "$OWNER"
    cd "$OWNER" || return
    
    # List the repositories and save full info
    gh repo list "$OWNER" --json name,description,url,createdAt,updatedAt,stargazerCount,forkCount,languages,owner --limit 100 > repos.json
    
    # Check if we got any repositories
    if [[ ! -s repos.json ]]; then
      echo "Error: No repositories found for $OWNER"
      return 1
    fi
    
    # Generate the URLs-only list file
    jq -r ".[].url" repos.json > repos.list
    echo "Created $OWNER/repos.list with repository URLs"
    
    # Process each repository
    jq -r ".[] | [.name, .url] | @tsv" repos.json | while read -r name url; do
      if [[ -d "$name" ]]; then
        echo "Updating existing repository: $name"
        (cd "$name" && git pull --quiet)
      else
        echo "Cloning new repository: $name"
        git clone --quiet "$url" "$name"
      fi
    done
    
    echo "Finished processing repositories for $OWNER"
  )
}; f "$@"'

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

alias ghfork='local f; f() { repo=$1; owner=$(basename $(dirname "$repo")); name=$(basename "$repo"); gh repo fork "$repo" --clone; mv "$name" "${name}__${owner}"; }; f'  # Fork and clone with namespaced dir
alias gcl='local f; f() { url=$1; git clone "$url" "${url:t}"; }; f'
alias gclo='local f; f() { url=$1; git clone "$url" "${url:h:t}/${url:t}"; }; f'
alias gcls='local f; f() { url=$1; git clone --depth=1 --no-single-branch "$url" "${url:t}"; }; f'
gcll() { local filename="${1:-repos.list}"; while read -r i; do echo "$i"; gcls "$i"; done < "$filename"; }  # Clone all repos from list file
alias cls="chrome-cli list links | fzf"
alias clst="chrome-cli list tablinks | fzf"
alias ghls="chrome-cli list links | grep github | cut -f2 -d ' ' | grep -v github.com/search | perl -pe 's|\?.*||'"
alias ghcl="chrome-cli list links | grep github | cut -f2 -d ' ' | grep -v github.com/search | perl -pe 's|\?.*||' | xargs -L1 git clone"
alias og='organize-github'     # Preview mode
alias ogf='organize-github -f' # Force mode
alias ogl='fd -td -d2 | fzf'

# Git Ignore and File Management
alias giglv='cat .git/info/exclude'                                                                           # View local gitignore
alias gigl='local f; f() { for f in "$@"; do echo "$f" >> .git/info/exclude; done; giglv }; f'        # Add to local gitignore
alias gigld='local f; f() { local file=".git/info/exclude"; local lines=$(cat "$file" | fzf -m); [[ -n "$lines" ]] && echo "$lines" | while read -r line; do sed -i "" "/^$line\$/d" "$file"; done; giglv }; f'  # Remove from local gitignore with fzf
alias gigau='local f; f() { for f in "$@"; do git update-index --assume-unchanged "$f"; done }; f'  # Mark files as assume-unchanged
alias gigwt='local f; f() { for f in "$@"; do git update-index --skip-worktree "$f"; done }; f'     # Mark files as skip-worktree
alias gigauv='git ls-files -v | grep "^[a-z]"'                                                                # List assume-unchanged files
alias gigwtv='git ls-files -v | grep "^[S]"'                                                                  # List skip-worktree files
alias current_branch='git rev-parse --abbrev-ref HEAD'
alias gbsu='git branch --set-upstream-to=origin/$(current_branch) $(current_branch)'
alias gbaa='git --paginate for-each-ref --sort=-committerdate refs/heads/ refs/remotes/ --format="%(committerdate:short) %(committerdate:iso8601) %(committerdate:relative)%09%(refname:short)"'
alias gbaaa='git --paginate for-each-ref --sort=committerdate refs/heads/ refs/remotes/ --format="%(committerdate:short) %(committerdate:iso8601) %(committerdate:relative)%09%(refname:short)"'

# Use `export GIT_PAGER='less -F -X'` for the current session.
# Use `git config --global core.pager 'less -F -X'` to set it globally.
# Use `--paginate` with specific commands as needed.
export GIT_PAGER='cat' # by default turn the git pager off unless we explicitly turn it on for a session (so it doesn't mess up cursor!)
alias gpage='toggle_git_pager -v'  # Toggle git pager with verbose output

# Git pager configuration
function set_git_pager() {
  [[ "$TERM_PROGRAM" =~ ^(vscode|cursor)$ ]] && export GIT_PAGER='cat' || export GIT_PAGER='less -FRX'
  [[ "$1" == "-v" ]] && echo "Pager mode: ${GIT_PAGER}"
}

function toggle_git_pager() {
  export GIT_PAGER=$([[ "${GIT_PAGER:0:3}" == "cat" ]] && echo "less -FRX" || echo "cat")
  [[ "$1" == "-v" ]] && echo "Pager mode: ${GIT_PAGER}"
}

# Set initial pager based on terminal
set_git_pager

# Add hook to update pager when terminal changes
function chpwd() { set_git_pager }

# Alias 'gwtb' creates or uses a git worktree for a specified branch in a given repository.
# Usage: gwtb <repo_path> <branch_name> [base_dir] [source_branch]
# - repo_path: Path to the git repository.
# - branch_name: Name of the branch to create or use.
# - base_dir: Optional. Base directory name for the worktree; defaults to the repository name.
# - source_branch: Optional. The branch from which a new branch will be created; defaults to the currently checked out branch.
alias gwtb='local f; f() {
    # Require both arguments
    local repo_path="${1:?Must provide path to repository}"
    local branch="${2:?Must provide branch name}"
    local base_dir="${3:-${repo_path:t}}"  # Use repo name as default base_dir
    local source_branch="${4:-$(git -C "$repo_path" rev-parse --abbrev-ref HEAD)}"
    local safe_branch="${branch//\//_}"
    
    # Ensure repo_path is a git repository
    if [[ ! -d "$repo_path/.git" ]]; then
        echo "Error: $repo_path is not a git repository" >&2
        return 1
    fi
    
    # If creating a new branch
    if ! git -C "$repo_path" show-ref --verify --quiet "refs/heads/$branch"; then
        echo "Creating new branch: $branch from $source_branch"
        git -C "$repo_path" worktree add -b "$branch" "${PWD}/${base_dir}__${safe_branch}" "$source_branch"
    else
        # For existing branches
        echo "Using existing branch: $branch"
        git -C "$repo_path" worktree add "${PWD}/${base_dir}__${safe_branch}" "$branch"
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

# Git Shortcuts
alias gi='git init'       # Initialize git repo
alias gcom='git gcommit'  # Custom git commit
alias gcoma='git ac'      # Git add and commit
alias ged='git diff HEAD~1 | llm -m 4o-mini -s "explain changes from last commit"'
alias gp='(git push --dry-run; echo; git log --oneline --decorate @{push}..HEAD) | less -R -F'

alias pc='pbcopy'

date_file_with_increment() {
    local action="$1"   # "nf" (new file) or "lf" (latest file)
    local filename="${2:-untitled.txt}"  # Default to "untitled.txt" if no filename is provided
    local extension="${filename##*.}"
    local base="${filename%.*}-$(date +%Y-%m-%d)"
    local i=0
    local latest_file

    # Enable NULL_GLOB temporarily to avoid errors if no files exist
    setopt LOCAL_OPTIONS NULL_GLOB

    # Find the latest existing file
    latest_file=$(ls -v "${base}"-*.${extension} 2>/dev/null | tail -n 1)

    if [[ "$action" == "lf" ]]; then
        echo "${latest_file:-$base-0.$extension}"  # If no file exists, return the first expected filename
    elif [[ "$action" == "nf" ]]; then
        if [[ -n "$latest_file" ]]; then
            # Extract the last number in the sequence using Zsh-compatible regex matching
            if [[ "$latest_file" =~ ${base}-([0-9]+)\.${extension} ]]; then
                i=$(( match[1] + 1 ))  # Use Zsh's match array instead of BASH_REMATCH
            fi
        fi

        local new_file="${base}-${i}.${extension}"
        touch "$new_file"
        echo "$new_file"
    else
        echo "Invalid action. Use 'nf' to create a new file or 'lf' to find the latest file." >&2
        return 1
    fi
}

nf() { date_file_with_increment "nf" "$1"; }  # Create the next available file with a date-based sequence
lf() { date_file_with_increment "lf" "$1"; }  # Get the latest file in the date-based sequence
alias ndu='ncdu -1xo- > $(nf ncdu.jsonl); ncdu -f $(lf ncdu.jsonl)'

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
# defaults write -g AppleLocale "en_US.UTF-8"

# Helper function to check directory existence and git repo status
continue_git_setup() {
    emulate -L zsh
    setopt err_exit local_options local_traps
    
    [[ -z "$1" ]] && {
        print "❌ Please provide a repository URL"
        print "Usage: setup-repo <repository_url>"
        return 1
    }
    
    # Extract repo name from URL
    typeset repo_name
    repo_name=${${1:t}%.git}
    
    print "🔍 Checking current state for $repo_name..."
    
    [[ ! -d "$repo_name" ]] && {
        print "📥 Starting fresh clone..."
        git clone --depth 1 --no-checkout "$1" || {
            print "❌ Clone failed!"
            return 1
        }
    }
    
    cd "$repo_name" || {
        print "❌ Failed to change directory to $repo_name!"
        return 1
    }
    
    git rev-parse --git-dir > /dev/null 2>&1 || {
        print "❌ Not a git repository! Something went wrong with the clone."
        return 1
    }
    
    # Detect default branch
    typeset default_branch remote_info
    remote_info=("${(f)$(git remote show origin)}")
    default_branch=''
    
    for line in $remote_info; do
        if [[ "$line" = *"HEAD branch:"* ]]; then
            default_branch=${line##*: }
            break
        fi
    done
    
    [[ -z "$default_branch" ]] && {
        print "❌ Could not detect default branch!"
        return 1
    }
    
    # Force checkout of default branch
    print "🔄 Checking out $default_branch branch..."
    git checkout "$default_branch" -f || {
        print "❌ Checkout failed!"
        return 1
    }
    
    print "⬆️ Pulling latest changes..."
    git pull --rebase --autostash || {
        print "❌ Pull failed!"
        return 1
    }
    
    print "✅ Setup completed successfully!"
}

alias setup-repo='continue_git_setup'

# Enhanced directory navigation with z and fzf
alias zz='z -l | sort -rn | cut -c 12- | fzf --height 40% --reverse --tac | read selected && cd "$selected"'  # Interactive z with fzf
alias zd='cd "$(find . -type d -not -path "*/\.*" 2>/dev/null | fzf --preview "tree -L 1 {}" --height 40%)"'  # Find and cd to subdirectory
alias zh='cd ~/"$(find ~ -maxdepth 1 -type d -not -path "*/\.*" -printf "%P\n" 2>/dev/null | fzf --height 40%)"'  # Fuzzy cd to ~/directory

# Enhanced directory stack operations
alias d='dirs -v | head -n 10'  # Show directory stack (limit to 10)
alias pd='pushd "$(find . -type d -not -path "*/\.*" 2>/dev/null | fzf --preview "tree -L 1 {}" --height 40%)"'  # Push directory with fzf
alias pz='pushd "$(z -l | sort -rn | cut -c 12- | fzf --height 40% --reverse --tac)"'  # Push z directory with fzf

# FZF + Z keybindings - using explicit Esc sequences
bindkey '\ez' _zz_widget    # Esc-z for zz (z with fzf)
bindkey '\ep' _pz_widget    # Esc-p for pz (pushd with z+fzf)
bindkey '\ed' _zd_widget    # Esc-d for zd (find subdirectory)

# Create the widget functions
function _zz_widget() {
    BUFFER="zz"
    zle accept-line
}
zle -N _zz_widget

function _pz_widget() {
    BUFFER="pz"
    zle accept-line
}
zle -N _pz_widget

function _zd_widget() {
    BUFFER="zd"
    zle accept-line
}
zle -N _zd_widget
