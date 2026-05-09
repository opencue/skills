#!/usr/bin/env bash
# Snapshot the user's Claude Code MCP server configuration into mcps/.
#
# Reads `mcpServers` from ~/.claude/settings.json and writes a sanitized
# JSON snapshot to mcps/claude-mcp-servers.json. Strips keys that look
# like secrets so nothing sensitive ends up in the repo.
#
# Idempotent: only writes if the snapshot would change. Silent on no-op.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target_dir="$repo_root/mcps"
target_file="$target_dir/claude-mcp-servers.json"
source_file="${HOME}/.claude/settings.json"

[[ -f "$source_file" ]] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

mkdir -p "$target_dir"

# Pull mcpServers, recursively redact any object value whose key smells like a secret.
new_snapshot=$(
  jq -e '
    def redact:
      if type == "object" then
        with_entries(
          if (.key | ascii_downcase
              | test("token|secret|password|api[_-]?key|auth[_-]?key|private[_-]?key|access[_-]?key|bearer"))
          then .value = "<redacted>"
          else .value |= redact
          end
        )
      elif type == "array" then map(redact)
      else .
      end;
    {
      generated: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
      source: "~/.claude/settings.json",
      mcpServers: ((.mcpServers // {}) | redact)
    }
  ' "$source_file" 2>/dev/null
) || exit 0

# Skip if nothing changed (compare ignoring the `generated` timestamp)
if [[ -f "$target_file" ]]; then
  old_payload=$(jq 'del(.generated)' "$target_file" 2>/dev/null || echo '{}')
  new_payload=$(echo "$new_snapshot" | jq 'del(.generated)')
  if [[ "$old_payload" == "$new_payload" ]]; then
    exit 0
  fi
fi

echo "$new_snapshot" > "$target_file"
