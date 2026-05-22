---
name: save-profile
description: >-
  Use when user says "save as profile", "create profile from session", or "export this setup". Captures current skills and MCPs into a new cue profile.
---

# Save Profile

Save the current Claude Code session's loaded skills as a new cue profile.

## Workflow

1. **Ask for a profile name** — must be kebab-case, e.g. `my-project-dev`
2. **Collect loaded skills** — list files in `.claude/skills/` relative paths
3. **Pick an icon** — offer these emoji options:
   🐻 🦋 🦜 🦉 🐺 🦚 🐝 🐆 🐢 🦄 🦊 🐙 🐬 🦔 🐇 🐛 🤖 🐍 🦀 🐋 🦈 🐊 🦅 🐎 🦁 🐘
4. **Write profile.yaml** — create `~/Documents/cue/profiles/<name>/profile.yaml`
5. **Optionally pin** — write the profile name to `.cue-profile` in the current directory

## Template

```yaml
name: <name>
icon: "<chosen-icon>"
description: <ask user for one-line description>
inherits: core
skills:
  local:
    - <skill-path-1>
    - <skill-path-2>
mcps: []
```

## Steps

1. Ask: "What should this profile be called?" (validate kebab-case)
2. Ask: "One-line description?"
3. Run: `ls .claude/skills/` to discover loaded skill symlinks
4. Map each symlink target back to a `resources/skills/skills/` relative path (strip the prefix to get `category/slug`)
5. Present the icon picker — ask user to choose one
6. Write the profile.yaml to `~/Documents/cue/profiles/<name>/profile.yaml`
7. Ask: "Pin this profile to the current directory?" — if yes, write `<name>` to `.cue-profile`
8. Confirm: "Profile <icon> <name> saved. Launch with: `claude`"

## Notes

- Always inherit from `core` unless user specifies otherwise
- Skills paths are relative to `resources/skills/skills/` (e.g. `design/ui-ux-pro-max`)
- If a skill can't be mapped back to the library, skip it with a warning
- The profile directory is created if it doesn't exist
