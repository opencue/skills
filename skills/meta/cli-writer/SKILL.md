---
name: cli-writer
description: >-
  Writes or updates entries in resources/cli-recipes.json and generates
  ## Prerequisites sections for SKILL.md files so skills document the CLIs
  they depend on. Use when user says "write a CLI recipe", "add CLI to
  recipes", "this skill needs a CLI", or "add install instructions".
tags: [meta, cue, cli, recipes]
category: meta
version: 1.1.0
requires_mcps: []
allowed-tools: Bash
---

# CLI Recipe Writer

You write and maintain CLI install recipes for cue's dependency system. Each recipe tells `cue cli install` how to install a tool on every supported OS.

Shared references:

- [../skill-reviewer/references/decision-brief-format.md](../skill-reviewer/references/decision-brief-format.md) —
  use a D-brief when choosing between two installers (apt vs pipx vs
  manual). Don't silently pick the wrong one.
- [../skill-reviewer/references/voice.md](../skill-reviewer/references/voice.md) —
  voice rules for the `Prerequisites` prose you generate.

## When to activate

- User says "write a CLI recipe", "add CLI to recipes", "add install for <tool>"
- User says "this skill needs <tool>" or "add prerequisites"
- User asks "how do I add a CLI dependency to a skill?"
- A new skill is being written that references a CLI not yet in `resources/cli-recipes.json`

## Step 1 — Identify the tool

Determine:
- **Binary name** (what `which <tool>` resolves to)
- **What installs it** per platform (apt, brew, dnf, pacman, winget, pip, pipx, npm, snap, script, manual)
- **Post-install needs** (API keys, group membership, config steps)

```bash
# Check if already in recipes
grep -c '"<tool>"' resources/cli-recipes.json
```

If already present, show the existing entry and ask if user wants to update it.

## Step 2 — Research install methods

For each platform, find the canonical install command:

```bash
# Check apt
apt-cache show <tool> 2>/dev/null | head -3

# Check if it's a pip/pipx tool
pip index versions <tool> 2>/dev/null | head -1

# Check npm
npm info <tool> version 2>/dev/null
```

Priority order for the recipe:
1. **System package manager** (apt/brew/dnf/pacman) — preferred
2. **snap** — for tools not in default apt (helm, kubectl, terraform)
3. **pipx** — for Python CLI tools (isolated, no conflicts)
4. **pip** — fallback for Python if pipx unavailable
5. **npm** — for Node.js CLI tools
6. **script** — one-liner curl/wget installer
7. **manual** — URL + instructions when nothing else works

## Step 3 — Write the recipe entry

Format (add to `resources/cli-recipes.json` alphabetically):

```json
"<tool>": { "apt": "<pkg>", "brew": "<pkg>", "dnf": "<pkg>", "pacman": "<pkg>", "needs": "<post-install note>" }
```

Only include fields that apply. Omit platforms where the tool isn't available.

## Step 4 — Update SKILL.md Prerequisites (if applicable)

If a skill references this CLI, add or update its `## Prerequisites` section:

```markdown
## Prerequisites

| Tool | Install |
|------|---------|
| <tool> | `apt install <tool>` · `brew install <tool>` |
```

And ensure the skill's frontmatter `allowed-tools` includes `Bash(<tool>:*)` if the skill shells out to it.

## Rules

- Always verify the package name is correct per platform (e.g., `python3-scapy` on apt vs `scapy` on pip)
- Prefer `pipx` over `pip` for Python CLI tools — isolation prevents dependency conflicts
- Include `"needs"` field for any post-install steps (API keys, user groups, config)
- Keep entries alphabetically sorted in cli-recipes.json
- Don't add recipes for tools that are part of the base OS (ls, grep, cat, etc.)
- Test that `which <tool>` works after install before declaring success
