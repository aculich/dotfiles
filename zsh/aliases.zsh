# Alias Management and ZSH Configuration
alias adump='alias | tee $ZSH_CUSTOM/aliases.dump; ls -lah $ZSH_CUSTOM/aliases.dump'                   # Dump all aliases to file and show it
alias al='alias | perl -pe "s/=/\x23/" | column -x -s$(printf "\x23") -t | cut -c-$(tput cols) | fzf'  # Fuzzy find aliases
#alias als='less -C $ZSH_CUSTOM/aliases.zsh'                                                            # View aliases file
alias ag='alias | grep'                                                                                # Search aliases

# ZSH Custom Directory Management
alias zc='cd $ZSH_CUSTOM/'                                                                            # Go to ZSH custom dir
alias zcc='z=$ZSH_CUSTOM/aliases.zsh; echo Sourcing $z; source $z'                                    # Source aliases file
alias zca='echo "Add custom alias: Ctrl-C to cancel, or copy and paste, then Ctrl-D when done."; cat >> $ZSH_CUSTOM/aliases.zsh; zcc'  # Add new alias interactively
alias zcv='vi $ZSH_CUSTOM/aliases.zsh; zcc; (cd ~/dotfiles/zsh; git add aliases.zsh; gcom)'              # Edit and source aliases
alias zrc='vi $HOME/.zshrc; source $HOME/.zshrc'                                                      # Edit and source zshrc

# Directory Stack Operations
alias po='popd; dirs -v'       # Pop directory from stack
alias pu='pushd'               # Push directory to stack
alias dro='pushd -1; dirs -v'  # Rotate directory stack and show

# File Listing Enhancements
alias llt='ll -tr'                           # List by time, reversed
alias lls='ll -sr'                           # List by size, reversed
alias t='local f; f(){ tree -a -I .git -C $* | less -FRX }; f'  # Tree view with color in less
# alias t='tree'

# File Finding and Searching
alias find=gfind               # Use GNU find
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

# Graphviz
alias dotopen='local f; f() { dot -Tpng "$1" -o "${1%.dot}.png" && open "${1%.dot}.png"; }; f'     # Convert and open dot file

# Git and Github Repository Management
#alias gro='open $(git remote get-url origin)'                                                         # Open repo in browser
alias gro='open ${(S)${${(M)$(git remote get-url origin)#git@github.com:*}#git@github.com:}#https://github.com/} | sed "s/\.git$//"'
alias grp='git remote get-url origin | pbcopy; pbpaste'                                               # Copy git remote to paste buffer
alias gitpullall='for d in */; do echo -n "$d..."; (cd "$d" && git pull --all); done'                 # Pull all repos in current dir
alias gclones='for url in $(<urls.list); do echo $i; git clone "$url" "${url:t}__${url:h:t}" ; done'  # Clone repos from urls.list with namespaced dirs
alias ghrepos='local f; f() { 
    OWNER="${1}"; 
    [[ "$OWNER" =~ ^https?://(www\.)?github\.com/(.+)/?$ ]] && OWNER="${BASH_REMATCH[2]}";
    mkdir -p "$OWNER";
    cd "$OWNER";
    gh repo list "$OWNER" --json name,description,url,createdAt,updatedAt,stargazerCount,forkCount,languages,owner --limit 100 | 
    tee repos.json | 
    jq ".[].url" -r | 
    tee repos.list;
    echo "Created $OWNER/repos.list - run \"cd $OWNER && gcll\" to clone all repos";
    cd ..;
    unset -f f; 
}; f'  # List all repos for a GitHub user/org
alias ghfork='local f; f() { repo=$1; owner=$(basename $(dirname "$repo")); name=$(basename "$repo"); gh repo fork "$repo" --clone; mv "$name" "${name}__${owner}"; }; f'  # Fork and clone with namespaced dir
alias gcl='local f; f() { url=$1; git clone "$url" "${url:t}"; }; f'
alias gcls='local f; f() { url=$1; git clone --depth=1 --no-single-branch "$url" "${url:t}"; }; f'
gcll() { local filename="${1:-repos.list}"; while read -r i; do echo "$i"; gcls "$i"; done < "$filename"; }  # Clone all repos from list file

# Git Ignore and File Management
alias giglv='cat .git/info/exclude'                                                                           # View local gitignore
alias gigl='local f; f() { for f in "$@"; do echo "$f" >> .git/info/exclude; done; giglv }; f'        # Add to local gitignore
alias gigau='local f; f() { for f in "$@"; do git update-index --assume-unchanged "$f"; done }; f'  # Mark files as assume-unchanged
alias gigwt='local f; f() { for f in "$@"; do git update-index --skip-worktree "$f"; done }; f'     # Mark files as skip-worktree
alias gigauv='git ls-files -v | grep "^[a-z]"'                                                                # List assume-unchanged files
alias gigwtv='git ls-files -v | grep "^[S]"'                                                                  # List skip-worktree files
alias current_branch='git rev-parse --abbrev-ref HEAD'
alias gbsu='git branch --set-upstream-to=origin/$(current_branch) $(current_branch)'
 
# Git Shortcuts
alias gi='git init'       # Initialize git repo
alias gcom='git gcommit'  # Custom git commit
alias gcoma='git ac'      # Git add and commit
alias ged='git diff HEAD~1 | llm -m 4o-mini -s "explain changes from last commit"'
alias gpdl='git push --dry-run && git log --oneline --decorate @{push}..HEAD'

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
        echo "Created file: $new_file"
    else
        echo "Invalid action. Use 'nf' to create a new file or 'lf' to find the latest file." >&2
        return 1
    fi
}

nf() { date_file_with_increment "nf" "$1"; }  # Create the next available file with a date-based sequence
lf() { date_file_with_increment "lf" "$1"; }  # Get the latest file in the date-based sequence
