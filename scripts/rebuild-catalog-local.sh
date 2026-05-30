#!/usr/bin/env bash
# rebuild-catalog-local.sh
#
# Regenerate cue/resources/skills/catalog/catalog.json from the actual
# cue tree (resources/skills/skills/**/SKILL.md). No network, no soul/
# assumption, no jq-fancy upstream calls. Used to fix path drift after
# the soul/ → cue/ migration.
#
# Output schema is additive-compatible with the prior catalog. New fields:
#   triggers   — array of trigger phrases (from `triggers:` YAML list / inline)
#   links      — array of [[name]] wiki-links found in body
# Existing readers ignore unknown fields; smart-lookup.sh uses them.
#
# Side effect: writes ~/.cache/cue/catalog-rebuild.log with added/removed/moved
# skills vs the previous catalog (observability — issue #11).

set -euo pipefail

SKILLS_ROOT="${CUE_SKILLS_ROOT:-$HOME/Documents/cue/resources/skills/skills}"
CATALOG_DIR="${CUE_CATALOG_DIR:-$HOME/Documents/cue/resources/skills/catalog}"
OUT="${CATALOG_DIR}/catalog.json"
MCPS_ROOT="${CUE_MCPS_ROOT:-$HOME/Documents/cue/resources/mcps/mcps}"
DIFF_LOG="${CUE_REBUILD_LOG:-$HOME/.cache/cue/catalog-rebuild.log}"

command -v jq >/dev/null || { echo "ERROR: jq required" >&2; exit 1; }
[ -d "$SKILLS_ROOT" ] || { echo "ERROR: $SKILLS_ROOT not found" >&2; exit 1; }
mkdir -p "$CATALOG_DIR" "$(dirname "$DIFF_LOG")"

# Snapshot existing catalog (category/name → source) for diff log.
prev_snapshot=""
if [ -f "$OUT" ]; then
  prev_snapshot=$(jq -r '.installed[]? | "\(.category)/\(.name)\t\(.source // "")"' "$OUT" 2>/dev/null | sort -u)
fi

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

# Extract triggers as comma-separated string from YAML list OR inline array.
extract_triggers() {
  local file="$1"
  awk '
    BEGIN { in_fm = 0; in_trig = 0 }
    /^---[[:space:]]*$/ {
      if (in_fm == 0) { in_fm = 1; next }
      else { exit }
    }
    in_fm == 0 { next }
    # Inline form: triggers: [a, b, c]
    /^triggers:[[:space:]]*\[/ {
      line = $0
      sub(/^triggers:[[:space:]]*\[/, "", line)
      sub(/\][[:space:]]*$/, "", line)
      gsub(/"/, "", line)
      print line
      exit
    }
    # Block form start: triggers: (then `- item` lines)
    /^triggers:[[:space:]]*$/ {
      in_trig = 1
      next
    }
    in_trig == 1 {
      # End of block when we hit a new top-level key or blank line at column 0
      if ($0 ~ /^[a-zA-Z_-]+:/) { exit }
      if ($0 ~ /^[[:space:]]*-[[:space:]]+/) {
        item = $0
        sub(/^[[:space:]]*-[[:space:]]+/, "", item)
        gsub(/^"|"$/, "", item)
        gsub(/^'\''|'\''$/, "", item)
        out = (out ? out "," item : item)
      }
    }
    END { if (out) print out }
  ' "$file" 2>/dev/null
}

# Extract [[wiki-links]] from body (after the second --- of frontmatter).
extract_links() {
  local file="$1"
  awk '
    BEGIN { fm = 0; in_body = 0 }
    /^---[[:space:]]*$/ {
      fm++
      if (fm == 2) { in_body = 1; next }
      next
    }
    in_body == 0 { next }
    {
      while (match($0, /\[\[[a-z0-9_-]+\]\]/)) {
        s = substr($0, RSTART + 2, RLENGTH - 4)
        if (!seen[s]++) print s
        $0 = substr($0, RSTART + RLENGTH)
      }
    }
  ' "$file" 2>/dev/null | paste -sd, -
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
  triggers=$(extract_triggers "$f")
  links=$(extract_links "$f")

  if [ $first -eq 0 ]; then echo "," >> "$tmp"; fi
  first=0
  jq -n \
    --arg name "$name" \
    --arg desc "$desc" \
    --arg src  "$f" \
    --arg cat  "$category" \
    --arg tags "$tags" \
    --arg triggers "$triggers" \
    --arg links "$links" \
    '{
       name: $name,
       description: $desc,
       source: $src,
       category: $cat,
       tags:     ($tags     | split(",") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0))),
       triggers: ($triggers | split(",") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0))),
       links:    ($links    | split(",") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0)))
     }' \
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
    schema_version: "2.1",
    generated_at: $now,
    offline: true,
    counts: { installed: $total, upstream: 0, mcps: $mcps_count },
    installed: $installed[0],
    upstream: [],
    mcps: $mcps
  }' > "$OUT"

# ─── #11 catalog rebuild observability ───────────────────────────────────
{
  echo "===== $now  rebuild  total=$total ====="
  if [ -n "$prev_snapshot" ]; then
    new_snapshot=$(jq -r '.installed[]? | "\(.category)/\(.name)\t\(.source // "")"' "$OUT" 2>/dev/null | sort -u)
    added=$(comm -13 <(printf '%s\n' "$prev_snapshot" | cut -f1) <(printf '%s\n' "$new_snapshot" | cut -f1))
    removed=$(comm -23 <(printf '%s\n' "$prev_snapshot" | cut -f1) <(printf '%s\n' "$new_snapshot" | cut -f1))
    moved=$(join -t$'\t' \
      <(printf '%s\n' "$prev_snapshot" | sort) \
      <(printf '%s\n' "$new_snapshot" | sort) \
      | awk -F'\t' '$2 != $3 {print $1 "\t" $2 " -> " $3}')
    [ -n "$added" ]   && printf '  + added:\n%s\n'   "$(printf '%s\n' "$added"   | sed 's/^/      /')"
    [ -n "$removed" ] && printf '  - removed:\n%s\n' "$(printf '%s\n' "$removed" | sed 's/^/      /')"
    [ -n "$moved" ]   && printf '  ~ moved:\n%s\n'   "$(printf '%s\n' "$moved"   | sed 's/^/      /')"
    [ -z "$added$removed$moved" ] && echo "  (no changes)"
  else
    echo "  (first rebuild — no prior catalog to diff)"
  fi
} >> "$DIFF_LOG"

echo "wrote $OUT ($total skills, $mcps_count mcps); diff log: $DIFF_LOG" >&2
