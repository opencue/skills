#!/usr/bin/env bash
# refresh-catalog.sh
#
# Builds ~/Documents/soul/skills/catalog/catalog.json — an index of:
#   1. Locally-installed skills (from ~/.claude/skills/ and soul/skills/skills/)
#   2. Available skills in trusted upstream repos (from known_repos.json)
#   3. MCP servers under soul/mcps/mcps/
#
# Used by the `skill-suggestion` skill to answer "is there an existing skill
# that does X?" without burning a fresh GitHub search every turn.
#
# Run via:
#   ~/Documents/soul/skills/scripts/refresh-catalog.sh
#   just refresh-catalog
#
# Requires: bash, jq, gh (with valid auth), find, awk.
# Network: hits GitHub via `gh` to enumerate upstream repo trees.
# Best-effort: skips upstream sources that fail; never errors on partial data.
# Kill switch: SOUL_CATALOG_OFFLINE=1 → skip the upstream fetch, only refresh local.

set -euo pipefail

ROOT="${HOME}/Documents/soul/skills"
CATALOG_DIR="${ROOT}/catalog"
KNOWN_REPOS="${CATALOG_DIR}/known_repos.json"
OUT="${CATALOG_DIR}/catalog.json"
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

OFFLINE="${SOUL_CATALOG_OFFLINE:-0}"
LOG=()
log() { LOG+=("$1"); echo "  $1" >&2; }

# ----------------------------------------------------------------------------
# Pre-flight
# ----------------------------------------------------------------------------
command -v jq >/dev/null || { echo "ERROR: jq required" >&2; exit 1; }
[[ -f "$KNOWN_REPOS" ]] || { echo "ERROR: $KNOWN_REPOS missing" >&2; exit 1; }

if [[ "$OFFLINE" != "1" ]]; then
  command -v gh >/dev/null || { echo "WARN: gh missing — running offline" >&2; OFFLINE=1; }
  if [[ "$OFFLINE" != "1" ]] && ! gh auth status >/dev/null 2>&1; then
    echo "WARN: gh not authenticated — running offline" >&2
    OFFLINE=1
  fi
fi

echo "Building skill catalog..." >&2
echo "  out:     $OUT" >&2
echo "  offline: $OFFLINE" >&2
echo >&2

# ----------------------------------------------------------------------------
# Helpers — extract `name` and `description` from a SKILL.md frontmatter
# ----------------------------------------------------------------------------
extract_field() {
  local file="$1" field="$2"
  awk -v f="$field" '
    BEGIN { in_fm=0; collecting=0; out="" }
    /^---[[:space:]]*$/ { if (!in_fm) { in_fm=1; next } else { exit } }
    in_fm && $0 ~ ("^"f":") {
      sub("^"f":[[:space:]]*","")
      if ($0 == ">-" || $0 == ">") { collecting=1; next }
      gsub(/^[[:space:]]*"|"[[:space:]]*$/, "")
      out = $0
      print out; exit
    }
    in_fm && collecting {
      if ($0 ~ /^[a-zA-Z_-]+:/) { print out; exit }
      sub(/^[[:space:]]+/,"")
      out = (out=="" ? $0 : out " " $0)
    }
    END { if (collecting) print out }
  ' "$file" 2>/dev/null
}

# ----------------------------------------------------------------------------
# Section 1: locally installed skills
# ----------------------------------------------------------------------------
log "Scanning locally-installed skills..."
INSTALLED_JSON="$(mktemp)"
trap 'rm -f "$TMP" "$INSTALLED_JSON" "$UPSTREAM_JSON" "$MCP_JSON"' EXIT

# Source paths to scan: soul source-of-truth + Claude/Codex symlinks
declare -a SCAN_PATHS=(
  "${ROOT}/skills"
  "${HOME}/.claude/skills"
)

echo "[]" > "$INSTALLED_JSON"
INSTALLED_COUNT=0
SEEN_NAMES="$(mktemp)"; trap 'rm -f "$TMP" "$INSTALLED_JSON" "$UPSTREAM_JSON" "$MCP_JSON" "$SEEN_NAMES"' EXIT

while IFS= read -r skill_md; do
  name="$(extract_field "$skill_md" name)"
  [[ -z "$name" ]] && continue
  grep -qxF "$name" "$SEEN_NAMES" 2>/dev/null && continue
  echo "$name" >> "$SEEN_NAMES"

  desc="$(extract_field "$skill_md" description)"
  # Resolve real source path (follow symlinks)
  src="$(readlink -f "$skill_md")"
  category="$(dirname "$src" | sed 's|.*/skills/skills/||; s|/[^/]*$||')"

  jq --arg n "$name" --arg d "$desc" --arg s "$src" --arg c "$category" \
     '. += [{name: $n, description: $d, source: $s, category: $c}]' \
     "$INSTALLED_JSON" > "$TMP" && mv "$TMP" "$INSTALLED_JSON"
  INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
done < <(find "${SCAN_PATHS[@]}" -name SKILL.md -not -path '*/node_modules/*' 2>/dev/null | sort -u)

log "Found $INSTALLED_COUNT locally-installed skills"

# ----------------------------------------------------------------------------
# Section 2: upstream available skills (from known_repos.json)
# ----------------------------------------------------------------------------
UPSTREAM_JSON="$(mktemp)"
echo "[]" > "$UPSTREAM_JSON"
UPSTREAM_COUNT=0

if [[ "$OFFLINE" == "1" ]]; then
  log "Skipping upstream fetch (offline mode)"
else
  log "Fetching upstream skill catalogs..."
  REPOS_LEN="$(jq '.repos | length' "$KNOWN_REPOS")"
  for i in $(seq 0 $((REPOS_LEN - 1))); do
    owner="$(jq -r ".repos[$i].owner" "$KNOWN_REPOS")"
    name="$(jq -r ".repos[$i].name" "$KNOWN_REPOS")"
    trust="$(jq -r ".repos[$i].trust" "$KNOWN_REPOS")"
    url="$(jq -r ".repos[$i].url" "$KNOWN_REPOS")"

    log "  → $owner/$name"

    # Use gh API to list SKILL.md files in default branch (best-effort)
    if ! tree_json="$(gh api "repos/$owner/$name/git/trees/HEAD?recursive=1" 2>/dev/null)"; then
      log "    (skip: API failed)"
      continue
    fi

    # Find every SKILL.md path
    while IFS= read -r path; do
      [[ -z "$path" ]] && continue
      skill_name="$(basename "$(dirname "$path")")"
      raw_url="https://raw.githubusercontent.com/$owner/$name/HEAD/$path"
      jq --arg n "$skill_name" \
         --arg p "$path" \
         --arg r "$owner/$name" \
         --arg t "$trust" \
         --arg u "$raw_url" \
         --arg w "$url" \
         '. += [{name: $n, repo: $r, trust: $t, path: $p, raw_url: $u, web_url: $w}]' \
         "$UPSTREAM_JSON" > "$TMP" && mv "$TMP" "$UPSTREAM_JSON"
      UPSTREAM_COUNT=$((UPSTREAM_COUNT + 1))
    done < <(echo "$tree_json" | jq -r '.tree[]?.path | select(endswith("/SKILL.md") or . == "SKILL.md")')
  done
  log "Found $UPSTREAM_COUNT upstream skills across $REPOS_LEN repos"
fi

# ----------------------------------------------------------------------------
# Section 3: locally installed MCPs
# ----------------------------------------------------------------------------
MCP_JSON="$(mktemp)"
echo "[]" > "$MCP_JSON"
MCP_COUNT=0

if [[ -d "${HOME}/Documents/soul/mcps/mcps" ]]; then
  while IFS= read -r mcp_dir; do
    mcp_name="$(basename "$mcp_dir")"
    desc=""
    if [[ -f "$mcp_dir/README.md" ]]; then
      # First non-blank, non-heading line as a quick description
      desc="$(awk '/^[^#[:space:]]/{print; exit}' "$mcp_dir/README.md" | head -c 200)"
    fi
    jq --arg n "$mcp_name" --arg d "$desc" --arg p "$mcp_dir" \
       '. += [{name: $n, description: $d, source: $p}]' \
       "$MCP_JSON" > "$TMP" && mv "$TMP" "$MCP_JSON"
    MCP_COUNT=$((MCP_COUNT + 1))
  done < <(find "${HOME}/Documents/soul/mcps/mcps" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
fi
log "Found $MCP_COUNT MCP servers"

# ----------------------------------------------------------------------------
# Assemble catalog
# ----------------------------------------------------------------------------
mkdir -p "$CATALOG_DIR"
jq -n \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg offline "$OFFLINE" \
  --slurpfile installed "$INSTALLED_JSON" \
  --slurpfile upstream "$UPSTREAM_JSON" \
  --slurpfile mcps "$MCP_JSON" \
  '{
    schema_version: 1,
    generated_at: $ts,
    offline: ($offline == "1"),
    counts: {
      installed: ($installed[0] | length),
      upstream:  ($upstream[0]  | length),
      mcps:      ($mcps[0]      | length)
    },
    installed: $installed[0],
    upstream:  $upstream[0],
    mcps:      $mcps[0]
  }' > "$OUT"

echo >&2
echo "✓ Catalog written: $OUT" >&2
echo "  installed: $INSTALLED_COUNT  upstream: $UPSTREAM_COUNT  mcps: $MCP_COUNT" >&2
