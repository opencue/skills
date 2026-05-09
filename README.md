# recodeee skills

Canonical source for reusable agent skills shared by Codex and Claude.

## Layout

```text
skills/
  <skill-name>/
    SKILL.md
    references/
    assets/
scripts/
  install-codex.sh
  install-claude.sh
  install-local.sh
docs/
  install.md
```

## Install locally

From this repo:

```sh
./scripts/install-local.sh
```

This links each folder under `skills/` into:

- `~/.codex/skills/<skill-name>`
- `~/.claude/skills/<skill-name>`

Existing skill folders are moved to timestamped backups before linking.

## Secrets

Do not store secrets in this repo.

For WooCommerce imports, use:

```text
~/.config/woocommerce-medusa-import/env
```

with permissions `600`.
