#!/usr/bin/env bash
# Auto-push for the unified soul/ repo (recodeee/soul, public).
#
# Snapshots ~/Documents/soul/ → $HOME/.local/state/soul-mirror, then
# commits + pushes if anything changed. Excludes tooling state, embedded
# git dirs, and the deleted-stub mirror so soul stays a clean public
# snapshot of skills/ + mcps/.
#
# Called by sync-all.sh after the per-repo skills/mcps pushes so the
# soul mirror reflects the just-pushed state. Silent on no-op.
# Best-effort: never blocks the session. Disable via SOUL_AUTO_PUSH=0.

set -euo pipefail

if [[ "${SOUL_AUTO_PUSH:-1}" == "0" ]]; then
  exit 0
fi

SRC="${HOME}/Documents/soul"
MIRROR="${HOME}/.local/state/soul-mirror"

[[ -d "$SRC"    ]] || exit 0
[[ -d "$MIRROR" ]] || exit 0

cd "$MIRROR"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
git remote get-url origin >/dev/null 2>&1 || exit 0

# Skip during rebase/merge
if [[ -d .git/rebase-merge ]] || [[ -d .git/rebase-apply ]] || [[ -f .git/MERGE_HEAD ]]; then
  exit 0
fi

# Pull first so multi-machine commits don't diverge. --ff-only refuses on
# divergence — surface conflicts to a human, never auto-merge.
git pull --ff-only --quiet 2>/dev/null || true

# Rsync source → mirror. --delete keeps the mirror an exact snapshot
# (skills/mcps deletions propagate). Exclude tooling state, embedded
# .git dirs (mcps/ and skills/ are themselves clones), and deleted-stubs.
rsync -a --delete \
  --exclude='.git' \
  --exclude='.omc' \
  --exclude='.omx' \
  --exclude='.codex' \
  --exclude='.codex-fleet' \
  --exclude='.claude' \
  --exclude='.deleted-stubs' \
  --exclude='agent-*-2*' \
  --exclude='node_modules' \
  --exclude='target' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='.venv' \
  --exclude='dist' \
  --exclude='build' \
  --exclude='.DS_Store' \
  "$SRC/" "$MIRROR/"

# Redact personal home-dir paths before they hit the public mirror.
# Source files in ~/Documents/soul/ may use absolute /home/<user>/... paths
# (generated catalog, install-sources tsv, SKILL.md examples) — replace with
# `~` so the public repo doesn't leak the developer's home directory.
# Operates only on text files in the mirror, never the source.
find "$MIRROR" -path "$MIRROR/.git" -prune -o -type f \
  \( -name '*.md' -o -name '*.json' -o -name '*.tsv' -o -name '*.yaml' -o -name '*.yml' -o -name '*.txt' -o -name '*.sh' \) \
  -print 2>/dev/null \
  | xargs -r grep -l '/home/[a-zA-Z0-9_-]\+' 2>/dev/null \
  | xargs -r sed -i -E 's|/home/[a-zA-Z0-9_-]+|~|g' 2>/dev/null || true

# Preserve repo-level files the source doesn't own
# (LICENSE, top-level README, .gitignore — these live only in the mirror).
# rsync --delete would normally wipe them; we restore from the last commit.
for keep in LICENSE README.md .gitignore; do
  if [[ ! -e "$MIRROR/$keep" ]] && git ls-tree -r --name-only HEAD | grep -qx "$keep"; then
    git checkout -- "$keep" 2>/dev/null || true
  fi
done

git add -A 2>/dev/null || exit 0
if git diff --cached --quiet; then
  exit 0
fi

# Compact summary line
added=$(git diff --cached --name-only --diff-filter=A | wc -l | tr -d ' ')
modified=$(git diff --cached --name-only --diff-filter=M | wc -l | tr -d ' ')
deleted=$(git diff --cached --name-only --diff-filter=D | wc -l | tr -d ' ')
renamed=$(git diff --cached --name-only --diff-filter=R | wc -l | tr -d ' ')

parts=()
[[ "$added"    -gt 0 ]] && parts+=("+${added} added")
[[ "$modified" -gt 0 ]] && parts+=("~${modified} modified")
[[ "$deleted"  -gt 0 ]] && parts+=("-${deleted} deleted")
[[ "$renamed"  -gt 0 ]] && parts+=("→${renamed} renamed")
summary="${parts[*]:-mirror refresh}"

# Top-level dirs touched (skills, mcps, etc.) for at-a-glance context
top_dirs=$(git diff --cached --name-only | awk -F/ 'NF>1{print $1}' | sort -u | head -3 | paste -sd, -)
[[ -n "$top_dirs" ]] && summary="${summary} (${top_dirs})"

# Use the mirror's local git config (set once when the mirror was created)
# so we don't bake personal contact info into a script that ships publicly.
git commit --quiet -m "auto: soul sync — ${summary}" || exit 0

git push --quiet origin main 2>/dev/null || true
