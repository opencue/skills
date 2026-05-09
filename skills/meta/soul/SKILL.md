---
name: soul
description: >-
  Use when user says "/soul", "new soul skill", "create soul skill", "soul mcp",
  "scaffold a skill", "add this to soul", "where does this skill go", or wants
  to create a new skill or MCP catalog entry in the right place under
  ~/Documents/soul/. Knows the soul/ folder taxonomy and writes SKILL.md
  files (with proper frontmatter) and MCP README.md catalog entries directly
  into the correct category folder. NOT for editing arbitrary files —
  use only for new soul skills and new soul MCP catalog entries.
---

# soul

The soul/ tree is the user's personal toolbox of skills and MCP catalog
entries that get loaded into every Claude Code / Codex session via
`install-local.sh` symlinks into `~/.claude/skills/` and `~/.codex/skills/`.

This skill keeps soul/ tidy. When the user wants a new skill or a new MCP
entry, this skill writes the file in the **correct category folder** with
the **correct frontmatter shape**, so the sync timer picks it up cleanly
on the next fire.

## Canonical paths

```
~/Documents/soul/skills/skills/<category>/<name>/SKILL.md   ← skill
~/Documents/soul/mcps/mcps/<name>/README.md                 ← MCP catalog
~/Documents/soul/mcps/mcps/<name>/skills.md                 ← related skills
```

After writing, the next sync fire (every 15 min via systemd timer, or
end of a Claude Code turn via Stop hook) runs `install-local.sh` which
symlinks the new skill into `~/.claude/skills/<name>` and
`~/.codex/skills/<name>`. The user does not need to do anything else.

## Skill categories

Pick the closest fit. If nothing matches, ask the user before creating
a new category — `meta/` is the safe fallback for cross-cutting tooling.

| Category | When to use |
|---|---|
| `caveman` | Token-compression style/communication tweaks |
| `colony` | Multi-agent coordination, file claims, handoffs |
| `content` | Content generation (writers, copy, marketing) |
| `deployment` | Coolify, Hostinger deploy, infra automation |
| `design` | UI/UX, visual systems, brandkit, image-gen, design tokens |
| `github` | `gh` CLI, PRs, CI/Actions, repo automation |
| `higgsfield` | Higgsfield image/video gen specifics |
| `hostinger` | Hostinger-specific APIs (DNS, VPS, billing, hosting, reach) |
| `medusa` | Medusa ecommerce backend/storefront/admin |
| `meta` | Meta-tooling: this skill, doctor, plan, hud, skill manager |
| `obsidian` | Obsidian vault tooling, markdown, bases, canvas |
| `orchestration` | Multi-mode runners: autopilot, ralph, ralplan, team, ulw |
| `private` | User-private skills (don't publish) |
| `research` | Research/scrape: autoresearch, defuddle, keyword research |
| `review` | Code review, security review, slop cleanup |
| `stripe` | Stripe-specific (webhooks, billing, Connect, subscriptions) |

## SKILL.md frontmatter template

```markdown
---
name: <kebab-case-name>
description: >-
  Use when user says "<trigger 1>", "<trigger 2>", "/<name>", or wants <verb>
  <object>. <One sentence describing what it does>. NOT for <when not to use>
  — use <other-skill> instead.
---

# <Title Case Name>

<One paragraph: the why and the what.>

## When to use

- "<exact trigger phrase>"
- <another phrasing>

## When NOT to use

- <out-of-scope case>

## How

<the actual instructions Claude follows>
```

Description-field rules (these matter — the skill listing is matched
against this string by every model on every turn):
- Lead with `Use when user says ...` and list the exact trigger phrases
- Phrase from the user's mouth, not the skill's mouth
- Include `/<name>` as a slash-trigger if the skill is also user-invocable
- End with `NOT for ...` so the model has a negative anchor to disambiguate
- Keep under 400 chars for context efficiency

## MCP catalog entry template

`soul/mcps/mcps/<name>/README.md`:

```markdown
# <name> MCP

Source URL: <github / npm URL>

Install command:

\`\`\`sh
<one-liner that installs the binary>
\`\`\`

Expected command/type:

\`\`\`text
command: <bin or runtime>
args: <args>
type: stdio | http | sse
\`\`\`

Required env vars:

\`\`\`text
<VAR_NAME>
\`\`\`

Related skills:

\`\`\`text
<skill-name>
\`\`\`

Quick health check:

\`\`\`sh
<one-liner that probes the server>
\`\`\`
```

Optional sibling: `soul/mcps/mcps/<name>/skills.md` — long-form notes on
skill bundling, prompt patterns, integration tips.

## Workflow

When invoked, follow this order:

1. **Identify intent.** Skill, MCP catalog entry, or both? If ambiguous, ask.
2. **Collect inputs.** Either ask explicitly or extract from the user's
   message:
   - Skill: `name` (kebab-case), `category` (from list above), description
     fragments (triggers, what-it-does, not-for), short body.
   - MCP: `name`, source URL, install command, expected command/args/type,
     env vars, related skills.
3. **Pick the category.** Match against the table above. If multiple apply,
   prefer the most specific one. If none match, ask the user before
   inventing a new category — categories are durable.
4. **Check for collisions.** Does `soul/skills/skills/<category>/<name>/`
   already exist? Does `soul/mcps/mcps/<name>/` already exist? If yes, ask
   whether to update vs. rename.
5. **Write the file.** Use the template above; do not invent extra fields.
   Description goes in frontmatter; everything else in body.
6. **(Skill only) Verify the frontmatter.** `description` must start with
   `Use when user says` and include at least 3 trigger phrases.
7. **Don't run install-local.sh manually.** The systemd timer fires every
   15 min and the Claude Code Stop hook fires at end of turn. Either path
   picks the new skill up. Tell the user the new skill will be live within
   15 min, or they can force it with:

   ```sh
   ~/Documents/soul/skills/scripts/install-local.sh
   ```

8. **Tell the user the path.** Always echo the absolute path of the file
   you wrote so they can review.

## Naming rules

- **Skill names:** `kebab-case`, ASCII only, ≤30 chars. Match the directory
  name to the `name` field in frontmatter (the harness expects this).
- **MCP catalog names:** match the registered MCP name (`mcpServers.<key>`
  in `~/.claude.json` or `~/.codex/config.toml`).
- **Avoid plurals.** `colony` not `colonies`. `review` not `reviews`.
- **Avoid the word "skill"** inside skill names. Just describe what it does.

## What NOT to do

- Don't write outside the canonical paths. Skills live under
  `soul/skills/skills/<category>/<name>/`, not at the soul root or in
  `~/.claude/skills/` directly (those are managed by `install-local.sh`).
- Don't create a new category without asking the user first.
- Don't auto-publish or auto-push. The Stop hook + 15-min timer handle
  that — staying out of the way avoids races and double-commits.
- Don't add fields beyond `name`/`description` to skill frontmatter unless
  the user explicitly asks (e.g. `argument-hint` for slash-command skills).

## Sister tooling

- `meta/skill` — the OMX skill manager (CRUD for `~/.codex/skills/`). Use
  it when the user wants to *manage existing skills*; this skill is for
  *creating new ones in soul/*.
- `meta/plugin-creator` — codex plugin scaffolder. Different scope: that
  builds plugin packages with `marketplace.json`, this builds simple
  SKILL.md files in soul/.
