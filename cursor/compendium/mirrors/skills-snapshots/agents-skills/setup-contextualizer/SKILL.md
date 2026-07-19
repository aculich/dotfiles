---
name: setup-contextualizer
description: |
  Contextualize upstream repo install and configuration for the current machine and for agent/IDE use.
  Reads upstream docs (dependencies, AGENTS.md, README, install/config), infers or accepts machine context
  (OS, host type, Node version, global vs project scope), and produces a briefing so you can install
  correctly and coding agents know how to apply the tool in project contexts and in ecosystem orchestration.
  Use when preparing to install an upstream tool (e.g. portless), when README/quickstart assumptions
  don't match your machine, or when you want agents to self-configure other projects that use the tool.
---

# Setup Contextualizer

## Overview

This skill turns upstream documentation and machine context into a single, agent-friendly briefing. It runs after or alongside repo-evaluation: the evaluator answers "Is this upstream healthy?"; the contextualizer answers "Given this upstream and this machine, how do I install and configure it, and how do agents apply it in projects?"

## When To Use

- "Prepare install for portless" / "Contextualize this upstream for my machine"
- Before installing a tool that affects the dev environment (e.g. global CLI)
- When README/QUICKSTART make assumptions that don't match your system
- When you want agents/IDE to know how to apply the tool in other project repos
- When orchestrating an upstream with a meta-project (e.g. vercel-ecosystem, LINKS.md)

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| **Upstream repo path** | Yes | Path to the cloned upstream (e.g. `upstream/portless__vercel-labs/`) |
| **Meta-project root** | No | Root of the meta-project (e.g. `vercel-ecosystem`) for ecosystem fit |
| **LINKS path** | No | Path to LINKS.md or similar (e.g. `LINKS.md`) for ecosystem orchestration |
| **Machine overrides** | No | Label (e.g. "MacBook Pro, main dev laptop"), install scope, proxy port, etc. |

## Workflow

### Step 1: Resolve Upstream Path

- Use the path provided by the user or infer from context (e.g. current workspace `upstream/<name>/`).
- If the path is relative, resolve it from the current workspace root.

### Step 2: Gather Data From Upstream

Read and parse:

1. **Requirements**: README "Requirements" or "Development" sections; package.json engines, optional system deps (e.g. Node 20+, macOS/Linux, `openssl`).
2. **AGENTS.md**: Package manager, conventions, docs to update when behavior changes.
3. **README**: Quick Start, Installation, Usage, Configuration, Environment variables, Troubleshooting.
4. **Agent skill**: If present (e.g. `skills/<tool>/SKILL.md`), use for install scope and integration patterns.
5. **Other docs**: QUICKSTART, CONTRIBUTING, or any file that describes install/config (e.g. CHANGELOG for version notes).

Extract: install command(s), global vs project scope, env vars, state directories, OS-specific notes (Safari/hosts, sudo, Linux trust store), reserved ports.

### Step 3: Gather Machine / Environment Context

Infer or ask:

- **OS**: e.g. `uname -s` (darwin, linux). Use for Safari vs Chrome, hosts sync, trust store.
- **Host type**: Laptop vs CI (affects "no sudo" vs sudo, state dir).
- **Node**: `node -v` (must meet upstream requirement, e.g. Node 20+).
- **Now**: Current date for doc freshness and deprecation implications.
- **Overrides**: If the user provided machine label or preferences (e.g. "global only", "proxy port 8080"), use them.

Optional: Check if the tool is already installed (e.g. `which portless`), existing state dir (e.g. `~/.portless`), or ports in use.

### Step 4: Map Instructions To This Machine

- Translate generic upstream steps into concrete steps for this OS and host (e.g. "On this MacBook Pro: `npm install -g portless`; no sudo for default port 1355; if using Safari, run `sudo portless hosts sync`.").
- List **assumptions corrected**: where upstream assumes Linux/macOS/CI and what to do on this machine instead.
- Confirm **install scope**: global vs project; for tools like portless, insist global-only and do not add as project dependency.

### Step 5: Write Agent/IDE Guidance

- How to apply the tool in any project: e.g. add `"dev": "portless run next dev"` to package.json, set env vars, use the upstream skill if available.
- Bypass or override: e.g. `PORTLESS=0` to run without proxy.
- How agents should self-configure another repo that will use this tool (what to add, what to copy, what to document).

### Step 6: Ecosystem Fit (Optional)

If meta-project root and LINKS path were provided:

- How this tool fits with other upstreams (e.g. portless + Next.js + other vercel-labs repos for a greenfield app).
- Pointers to LINKS.md and suggested `upstream/` clones.
- One short paragraph for the briefing.

### Step 7: Produce Output

Write:

1. **briefing.md** (required): Human- and agent-readable briefing with the sections below.
2. **briefing-summary.json** (optional): One-line summary, machine type, install scope, and paths to key docs.

Save to the workspace root or to a path the user specified. Tell the user where the files were saved.

## Briefing Document Structure

Use this template for **briefing.md**:

```markdown
# Setup Briefing: {tool or repo name}

**Generated: {date}**  
**Upstream:** {path or URL}  
**Machine:** {OS, host type, Node version}

## One-line summary

{What this tool is and how it fits; e.g. "Portless: stable .localhost URLs for local dev; global CLI; proxy on 1355."}

## Machine-specific setup

{Exact install and config steps for this machine. Bullet or numbered list.}

## Assumptions corrected

{Where upstream docs assume something (e.g. Linux) and what to do on this OS instead. Use "None" if not applicable.}

## Agent/IDE guidance

{How to apply the tool in any project: scripts, env vars, skill usage, bypass. How agents can self-configure another repo that uses this tool.}

## Ecosystem fit

{If meta-project/LINKS provided: how this tool fits with other upstreams and suggested clones. Otherwise: "Not specified."}

## References

- Upstream README: {path or URL}
- Upstream agent skill (if any): {path or URL}
- Requirements: {short list}
```

## Handling Incomplete Data

- If AGENTS.md or an agent skill is missing, infer install scope from README (e.g. "npm install -g" implies global).
- If machine context is missing, infer what you can (e.g. from `uname`, `node -v`) and note "Machine context partially inferred" in the briefing.
- Never fabricate requirements or steps; mark as "Unknown" or "See upstream README" when unclear.

## Relationship To Other Skills

- **repo-evaluator**: Answers "Is this upstream healthy and worth depending on?" Output: evaluation.json / evaluation.md. Run evaluation first if you want both health and setup context.
- **setup-contextualizer**: Answers "How do I install and configure it on this machine, and how do agents apply it?" Output: briefing.md (+ optional briefing-summary.json).

## Example Invocation

User: "Prepare install for portless; use upstream/portless__vercel-labs and this repo as meta-project."

Agent: Resolves upstream path, reads portless README and skills/portless/SKILL.md, gathers machine context (e.g. darwin, Node 20), writes briefing.md with machine-specific setup, Safari/hosts note, agent guidance (package.json, PORTLESS=0), and ecosystem fit using LINKS.md. Saves briefing.md to workspace root.
