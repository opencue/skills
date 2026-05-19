#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$repo_root/scripts/activate-profile.sh" \
  --profile "${SOUL_SKILL_PROFILE:-all}" \
  --agent codex \
  --target "${CODEX_HOME:-$HOME/.codex}/skills"
