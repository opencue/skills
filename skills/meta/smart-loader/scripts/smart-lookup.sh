#!/usr/bin/env bash
# smart-lookup.sh [--exclude-loaded] [--limit N] <keyword>
#
# Find SKILL.md files matching <keyword>, ranked by match strength.
#
# Ranking (higher = better match):
#   100  exact name match  (name == keyword, case-insensitive)
#    80  name substring    (keyword appears in skill's name)
#    60  description match (keyword appears in description text)
#    20  body match        (keyword appears anywhere in SKILL.md)
#
# Output (one row per match, tab-separated, ranked desc, capped at limit):
#   <category>/<name>  <absolute path>  <score>  <description preview>
#
# Flags:
#   --exclude-loaded    drop skills already symlinked into the active cue
#                       runtime (CUE_ACTIVE_PROFILE env var, or read pin file)
#   --limit N           cap results (default 5)
#
# Used by the meta/smart-loader skill. Exits 0 with empty output on no match.

set -uo pipefail

EXCLUDE_LOADED=0
LIMIT=5
KEYWORD=""
while [ $# -gt 0 ]; do
  case "$1" in
    --exclude-loaded) EXCLUDE_LOADED=1; shift ;;
    --limit) LIMIT="$2"; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) KEYWORD="$1"; shift ;;
  esac
done

if [ -z "$KEYWORD" ]; then
  echo "usage: smart-lookup.sh [--exclude-loaded] [--limit N] <keyword>" >&2
  exit 2
fi

CATALOG="${CUE_CATALOG:-$HOME/Documents/cue/resources/skills/catalog/catalog.json}"
SKILLS_ROOT="${CUE_SKILLS_ROOT:-$HOME/Documents/cue/resources/skills/skills}"

# Build the "loaded skills" set from the active profile runtime if requested.
loaded_set=""
if [ "$EXCLUDE_LOADED" -eq 1 ]; then
  active="${CUE_ACTIVE_PROFILE:-}"
  if [ -z "$active" ]; then
    pin_file="$HOME/.config/cue/pins/$(pwd | sed 's|/|_|g')"
    [ -f "$pin_file" ] && active=$(cat "$pin_file" 2>/dev/null)
  fi
  if [ -z "$active" ]; then
    for d in "$HOME/.config/cue/runtime"/*/; do
      [ -d "$d/claude/skills" ] && active=$(basename "$d") && break
    done
  fi
  if [ -n "$active" ]; then
    runtime="$HOME/.config/cue/runtime/$active/claude/skills"
    if [ -d "$runtime" ]; then
      loaded_set=$(find "$runtime" -mindepth 2 -maxdepth 2 -name "*" -print 2>/dev/null \
        | sed "s|^$runtime/||" | sort -u)
    fi
  fi
fi

is_loaded() {
  [ -z "$loaded_set" ] && return 1
  grep -qFx "$1" <<< "$loaded_set"
}

# Score a single skill against the keyword. Echoes the score (integer).
score_skill() {
  local name="$1" desc="$2" path="$3"
  local kw_lower="${KEYWORD,,}" name_lower="${name,,}" desc_lower="${desc,,}"

  if [ "$name_lower" = "$kw_lower" ]; then echo 100; return; fi
  if [[ "$name_lower" == *"$kw_lower"* ]]; then echo 80; return; fi
  if [[ "$desc_lower" == *"$kw_lower"* ]]; then echo 60; return; fi
  if grep -qiF -- "$KEYWORD" "$path" 2>/dev/null; then echo 20; return; fi
  echo 0
}

# Collect candidates: catalog (with stale-path filtering) + filesystem grep.
declare -A seen
candidates=""

if [ -f "$CATALOG" ] && command -v jq >/dev/null 2>&1; then
  while IFS=$'\t' read -r cat_name src desc; do
    [ -z "$src" ] && continue
    [ -f "$src" ] || continue
    [ -n "${seen[$src]:-}" ] && continue
    seen[$src]=1
    candidates+="${cat_name}"$'\t'"${src}"$'\t'"${desc}"$'\n'
  done < <(jq -r --arg q "$KEYWORD" '
    .installed[] |
    select(
      ((.name // "") | test($q; "i")) or
      ((.description // "") | test($q; "i"))
    ) |
    "\(.category)/\(.name)\t\(.source)\t\((.description // "")[:140])"
  ' "$CATALOG" 2>/dev/null)
fi

# Filesystem sweep catches body-match hits the catalog won't surface
# (and any skills added since the catalog was last rebuilt).
if [ -d "$SKILLS_ROOT" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    [ -n "${seen[$f]:-}" ] && continue
    seen[$f]=1
    rel="${f#$SKILLS_ROOT/}"
    cat_name="${rel%/SKILL.md}"
    desc=$(awk '
      /^description:/{cap=1; sub(/^description:[[:space:]]*[>|]-?[[:space:]]*/, ""); print; next}
      cap && /^[a-zA-Z_-]+:/{exit}
      cap{sub(/^[[:space:]]+/, ""); print}
    ' "$f" 2>/dev/null | tr '\n' ' ' | cut -c1-140)
    candidates+="${cat_name}"$'\t'"${f}"$'\t'"${desc}"$'\n'
  done < <(grep -ril -- "$KEYWORD" "$SKILLS_ROOT"/*/*/SKILL.md 2>/dev/null | head -40)
fi

[ -z "$candidates" ] && exit 0

# Score, dedupe-against-loaded, sort, cap.
scored=""
while IFS=$'\t' read -r cat_name src desc; do
  [ -z "$src" ] && continue
  is_loaded "$cat_name" && continue
  name="${cat_name##*/}"
  score=$(score_skill "$name" "$desc" "$src")
  [ "$score" -eq 0 ] && continue
  scored+="${score}"$'\t'"${cat_name}"$'\t'"${src}"$'\t'"${desc}"$'\n'
done <<< "$candidates"

[ -z "$scored" ] && exit 0

printf '%s' "$scored" | sort -t$'\t' -k1,1nr -k2,2 | head -n "$LIMIT" | \
  awk -F'\t' 'BEGIN{OFS="\t"} {print $2, $3, $1, $4}'
