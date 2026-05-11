```
   ┌───────────────────────────────────────────────────────────────┐
   │                                                               │
   │     r e c o d e e e  /  s k i l l s                           │
   │     ─────────────────────────────────                         │
   │     167 skills · 20 categories · one source of truth          │
   │                                                               │
   └───────────────────────────────────────────────────────────────┘
```

> **My laptop's current skill set.** This is the live snapshot of every agent
> skill installed on my machine — the same folders that Claude Code and Codex
> read at runtime. The repo is the source; my `~/.claude/skills` and
> `~/.codex/skills` are just symlinks back here.

---

## Why this exists

I run a lot of agents. Skills drift fast: I install one from a marketplace,
edit it, copy it to a new project, forget where the original lived. This repo
is the one place that's allowed to be authoritative. If a skill isn't here, it
isn't real on this laptop.

Everything else (`~/.claude/skills/<name>`, `~/.codex/skills/<name>`) is a
symlink. Edit a file under `skills/` and every agent picks it up on next load —
no copy, no resync, no drift.

---

## Layout

```text
skills/
  <category>/
    <skill-name>/
      SKILL.md          # the agent-facing spec
      scripts/          # optional bundled scripts
      references/       # optional supporting docs
      assets/           # optional images, samples
scripts/
  install-local.sh      # installs to both Codex and Claude
  install-codex.sh
  install-claude.sh
docs/
  installed-sources.tsv # provenance log from last install
  install.md
.claude/
  settings.json         # repo-scoped Claude Code config
```

---

## Categories

| Folder            | Count | What lives here                                                  |
| ----------------- | ----: | ---------------------------------------------------------------- |
| `ai/`             |     3 | Anthropic SDK integration, prompt caching, Claude migration      |
| `automation/`     |     2 | Task scheduling, cron jobs, recurring automation                 |
| `caveman/`        |     5 | Token compression — caveman, caveman-commit, caveman-review, …   |
| `colony/`         |     2 | Colony coordination, prompts, and handoff surfaces               |
| `content/`        |     8 | Technical writing, copywriting, theming, docs, PDF, browser work |
| `deployment/`     |     3 | Coolify, pnpm, Supabase                                          |
| `design/`         |    19 | UI, UX, visual design, image-direction, brandkit, mockups        |
| `github/`         |     6 | github CLI, gh-fix-ci, gitguardex, worktrees, branch finish      |
| `growth/`         |    12 | CRO, analytics, retention, referrals, free-tool growth           |
| `higgsfield/`     |     4 | Higgsfield AI — generate, soul-id, photoshoot, marketplace       |
| `hostinger/`      |     4 | Hostinger domains, DNS, hosting, VPS                             |
| `marketing/`      |    18 | SEO, ads, email, launch, PMM, pricing, community, RevOps-adjacent |
| `medusa/`         |    14 | Medusa commerce, storefronts, db migrations, woocommerce import  |
| `meta/`           |    25 | Agent meta, config, workflow, plans, doctor, hud, ask-*, trace   |
| `obsidian/`       |     4 | Obsidian vault tooling and JSON canvas                           |
| `orchestration/`  |    13 | autopilot, ralph, team, subagents, ultraqa, ultrawork, pipeline  |
| `private/`        |     1 | Host- / account-specific skills (no secrets in repo)             |
| `research/`       |    11 | autoresearch, interviews, customer/competitor research, keywords |
| `review/`         |    11 | code/security/architecture review, debugging, TDD, verification  |
| `stripe/`         |     2 | Stripe integration and webhooks                                  |

> Skill leaf names are unique repo-wide so symlink installs never collide.

---

## Install

```sh
./scripts/install-local.sh
```

The installer walks every category for `SKILL.md` files and links each parent
folder into both:

- `~/.codex/skills/<skill-name>`
- `~/.claude/skills/<skill-name>`

Existing skill folders at the destination are moved to timestamped backups
before linking — nothing is overwritten silently.

`docs/installed-sources.tsv` records where each imported skill came from at
last import and whether duplicates were skipped.

---

## Adding a new skill

1. Drop it under the right category as `skills/<category>/<skill-name>/`.
2. Make sure it has `SKILL.md` with valid frontmatter (`name`, `description`).
3. Re-run `./scripts/install-local.sh`. The installer is idempotent.

Single-skill category? Still create the folder — flat skills aren't allowed
anymore. Better to have `deployment/coolify/` with one entry than a special
case.

---

## Secrets

Do not store secrets in this repo.

The `private/` category exists for skills that touch host-specific or
account-specific surfaces. Secrets and connection details (IPs, usernames,
tokens) **must** come from environment variables or `~/.ssh/config` aliases —
never from committed files. The bundled scripts under `private/myvps/` enforce
this: they fail fast if `SUPA_SCHEMA_SSH_TARGET` isn't set.

For WooCommerce imports, credentials live in:

```text
~/.config/woocommerce-medusa-import/env       # mode 600
```

---

```
   ─── this is mine. fork it, gut it, build your own. ───
```
