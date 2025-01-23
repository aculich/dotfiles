| Alias                  | Explanation                                                                                                       |
|------------------------|-------------------------------------------------------------------------------------------------------------------|
| gk                     | Lists all branches and tags, showing detailed information.                                                      |
| gke                    | Lists all branches, including commit references from reflogs, with additional details.                          |
| gclones                | Clones repositories from a list of URLs stored in `urls.list`.                                                 |
| glp                    | Displays the Git log in a more readable format.                                                                 |
| giglv                  | Shows the `.git/info/exclude` file, which lists ignored files.                                                  |
| clp                    | Clears the terminal, pulls changes using `clasp`, shows uncommitted changes, then displays the status.         |
| gtl                    | Lists tags sorted by version number in descending order.                                                        |
| gro                    | Opens the URL for the remote origin in a web browser.                                                           |
| grt                    | Changes the working directory to the root of the current Git repository.                                        |
| gpullall              | Pulls the latest changes from all subdirectories that are Git repositories.                                       |
| current_branch         | Returns the name of the current branch.                                                                          |
| delete-local-branches  | Deletes all branches that have been merged, excluding the current branch.                                        |
| g                      | A shorthand for the `git` command.                                                                              |
| ga                     | Stages changes for the next commit.                                                                              |
| gaa                    | Stages all changes, including new files.                                                                        |
| gam                    | Stages a commit's contents from a patch file.                                                                   |
| gama                   | Aborts the current `am` operation.                                                                               |
| gamc                   | Continues the `am` operation after fixing conflicts.                                                            |
| gams                   | Skips the current patch during an `am` operation.                                                               |
| gamscp                 | Shows the current patch during an `am` operation.                                                                |
| gap                    | Applies a patch to the files in the repository.                                                                 |
| gapa                   | Stages changes interactively while applying patches.                                                             |
| gapt                   | Attempts a 3-way merge when applying a patch.                                                                    |
| gau                    | Stages modified files for the next commit.                                                                      |
| gav                    | Stages files interactively while displaying information for each file.                                          |
| gb                     | Lists all branches in the repository.                                                                            |
| gbD                    | Forcefully deletes a specified branch.                                                                           |
| gba                    | Lists all branches including remote branches.                                                                    |
| gbd                    | Deletes a specified branch after confirmation.                                                                    |
| gbg                    | Lists branches that are no longer present in remote repositories.                                               |
| gbgD                   | Forcefully deletes branches that are no longer present in remote.                                                |
| gbgd                   | Deletes merged branches that are no longer present in remote repositories, keeping unmerged branches.            |
| gbl                    | Blames a specified line in the file.                                                                             |
| gbm                    | Renames a specified branch.                                                                                     |
| gbnm                   | Lists branches that have not been merged into the current branch.                                               |
| gbr                    | Lists remote branches in the repository.                                                                         |
| gbs                    | Starts a bisect session.                                                                                       |
| gbsb                   | Marks the current commit as bad during a bisect session.                                                       |
| gbsg                   | Marks the current commit as good during a bisect session.                                                      |
| gbsn                   | Marks the current commit as new during a bisect session.                                                       |
| gbso                   | Marks the current commit as old during a bisect session.                                                       |
| gbsr                   | Resets the bisect session to its original state.                                                               |
| gbss                   | Starts a bisect session with a specific range.                                                                 |
| gbsu                   | Sets the upstream tracking branch for the current branch to match the corresponding origin branch.              |
| gc                     | Commits changes with a verbose message.                                                                         |
| 'gc!'                  | Amends the last commit's message using verbose output.                                                          |
| gcB                    | Checks out a branch and creates it, resetting the current branch to a specific state.                         |
| gca                    | Commits all changes with a verbose message.                                                                    |
| 'gca!'                 | Amends the last commit's message after committing all changes with verbose output.                              |
| gcam                   | Commits with a specific message including all changed and new files.                                            |
| 'gcan!'                | Amends the last commit without editing the message.                                                            |
| 'gcann!'               | Amends the last commit marking the date as "now".                                                               |
| 'gcans!'               | Amends the last commit with signoff included.                                                                  |
| gcas                   | Commits all changes with a signoff.                                                                            |
| gcasm                  | Commits all changes with a signoff and a message.                                                              |
| gcb                    | Checks out a new branch.                                                                                       |
| gcd                    | Checks out a specified branch that pulls from the develop branch.                                             |
| gcf                    | Lists all current configurations in the repository.                                                           |
| gclean                 | Cleans the repository interactively by selecting files to remove.                                               |
| gclf                   | Clones a Git repository including recursive submodules, while applying shallow filters.                             |
| gcm                    | Switches to the main branch.                                                                                    |
| gcmsg                  | Commits changes using a specified message.                                                                     |
| gcn                    | Commits the changes without editing the message interactively.                                                 |
| 'gcn!'                 | Amends the last commit's message without editing.                                                              |
| gco                    | Switches to a specified branch.                                                                                |
| gcom                   | An alias for `gcommit`.                                                                                      |
| gcoma                  | An alias for `ac`, typically for executing a specific command.                                                |
| gcor                   | Checks out files in the working directories and their submodules.                                            |
| gcount                 | Shows a summary of commits arranged by the number of commits.                                                 |
| gcp                    | Cherry-picks a commit specified by the user.                                                                   |
| gcpa                   | Aborts the current cherry-pick operation.                                                                     |
| gcpc                   | Continues the cherry-pick operation after resolving conflicts.                                                |
| gcs                    | Signs commits with GPG signature.                                                                             |
| gcsm                   | Commits with a signoff applied along with any specified message.                                              |
| gcss                   | Commits with both GPG signature and signoff applied.                                                          |
| gcssm                  | Commits with GPG signature, signoff, and a specified message.                                                |
| gd                     | Shows changes between the working directory and the index.                                                    |
| gdca                   | Shows differences between the index and the last commit.                                                      |
| gdct                   | Shows the latest tag description in the repository.                                                           |
| gdcw                   | Shows differences between the working directory and the index, visually displaying changes.                    |
| gds                    | Shows all staged changes.                                                                                     |
| gdt                    | Displays a summary of file changes for the last commit.                                                       |
| gdup                   | Shows differences between the current branch and its upstream branch.                                         |
| gdw                    | Displays changes in the working directory against the last commit.                                            |
| gf                     | Fetches changes from a remote repository.                                                                    |
| gfa                    | Fetches all branches, tags, and removes deleted branches from remote.                                       |
| gfg                    | Searches the git files using grep with specific options.                                                    |
| gfo                    | Fetches changes from the origin remote repository.                                                             |
| gg                     | Opens the Git GUI for commit history and management.                                                           |
| gga                    | Opens the Git GUI to amend the last commit.                                                                   |
| ggpull                 | Pulls the latest changes from the current branch on the origin remote.                                        |
| ggpush                 | Pushes changes to the current branch on the origin remote.                                                    |
| ggsup                  | Sets the upstream branch for tracking to origin for the current branch.                                       |
| ghh                    | Displays Git help documentation.                                                                               |
| gi                     | Initializes a new Git repository.                                                                             |
| gigauv                 | Lists all untracked files or directories in verbose format.                                                 |
| gignore                | Updates the index to treat specified files as unchanged (not tracked).                                        |
| gignored               | Lists untracked files and directories.                                                                        |
| gigwtv                 | Lists all files that are skipped in the working tree.                                                          |
| git-svn-dcommit-push   | Performs a dcommit to the SVN and pushes to the main branch in git.                                          |
| gl                     | Pulls updates from the current remote branch without further details.                                          |
| glg                    | Displays the log with stats for each commit.                                                                  |
| glgg                   | Displays the log in a graphical representation.                                                                |
| glgga                  | Displays a detailed log with decorations and all branches in a graphical view.                                 |
| glgm                   | Displays the last 10 commits along with their logs.                                                            |
| glgp                   | Displays the log with stats and diffs.                                                                          |
| glo                    | Shows a one-line summary of the commit history.                                                               |
| glod                   | Shows formatted log with commit hashes, tags, and dates.                                                      |
| glods                  | Shows formatted logs with dates shortened.                                                                    |
| glog                   | Displays a graph representation of the commit history.                                                        |
| gloga                  | Displays a graph with detailed commit information for all branches.                                           |
| glol                   | Displays a formatted log with commit hashes and authors for a clean overview.                                  |
| glola                  | Displays a detailed log across all branches with a clean format.                                              |
| glols                  | Shows a detailed log with stats across all branches.                                                          |
| gluc                   | Pulls the latest changes from the upstream for the current branch.                                            |
| glum                   | Pulls the latest changes from the upstream for the main branch.                                              |
| gm                     | Merges a specified branch into the current branch.                                                              |
| gma                    | Aborts the current merge operation.                                                                            |
| gmc                    | Continues a merge after resolving conflicts.                                                                   |
| gmff                   | Ensures that merges happen only when a fast-forward is possible.                                              |
| gmom                   | Merges the latest changes from the origin's main branch into the current branch.                               |
| gms                    | Merges changes and squashes commits into a single one.                                                        |
| gmtl                   | Launches the merge tool without prompt for resolving conflicts.                                                |
| gmtlvim                | Launches the merge tool with vimdiff for resolving conflicts.                                                |
| gmum                   | Merges the upstream main branch into the current branch.                                                      |
| gp                     | Pushes committed changes to the specified remote.                                                              |
| gpd                    | Simulates a push operation to see what would happen.                                                           |
| gpf                    | Pushes with a force that preserves the state of remote branches.                                             |
| 'gpf!'                 | Forcefully pushes changes to the remote repository.                                                            |
| gpoat                  | Pushes all branches and tags to the origin remote repository.                                                  |
| gpod                   | Deletes a specified remote branch from the origin.                                                             |
| gpr                    | Pulls the latest changes with rebasing.                                                                        |
| gpra                   | Pulls with rebasing and automatically stashing changes.                                                       |
| gprav                  | Pulls with rebasing, autostashing, and verbosity for more details.                                            |
| gpristine              | Resets the working directory to match the upstream branch, forcing deletion of all untracked changes.         |
| gprom                  | Pulls the latest changes from the main branch while rebasing.                                                  |
| gpromi                 | Pulls changes interactively from the main branch with rebasing.                                               |
| gprum                  | Pulls the latest changes from upstream for the main branch.                                                   |
| gprumi                 | Pulls changes interactively from upstream for the main branch.                                               |
| gprv                   | Pulls with verbose output for better logging.                                                                    |
| gpsup                  | Pushes to the designated upstream branch for the current local branch.                                         |
| gpsupf                 | Pushes to the designated upstream branch, forcing changes if necessary.                                         |
| gpu                    | Pushes changes to the upstream remote repository.                                                              |
| gpv                    | Pushes commits with verbose logging.                                                                           |
| gr                     | Manages the remote repositories.                                                                                |
| gra                    | Adds a new remote repository.                                                                                  |
| grb                    | Initiates a rebase operation.                                                                                  |
| grba                   | Aborts the ongoing rebase.                                                                                    |
| grbc                   | Continues a rebase after resolving conflicts.                                                                   |
| grbd                   | Rebases the current branch onto the develop branch.                                                            |
| grbi                   | Starts an interactive rebase session.                                                                          |
| grbm                   | Rebases the current branch onto the main branch.                                                                |
| grbo                   | Rebases using a different base.                                                                                |
| grbom                  | Rebases the current branch onto the origin's main branch.                                                     |
| grbs                   | Skips the current patch during a rebase operation.                                                            |
| grbum                  | Rebases the current branch onto upstream's main branch.                                                       |
| grev                   | Reverts changes made in the specified commit.                                                                  |
| greva                  | Aborts the ongoing revert operation.                                                                           |
| grevc                  | Continues the revert operation after manual resolution.                                                       |
| grf                    | Displays the git reflog for viewing a history of what has happened.                                           |
| grh                    | Resets the current local branch to the state of the specified commit.                                          |
| grhh                   | Hard resets the local branch, discarding all changes.                                                         |
| grhk                   | Resets the local branch while keeping unstaged changes.                                                       |
| grhs                   | Soft resets the local branch, keeping changes in the working directory.                                        |
| grm                    | Removes specified files from the repository.                                                                  |
| grmc                   | Removes files from the index but keeps them in the working directory.                                          |
| grmv                   | Renames a remote repository.                                                                                    |
| groh                   | Resets the current branch to match the remote repository.                                                     |
| grrm                   | Removes specified remote repositories.                                                                          |
| grs                    | Restores files to a previous commit state directly.                                                           |
| grset                  | Updates the URL of a specified remote repository.                                                             |
| grss                   | Restores files from a specific commit or branch.                                                              |
| grst                   | Restores files to the staged area (index).                                                                     |
| gru                    | Resets the current branch to the specified commit, discarding all changes.                                   |
| grup                   | Updates the information from remote repositories.                                                             |
| grv                    | Displays verbose information about remote repositories.                                                       |
| gsb                    | Displays a short status summary along with the current branch.                                                 |
| gsd                    | Updates an SVN repository from the current Git branch.                                                        |
| gsh                    | Shows the content of a specific commit.                                                                       |
| gsi                    | Initializes git submodules within the repository.                                                              |
| gsps                   | Shows a short summary of commit changes along with the signature.                                             |
| gsr                    | Rebases an SVN repository to match the current state.                                                         |
| gss                    | Displays a short status of changes in the repository.                                                           |
| gst                    | Displays the current status of the working directory and index.                                              |
| gsta                   | Applies changes currently in the stash.                                                                       |
| gstaa                  | Applies the latest stash and keeps it in the stash list.                                                     |
| gstall                 | Stashes all changes including ignored files.                                                                     |
| gstc                   | Clears all stashed changes.                                                                                   |
| gstd                   | Drops a specific stash item from the stash list.                                                               |
| gstl                   | Lists out all the current stash items.                                                                          |
| gstp                   | Applies and removes the latest stash.                                                                          |
| gsts                   | Shows specific details of the stashed changes.                                                                |
| gsu                    | Updates Git submodules to their tip commit.                                                                    |
| gsw                    | Switches between branches.                                                                                     |
| gswc                   | Creates and switches to a new branch.                                                                         |
| gswd                   | Switches to the develop branch.                                                                                |
| gswm                   | Switches to the main branch.                                                                                  |
| gta                    | Tags a specific commit with annotations.                                                                       |
| gts                    | Creates a signed tag for commits.                                                                              |
| gtv                    | Lists all tags sorted in version order.                                                                        |
| gunignore              | Updates the index to treat specified files as tracked again.                                                  |
| gunwip                 | Resets the last commit if the commit message contains `--wip--`.                                             |
| gwch                   | Displays a detailed change history based on how commits have evolved.                                          |
| gwip                   | Stages all changes and creates a temporary commit indicating work in progress.                                  |
| gwipe                  | Resets the working tree to a given commit, destroying all changes.                                           |
| gwt                    | Manages Git worktree operations.                                                                               |
| gwta                   | Adds a new worktree to the repository.                                                                         |
| gwtls                  | Lists all worktrees associated with the repository.                                                           |
| gwtmv                  | Moves a worktree to a new location.                                                                           |
| gwtrm                  | Removes a specified worktree from the repository.                                                             |
| sgrep                  | Searches recursively through files in the repository excluding the git directory and other ignored files.     |
| gcl                    | Locally clones a Git repository.                                                                               |
| gigau                  | Locally updates the index to treat specified files as unchanged.                                               |
| gigl                   | Adds specified files to the Git ignore list.                                                                   |
| gigwt                  | Locally updates the index to skip tracking specified files.                                                     |

