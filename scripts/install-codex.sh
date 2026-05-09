#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${CODEX_HOME:-$HOME/.codex}/skills"
mkdir -p "$target"

# Skills live at skills/<category>/<skill-name>/SKILL.md.
# Walk to any directory containing a SKILL.md and symlink that directory
# into <codex>/skills/<basename>. Flat skills/<skill-name>/SKILL.md
# layouts are also supported transparently.
while IFS= read -r -d '' skill_md; do
  skill="$(dirname "$skill_md")"
  name="$(basename "$skill")"
  dest="$target/$name"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$skill" ]; then
    continue
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.backup.$(date +%Y%m%d%H%M%S)"
  fi
  ln -s "$skill" "$dest"
done < <(find "$repo_root/skills" -mindepth 2 -maxdepth 4 -type f -name SKILL.md -print0)
