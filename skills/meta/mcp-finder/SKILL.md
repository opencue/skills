---
name: mcp-finder
description: Use when user says "find an MCP for X" or "add MCP to profile". Searches the local registry, awesome-mcp-servers, Smithery, and GitHub to find and wire MCPs into cue profiles.
tags: [meta, cue, mcp, discovery]
category: meta
version: 1.1.0
requires_mcps: []
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(grep:*), Bash(npx:*), Bash(gh:*), Bash(opensrc:*)
---

# MCP Finder

You find, evaluate, and wire MCP servers into cue profiles. MCPs give skills callable tools and persistent connections; they're the action layer beneath skills.

## Prerequisites

- `opensrc` to pull the awesome-mcp-servers catalog (ships with cue core):
  `opensrc --version || npm install -g opensrc`
- `gh` (authenticated) for GitHub repo/code search
- `npx` for the Smithery CLI (`@smithery/cli`)

## When to activate

- User says "find an MCP for <X>", "what MCP does <X>", "is there an MCP for <tool>"
- User says "add MCP to profile", "wire MCP", "connect <service>"
- User says "what MCPs pair with this profile", "match MCPs to my profile's skills"
- A skill is being written that needs a tool surface (API, database, stateful connection)
- User asks "what MCPs are available?" or "list MCPs"

## Example

User: "what already-built MCP servers match the frontend profile's skills?"

```bash
LIST=$(opensrc path punkpeye/awesome-mcp-servers)/README.md
grep -oE "[a-z0-9-]+/[a-z0-9-]+" profiles/frontend/profile.yaml | tr '/' '\n' | sort -u > /tmp/dom.txt
grep -iEf /tmp/dom.txt "$LIST" | grep -E "^- \[" | head
```

You surface browser-automation and design MCPs (Playwright, Figma) that pair
with the profile's skills, then recommend the best fit and wire it.

## Step 1: Check local registry first

```bash
# List all MCPs already configured in cue
ls resources/mcps/mcps/

# Check if the MCP is already in the sanitized config
cat resources/mcps/configs/claude.sanitized.json | grep -i "<keyword>"

# Check mcp-skill-map for existing mappings
cat resources/mcps/configs/mcp-skill-map.json | grep -i "<keyword>"
```

If found locally, show the user what it does and which profiles already use it.

## Step 2: Cross-check the awesome-mcp-servers catalog

`punkpeye/awesome-mcp-servers` is a curated list of ~1000 MCP servers grouped by
domain (browser-automation, databases, cloud-platforms, communication,
e-commerce, ...). Pull it once via opensrc, then grep it offline. Higher-signal
than a raw GitHub search because entries are categorized and human-reviewed.

```bash
LIST=$(opensrc path punkpeye/awesome-mcp-servers)/README.md

# Browse the domain categories
grep -E "^### " "$LIST"

# Find servers for a keyword (entries are: - [owner/repo](url) <legend> - desc)
grep -iE "^- \[" "$LIST" | grep -i "<keyword>" | head -20
```

The trailing emoji legend encodes each server's stack and runtime (📇 TypeScript,
🐍 Python, 🏠 local, ☁️ cloud, 🍎🪟🐧 OS). The Legend section near the top of the
README explains them.

### Match against a profile's skills

To suggest MCPs that pair with an existing profile, turn its skill categories
and names into keywords and grep the catalog for each:

```bash
PROFILE=profiles/<name>/profile.yaml
# Skill tokens = category + name of each "category/skill" entry, deduped
grep -oE "[a-z0-9-]+/[a-z0-9-]+" "$PROFILE" | tr '/' '\n' | sort -u > /tmp/profile-domains.txt
grep -iEf /tmp/profile-domains.txt "$LIST" | grep -E "^- \[" | head -20
```

A frontend profile surfaces browser/design MCPs; a backend profile surfaces
database/cloud MCPs. Map the matches back to the profile's `mcps:` list and skip
any the profile already wires.

## Step 3: Search Smithery registry

```bash
# Search Smithery for MCP servers
npx -y @smithery/cli search "<keyword>" 2>/dev/null | head -20
```

Evaluate results by:
- **Relevance**: does it solve the user's actual need?
- **Maintenance**: last commit, open issues, stars
- **Security**: what permissions does it need? API keys? Network access?

## Step 4: Search GitHub for MCP servers

```bash
# Search for MCP server repos
gh search repos "mcp server <keyword>" --sort stars --limit 10 2>/dev/null

# Search for repos with MCP config files
gh search code "mcpServers" "filename:claude_desktop_config.json" "<keyword>" --limit 5 2>/dev/null
```

## Step 5: Evaluate and recommend

Present findings as:

```
🔌 MCP Options for "<need>":

  1. <name> (local — already configured)
     Tools: <tool1>, <tool2>
     Used by: <profile1>, <profile2>

  2. <name> (awesome-mcp-servers — <category>)
     <owner/repo> · <one-line description from the list>
     Install: npx -y <package> OR clone + build

  3. <name> (Smithery)
     ★ <stars> · Last updated: <date>
     Install: npx -y @smithery/cli install <name>

  4. <name> (GitHub)
     ★ <stars> · <description>
     Install: npm install -g <pkg> OR clone + build
```

## Step 6: Wire into cue (if user confirms)

1. Add server config to `resources/mcps/configs/claude.sanitized.json`:
   ```json
   "<mcp-name>": {
     "command": "npx",
     "args": ["-y", "<package>"],
     "env": { "API_KEY": "<redacted>" }
   }
   ```

2. Create docs at `resources/mcps/mcps/<mcp-name>/skills.md`

3. Add to the target profile's `mcps:` list in `profile.yaml`

4. Update `mcp-skill-map.json` if the MCP maps to specific skills

## Rules

- Check local registry first, then the awesome-mcp-servers catalog, before raw
  GitHub search. Curated and local-greppable beats unranked search.
- Prefer MCPs already in the registry over new installs (less maintenance).
- Flag security concerns: MCPs with broad filesystem access, network access, or API key requirements.
- Sanitize configs: never commit real API keys, use `<redacted>` placeholders.
- MCP > skill when the task needs stateful connections, real-time APIs, or persistent tool surfaces.
- Skill > MCP when the task is prompt-driven workflows, one-shot operations, or LLM reasoning.
- Always document what tools the MCP exposes in its `skills.md` file.
