```
   ┌───────────────────────────────────────────────────────────────┐
   │                                                               │
   │     r e c o d e e e  /  s k i l l s                           │
   │     ─────────────────────────────────                         │
   │     85 skills · 13 categories · one source of truth           │
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
| `caveman/`        |     5 | Token compression — caveman, caveman-commit, caveman-review, …   |
| `content/`        |     8 | Note, doc, pdf, openai-docs, wiki, playwright, help, new-user    |
| `deployment/`     |     1 | Coolify (server / deployment management)                         |
| `design/`         |    16 | UI, UX, visual design, image-direction, brandkit, mockups        |
| `github/`         |     5 | github CLI, gh-fix-ci, gh-submodule-publish, gitguardex          |
| `higgsfield/`     |     4 | Higgsfield AI — generate, soul-id, photoshoot, marketplace       |
| `medusa/`         |     9 | Medusa commerce, storefronts, db migrations, woocommerce import  |
| `meta/`           |    12 | Agent meta — skill mgmt, plan, doctor, hud, ask-*, trace, …      |
| `obsidian/`       |     4 | Obsidian vault tooling and JSON canvas                           |
| `orchestration/`  |    10 | autopilot, ralph, team, ultraqa, ultrawork, pipeline, worker, …  |
| `private/`        |     1 | Host- / account-specific skills (no secrets in repo)             |
| `research/`       |     6 | autoresearch, deep-interview, keyword-research, defuddle, …      |
| `review/`         |     4 | code-review, security-review, ai-slop-cleaner                    |

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
