---
name: mcp-finder
description: >-
  When user says "find an MCP for this", "what MCP server does <X>", "add MCP to profile",
  or "which MCP handles <tool>". Searches Smithery, GitHub, and the local registry to find
  and wire MCP servers into cue profiles.
tags: [meta, cue, mcp, discovery]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: Bash
---

# MCP Finder

You find, evaluate, and wire MCP servers into cue profiles. MCPs give skills callable tools and persistent connections — they're the action layer beneath skills.

## When to activate

- User says "find an MCP for <X>", "what MCP does <X>", "is there an MCP for <tool>"
- User says "add MCP to profile", "wire MCP", "connect <service>"
- A skill is being written that needs a tool surface (API, database, stateful connection)
- User asks "what MCPs are available?" or "list MCPs"

## Step 1 — Check local registry first

```bash
# List all MCPs already configured in cue
ls resources/mcps/mcps/

# Check if the MCP is already in the sanitized config
cat resources/mcps/configs/claude.sanitized.json | grep -i "<keyword>"

# Check mcp-skill-map for existing mappings
cat resources/mcps/configs/mcp-skill-map.json | grep -i "<keyword>"
```

If found locally, show the user what it does and which profiles already use it.

## Step 2 — Search Smithery registry

```bash
# Search Smithery for MCP servers
npx -y @smithery/cli search "<keyword>" 2>/dev/null | head -20
```

Evaluate results by:
- **Relevance** — does it solve the user's actual need?
- **Maintenance** — last commit, open issues, stars
- **Security** — what permissions does it need? API keys? Network access?

## Step 3 — Search GitHub for MCP servers

```bash
# Search for MCP server repos
gh search repos "mcp server <keyword>" --sort stars --limit 10 2>/dev/null

# Search for repos with MCP config files
gh search code "mcpServers" "filename:claude_desktop_config.json" "<keyword>" --limit 5 2>/dev/null
```

## Step 4 — Evaluate and recommend

Present findings as:

```
🔌 MCP Options for "<need>":

  1. <name> (local — already configured)
     Tools: <tool1>, <tool2>
     Used by: <profile1>, <profile2>

  2. <name> (Smithery)
     ★ <stars> · Last updated: <date>
     Tools: <tool_list>
     Install: npx -y @smithery/cli install <name>

  3. <name> (GitHub)
     ★ <stars> · <description>
     Install: npm install -g <pkg> OR clone + build
```

## Step 5 — Wire into cue (if user confirms)

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

- Always check local registry before searching externally — avoid duplicates
- Prefer MCPs already in the registry over new installs (less maintenance)
- Flag security concerns: MCPs with broad filesystem access, network access, or API key requirements
- Sanitize configs — never commit real API keys, use `<redacted>` placeholders
- MCP > skill when the task needs: stateful connections, real-time APIs, persistent tool surfaces
- Skill > MCP when the task is: prompt-driven workflows, one-shot operations, LLM reasoning
- Always document what tools the MCP exposes in its `skills.md` file
