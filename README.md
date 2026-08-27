# cue/skills — Skill Library

> 443 skills across 40 categories. The source of truth for all local skills used by [cue](https://github.com/opencue/claude-code-skills) profiles.

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

- `name:` — required, the discovery name exposed to coding agents.
- `description:` — what the LLM matches against to decide when to use the skill.
  Keep it under 200 characters and include a trigger phrase ("Use when ...").
- `allowed-tools:` — use `Bash(name:*)` for shell commands and bare names for
  top-level tools (`Read`, `Write`, `Edit`, ...). Not `["tool_name"]`.
- `category:` / `tags:` / `domain:` — at least one, for discoverability.

The repository-relative `category/slug` path is the canonical library ID. A
`name:` may remain user-friendly, but duplicate names are reported because a
flat agent runtime cannot load them unambiguously.

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
Repository organization is checked separately with:

```bash
python scripts/library_inventory.py
```

This verifies catalog portability and freshness, generated/template metadata,
README counts, canonical IDs, and structural collisions. Existing duplicate
names and category mismatches are warnings until their migrations are reviewed;
new generated drift and stale artifacts fail CI.

Removed duplicate IDs remain discoverable in
[`catalog/aliases.json`](catalog/aliases.json). Consumers should resolve an
alias before looking up the canonical `category/slug` ID.

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

To import an existing user's Codex or Claude Code skills safely, start a new
session in this repository with one of the reusable prompts:

- [`prompts/import-skills-codex.md`](prompts/import-skills-codex.md)
- [`prompts/import-skills-claude-code.md`](prompts/import-skills-claude-code.md)

The prompts preserve complete skill directories, report semantic collisions
instead of overwriting them, and refresh the cue catalog after import.

## Categories

<!-- BEGIN GENERATED CATEGORY TABLE -->
| Category | Skills |
|----------|-------:|
| `media` | 61 |
| `gstack` | 53 |
| `meta` | 49 |
| `marketing` | 45 |
| `rust` | 41 |
| `design` | 22 |
| `medusa` | 17 |
| `legal` | 14 |
| `nvidia` | 13 |
| `content` | 11 |
| `research` | 10 |
| `vercel` | 9 |
| `review` | 7 |
| `tools` | 7 |
| `video` | 7 |
| `caveman` | 6 |
| `github` | 6 |
| `orchestration` | 6 |
| `ssh` | 6 |
| `strapi` | 6 |
| `plan` | 5 |
| `higgsfield` | 4 |
| `hostinger` | 4 |
| `obsidian` | 4 |
| `browser` | 3 |
| `career` | 3 |
| `deployment` | 3 |
| `eu-funding` | 3 |
| `security` | 3 |
| `colony` | 2 |
| `polymarket` | 2 |
| `robotics` | 2 |
| `stripe` | 2 |
| `event-design` | 1 |
| `google-workspace` | 1 |
| `predict-everything` | 1 |
| `private` | 1 |
| `secrets` | 1 |
| `test` | 1 |
| `xbot` | 1 |
<!-- END GENERATED CATEGORY TABLE -->

## Related

- [cue](https://github.com/opencue/claude-code-skills) — the profile manager
- [resources/mcps](../mcps/) — MCP server registry
