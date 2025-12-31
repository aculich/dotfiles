---
name: MCP Toolbox System & SLOW Tracking
overview: Create a project-specific MCP toolbox system for quick wins, plus a strategic SLOW methodology for continuous MCP landscape tracking throughout 2026
todos:
  - id: toolbox-structure
    content: Create /Users/me/dotfiles/cursor/mcp-toolboxes/ directory and extract MCPs from disabled config into logical toolbox JSON files (web-dev, cloud-infra, ai-research, full-stack)
    status: pending
  - id: activation-script
    content: Create activate-mcp-toolbox.sh script that copies toolbox config to .cursor/mcp.json in current project
    status: pending
  - id: toolbox-docs
    content: Create README.md documenting toolbox system, usage patterns, and when to use each toolbox
    status: pending
  - id: landscape-structure
    content: Create /Users/me/tools/toolchain-2026/mcp-landscape/ with daily-scans/, weekly-synthesis/, operationalizations/, wonderment/ directories
    status: pending
  - id: baseline-landscape
    content: "Create initial landscape baseline document capturing Dec 31, 2025 state: governance, security, ecosystem, key players"
    status: pending
  - id: tracking-sources
    content: Set up watchlists and source feeds for daily scanning (GitHub, HN, official docs, community forums)
    status: pending
  - id: scanning-automation
    content: Create scan-mcp-landscape.sh script for automated daily scanning and capture
    status: pending
  - id: weekly-synthesis
    content: Create first weekly synthesis template and process for pattern identification
    status: pending
---

# MCP Toolbox System & SLOW Landscape Tracking Plan

## Part 1: Quick Win - MCP Toolbox System

### Problem

Cursor struggles with too many globally-enabled MCPs. Need project-specific "toolboxes" (preassembled kits) that can be quickly activated per project.

### Solution Architecture

**1. Toolbox Definitions** (`/Users/me/dotfiles/cursor/mcp-toolboxes/`)

- Store reusable MCP bundle definitions as JSON files
- Each toolbox = curated set of MCPs for specific use cases
- Examples:
    - `web-dev.json` - context7, repomix, chrome-devtools
    - `cloud-infra.json` - gcloud, github, repomix
    - `ai-research.json` - context7, huggingface, limitless
    - `full-stack.json` - github, notion, repomix, context7, gcloud

**2. Activation Script** (`/Users/me/dotfiles/cursor/scripts/activate-mcp-toolbox.sh`)

- Takes toolbox name as argument
- Copies toolbox config to `.cursor/mcp.json` in current project
- Validates MCP server availability
- Provides feedback on activation

**3. Toolbox Library** (from archived configs)

- Extract all MCPs from `cursor/mcp.json.disabled`
- Create logical groupings based on use cases
- Document each toolbox's purpose and when to use it

**4. Global Config** (`~/.cursor/mcp.json`)

- Keep minimal: only essential MCPs (context7, repomix)
- These are "always-on" utilities

### Implementation Files

- `cursor/mcp-toolboxes/` - Directory for toolbox definitions
- `cursor/scripts/activate-mcp-toolbox.sh` - Activation script
- `cursor/mcp-toolboxes/README.md` - Documentation and usage guide
- Update `cursor/mcp.json.disabled` → extract to individual toolbox files

### Usage Pattern

```bash
cd /path/to/project
activate-mcp-toolbox web-dev
# Creates .cursor/mcp.json with web-dev MCPs
```

---

## Part 2: Strategic Plan - SLOW Methodology for MCP Landscape Tracking

### SLOW Framework

**S**canning → **L**earning → **O**perationalizing → **W**onderment

### Current Landscape (Dec 31, 2025)

**Key Developments:**

- MCP donated to Agentic AI Foundation (Linux Foundation) - governance shift
- Security frameworks emerging (RSA manifest signing, semantic vetting)
- Enterprise adoption accelerating (Microsoft Dynamics 365, etc.)
- MCP Toolbox platform launched (reference implementations, playbooks)

**Ecosystem Players:**

- Anthropic (originator, now steward)
- Microsoft (enterprise integration)
- OpenAI (AAIF co-founder)
- Block (AAIF co-founder)
- Community: MCP Toolbox, various server implementations

### Tracking System Structure

**1. Daily Scanning** (`/Users/me/tools/toolchain-2026/mcp-landscape/`)

- `daily-scans/YYYY-MM-DD.md` - Daily capture of:
    - New MCP servers discovered
    - Toolchain management tools
    - Security advisories
    - Governance updates
    - Community discussions
- Sources: GitHub, Hacker News, Twitter/X, MCP forums, official docs

**2. Weekly Learning** (`weekly-synthesis/`)

- Synthesize daily scans into patterns
- Identify trends and emerging standards
- Document "aha moments" and insights
- Create learning summaries

**3. Monthly Operationalizing** (`operationalizations/`)

- Convert learnings into actionable toolchain improvements
- Update toolbox definitions
- Create new toolboxes based on discoveries
- Refine activation scripts
- Document best practices

**4. Quarterly Wonderment** (`wonderment/`)

- Big-picture reflections
- Strategic direction assessment
- Hypothesis testing (multipliers vs exponentiators)
- Vision refinement

### Tracking Sources & Watchlists

**Primary Sources:**

- Official: `modelcontextprotocol.info`, `github.com/modelcontextprotocol`
- Community: MCP Toolbox, server repositories
- News: Hacker News, Reddit r/MCP, Twitter/X #ModelContextProtocol

**Luminaries to Track:**

- Simon Willison (datasette, AI tooling)
- Anthropic team (MCP creators)
- Microsoft AI team (enterprise adoption)
- Community contributors (server implementations)

**Metrics to Track:**

- New MCP servers per week
- Security advisories
- Governance decisions
- Enterprise adoption announcements
- Toolchain tool releases

### Automation & Tools

**1. RSS/Feed Aggregation**

- Set up feeds for key sources
- Daily digest generation

**2. GitHub Monitoring**

- Watch MCP-related repositories
- Track new server implementations
- Monitor security advisories

**3. Scripts**

- `scan-mcp-landscape.sh` - Automated daily scan
- `synthesize-weekly.sh` - Weekly pattern extraction
- `update-toolboxes.sh` - Operationalize learnings

### Integration with Existing Systems

- Connect to `/Users/me/tools/toolchain-2026/` structure
- Align with "viva la vita codification" methodology
- Feed into dotfiles automation
- Support both single-player (human) and multi-player (agentic) workflows

---

## Implementation Priority

**Phase 1 (Immediate - Quick Win):**

1. Create toolbox directory structure
2. Extract MCPs from disabled config into logical toolboxes
3. Create activation script
4. Test with one project
5. Document usage

**Phase 2 (Week 1 - Foundation):**

1. Set up daily scanning structure
2. Create initial landscape baseline (Dec 31, 2025)
3. Set up source feeds/watchlists
4. Create first weekly synthesis

**Phase 3 (Ongoing - SLOW Loop):**

1. Daily: Run scans, capture findings
2. Weekly: Synthesize, identify patterns
3. Monthly: Operationalize learnings into toolchain
4. Quarterly: Reflect, refine strategy

---

## Success Metrics

**Quick Win:**

- Can activate a toolbox in < 30 seconds
- Toolboxes cover 80% of common use cases
- Zero global MCP conflicts

**SLOW Tracking:**

- Daily scans completed 90%+ of days