#!/usr/bin/env bash
# rebuild-catalog-local.sh
#
# Regenerate cue/resources/skills/catalog/catalog.json from the actual
# cue tree (resources/skills/skills/**/SKILL.md). No network, no soul/
# assumption, no jq-fancy upstream calls. Used to fix path drift after
# the soul/ → cue/ migration.
#
# Output schema matches the existing catalog so smart-lookup.sh and
# anything else reading it continues to work.

set -euo pipefail

SKILLS_ROOT="${CUE_SKILLS_ROOT:-$HOME/Documents/cue/resources/skills/skills}"
CATALOG_DIR="${CUE_CATALOG_DIR:-$HOME/Documents/cue/resources/skills/catalog}"
OUT="${CATALOG_DIR}/catalog.json"
MCPS_ROOT="${CUE_MCPS_ROOT:-$HOME/Documents/cue/resources/mcps/mcps}"

command -v jq >/dev/null || { echo "ERROR: jq required" >&2; exit 1; }
[ -d "$SKILLS_ROOT" ] || { echo "ERROR: $SKILLS_ROOT not found" >&2; exit 1; }
mkdir -p "$CATALOG_DIR"

extract_field() {
  # extract_field <file> <key> — handles single-line, `>-` folded, and `|` literal.
  local file="$1" key="$2"
  local in_fm=0 cap=0 result="" line raw
  while IFS= read -r raw; do
    if [[ "$raw" =~ ^---[[:space:]]*$ ]]; then
      if [ $in_fm -eq 0 ]; then in_fm=1; continue; else break; fi
    fi
    [ $in_fm -eq 0 ] && continue
    if [ $cap -eq 1 ]; then
      if [[ "$raw" =~ ^[a-zA-Z_-]+: ]]; then break; fi
      line="${raw#"${raw%%[![:space:]]*}"}"
      result="${result}${line} "
      continue
    fi
    if [[ "$raw" == "$key:"* ]]; then
      line="${raw#$key:}"
      line="${line#"${line%%[![:space:]]*}"}"
      if [[ "$line" == ">"* || "$line" == "|"* ]]; then
        cap=1
      else
        result="$line"
        break
      fi
    fi
  done < "$file"
  printf '%s' "$result" | sed 's/[[:space:]]\+$//'
}

extract_tags() {
  local file="$1"
  local raw
  raw=$(grep -m1 -E "^tags:[[:space:]]*\[" "$file" 2>/dev/null || true)
  [ -z "$raw" ] && return 0
  printf '%s' "$raw" | sed -E 's/^tags:[[:space:]]*\[//; s/\][[:space:]]*$//'
}

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

echo "[" > "$tmp"
first=1
total=0

while IFS= read -r -d '' f; do
  rel="${f#$SKILLS_ROOT/}"
  cat_name="${rel%/SKILL.md}"
  category="${cat_name%%/*}"
  name=$(extract_field "$f" "name")
  [ -z "$name" ] && name="${cat_name##*/}"
  desc=$(extract_field "$f" "description")
  tags=$(extract_tags "$f")

  if [ $first -eq 0 ]; then echo "," >> "$tmp"; fi
  first=0
  jq -n \
    --arg name "$name" \
    --arg desc "$desc" \
    --arg src  "$f" \
    --arg cat  "$category" \
    --arg tags "$tags" \
    '{name: $name, description: $desc, source: $src, category: $cat, tags: ($tags | split(",") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0)))}' \
    >> "$tmp"
  total=$((total + 1))
done < <(find "$SKILLS_ROOT" -mindepth 2 -name SKILL.md -print0)

echo "]" >> "$tmp"

mcps_count=0
mcps_json="[]"
if [ -d "$MCPS_ROOT" ]; then
  mcps_count=$(find "$MCPS_ROOT" -mindepth 1 -maxdepth 1 -type d | wc -l)
  mcps_json=$(find "$MCPS_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | jq -R . | jq -s .)
fi

now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
jq -n \
  --slurpfile installed "$tmp" \
  --argjson mcps "$mcps_json" \
  --arg now "$now" \
  --argjson total "$total" \
  --argjson mcps_count "$mcps_count" \
  '{
    schema_version: "2.0",
    generated_at: $now,
    offline: true,
    counts: { installed: $total, upstream: 0, mcps: $mcps_count },
    installed: $installed[0],
    upstream: [],
    mcps: $mcps
  }' > "$OUT"

echo "wrote $OUT ($total skills, $mcps_count mcps)" >&2
