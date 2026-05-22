---
name: save-profile
description: >-
  Use when user says "save as profile", "create profile from session", or "export this setup". Captures current skills and MCPs into a new cue profile via `cue create-profile`.
---

# Save Profile

Save the current Claude Code session's loaded skills as a new cue profile.

## Quickest path: use `cue create-profile`

The `cue create-profile` CLI accepts everything as flags, so you can build the
profile in one shot without prompting the user multiple times:

```bash
cue create-profile <name> \
  --icon "🦊" \
  --description "Frontend work for project X" \
  --inherits core \
  --skills design/ui-ux-pro-max,research/find-skills,content/playwright \
  --mcps gbrain,colony \
  --pin
```

Flags:
- `<name>` — required, kebab-case (e.g. `my-project-dev`)
- `--icon` — single emoji (default `🐾`)
- `--description` — one-line summary
- `--inherits` — parent profile (default `core`)
- `--skills` — comma-separated `category/slug` paths
- `--mcps` — comma-separated MCP IDs
- `--pin` — also write `.cue-profile` in the cwd
- `--force` — overwrite an existing profile

## Workflow inside Claude Code

1. **Ask the user** for: name, one-line description, and an icon.
   Icons to offer: 🐻 🦋 🦜 🦉 🐺 🦚 🐝 🐆 🐢 🦄 🦊 🐙 🐬 🦔 🐇 🐛 🤖 🐍 🦀 🐋 🦈 🐊 🦅 🐎 🦁 🐘
2. **Discover loaded skills** — run `ls .claude/skills/` and follow each symlink:
   ```bash
   for d in .claude/skills/*/*; do readlink -f "$d"; done
   ```
   For each absolute path, strip the prefix `…/resources/skills/skills/` to get
   the `category/slug` form. Skip anything that doesn't match (npx skills, etc.).
3. **Discover loaded MCPs** — read `settings.json`, take the keys of
   `mcpServers` that match cue's known MCP registry.
4. **Run `cue create-profile`** with the collected values:
   ```bash
   cue create-profile <name> --icon "<icon>" --description "<desc>" \
     --skills "<comma,joined,skills>" --mcps "<comma,joined,mcps>" --pin
   ```
5. **Confirm** — print the path the CLI returned and remind the user the
   profile loads automatically next time they `claude` from this directory.

## Notes

- Always inherit from `core` unless the user specifies otherwise.
- If a skill symlink resolves to something outside `resources/skills/skills/`,
  skip it with a warning — the user can add it back manually.
- Don't write the YAML by hand; `cue create-profile` validates the name and
  refuses to overwrite by default.
- The cue repo lives at `~/Documents/cue/`. Profiles live at
  `~/Documents/cue/profiles/<name>/profile.yaml`.
