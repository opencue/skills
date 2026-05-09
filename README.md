# recodeee skills

Canonical source for reusable agent skills shared by Codex, Claude, and shared agent skill folders.

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
  installed-sources.tsv
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

`docs/installed-sources.tsv` records where each imported local skill came from and whether duplicates were skipped.

## Secrets

Do not store secrets in this repo.

For WooCommerce imports, use:

```text
~/.config/woocommerce-medusa-import/env
```

with permissions `600`.
