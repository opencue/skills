# recodeee skills

Canonical source for reusable agent skills shared by Codex, Claude, and shared agent skill folders.

## Layout

Skills live one level inside a topical category folder:

```text
skills/
  <category>/
    <skill-name>/
      SKILL.md
      references/
      assets/
scripts/
  install-codex.sh
  install-claude.sh
  install-local.sh
docs/
  installed-sources.tsv
  install.md
```

Current categories:

- `caveman/`        — caveman-mode token compression skills
- `content/`        — note, doc, pdf, openai-docs, wiki, playwright, help, new-user
- `deployment/`     — coolify (server / deployment management)
- `design/`         — UI, UX, visual design, image-direction skills
- `github/`         — github CLI, gh-* helpers, gitguardex
- `higgsfield/`     — Higgsfield AI generation suite
- `medusa/`         — Medusa commerce, storefronts, woocommerce import
- `meta/`           — agent meta-tools (skill mgmt, plan, doctor, hud, ask-*, …)
- `obsidian/`       — Obsidian vault tooling and JSON canvas
- `orchestration/`  — autopilot, ralph, team, ultraqa, ultrawork, pipeline, worker, …
- `private/`        — host- or account-specific skills (do not publish secrets)
- `research/`       — autoresearch, deep-interview, keyword-research, defuddle, …
- `review/`         — code-review, security-review, ai-slop-cleaner

Skill leaf names are unique repo-wide so symlink installs don't collide.

## Install locally

From this repo:

```sh
./scripts/install-local.sh
```

The installer walks every category for `SKILL.md` files and links each parent folder into:

- `~/.codex/skills/<skill-name>`
- `~/.claude/skills/<skill-name>`

Existing skill folders at the destination are moved to timestamped backups before linking.

`docs/installed-sources.tsv` records where each imported local skill came from at last import and whether duplicates were skipped.

## Secrets

Do not store secrets in this repo.

The `private/` category exists for skills that touch host-specific or account-specific surfaces. Secrets and connection details (IPs, usernames, tokens) **must** come from environment variables or `~/.ssh/config` aliases, never from committed files.

For WooCommerce imports, use:

```text
~/.config/woocommerce-medusa-import/env
```

with permissions `600`.
