#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$repo_root/scripts/activate-profile.sh" \
  --profile "${SOUL_SKILL_PROFILE:-all}" \
  --agent claude \
  --target "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
