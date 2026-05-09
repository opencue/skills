#!/usr/bin/env bash
# Stop-hook auto-push for the skills repo.
#
# Runs after each Claude turn. If `skills/`, `mcps/`, or `docs/installed-sources.tsv`
# have uncommitted changes, auto-commits and pushes to origin/main.
#
# Silent on no-op. Best-effort: never blocks the session.
# Disable per-session by exporting SKILLS_AUTO_PUSH=0.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# Kill switch
if [[ "${SKILLS_AUTO_PUSH:-1}" == "0" ]]; then
  exit 0
fi

# Only run inside a clean git repo with origin/main reachable
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
git remote get-url origin >/dev/null 2>&1 || exit 0

# Stage only repo paths we care about — never the user's WIP elsewhere
paths_to_stage=()
for p in skills mcps plugins docs/installed-sources.tsv README.md .gitignore scripts; do
  [[ -e "$p" ]] && paths_to_stage+=("$p")
done

# Add only the tracked paths; capture if anything actually staged
git add -A "${paths_to_stage[@]}" 2>/dev/null || exit 0

if git diff --cached --quiet; then
  exit 0
fi

# Build a compact commit message from the staged diff
short_summary() {
  local added modified renamed deleted
  added=$(git diff --cached --name-only --diff-filter=A | wc -l | tr -d ' ')
  modified=$(git diff --cached --name-only --diff-filter=M | wc -l | tr -d ' ')
  renamed=$(git diff --cached --name-only --diff-filter=R | wc -l | tr -d ' ')
  deleted=$(git diff --cached --name-only --diff-filter=D | wc -l | tr -d ' ')

  local parts=()
  [[ "$added"    -gt 0 ]] && parts+=("+$added added")
  [[ "$modified" -gt 0 ]] && parts+=("~$modified modified")
  [[ "$renamed"  -gt 0 ]] && parts+=("→$renamed renamed")
  [[ "$deleted"  -gt 0 ]] && parts+=("-$deleted deleted")

  IFS=', '
  echo "${parts[*]}"
}

summary="$(short_summary)"

# First-line hint: which top-level folder changed most
top_paths=$(git diff --cached --name-only | awk -F/ '{print $1}' | sort -u | head -3 | tr '\n' ',' | sed 's/,$//')

# Commit (preserve repo's signing/hook behavior)
git commit -q -m "auto: skills sync — ${summary} (${top_paths})" 2>/dev/null || exit 0

# Push (best-effort, do not fail the session)
git push --quiet origin main 2>/dev/null || {
  echo "[auto-push] push failed; commit is local on $(git rev-parse --abbrev-ref HEAD)" >&2
  exit 0
}

# Quiet success — only log on actual push
echo "[auto-push] pushed: ${summary}" >&2
