# Extension Analysis and Organization Strategy

This document analyzes Cursor extensions, categorizes them, and provides an organization strategy.

**Last Updated**: 2026-01-11  
**Current Extension Count**: 96 extensions

## Extension Evolution

### Historical Comparison

**October 2025 Snapshot**: 127 extensions  
**January 2026 Current**: 96 extensions  
**Change**: -31 extensions (24% reduction)

### Removed Extensions (Since Oct 2025)

The following extensions were removed:

1. `anysphere.remote-ssh` - Remote SSH (functionality may be in remote-containers)
2. `bradlc.vscode-tailwindcss` - Tailwind CSS IntelliSense
3. `codeandstuff.vscode-navigate-edit-history` - Navigate edit history
4. `docker.docker` - Docker extension (may have been replaced)
5. `expo.vscode-expo-tools` - Expo tools
6. `goodfoot.compare-branch` - Compare branch
7. `jackiotyu.git-worktree-manager` - Git worktree manager
8. `jsimonrichard.vscode-prosemark` - Prosemark
9. `ms-azuretools.vscode-containers` - Azure containers
10. `ms-python.vscode-python-envs` - Python environments
11. `pflannery.vscode-versionlens` - Version lens
12. `redhat.java` - Java language support
13. `rooveterinaryinc.roo-cline` - Roo Cline
14. `streetsidesoftware.code-spell-checker` - Code spell checker
15. `vscjava.vscode-gradle` - Gradle support
16. `vscjava.vscode-java-debug` - Java debugger
17. `vscjava.vscode-java-dependency` - Java dependencies
18. `vscjava.vscode-java-pack` - Java extension pack
19. `vscjava.vscode-java-test` - Java testing
20. `vscjava.vscode-maven` - Maven support

**Analysis**: Removed Java ecosystem extensions (9 extensions), Docker/container tools, and some utility extensions. This suggests a shift away from Java development and container-focused workflows.

### Added Extensions (Since Oct 2025)

The following extensions were added:

1. `akhaled.key-bindings-to-md` - Key bindings to markdown
2. `alexzheng111.kb-shortcut-learner` - Keyboard shortcut learner
3. `bodil.file-browser` - File browser
4. `bpruitt-goddard.mermaid-markdown-syntax-highlighting` - Mermaid syntax highlighting
5. `danielnichols.slurm-dashboard` - SLURM dashboard
6. `donebd.vscode-keypromoter` - Key promoter
7. `eamodio.gitlens` - GitLens (popular Git extension)
8. `esbenp.prettier-vscode` - Prettier code formatter
9. `github.remotehub` - GitHub RemoteHub
10. `jrieken.vscode-pr-pinger` - PR pinger
11. `kevinkern.instructa-ai-prompts` - AI prompts
12. `mermaidchart.vscode-mermaid-chart` - Mermaid charts
13. `ms-azuretools.azure-dev` - Azure Dev
14. `ms-azuretools.vscode-azure-github-copilot` - Azure GitHub Copilot
15. `ms-azuretools.vscode-azureappservice` - Azure App Service
16. `ms-azuretools.vscode-azurecontainerapps` - Azure Container Apps
17. `ms-azuretools.vscode-azurefunctions` - Azure Functions
18. `ms-azuretools.vscode-azureresourcegroups` - Azure Resource Groups
19. `ms-azuretools.vscode-azurestaticwebapps` - Azure Static Web Apps
20. `ms-azuretools.vscode-azurestorage` - Azure Storage

**Analysis**: Added Azure ecosystem extensions (10 extensions), Git tools (GitLens, PR pinger), code quality tools (Prettier), and keyboard/UI enhancements. This suggests increased focus on Azure cloud development and developer experience improvements.

## Extension Categories

### Core Development (Base Extensions)

**Essential for all development work:**

1. `anysphere.cursorpyright` - Cursor's Python language server
2. `dbaeumer.vscode-eslint` - ESLint JavaScript linter
3. `esbenp.prettier-vscode` - Prettier code formatter
4. `editorconfig.editorconfig` - EditorConfig support
5. `ms-python.python` - Python extension
6. `ms-python.debugpy` - Python debugger
7. `github.vscode-pull-request-github` - GitHub PR support
8. `eamodio.gitlens` - GitLens (Git supercharged)

**Count**: 8 extensions  
**Strategy**: Always installed, part of base profile

### Language Support

**Language-specific extensions:**

1. `golang.go` - Go language support
2. `ms-python.python` - Python (already in core)
3. `ms-python.debugpy` - Python debugger (already in core)
4. `redhat.vscode-yaml` - YAML support
5. `reditorsupport.r` - R language support
6. `reditorsupport.r-syntax` - R syntax
7. `svelte.svelte-vscode` - Svelte support
8. `prisma.prisma` - Prisma ORM
9. `graphql.vscode-graphql-syntax` - GraphQL syntax
10. `ms-vscode.cpptools` - C++ tools
11. `ms-vscode.cmake-tools` - CMake tools
12. `hashicorp.terraform` - Terraform
13. `lextudio.restructuredtext` - reStructuredText
14. `tht13.rst-vscode` - reStructuredText (alternative)

**Count**: 14 extensions  
**Strategy**: Install based on project needs (optional profiles)

### AI & Code Assistance

**AI-powered development tools:**

1. `anthropic.claude-code` - Claude Code
2. `google.geminicodeassist` - Gemini Code Assist
3. `openai.chatgpt` - ChatGPT
4. `saoudrizwan.claude-dev` - Claude Dev
5. `kevinkern.instructa-ai-prompts` - AI prompts
6. `anysphere.cursorpyright` - Cursor's AI (already in core)

**Count**: 6 extensions  
**Strategy**: Core AI tools always installed, optional AI assistants as needed

### Git & Version Control

**Git and version control tools:**

1. `eamodio.gitlens` - GitLens (already in core)
2. `donjayamanne.githistory` - Git history
3. `bee.git-temporal-vscode` - Git temporal
4. `gitworktrees.git-worktrees` - Git worktrees
5. `github.vscode-pull-request-github` - GitHub PRs (already in core)
6. `github.vscode-github-actions` - GitHub Actions
7. `github.remotehub` - GitHub RemoteHub
8. `jrieken.vscode-pr-pinger` - PR pinger
9. `letmaik.git-tree-compare` - Git tree compare

**Count**: 9 extensions  
**Strategy**: Core Git tools always installed, advanced tools optional

### Cloud & Infrastructure

**Cloud platform and infrastructure tools:**

#### Azure (10 extensions)
1. `ms-azuretools.azure-dev` - Azure Dev
2. `ms-azuretools.vscode-azure-github-copilot` - Azure GitHub Copilot
3. `ms-azuretools.vscode-azureappservice` - Azure App Service
4. `ms-azuretools.vscode-azurecontainerapps` - Azure Container Apps
5. `ms-azuretools.vscode-azurefunctions` - Azure Functions
6. `ms-azuretools.vscode-azureresourcegroups` - Azure Resource Groups
7. `ms-azuretools.vscode-azurestaticwebapps` - Azure Static Web Apps
8. `ms-azuretools.vscode-azurestorage` - Azure Storage
9. `ms-azuretools.vscode-docker` - Docker
10. `ms-azuretools.vscode-cosmosdb` - Cosmos DB

#### Google Cloud (3 extensions)
1. `googlecloudtools.cloudcode` - Cloud Code
2. `googlecloudtools.firebase-dataconnect-vscode` - Firebase Data Connect
3. `vymarkov.firebase-explorer` - Firebase Explorer

#### Kubernetes (1 extension)
1. `ms-kubernetes-tools.vscode-kubernetes-tools` - Kubernetes tools

**Count**: 14 extensions  
**Strategy**: Install based on cloud platform needs (Azure profile, GCP profile)

### Database & Data

**Database and data tools:**

1. `alexcvzz.vscode-sqlite` - SQLite
2. `mtxr.sqltools` - SQL Tools
3. `mtxr.sqltools-driver-pg` - PostgreSQL driver
4. `mtxr.sqltools-driver-sqlite` - SQLite driver
5. `curioswitch.sqltools-driver-cloudsql-pg` - Cloud SQL PostgreSQL
6. `inferrinizzard.prettier-sql-vscode` - Prettier SQL
7. `prisma.prisma` - Prisma (already in languages)
8. `ms-toolsai.jupyter` - Jupyter notebooks
9. `ms-toolsai.jupyter-renderers` - Jupyter renderers
10. `ms-toolsai.vscode-jupyter-cell-tags` - Jupyter cell tags
11. `ms-toolsai.vscode-jupyter-slideshow` - Jupyter slideshow
12. `mechatroner.rainbow-csv` - Rainbow CSV

**Count**: 12 extensions  
**Strategy**: Database tools for data work profile, Jupyter for data science

### Markdown & Documentation

**Markdown and documentation tools:**

1. `bierner.markdown-mermaid` - Markdown Mermaid
2. `bpruitt-goddard.mermaid-markdown-syntax-highlighting` - Mermaid syntax
3. `mermaidchart.vscode-mermaid-chart` - Mermaid charts
4. `davidanson.vscode-markdownlint` - Markdown linting
5. `marp-team.marp-vscode` - Marp presentations
6. `icvanee.chat-to-markdown` - Chat to markdown
7. `lextudio.restructuredtext` - reStructuredText (already in languages)
8. `tht13.rst-vscode` - reStructuredText (already in languages)

**Count**: 8 extensions  
**Strategy**: Core markdown tools always installed, presentation tools optional

### UI & Navigation

**User interface and navigation enhancements:**

1. `bodil.file-browser` - File browser
2. `rrudi.vscode-dired` - Dired file manager
3. `tanduc.dired` - Dired (alternative)
4. `vscodevim.vim` - Vim emulation
5. `vspacecode.vspacecode` - VSpaceCode
6. `vspacecode-expanded.vspacecode-expanded` - VSpaceCode expanded
7. `vspacecode.whichkey` - WhichKey
8. `tuttieee.emacs-mcx` - Emacs MCX
9. `kahole.magit` - Magit for VSCode
10. `jakubniewczas.keybinding-mode` - Keybinding mode
11. `alexzheng111.kb-shortcut-learner` - Shortcut learner
12. `donebd.vscode-keypromoter` - Key promoter
13. `aculich.key-bindings-to-md` - Key bindings to markdown
14. `akhaled.key-bindings-to-md` - Key bindings to markdown (alternative)
15. `cfcluan.project-scopes` - Project scopes

**Count**: 15 extensions  
**Strategy**: Core navigation always installed, advanced UI tools optional

### Remote Development

**Remote development and containers:**

1. `anysphere.remote-containers` - Remote containers
2. `ms-vscode-remote.remote-ssh` - Remote SSH
3. `ms-vscode-remote.remote-ssh-edit` - Remote SSH edit
4. `ms-vscode-remote.remote-wsl` - Remote WSL
5. `ms-vscode-remote.vscode-remote-extensionpack` - Remote extension pack
6. `ms-vscode.remote-explorer` - Remote explorer
7. `ms-vscode.remote-repositories` - Remote repositories
8. `ms-vscode.remote-server` - Remote server
9. `github.remotehub` - GitHub RemoteHub (already in Git)

**Count**: 9 extensions  
**Strategy**: Install for remote development needs

### Testing & Quality

**Testing and code quality tools:**

1. `ms-playwright.playwright` - Playwright testing
2. `ms-vscode.extension-test-runner` - Extension test runner
3. `dbaeumer.vscode-eslint` - ESLint (already in core)
4. `esbenp.prettier-vscode` - Prettier (already in core)
5. `yoavbls.pretty-ts-errors` - Pretty TypeScript errors
6. `amodio.tsl-problem-matcher` - TypeScript problem matcher

**Count**: 6 extensions  
**Strategy**: Core quality tools always installed, testing tools optional

### Utilities & Productivity

**Utility and productivity extensions:**

1. `dnut.rewrap-revived` - Rewrap text
2. `formulahendry.auto-close-tag` - Auto close tags
3. `bungcip.better-toml` - Better TOML
4. `dotjoshjohnson.xml` - XML tools
5. `christian-kohler.npm-intellisense` - NPM IntelliSense
6. `jacobdufault.fuzzy-search` - Fuzzy search
7. `jakearl.search-editor-apply-changes` - Search editor
8. `joshmu.periscope` - Periscope
9. `nguyenngoclong.terminal-keeper` - Terminal keeper
10. `shortcutsninja.shortcutsninja` - Shortcuts Ninja
11. `bmuskalla.vscode-tldr` - TLDR
12. `douniwan.redact-secrets` - Redact secrets
13. `tomoki1207.pdf` - PDF viewer
14. `specstory.specstory-vscode` - SpecStory

**Count**: 14 extensions  
**Strategy**: Install based on workflow needs

## Extension Organization Strategy

### Base Profile (Always Installed)

**Core Development** (8):
- Cursor Pyright, ESLint, Prettier, EditorConfig
- Python, Python Debugger
- GitHub PR, GitLens

**AI & Code Assistance** (3):
- Claude Code, Gemini Code Assist, Cursor Pyright

**Essential Git** (2):
- GitLens, GitHub PRs

**Essential Markdown** (2):
- Markdown Mermaid, Markdown linting

**Essential Navigation** (3):
- File browser, Vim emulation, Project scopes

**Essential Quality** (2):
- ESLint, Prettier

**Total Base**: ~20 extensions

### Optional Profiles

#### Web Development Profile
- Svelte, GraphQL, Prisma
- Playwright, Remote containers
- Additional markdown tools

#### Cloud Development Profile
- Azure extensions (10)
- Google Cloud extensions (3)
- Kubernetes tools
- Terraform

#### Data Science Profile
- Jupyter extensions (4)
- Database tools (SQLite, PostgreSQL)
- R language support
- Rainbow CSV

#### Remote Development Profile
- Remote SSH, Remote containers
- Remote WSL, Remote repositories
- Remote extension pack

#### Advanced UI Profile
- VSpaceCode, WhichKey
- Emacs MCX, Magit
- Keybinding tools

## Recommendations

### Immediate Actions

1. ✅ **Update Extension List**: Current list updated (96 extensions)
2. ⏳ **Create Base Profile**: Define core 20 extensions
3. ⏳ **Create Optional Profiles**: Organize by use case
4. ⏳ **Document Profile System**: How to activate profiles

### Extension Cleanup Opportunities

1. **Duplicate Functionality**:
   - Two key-bindings-to-md extensions (aculich, akhaled)
   - Two dired extensions (rrudi, tanduc)
   - Two reStructuredText extensions (lextudio, tht13)

2. **Unused Extensions**:
   - Review Azure extensions if not actively using Azure
   - Review Java-related if not doing Java development
   - Review remote extensions if not doing remote development

3. **Consolidation**:
   - Consider extension packs instead of individual extensions
   - Use remote extension pack instead of individual remote extensions

### Maintenance Strategy

1. **Regular Audits**: Quarterly review of installed extensions
2. **Profile Management**: Use profiles to manage extension sets
3. **Documentation**: Keep extension list updated in dotfiles
4. **Testing**: Test extension compatibility after updates

## Extension Installation Workflow

### Current Workflow
```bash
# Install from list
cat extensions.list | xargs -L 1 cursor --force --install-extension

# Update list
cursor --list-extensions > extensions.list
```

### Recommended Workflow
```bash
# Install base profile
./install-extensions.sh --profile base

# Install additional profile
./install-extensions.sh --profile web-dev

# Update extension list
./update-extensions.sh
```

## Summary

- **Current Count**: 96 extensions
- **Base Profile**: ~20 essential extensions
- **Optional Profiles**: 5+ profiles for different use cases
- **Trend**: Moving away from Java, toward Azure cloud development
- **Focus**: Developer experience improvements (keyboard shortcuts, Git tools, code quality)
