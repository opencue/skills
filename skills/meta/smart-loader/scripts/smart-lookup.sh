#!/usr/bin/env bash
# smart-lookup.sh — find SKILL.md files matching a query, ranked.
#
# v2: multi-keyword, triggers/tags-aware, field-weighted, multilingual,
# project-context boosts, feedback-learned, explain mode, embed fallback.
# Backward compatible: a single-word call works exactly like v1.
#
# Usage:
#   smart-lookup.sh [flags] <query...>
#     <query> may be one word (legacy) or multiple words (new).
#
# Flags:
#   --exclude-loaded     drop skills already in active profile
#   --limit N            cap results (default: 5 strict, 10 loose)
#   --no-fuzzy           disable difflib fuzzy fallback
#   --no-embed           disable embedding fallback (default off unless CUE_USE_EMBEDDINGS=1)
#   --no-cache           ignore feedback-log boost
#   --explain            append 6th tab column: matched-field+token info
#   --mode strict|loose  strict (default) keeps cutoff at score>0; loose lowers limit
#                         floor and shows top 10
#   --record-pick CAT/NAME
#                        append (query, CAT/NAME) to feedback log, exit 0
#
# Scoring tiers (per token, highest field wins):
#   100  exact name match              (name == token)
#    90  trigger phrase contains token
#    80  name substring                (token in name)
#    70  tag exact match
#    60  description contains token
#    40  H1/H2 heading contains token
#    20  body contains token
#    10  fuzzy name match (difflib fallback)
#
# Cross-token bonuses:
#   x1.5  if >=2 tokens hit the same skill
#   +15   if (normalized_query, skill) recorded in feedback log
#   +10   if cwd matches a cwd-domains pattern boosting this skill's category
#
# Output (TSV per row, ranked desc, capped at LIMIT):
#   <category/name>  <abs path>  <score>  <description>  <mcp_status>  [explain]
#
# Exit 0 with empty stdout = no match.

set -uo pipefail

# ─── Flag parsing ───────────────────────────────────────────────────────
EXCLUDE_LOADED=0
LIMIT=""
NO_FUZZY=0
NO_EMBED=0
NO_CACHE=0
EXPLAIN=0
MODE="strict"
RECORD_PICK=""
QUERY_TOKENS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --exclude-loaded) EXCLUDE_LOADED=1; shift ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --no-fuzzy) NO_FUZZY=1; shift ;;
    --no-embed) NO_EMBED=1; shift ;;
    --no-cache) NO_CACHE=1; shift ;;
    --explain) EXPLAIN=1; shift ;;
    --mode) MODE="$2"; shift 2 ;;
    --record-pick) RECORD_PICK="$2"; shift 2 ;;
    -h|--help) sed -n '2,50p' "$0"; exit 0 ;;
    --) shift; QUERY_TOKENS+=("$@"); break ;;
    *)  QUERY_TOKENS+=("$1"); shift ;;
  esac
done

# Default limit by mode
if [ -z "$LIMIT" ]; then
  if [ "$MODE" = "loose" ]; then LIMIT=10; else LIMIT=5; fi
fi

# ─── Paths ──────────────────────────────────────────────────────────────
CATALOG="${CUE_CATALOG:-$HOME/Documents/cue/resources/skills/catalog/catalog.json}"
SKILLS_ROOT="${CUE_SKILLS_ROOT:-$HOME/Documents/cue/resources/skills/skills}"
REBUILD_SCRIPT="${CUE_REBUILD_SCRIPT:-$HOME/Documents/cue/resources/skills/scripts/rebuild-catalog-local.sh}"
REBUILD_THROTTLE="${CUE_REBUILD_THROTTLE:-/tmp/cue-catalog-rebuild.stamp}"
ALIASES_FILE="${CUE_ALIASES:-$HOME/Documents/cue/resources/skills/skills/meta/smart-loader/aliases.json}"
CWD_DOMAINS="${CUE_CWD_DOMAINS:-$HOME/.config/cue/cwd-domains.json}"
FEEDBACK_LOG="${CUE_FEEDBACK_LOG:-$HOME/.cache/cue/smart-loader.jsonl}"
MISS_CACHE="${CUE_MISS_CACHE:-$HOME/.cache/cue/smart-loader-misses}"
EMBED_SCRIPT="$HOME/Documents/cue/resources/skills/skills/meta/smart-loader/scripts/embed-search.py"
mkdir -p "$(dirname "$FEEDBACK_LOG")" "$(dirname "$MISS_CACHE")" 2>/dev/null

# ─── --record-pick: append feedback and exit ────────────────────────────
if [ -n "$RECORD_PICK" ]; then
  if [ ${#QUERY_TOKENS[@]} -eq 0 ]; then
    echo "usage: --record-pick CAT/NAME <query...>" >&2
    exit 2
  fi
  q_norm=$(printf '%s ' "${QUERY_TOKENS[@],,}" | sed 's/[[:space:]]\+$//')
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  printf '{"ts":"%s","query":"%s","skill":"%s"}\n' "$ts" "$q_norm" "$RECORD_PICK" >> "$FEEDBACK_LOG"
  exit 0
fi

if [ ${#QUERY_TOKENS[@]} -eq 0 ]; then
  echo "usage: smart-lookup.sh [flags] <query...>" >&2
  exit 2
fi

# Legacy single-arg: someone passed "foo bar" as one argument → split it.
if [ ${#QUERY_TOKENS[@]} -eq 1 ] && [[ "${QUERY_TOKENS[0]}" == *" "* ]]; then
  # shellcheck disable=SC2206
  QUERY_TOKENS=( ${QUERY_TOKENS[0]} )
fi

# ─── #4 multilingual alias expansion ────────────────────────────────────
expanded_tokens=()
if [ -f "$ALIASES_FILE" ] && command -v jq >/dev/null 2>&1; then
  for t in "${QUERY_TOKENS[@]}"; do
    tl="${t,,}"
    expanded_tokens+=("$tl")
    extras=$(jq -r --arg k "$tl" '.[$k] // [] | .[]' "$ALIASES_FILE" 2>/dev/null)
    if [ -n "$extras" ]; then
      while IFS= read -r e; do
        [ -n "$e" ] && expanded_tokens+=("$e")
      done <<< "$extras"
    fi
  done
else
  for t in "${QUERY_TOKENS[@]}"; do expanded_tokens+=("${t,,}"); done
fi
# Dedupe expanded_tokens
uniq_tokens=()
declare -A seen_tok
for t in "${expanded_tokens[@]}"; do
  [ -z "$t" ] && continue
  if [ -z "${seen_tok[$t]:-}" ]; then
    uniq_tokens+=("$t")
    seen_tok[$t]=1
  fi
done

# Normalized query string for feedback lookup + miss cache
NORM_QUERY=$(printf '%s ' "${QUERY_TOKENS[@],,}" | sed 's/[[:space:]]\+$//')
NORM_QUERY_KEY=$(printf '%s' "$NORM_QUERY" | tr ' ' '_')

# ─── #8 negative-cache check ────────────────────────────────────────────
# Skip the full pipeline if we missed on this exact query within 5 minutes.
if [ -f "$MISS_CACHE" ]; then
  cutoff=$(( $(date +%s) - 300 ))
  if awk -F'\t' -v key="$NORM_QUERY_KEY" -v cutoff="$cutoff" '
      $1 == key && $2 >= cutoff { found=1; exit }
      END { exit found ? 0 : 1 }
    ' "$MISS_CACHE" 2>/dev/null; then
    exit 0
  fi
fi

# ─── Stale-catalog auto-rebuild (throttled) ─────────────────────────────
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

# ─── Active profile resolution ──────────────────────────────────────────
active_profile=""
resolve_active_profile() {
  [ -n "$active_profile" ] && return
  active_profile="${CUE_ACTIVE_PROFILE:-}"
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
  if [ -z "$active_profile" ]; then
    for d in $(ls -1dt "$HOME/.config/cue/runtime"/*/ 2>/dev/null); do
      [ -d "$d/claude/skills" ] && active_profile=$(basename "$d") && break
    done
  fi
}
resolve_active_profile

loaded_set=""
if [ "$EXCLUDE_LOADED" -eq 1 ] && [ -n "$active_profile" ]; then
  runtime="$HOME/.config/cue/runtime/$active_profile/claude/skills"
  if [ -d "$runtime" ]; then
    loaded_set=$(find "$runtime" -mindepth 2 -maxdepth 2 -name "*" -print 2>/dev/null \
      | sed "s|^$runtime/||" | sort -u)
  fi
fi
is_loaded() {
  [ -z "$loaded_set" ] && return 1
  grep -qFx "$1" <<< "$loaded_set"
}

# ─── MCP-loaded set ─────────────────────────────────────────────────────
loaded_mcps=""
if [ -n "$active_profile" ]; then
  mcp_file="$HOME/.config/cue/runtime/$active_profile/claude/settings.json"
  if [ -f "$mcp_file" ] && command -v jq >/dev/null 2>&1; then
    loaded_mcps=$(jq -r '.mcpServers // {} | keys[]' "$mcp_file" 2>/dev/null | sort -u)
  fi
fi

extract_requires_mcps() {
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
  ' "$1" 2>/dev/null
}

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

# ─── #7 cwd-domain boost map ────────────────────────────────────────────
cwd_boost_cats=""
if [ -f "$CWD_DOMAINS" ] && command -v jq >/dev/null 2>&1; then
  cwd_path=$(pwd)
  cwd_boost_cats=$(jq -r --arg p "$cwd_path" '
    .patterns // [] | map(select(.match as $m | $p | contains($m))) | first | .boost_categories // [] | .[]
  ' "$CWD_DOMAINS" 2>/dev/null | sort -u)
fi
cwd_boost_for_category() {
  [ -z "$cwd_boost_cats" ] && { echo 0; return; }
  grep -qFx "$1" <<< "$cwd_boost_cats" && echo 10 || echo 0
}

# ─── #6 feedback boost (skills user previously accepted for this query) ─
feedback_boost_for() {
  [ "$NO_CACHE" -eq 1 ] && { echo 0; return; }
  [ ! -f "$FEEDBACK_LOG" ] && { echo 0; return; }
  command -v jq >/dev/null 2>&1 || { echo 0; return; }
  local skill="$1"
  local hit
  hit=$(jq -r --arg q "$NORM_QUERY" --arg s "$skill" \
    'select(.query == $q and .skill == $s) | .ts' "$FEEDBACK_LOG" 2>/dev/null | head -1)
  [ -n "$hit" ] && echo 15 || echo 0
}

# ─── #1+#3 field-weighted single-token scoring ──────────────────────────
# Echoes: <score>\t<matched_field>:<token>
score_token_against_skill() {
  local token="$1" name="$2" desc="$3" path="$4" triggers="$5" tags="$6"
  local tl="${token,,}"
  local nl="${name,,}" dl="${desc,,}"

  # 100 exact name
  if [ "$nl" = "$tl" ]; then echo $'100\tname='"$token"; return; fi
  # 90 trigger phrase substring (triggers are pipe-separated)
  if [ -n "$triggers" ] && [[ "${triggers,,}" == *"$tl"* ]]; then
    echo $'90\ttrigger='"$token"; return
  fi
  # 80 name substring
  if [[ "$nl" == *"$tl"* ]]; then echo $'80\tname~'"$token"; return; fi
  # 70 tag exact match (tags are pipe-separated)
  if [ -n "$tags" ]; then
    IFS='|' read -ra tag_arr <<< "$tags"
    for t in "${tag_arr[@]}"; do
      if [ "${t,,}" = "$tl" ]; then echo $'70\ttag='"$token"; return; fi
    done
  fi
  # 60 description match
  if [[ "$dl" == *"$tl"* ]]; then echo $'60\tdesc~'"$token"; return; fi
  # 40 H1/H2 match
  if [ -f "$path" ] && grep -qiE "^#{1,2} .*$tl" "$path" 2>/dev/null; then
    echo $'40\thead~'"$token"; return
  fi
  # 20 body match
  if [ -f "$path" ] && grep -qiF -- "$token" "$path" 2>/dev/null; then
    echo $'20\tbody~'"$token"; return
  fi
  echo $'0\t'
}

# ─── Pull candidate set from catalog (with triggers/tags if present) ────
# Output rows: cat/name \t source \t desc \t triggers \t tags
candidates=""
declare -A seen_path

if [ -f "$CATALOG" ] && command -v jq >/dev/null 2>&1; then
  # Build a jq filter that matches if ANY token appears in name/desc/triggers/tags.
  jq_query=$(printf '%s\n' "${uniq_tokens[@]}" | jq -R . | jq -s 'map(ascii_downcase)')
  rows=$(jq -r --argjson q "$jq_query" '
    .installed[] |
    . as $e |
    (((.name // "") + " " + (.description // "") + " " +
       ((.triggers // []) | join(" ")) + " " +
       ((.tags // []) | join(" "))) | ascii_downcase) as $hay |
    select(any($q[]; $hay | contains(.))) |
    [
      "\(.category)/\(.name)",
      (.source // ""),
      ((.description // "")[:140]),
      ((.triggers // []) | join("|")),
      ((.tags // []) | join("|"))
    ] | @tsv
  ' "$CATALOG" 2>/dev/null)
  while IFS=$'\t' read -r cat_name src desc triggers tags; do
    [ -z "$src" ] && continue
    [ -f "$src" ] || continue
    [ -n "${seen_path[$src]:-}" ] && continue
    seen_path[$src]=1
    candidates+="${cat_name}"$'\t'"${src}"$'\t'"${desc}"$'\t'"${triggers}"$'\t'"${tags}"$'\n'
  done <<< "$rows"
fi

# Live filesystem fallback for tokens not yet in catalog (rare path).
if [ -d "$SKILLS_ROOT" ]; then
  for t in "${uniq_tokens[@]}"; do
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      [ -n "${seen_path[$f]:-}" ] && continue
      seen_path[$f]=1
      rel="${f#$SKILLS_ROOT/}"
      cat_name="${rel%/SKILL.md}"
      desc=$(awk '
        /^description:/{cap=1; sub(/^description:[[:space:]]*[>|]-?[[:space:]]*/, ""); print; next}
        cap && /^[a-zA-Z_-]+:/{exit}
        cap{sub(/^[[:space:]]+/, ""); print}
      ' "$f" 2>/dev/null | tr '\n' ' ' | cut -c1-140)
      candidates+="${cat_name}"$'\t'"${f}"$'\t'"${desc}"$'\t'$'\t'$'\n'
    done < <(grep -ril -- "$t" "$SKILLS_ROOT"/*/*/SKILL.md 2>/dev/null | head -20)
  done
fi

# ─── Score each candidate across all tokens with co-occurrence boost ────
scored=""
while IFS=$'\t' read -r cat_name src desc triggers tags; do
  [ -z "$src" ] && continue
  is_loaded "$cat_name" && continue
  name="${cat_name##*/}"
  category="${cat_name%%/*}"

  total=0
  hit_tokens=0
  explain=""
  for t in "${uniq_tokens[@]}"; do
    res=$(score_token_against_skill "$t" "$name" "$desc" "$src" "$triggers" "$tags")
    s="${res%%$'\t'*}"
    why="${res#*$'\t'}"
    if [ "${s:-0}" -gt 0 ]; then
      total=$((total + s))
      hit_tokens=$((hit_tokens + 1))
      explain="${explain}${why};"
    fi
  done

  [ "$total" -eq 0 ] && continue

  # x1.5 co-occurrence
  if [ "$hit_tokens" -ge 2 ]; then
    total=$(( total * 3 / 2 ))
    explain="${explain}cooc=${hit_tokens}x;"
  fi

  # +15 feedback
  fb=$(feedback_boost_for "$cat_name")
  if [ "$fb" -gt 0 ]; then
    total=$((total + fb))
    explain="${explain}feedback+${fb};"
  fi

  # +10 cwd boost
  cb=$(cwd_boost_for_category "$category")
  if [ "$cb" -gt 0 ]; then
    total=$((total + cb))
    explain="${explain}cwd+${cb};"
  fi

  req=$(extract_requires_mcps "$src")
  status=$(mcp_status "$req")
  scored+="${total}"$'\t'"${cat_name}"$'\t'"${src}"$'\t'"${desc}"$'\t'"${status}"$'\t'"${explain%;}"$'\n'
done <<< "$candidates"

# ─── Fuzzy fallback (difflib) ───────────────────────────────────────────
if [ -z "$scored" ] && [ "$NO_FUZZY" -ne 1 ] && [ -f "$CATALOG" ] && command -v python3 >/dev/null 2>&1; then
  fuzzy=$(python3 - "$NORM_QUERY" "$CATALOG" <<'PYEOF' 2>/dev/null
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
      scored+="10"$'\t'"${cat_name}"$'\t'"${src}"$'\t'"${desc} (fuzzy)"$'\t'"${status}"$'\t'"fuzzy"$'\n'
    done <<< "$fuzzy"
  fi
fi

# ─── #10 embedding fallback (opt-in) ────────────────────────────────────
if [ -z "$scored" ] && [ "$NO_EMBED" -ne 1 ] \
   && [ -n "${CUE_USE_EMBEDDINGS:-}" ] && [ -x "$EMBED_SCRIPT" ]; then
  emb=$(python3 "$EMBED_SCRIPT" "$NORM_QUERY" "$LIMIT" 2>/dev/null)
  if [ -n "$emb" ]; then
    while IFS=$'\t' read -r cat_name sim; do
      [ -z "$cat_name" ] && continue
      # Resolve path/desc from catalog
      row=$(jq -r --arg n "$cat_name" '
        .installed[] | select((.category + "/" + .name) == $n) |
        [.source, (.description // "")[:140]] | @tsv
      ' "$CATALOG" 2>/dev/null | head -1)
      [ -z "$row" ] && continue
      src="${row%%$'\t'*}"
      desc="${row#*$'\t'}"
      [ -f "$src" ] || continue
      is_loaded "$cat_name" && continue
      req=$(extract_requires_mcps "$src")
      status=$(mcp_status "$req")
      # Map cosine [0..1] into score [10..50] so it sits between fuzzy and desc-match
      iscore=$(awk -v s="$sim" 'BEGIN { printf "%d", 10 + s * 40 }')
      scored+="${iscore}"$'\t'"${cat_name}"$'\t'"${src}"$'\t'"${desc} (semantic ${sim})"$'\t'"${status}"$'\t'"embed=${sim}"$'\n'
    done <<< "$emb"
  fi
fi

# ─── Strict-mode floor (loose lowers it implicitly via top-N) ───────────
if [ -z "$scored" ]; then
  # Record miss in negative cache (#8) and emit scaffold hint (#9)
  now_ts=$(date +%s)
  printf '%s\t%s\n' "$NORM_QUERY_KEY" "$now_ts" >> "$MISS_CACHE"
  # Trim cache to last 200 lines to keep it small
  tail -200 "$MISS_CACHE" > "${MISS_CACHE}.tmp" 2>/dev/null && mv "${MISS_CACHE}.tmp" "$MISS_CACHE" 2>/dev/null
  echo "# no skill covers '${NORM_QUERY}'; consider scaffolding via /skill-discovery or meta/skill-suggestion" >&2
  exit 0
fi

# ─── Sort, top-N, emit ──────────────────────────────────────────────────
top_score=0
output=$(printf '%s' "$scored" | sort -t$'\t' -k1,1nr -k2,2 | head -n "$LIMIT")
top_score=$(printf '%s' "$output" | head -1 | awk -F'\t' '{print $1}')

# #9 low-confidence scaffold hint
if [ -n "$top_score" ] && [ "$top_score" -lt 60 ]; then
  echo "# top score=${top_score} (<60) — weak match; consider scaffolding a new skill if no row fits" >&2
fi

# Emit with or without --explain column
if [ "$EXPLAIN" -eq 1 ]; then
  printf '%s' "$output" | awk -F'\t' 'BEGIN{OFS="\t"} {print $2, $3, $1, $4, $5, $6}'
else
  printf '%s' "$output" | awk -F'\t' 'BEGIN{OFS="\t"} {print $2, $3, $1, $4, $5}'
fi
