# cue/skills — Skill Library

> 427 skills across 36 categories. The source of truth for all local skills used by [cue](https://github.com/opencue/claude-code-skills) profiles.

## What's here

```
skills/
├── skills/                 The skill library
│   ├── media/              Image and video generation, editing
│   ├── gstack/             Git workflow, reviews, planning, dev utilities
│   ├── meta/               Profile management, skill authoring, memory
│   ├── marketing/          Content, social, campaigns
│   ├── rust/               Rust development, cargo, tooling
│   ├── design/             UI/UX, branding, SVG, Remotion
│   ├── medusa/             Medusa v2 ecommerce
│   ├── nvidia/             GPU, cuOpt optimization
│   ├── content/            Writing, articles, threads
│   ├── research/           Search, papers, keywords
│   ├── review/             Code review, security, testing
│   ├── github/             GitHub CLI, CI fixes, auth
│   └── ...                 See the full table below
├── scripts/                Install, sync, lint scripts
├── plugins/                Claude Code plugin definitions
└── catalog/                Auto-generated skill index
```

## Skill format

Each skill is a directory with a `SKILL.md` file:

```markdown
---
name: my-skill
description: "Use when the user asks to do X. Does Y."
allowed-tools: Bash(git:*), Read, Write
category: tools
---

# Skill Name

Instructions for the model...
```

Frontmatter rules (enforced by the linter, see below):

- `name:` — required, the canonical id Claude's skill discovery uses.
- `description:` — what the LLM matches against to decide when to use the skill.
  Keep it under 200 characters and include a trigger phrase ("Use when ...").
- `allowed-tools:` — use `Bash(name:*)` for shell commands and bare names for
  top-level tools (`Read`, `Write`, `Edit`, ...). Not `["tool_name"]`.
- `category:` / `tags:` / `domain:` — at least one, for discoverability.

## Linting

Every `SKILL.md` is checked against the cue spec (rules R001–R013): frontmatter
fields, `allowed-tools` syntax, trigger phrases, voice rules, anchor links, and
more. Run it locally:

```bash
cue skills-lint my-skill                      # one skill
# or against the whole library from the cue repo:
bun src/index.ts lint-skill skills/
```

CI runs the same checks via [skill-md-lint-action](https://github.com/opencue/claude-code-skills/tree/main/skill-md-lint-action).

## How cue uses this

Profiles reference skills by `category/slug`:

```yaml
# profiles/backend/profile.yaml
skills:
  local:
    - review/code-review
    - deployment/coolify
    - github/gh-fix-ci
```

At launch, cue symlinks these into the runtime's `skills/` directory.

## Adding a skill

```bash
cue skills-new my-skill                       # scaffold
# edit skills/<category>/my-skill/SKILL.md
cue skills-lint my-skill                      # validate
cue skills-test my-skill                      # test
```

Or manually: create `skills/<category>/<slug>/SKILL.md` with the frontmatter format above.

## Categories

| Category | Skills | Domain |
|----------|-------:|--------|
| `media` | 61 | Image and video generation, editing |
| `gstack` | 53 | Git workflow, reviews, planning, dev utilities |
| `meta` | 49 | Profile management, skill authoring, memory |
| `marketing` | 45 | Content, social, campaigns |
| `rust` | 41 | Rust development, cargo, tooling |
| `design` | 33 | UI/UX, branding, SVG, Remotion |
| `medusa` | 17 | Medusa v2 ecommerce |
| `nvidia` | 13 | GPU, cuOpt optimization |
| `content` | 11 | Writing, articles, threads |
| `research` | 10 | Search, papers, keywords |
| `video` | 7 | Video production flows |
| `tools` | 7 | Utilities, token/cost analysis |
| `strapi` | 6 | Strapi v5 CMS |
| `ssh` | 6 | Remote servers, SSH ops |
| `review` | 6 | Code review, security, testing |
| `orchestration` | 6 | Multi-agent, fleets, pipelines |
| `github` | 6 | GitHub CLI, CI fixes, auth |
| `caveman` | 6 | Terse mode, commits, compression |
| `plan` | 5 | Planning, investigation, reviews |
| `obsidian` | 4 | Vault, markdown, canvas |
| `hostinger` | 4 | DNS, domains, VPS |
| `higgsfield` | 4 | AI image/video generation |
| `security` | 3 | Audits, secrets, hardening |
| `eu-funding` | 3 | EU grant applications |
| `deployment` | 3 | Coolify, Supabase, pnpm |
| `career` | 3 | Resumes, interviews |
| `browser` | 3 | Playwright, screenshots |
| `stripe` | 2 | Payments, webhooks |
| `polymarket` | 2 | Prediction markets |
| `colony` | 2 | Multi-agent coordination |
| `xbot` | 1 | X/Twitter automation |
| `test` | 1 | Edge-case and test generation |
| `private` | 1 | Private/internal |
| `predict-everything` | 1 | Forecasting, simulation |
| `google-workspace` | 1 | Docs, Sheets, Gmail |
| `event-design` | 1 | Invitations, cards |

## Related

- [cue](https://github.com/opencue/claude-code-skills) — the profile manager
- [resources/mcps](../mcps/) — MCP server registry
