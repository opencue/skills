# cue/skills — Skill Library

> 127 skills across 21 categories. The source of truth for all local skills used by [cue](https://github.com/opencue/cue) profiles.

## What's here

```
skills/
├── skills/                 The skill library
│   ├── browser/            Playwright, screenshots
│   ├── caveman/            Terse mode, commits, compression
│   ├── colony/             Multi-agent coordination
│   ├── deployment/         Coolify, Supabase, pnpm
│   ├── design/             UI/UX, branding, SVG, Remotion
│   ├── github/             GitHub CLI, CI fixes, auth
│   ├── higgsfield/         AI image/video generation
│   ├── hostinger/          DNS, domains, VPS
│   ├── medusa/             Medusa v2 ecommerce
│   ├── meta/               Profile management, memory, helpers
│   ├── nvidia/             cuOpt, GPU optimization
│   ├── obsidian/           Vault, markdown, canvas
│   ├── orchestration/      Fleet, pipelines, workers
│   ├── research/           Search, papers, keywords
│   ├── review/             Code review, security, testing
│   ├── secrets/            Envoult, credential management
│   ├── stripe/             Payments, webhooks
│   └── ...
├── scripts/                Install, sync, lint scripts
├── plugins/                Claude Code plugin definitions
└── catalog/                Auto-generated skill index
```

## Skill format

Each skill is a directory with a `SKILL.md` file:

```markdown
---
description: "When user says X, do Y"
allowed-tools: ["tool_name"]
---

# Skill Name

Instructions for the model...
```

The `description` frontmatter is what the LLM matches against to decide when to use the skill.

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
|----------|--------|--------|
| `browser` | 1 | Playwright, screenshots |
| `caveman` | 5 | Terse mode, commits |
| `design` | 16 | UI/UX, branding, SVG |
| `medusa` | 14 | Ecommerce platform |
| `meta` | 18 | Profile helpers, memory |
| `nvidia` | 12 | GPU optimization |
| `review` | 5 | Code quality, security |
| `research` | 8 | Search, papers |

## Related

- [cue](https://github.com/opencue/cue) — the profile manager
- [resources/mcps](../mcps/) — MCP server registry
