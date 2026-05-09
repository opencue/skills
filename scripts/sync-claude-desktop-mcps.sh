#!/usr/bin/env bash
# One-way sync: ~/.claude.json `mcpServers` → ~/.config/Claude/claude_desktop_config.json
#
# Why: `claude mcp add` writes to ~/.claude.json (Claude Code's canonical
# config). Claude Desktop reads its own file and doesn't share state. This
# script propagates new/removed/changed MCPs into Desktop's config so a
# Desktop restart picks them up.
#
# Adapter rules (Claude Desktop's stdio schema is stricter than Claude Code's):
#   - Drop entries with type="http" / "sse" / a `url` field — those are remote
#     MCPs and Desktop expects them via the Connectors UI, not local config.
#     Keeping them in mcpServers makes Desktop reject the WHOLE block.
#   - Strip the `type` field from stdio entries — Desktop's strict schema
#     rejects entries that have it.
#   - Preserve Desktop's existing `preferences` block byte-for-byte.
#
# Sync direction is one-way (CLI → Desktop). If you add an MCP via Desktop's
# "Edit Config" UI, the next sync run will overwrite it from ~/.claude.json.
# Treat ~/.claude.json as the source of truth for both CLI and Desktop MCPs.
#
# Idempotent: only writes when the resulting file content actually differs.
# Silent on no-op. Best-effort: never blocks the calling sync.
# Kill switch: export CLAUDE_DESKTOP_MCP_SYNC_OFF=1.

set -euo pipefail

if [[ "${CLAUDE_DESKTOP_MCP_SYNC_OFF:-0}" == "1" ]]; then
  exit 0
fi

src="${HOME}/.claude.json"
dst="${HOME}/.config/Claude/claude_desktop_config.json"

[[ -f "$src" ]] || exit 0
[[ -f "$dst" ]] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# ── REVERSE merge: if Desktop has stdio MCPs not in ~/.claude.json (because
# user added them via Desktop's "Edit Config" UI), pull them back so the next
# forward-sync pass doesn't wipe them. Skips http/sse entries (those don't
# exist in Desktop config anyway after the forward sync filters them out).
orphans=$(jq -r --slurpfile cli "$src" '
  .mcpServers // {} as $desktop |
  ($cli[0].mcpServers // {}) as $known |
  $desktop | to_entries | map(
    select(.key as $k | ($known | has($k)) | not)
    | select((.value.type // "stdio") == "stdio")
    | select((.value.command // null) != null)
  ) | from_entries | keys[]
' "$dst" 2>/dev/null || true)

if [[ -n "$orphans" ]]; then
  bak="${src}.soul-backup"
  cp -f "$src" "$bak"
  merged=$(jq -s '
    .[0] as $cli |
    (.[1].mcpServers // {}) as $desktop |
    $cli * { mcpServers: (($cli.mcpServers // {}) + (
      $desktop | with_entries(
        select((.value.type // "stdio") == "stdio")
        | select((.value.command // null) != null)
      )
    )) }
  ' "$src" "$dst" 2>/dev/null) || merged=""
  if [[ -n "$merged" ]] && echo "$merged" | jq empty 2>/dev/null; then
    tmp=$(mktemp "${src}.XXXXXX")
    echo "$merged" > "$tmp"
    mv "$tmp" "$src"
    echo "[claude-desktop sync] reverse-merged orphans → ~/.claude.json (backup: $bak):" >&2
    echo "$orphans" | sed 's/^/  + /' >&2
  else
    echo "[claude-desktop sync] reverse-merge produced invalid JSON; skipped" >&2
  fi
fi

new_content=$(jq -s '
  .[0].mcpServers as $cli_mcps |
  .[1] as $desktop |
  ( ($cli_mcps // {}) | with_entries(
      select(
        (.value.type // "stdio") != "http"
        and (.value.type // "stdio") != "sse"
        and (.value.url // null) == null
      )
      | .value |= (del(.type) | del(.url))
    )
  ) as $stdio_only |
  ($desktop // {}) | .mcpServers = $stdio_only
' "$src" "$dst" 2>/dev/null) || exit 0

[[ -z "$new_content" ]] && exit 0

old_norm=$(jq -S '.' "$dst" 2>/dev/null || echo '{}')
new_norm=$(echo "$new_content" | jq -S '.')

if [[ "$old_norm" == "$new_norm" ]]; then
  exit 0
fi

# Show what's changing — useful when this fires from the timer
diff_summary=$(diff <(echo "$old_norm" | jq -r '.mcpServers // {} | keys[]' 2>/dev/null | sort) \
                    <(echo "$new_norm" | jq -r '.mcpServers // {} | keys[]' 2>/dev/null | sort) \
                | grep -E '^[<>]' || true)

# Atomic write: temp file then rename. Avoids a half-written file if Desktop
# is reading at the same instant (it never is in practice — only reads on boot).
tmp=$(mktemp "${dst}.XXXXXX")
echo "$new_content" > "$tmp"
mv "$tmp" "$dst"

echo "[claude-desktop sync] mcpServers updated:" >&2
[[ -n "$diff_summary" ]] && echo "$diff_summary" >&2

# Best-effort desktop notification — non-blocking, ignored if notify-send absent
if command -v notify-send >/dev/null 2>&1; then
  notify-send -u low \
    "Claude Desktop MCPs synced" \
    "Restart Claude Desktop to load the new MCPs." 2>/dev/null || true
fi

exit 0
