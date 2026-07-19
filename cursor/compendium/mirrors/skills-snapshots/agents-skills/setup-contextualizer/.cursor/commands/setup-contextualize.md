# Setup Contextualize

Produce a machine- and ecosystem-contextualized install/config briefing for an upstream repo using the setup-contextualizer skill.

## Usage

```
/setup-contextualize [upstream-path] [meta-project-root]
```

- **No arguments**: Use current workspace; look for a single `upstream/*` directory or ask which upstream to use.
- **upstream-path**: Path to the upstream repo (e.g. `upstream/portless__vercel-labs` or `../other-repo`).
- **meta-project-root**: Optional. Root of the meta-project for ecosystem fit (default: current workspace root). If provided, LINKS.md at that root is used when present.

## What It Does

1. Reads upstream docs: requirements, AGENTS.md, README, install/config sections, and any agent skill (e.g. `skills/<tool>/SKILL.md`).
2. Gathers machine context: OS, Node version, host type; uses overrides if you specified them.
3. Maps upstream instructions to this machine and writes agent/IDE guidance.
4. Writes **briefing.md** (and optionally **briefing-summary.json**) in the workspace root or the path you specify.

## Output

- **briefing.md**: One-line summary, machine-specific setup, assumptions corrected, agent/IDE guidance, ecosystem fit (if meta-project/LINKS provided).
- **briefing-summary.json** (optional): Structured summary for automation.

Use the setup-contextualizer skill (SKILL.md) for the full workflow and briefing template.
