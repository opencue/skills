#!/usr/bin/env bash
# Pull in skills installed globally (e.g. via `npx skills add` or
# Claude/Codex marketplaces) so the soul/skills repo stays the source
# of truth for everything routable on this laptop.
#
# Behaviour:
#   - Walks ~/.claude/skills and ~/.codex/skills.
#   - For any entry that is a real dir OR a symlink pointing OUTSIDE this
#     repo (typically into ~/.agents/skills), copies the resolved content
#     into skills/imported/<name>/ and replaces the global entry with a
#     symlink back into the repo.
#   - Skips backups, hidden entries (.system, etc.), entries already
#     symlinked into this repo, and any name already present elsewhere
#     in the repo (don't shadow an existing categorized skill).
#
# Idempotent. Silent on no-op. Best-effort: never blocks the session.
# Disable per-session by exporting SKILLS_AUTO_IMPORT=0.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
imported_dir="$repo_root/skills/imported"

if [[ "${SKILLS_AUTO_IMPORT:-1}" == "0" ]]; then
  exit 0
fi

# All skill names that already live somewhere under skills/<category>/<name>/
# (so we don't shadow them with a duplicate under skills/imported/).
existing_names() {
  find "$repo_root/skills" -mindepth 2 -maxdepth 2 -type d -printf '%f\n' 2>/dev/null
}

# Returns 0 if the skill name already exists in the repo (any category)
exists_in_repo() {
  local name="$1"
  existing_names | grep -Fxq "$name"
}

# Walk one global skills root
process_root() {
  local root="$1"
  [[ -d "$root" ]] || return 0

  shopt -s nullglob
  for entry in "$root"/*; do
    local name; name="$(basename "$entry")"

    # Skip dotfiles, backup folders, junk
    [[ "$name" == .* ]] && continue
    [[ "$name" == *.backup.* ]] && continue
    [[ "$name" == *.original ]] && continue

    # Resolve target if symlink
    local target
    if [[ -L "$entry" ]]; then
      target="$(readlink -f "$entry")"
      # Already pointing into our repo → nothing to do
      case "$target" in
        "$repo_root"/*) continue ;;
      esac
    elif [[ -d "$entry" ]]; then
      target="$entry"
    else
      continue
    fi

    # Need a SKILL.md to consider it a skill
    [[ -f "$target/SKILL.md" ]] || continue

    # Don't shadow an existing categorized copy
    if exists_in_repo "$name"; then
      continue
    fi

    # Pull into skills/imported/<name>/
    mkdir -p "$imported_dir"
    local dest="$imported_dir/$name"
    if [[ -e "$dest" ]]; then
      # Already imported on a previous run — just refresh symlink and continue
      :
    else
      # Use rsync if available for a clean copy that follows symlinks within;
      # otherwise fall back to cp -RL
      if command -v rsync >/dev/null 2>&1; then
        rsync -a --delete --copy-links "$target/" "$dest/" 2>/dev/null || cp -RL "$target" "$dest"
      else
        cp -RL "$target" "$dest"
      fi
      echo "[import-globals] imported $name from $target"
    fi

    # Replace the global entry with a symlink into the repo
    if [[ -L "$entry" ]] || [[ -e "$entry" ]]; then
      rm -rf "$entry"
    fi
    ln -s "$dest" "$entry"
  done
}

process_root "$HOME/.claude/skills"
process_root "$HOME/.codex/skills"
