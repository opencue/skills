# Install

Clone:

```sh
git clone git@github.com:recodeee/skills.git ~/Documents/recodeee/skills
cd ~/Documents/recodeee/skills
```

Install for both Codex and Claude:

```sh
./scripts/install-local.sh
```

Install only Codex:

```sh
./scripts/install-codex.sh
```

Install only Claude:

```sh
./scripts/install-claude.sh
```

The scripts symlink each `skills/<name>` directory into the target global skill directory.
If a target folder already exists and is not this symlink, it is moved to a timestamped backup.

## Source Inventory

`installed-sources.tsv` records imported local skill sources from:

- `~/.codex/skills`
- `~/.claude/skills`
- `~/.agents/skills`

Backups, hidden/system folders, and repo-pointing symlinks are not imported as new canonical skills.
