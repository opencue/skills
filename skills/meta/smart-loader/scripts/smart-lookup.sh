#!/usr/bin/env bash
# smart-lookup.sh [--exclude-loaded] [--limit N] [--no-fuzzy] <keyword>
#
# Find SKILL.md files matching <keyword>, ranked by match strength.
#
# Ranking (higher = better match):
#   100  exact name match  (name == keyword, case-insensitive)
#    80  name substring    (keyword appears in skill's name)
#    60  description match (keyword appears in description text)
#    20  body match        (keyword appears anywhere in SKILL.md)
#    10  fuzzy name match  (within edit distance via difflib, fallback only)
#
# Output (one row per match, tab-separated, ranked desc, capped at limit):
#   <category>/<name>  <abs path>  <score>  <description>  <mcp_status>
#
# mcp_status column:
#   ""              skill declares no requires_mcps
#   "ok"            skill needs an MCP and it is loaded in active profile
#   "missing:<m1,m2>" skill needs MCPs that are NOT loaded; user must
#                     `cue use <profile>` that provides them
#
# Flags:
#   --exclude-loaded    drop skills already symlinked into the active cue
#                       runtime (CUE_ACTIVE_PROFILE env var, or pin file)
#   --limit N           cap results (default 5)
#   --no-fuzzy          disable difflib fuzzy fallback on zero hits
#
# Used by the meta/smart-loader skill. Exits 0 with empty output on no match.

set -uo pipefail

EXCLUDE_LOADED=0
LIMIT=5
NO_FUZZY=0
KEYWORD=""
while [ $# -gt 0 ]; do
  case "$1" in
    --exclude-loaded) EXCLUDE_LOADED=1; shift ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --no-fuzzy) NO_FUZZY=1; shift ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *) KEYWORD="$1"; shift ;;
  esac
done

if [ -z "$KEYWORD" ]; then
  echo "usage: smart-lookup.sh [--exclude-loaded] [--limit N] [--no-fuzzy] <keyword>" >&2
  exit 2
fi

CATALOG="${CUE_CATALOG:-$HOME/Documents/cue/resources/skills/catalog/catalog.json}"
SKILLS_ROOT="${CUE_SKILLS_ROOT:-$HOME/Documents/cue/resources/skills/skills}"
REBUILD_SCRIPT="${CUE_REBUILD_SCRIPT:-$HOME/Documents/cue/resources/skills/scripts/rebuild-catalog-local.sh}"
REBUILD_THROTTLE="${CUE_REBUILD_THROTTLE:-/tmp/cue-catalog-rebuild.stamp}"

# ─── #5 stale-catalog auto-rebuild ─────────────────────────────────────
# Rebuild only if (a) catalog older than newest SKILL.md AND
# (b) we haven't already rebuilt in the last 60 seconds.
if [ -f "$CATALOG" ] && [ -x "$REBUILD_SCRIPT" ] && [ -d "$SKILLS_ROOT" ]; then
  newest_skill=$(find "$SKILLS_ROOT" -name "SKILL.md" -printf '%T@\n' 2>/dev/null | sort -rn | head -1)
  catalog_mtime=$(stat -c '%Y' "$CATALOG" 2>/dev/null)
  throttle_mtime=$(stat -c '%Y' "$REBUILD_THROTTLE" 2>/dev/null || echo 0)
  now=$(date +%s)
  if [ -n "$newest_skill" ] && [ -n "$catalog_mtime" ]; then
    newest_int="${newest_skill%.*}"
    if [ "$newest_int" -gt "$catalog_mtime" ] && [ $((now - throttle_mtime)) -gt 60 ]; then
      bash "$REBUILD_SCRIPT" >/dev/null 2>&1 || true
      touch "$REBUILD_THROTTLE"
    fi
  fi
fi

# ─── Resolve active profile (used by both --exclude-loaded and #2 MCP) ──
active_profile=""
resolve_active_profile() {
  [ -n "$active_profile" ] && return
  active_profile="${CUE_ACTIVE_PROFILE:-}"
  # CLAUDE_CONFIG_DIR is the canonical signal: cue sets it at launch to
  # ~/.config/cue/runtime/<profile>/claude. Trust it over heuristics.
  if [ -z "$active_profile" ] && [ -n "${CLAUDE_CONFIG_DIR:-}" ]; then
    case "$CLAUDE_CONFIG_DIR" in
      *"/cue/runtime/"*"/claude")
        active_profile="${CLAUDE_CONFIG_DIR#*/cue/runtime/}"
        active_profile="${active_profile%/claude}"
        ;;
    esac
  fi
  if [ -z "$active_profile" ]; then
    pin_file="$HOME/.config/cue/pins/$(pwd | sed 's|/|_|g')"
    [ -f "$pin_file" ] && active_profile=$(cat "$pin_file" 2>/dev/null)
  fi
  # Last-resort: pick the most-recently-modified runtime (not the first
  # alphabetical one — that's almost always the wrong answer when multiple
  # runtimes exist from prior `cue use` invocations).
  if [ -z "$active_profile" ]; then
    for d in $(ls -1dt "$HOME/.config/cue/runtime"/*/ 2>/dev/null); do
      [ -d "$d/claude/skills" ] && active_profile=$(basename "$d") && break
    done
  fi
}

# Build the "loaded skills" set from the active profile runtime if requested.
loaded_set=""
if [ "$EXCLUDE_LOADED" -eq 1 ]; then
  resolve_active_profile
  if [ -n "$active_profile" ]; then
    runtime="$HOME/.config/cue/runtime/$active_profile/claude/skills"
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

# ─── #2 MCP-aware matching ──────────────────────────────────────────────
# Build the set of MCPs the active profile has actually loaded by reading
# the materialized runtime's settings.json.
loaded_mcps=""
resolve_active_profile
if [ -n "$active_profile" ]; then
  mcp_file="$HOME/.config/cue/runtime/$active_profile/claude/settings.json"
  if [ -f "$mcp_file" ] && command -v jq >/dev/null 2>&1; then
    loaded_mcps=$(jq -r '.mcpServers // {} | keys[]' "$mcp_file" 2>/dev/null | sort -u)
  fi
fi

# Extract `requires_mcps: [...]` from a SKILL.md frontmatter.
# Echoes comma-separated MCP names; empty if none required.
extract_requires_mcps() {
  local file="$1"
  awk '
    BEGIN{in_fm=0}
    /^---[[:space:]]*$/ { if (in_fm==0){in_fm=1; next} else {exit} }
    in_fm==0 { next }
    /^requires_mcps:[[:space:]]*\[/ {
      sub(/^requires_mcps:[[:space:]]*\[/, "")
      sub(/\][[:space:]]*$/, "")
      gsub(/[[:space:]]/, "")
      gsub(/"/, "")
      print
      exit
    }
  ' "$file" 2>/dev/null
}

# Given a comma-separated requires list, return mcp_status column value.
mcp_status() {
  local req="$1"
  [ -z "$req" ] && { echo ""; return; }
  local missing=""
  IFS=',' read -ra parts <<< "$req"
  for m in "${parts[@]}"; do
    [ -z "$m" ] && continue
    if ! grep -qFx "$m" <<< "$loaded_mcps"; then
      missing+="${m},"
    fi
  done
  missing="${missing%,}"
  if [ -z "$missing" ]; then echo "ok"; else echo "missing:$missing"; fi
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

# Score, dedupe-against-loaded, attach MCP status.
scored=""
while IFS=$'\t' read -r cat_name src desc; do
  [ -z "$src" ] && continue
  is_loaded "$cat_name" && continue
  name="${cat_name##*/}"
  score=$(score_skill "$name" "$desc" "$src")
  [ "$score" -eq 0 ] && continue
  req=$(extract_requires_mcps "$src")
  status=$(mcp_status "$req")
  scored+="${score}"$'\t'"${cat_name}"$'\t'"${src}"$'\t'"${desc}"$'\t'"${status}"$'\n'
done <<< "$candidates"

# ─── #4 fuzzy fallback ──────────────────────────────────────────────────
# If exact lookup returned zero scored hits, ask difflib for close matches
# against the catalog's name list. Tag fuzzy hits with score=10.
if [ -z "$scored" ] && [ "$NO_FUZZY" -ne 1 ] && [ -f "$CATALOG" ] && command -v python3 >/dev/null 2>&1; then
  fuzzy=$(python3 - "$KEYWORD" "$CATALOG" <<'PYEOF' 2>/dev/null
import difflib, json, sys
kw = sys.argv[1].lower()
try:
    catalog = json.load(open(sys.argv[2]))
except Exception:
    sys.exit(0)
entries = catalog.get('installed', [])
names = [(e.get('name', '').lower(), e) for e in entries]
matches = difflib.get_close_matches(kw, [n[0] for n in names], n=5, cutoff=0.6)
seen = set()
for m in matches:
    for n, e in names:
        if n == m and e.get('source') and e.get('name') not in seen:
            seen.add(e.get('name'))
            cat = e.get('category', '')
            name = e.get('name', '')
            src = e.get('source', '')
            desc = (e.get('description') or '')[:140]
            print(f"{cat}/{name}\t{src}\t{desc}")
            break
PYEOF
)
  if [ -n "$fuzzy" ]; then
    while IFS=$'\t' read -r cat_name src desc; do
      [ -z "$src" ] || [ ! -f "$src" ] && continue
      is_loaded "$cat_name" && continue
      req=$(extract_requires_mcps "$src")
      status=$(mcp_status "$req")
      scored+="10"$'\t'"${cat_name}"$'\t'"${src}"$'\t'"${desc} (fuzzy)"$'\t'"${status}"$'\n'
    done <<< "$fuzzy"
  fi
fi

[ -z "$scored" ] && exit 0

printf '%s' "$scored" | sort -t$'\t' -k1,1nr -k2,2 | head -n "$LIMIT" | \
  awk -F'\t' 'BEGIN{OFS="\t"} {print $2, $3, $1, $4, $5}'
