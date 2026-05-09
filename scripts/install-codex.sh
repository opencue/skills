#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="${CODEX_HOME:-$HOME/.codex}/skills"
mkdir -p "$target"

for skill in "$repo_root"/skills/*; do
  [ -d "$skill" ] || continue
  name="$(basename "$skill")"
  dest="$target/$name"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$skill" ]; then
    continue
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.backup.$(date +%Y%m%d%H%M%S)"
  fi
  ln -s "$skill" "$dest"
done
