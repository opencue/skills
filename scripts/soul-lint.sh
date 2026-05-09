#!/usr/bin/env bash
# soul-lint: human-readable summary of soul SKILL.md health.
# Modes:
#   soul-lint            — human output (default), exit 1 on errors
#   soul-lint --quiet    — only errors, silent on clean
#   soul-lint --json     — raw JSON from the linter
# Called by sync-all.sh in --quiet mode every 15 min.

set -euo pipefail

MODE="${1:-human}"
LINTER="${HOME}/Documents/soul/mcps/mcps/soul-skills/lint.py"

if [[ ! -x "$LINTER" ]]; then
  echo "soul-lint: linter not found or not executable: $LINTER" >&2
  exit 2
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "soul-lint: uv is required (https://docs.astral.sh/uv/)" >&2
  exit 2
fi

result=$("$LINTER" 2>/dev/null) || result=$(uv run --quiet "$LINTER" 2>&1) || {
  echo "soul-lint: linter failed to run" >&2
  exit 2
}

err_count=$(echo "$result" | jq -r '.error_count // 0')
warn_count=$(echo "$result" | jq -r '.warning_count // 0')
checked=$(echo "$result" | jq -r '.checked // 0')

case "$MODE" in
  --json)
    echo "$result"
    ;;
  --quiet)
    if [[ "$err_count" -gt 0 ]]; then
      echo "$result" | jq -r '.errors[] | "[soul-lint ERROR] \(.path): \(.issue)"' >&2
      exit 1
    fi
    ;;
  *)
    echo "soul-lint: checked $checked skill(s)"
    if [[ "$err_count" -gt 0 ]]; then
      echo "$result" | jq -r '.errors[] | "  [ERROR] \(.path): \(.issue)"' >&2
    fi
    if [[ "$warn_count" -gt 0 ]]; then
      echo "$result" | jq -r '.warnings[] | "  [warn]  \(.path): \(.issue)"' >&2
    fi
    if [[ "$err_count" -eq 0 && "$warn_count" -eq 0 ]]; then
      echo "  all clean"
    else
      echo "  $err_count error(s), $warn_count warning(s)"
    fi
    [[ "$err_count" -gt 0 ]] && exit 1 || exit 0
    ;;
esac
