#!/usr/bin/env bash
# Sync vercel-labs/agent-skills into skills/vercel/ (vendored read-only mirror).
# Re-run anytime to pull upstream updates. Build .zip artifacts are excluded.
#
#   bash scripts/sync-vercel-skills.sh
#
set -euo pipefail
UPSTREAM="${VERCEL_SKILLS_UPSTREAM:-https://github.com/vercel-labs/agent-skills.git}"
PREFIX="skills/vercel"
REPO_ROOT="$(git rev-parse --show-toplevel)"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT

git clone --quiet --depth=1 "$UPSTREAM" "$WORK/up"
SHA="$(git -C "$WORK/up" rev-parse HEAD)"
dest="$REPO_ROOT/$PREFIX"; mkdir -p "$dest"

# Replace vendored skill dirs (preserve UPSTREAM.md), excluding build artifacts
find "$dest" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
for d in "$WORK/up/skills"/*/; do
  rsync -a --exclude='*.zip' "$d" "$dest/$(basename "$d")/"
done
sed -i -E "s|^- Upstream commit:.*|- Upstream commit: $SHA|" "$dest/UPSTREAM.md" 2>/dev/null || true

cd "$REPO_ROOT"
git add "$PREFIX"
if git diff --cached --quiet; then
  echo "Already up to date with $SHA"
else
  git commit -q -m "chore(vercel): sync agent-skills to ${SHA:0:7}"
  echo "OK: $PREFIX synced to $SHA"
fi
