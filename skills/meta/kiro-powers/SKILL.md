---
name: kiro-powers
description: >-
  When user says "import kiro power", "add power to profile", or "use X power" —
  import a Kiro Power (POWER.md + MCP config) from GitHub into a cue profile as
  a skill + MCP entry. Bridges the Kiro Powers ecosystem into cue.
tags: [meta, cue, kiro, powers, interop]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: Bash(curl:*), Bash(gh:*), Bash(git:*), Read(*), Write(*)
---

# Kiro Powers → cue Profile Importer

Import Kiro Powers (from kiro.dev or GitHub) into cue profiles. A Kiro Power is:
- `POWER.md` — steering file with activation keywords + workflow instructions
- MCP server configuration
- Optional hooks and slash commands

cue can use these directly by converting them to skill + MCP entries.

## When to activate

- User says "import kiro power X" or "add the Stripe power"
- User says "use kiro powers" or "convert power to skill"
- User mentions a known Kiro power partner (Supabase, Stripe, Neon, Netlify, Figma, Postman, Datadog)

## Power → cue Mapping

| Kiro Power component | cue equivalent |
|---------------------|----------------|
| `POWER.md` | Skill `SKILL.md` (rename + adapt frontmatter) |
| MCP server config | Entry in `resources/mcps/configs/` |
| Activation keywords | Skill `description` field (triggers matching) |
| Hooks | Skill body instructions |
| Slash commands | Skill body sections |

## Workflow

### 1. Find the Power

```bash
# From GitHub URL
git clone --depth 1 <power-repo-url> /tmp/power-import

# Or from known partners
# Supabase: github.com/supabase/kiro-power
# Stripe: github.com/stripe/kiro-power
# Neon: github.com/neondatabase/kiro-power
```

Check for `POWER.md` at the root or in a `power/` subdirectory.

### 2. Parse the Power

Read `POWER.md` and extract:

```
---
name: supabase
keywords: [database, postgres, supabase, rls, edge-functions]
mcp:
  command: npx
  args: ["-y", "@supabase/mcp-server"]
  env:
    SUPABASE_ACCESS_TOKEN: "${SUPABASE_ACCESS_TOKEN}"
---

# Supabase Power

## Onboarding
...

## Workflows
...
```

### 3. Convert to cue skill

Create `resources/skills/skills/kiro/<power-name>/SKILL.md`:

```markdown
---
name: <power-name>
description: "<keywords joined as natural language trigger>"
tags: [kiro-power, <power-name>]
category: kiro
version: 1.0.0
requires_mcps: [<power-name>]
allowed-tools: mcp__<power-name>__*
---

<POWER.md body content here>
```

### 4. Add MCP config

Add to `resources/mcps/configs/claude_runtime.sanitized.json`:

```json
{
  "servers": {
    "<power-name>": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server"],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "${SUPABASE_ACCESS_TOKEN}"
      }
    }
  }
}
```

### 5. Add to profile

```yaml
# In profiles/<target>/profile.yaml
skills:
  local:
    - kiro/<power-name>
mcps:
  - <power-name>
```

### 6. Verify

```bash
cue validate <profile>
cue doctor --profile <profile>
```

## Known Kiro Power Partners

| Power | MCP Package | Keywords |
|-------|------------|----------|
| Supabase | `@supabase/mcp-server` | database, postgres, supabase, rls |
| Stripe | `@stripe/mcp` | payment, checkout, billing, stripe |
| Neon | `@neondatabase/mcp-server` | postgres, neon, serverless-db |
| Netlify | `@netlify/mcp-server` | deploy, netlify, hosting |
| Figma | `@figma/mcp-server` | design, figma, ui, components |
| Postman | `@postman/mcp-server` | api, testing, postman, collections |
| Datadog | `@datadog/mcp-server` | monitoring, datadog, observability |

## Rules

- Always preserve the original POWER.md content — it contains the expertise
- Map `keywords` to the skill `description` for cue's matching
- Add `requires_mcps` so cue warns if the MCP isn't configured
- Keep the MCP env vars as `${PLACEHOLDER}` — user fills them in
- If the power has multiple steering files, create one skill per workflow OR bundle them as references/
- Confirm with user before writing to the MCP registry
