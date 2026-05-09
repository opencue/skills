#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="$HOME/.claude/skills"
mkdir -p "$target"

# Skills live at skills/<category>/<skill-name>/SKILL.md.
# Walk to any directory containing a SKILL.md and symlink that directory
# into ~/.claude/skills/<basename>. Flat skills/<skill-name>/SKILL.md
# layouts are also supported transparently.
#
# `ln -sfn` atomically replaces an existing symlink (no .backup.* clutter).
# The -n flag prevents dereferencing when $dest is a symlink to a directory,
# which would otherwise place the new link *inside* the old target's tree.
while IFS= read -r -d '' skill_md; do
  skill="$(dirname "$skill_md")"
  name="$(basename "$skill")"
  ln -sfn "$skill" "$target/$name"
done < <(find "$repo_root/skills" -mindepth 2 -maxdepth 4 -type f -name SKILL.md -print0)
