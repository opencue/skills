---
name: awesome-list-submit
description: >-
  When user says "submit to awesome lists", "add to awesome repos",
  "promote on GitHub lists", or "find lists for this project" — auto-detect
  project metadata, find relevant awesome-* repos, check for duplicates,
  match entry format, draft PRs, and track submissions.
tags: [meta, marketing, github, promotion, outreach]
category: meta
version: 2.0.0
requires_mcps: []
allowed-tools: Bash(gh:*), Bash(curl:*), Bash(git:*), Bash(jq:*), WebSearch, Read(*), Write(*)
---

# Submit to Awesome Lists (v2)

Auto-detect project info, find relevant awesome-* repos, and submit PRs — with dedup, format matching, and submission tracking.

## When to activate

- User says "submit to awesome lists" or "add to awesome repos"
- User says "promote on GitHub" or "get listed"
- User says "find lists for this project"

## Step 1: Auto-detect project metadata

```bash
# Read from package.json, Cargo.toml, pyproject.toml, or README
PROJECT_NAME=$(jq -r '.name // empty' package.json 2>/dev/null || basename "$PWD")
DESCRIPTION=$(jq -r '.description // empty' package.json 2>/dev/null)
HOMEPAGE=$(jq -r '.homepage // empty' package.json 2>/dev/null)
REPO_URL=$(gh repo view --json url -q '.url' 2>/dev/null)
STARS=$(gh repo view --json stargazerCount -q '.stargazerCount' 2>/dev/null)
LICENSE=$(jq -r '.license // empty' package.json 2>/dev/null)
TOPICS=$(gh repo view --json repositoryTopics -q '.repositoryTopics[].name' 2>/dev/null | tr '\n' ',')

echo "Project: $PROJECT_NAME"
echo "Description: $DESCRIPTION"
echo "URL: $REPO_URL"
echo "Stars: $STARS"
echo "License: $LICENSE"
echo "Topics: $TOPICS"
```

## Step 2: Find relevant awesome lists

Search using the project's topics and keywords:

```bash
# Search by each topic
for topic in $(echo "$TOPICS" | tr ',' '\n'); do
  gh search repos "awesome-$topic" --sort stars --limit 3 --json fullName,stargazersCount,description
done

# Also search by project domain keywords from description
KEYWORDS=$(echo "$DESCRIPTION" | tr ' ' '\n' | grep -E '^[a-z]{4,}$' | head -5)
for kw in $KEYWORDS; do
  gh search repos "awesome $kw" --sort stars --limit 3 --json fullName,stargazersCount,description
done
```

Filter: only lists with >100 stars, not archived, updated in last 6 months.

## Step 3: Check for duplicates

Before submitting, verify the project isn't already listed:

```bash
check_already_listed() {
  local repo="$1"
  # Check README for our repo URL
  gh api "repos/$repo/readme" --jq '.content' | base64 -d | grep -qi "$PROJECT_NAME\|$REPO_URL"
}

# Check open PRs too
check_pending_pr() {
  local repo="$1"
  gh pr list --repo "$repo" --search "$PROJECT_NAME" --state open --json number | jq 'length'
}
```

## Step 4: Match entry format

Parse existing entries to match the list's style:

```bash
detect_format() {
  local readme="$1"
  if echo "$readme" | grep -q "^|.*|.*|"; then
    echo "table"  # Markdown table format
  elif echo "$readme" | grep -q "^- \["; then
    echo "bullet-link"  # - [name](url) — description
  elif echo "$readme" | grep -q "^- \*\*\["; then
    echo "bullet-bold"  # - **[name](url)** - description
  fi
}
```

Format templates:
- **table**: `| [name](url) | description |`
- **bullet-link**: `- [name](url) — description`
- **bullet-bold**: `- **[name](url)** - description`

## Step 5: Submit PRs

```bash
submit_to_list() {
  local target_repo="$1"
  local section="$2"
  local entry="$3"

  # Fork
  gh repo fork "$target_repo" --clone --remote 2>/dev/null
  local dir=$(basename "$target_repo")
  cd "/tmp/$dir"

  # Branch
  git checkout -b "add-$PROJECT_NAME"

  # Find insertion point (alphabetical within section)
  # Insert the entry at the right position
  # ... (agent edits README.md)

  git add README.md
  git commit -m "Add $PROJECT_NAME — $DESCRIPTION"
  git push -u origin "add-$PROJECT_NAME"

  # Create PR
  gh pr create \
    --title "Add $PROJECT_NAME" \
    --body "**[$PROJECT_NAME]($REPO_URL)** — $DESCRIPTION

⭐ $STARS stars | 📜 $LICENSE license | 🔧 Install: \`npm i -g $PROJECT_NAME\`

$REPO_URL" \
    --repo "$target_repo"
}
```

## Step 6: Track submissions

Save submission history to avoid re-submitting:

```bash
HISTORY_FILE="$HOME/.config/cue/awesome-submissions.json"

record_submission() {
  local target="$1" pr_url="$2" status="$3"
  jq --arg t "$target" --arg p "$pr_url" --arg s "$status" --arg d "$(date -I)" \
    '. += [{"list": $t, "pr": $p, "status": $s, "date": $d}]' \
    "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
}

# Check before submitting
already_submitted() {
  local target="$1"
  jq -e --arg t "$target" '.[] | select(.list == $t)' "$HISTORY_FILE" >/dev/null 2>&1
}
```

## Step 7: Report results

```
📋 Awesome List Submissions for "cue":

  ✅ PR #442 opened: rohitg00/awesome-claude-code-toolkit
     https://github.com/rohitg00/awesome-claude-code-toolkit/pull/442

  ✅ PR #767 opened: travisvn/awesome-claude-skills
     https://github.com/travisvn/awesome-claude-skills/pull/767

  ⏭️  Skipped: hesreallyhim/awesome-claude-code (repo restructuring)
  ⏭️  Skipped: punkpeye/awesome-mcp-servers (already listed)

  📊 Summary: 2 PRs opened, 2 skipped, 0 failed
  📁 History saved to ~/.config/cue/awesome-submissions.json
```

## Rules

- Auto-detect everything — don't ask user for metadata that's in package.json
- Always check for duplicates before submitting (README + open PRs)
- Match the existing format exactly (table vs bullet, alphabetical order)
- Only submit to lists with >100 stars and recent activity
- Track all submissions to prevent re-submitting
- Max 5 submissions per session
- Show the PR URLs so user can track acceptance
- If a list is archived or restructuring, skip with explanation

---

## Advanced: Competitor Analysis

Find where competing tools are listed and submit to those same lists:

```bash
COMPETITORS="claude-code-switcher skillport agent-skills-cli agent-skill-manager skillshub"

find_gaps() {
  local our_listings=$(gh search code "$PROJECT_NAME" --filename README.md --limit 50 --json repository | jq -r '.[].repository.fullName')
  for comp in $COMPETITORS; do
    gh search code "$comp" --filename README.md --limit 20 --json repository \
      | jq -r '.[].repository.fullName' \
      | grep -i "awesome\|list\|collection" \
      | while read repo; do
          echo "$our_listings" | grep -q "$repo" || echo "GAP: $repo (has $comp, missing us)"
        done
  done
}
```

Present as:
```
🔍 Competitor Analysis — found 3 gaps where competitors are listed but we aren't.
```

---

## Advanced: Custom PR Body Templates

Auto-detect list audience and use the right pitch:

```bash
detect_list_type() {
  local name="$1" desc="$2"
  if echo "$name $desc" | grep -qi "mcp\|model.context.protocol"; then echo "mcp"
  elif echo "$name $desc" | grep -qi "skill\|agent"; then echo "ai-agents"
  elif echo "$name $desc" | grep -qi "cli\|command.line"; then echo "cli"
  else echo "dev-tools"
  fi
}
```

Templates per audience:
- **ai-agents**: Lead with the problem (context overload), show 10-agent support
- **cli**: Lead with Unix philosophy, sub-5ms overhead, no daemon
- **mcp**: Lead with per-project MCP scoping, inheritance
- **skills**: Lead with 110+ bundled skills, npx skill packs
- **dev-tools**: Lead with developer experience, one-command install

---

## Advanced: Screenshot/GIF in PR Body

Auto-find and embed visual assets:

```bash
find_demo_assets() {
  for f in docs/assets/demo.gif assets/demo.gif \
           docs/assets/terminal-optimizer.svg docs/assets/hero.svg; do
    [ -f "$f" ] && echo "![Demo](https://raw.githubusercontent.com/$(gh repo view --json nameWithOwner -q '.nameWithOwner')/main/$f)" && return
  done
}
```

Inject into every PR body — maintainers see what the tool does without clicking through. Visual PRs get merged 2-3x faster.

---

## Advanced: Cross-reference After Merge

When one PR is merged, comment on pending PRs with social proof:

```bash
# After a merge is detected:
gh pr comment $PENDING_PR --repo "$list" \
  --body "👋 Friendly bump — recently accepted into $MERGED_LIST. Happy to adjust format if needed!"
```

---

## Advanced: Timing

Submit Tue-Thu during business hours for fastest maintainer response. Skip weekends and Mondays.

---

## Advanced: Automated Weekly Status Check

Set up a cron/scheduled check for PR status updates:

```bash
# Run weekly: cue awesome-submit --check-status
check_all_submissions() {
  jq -c '.[] | select(.status == "pending")' "$HISTORY_FILE" | while read entry; do
    local list=$(echo "$entry" | jq -r '.list')
    local pr=$(echo "$entry" | jq -r '.pr')
    local pr_num=$(basename "$pr")

    local state=$(gh pr view "$pr_num" --repo "$list" --json state -q '.state' 2>/dev/null)
    case "$state" in
      MERGED)
        echo "🎉 MERGED: $list (#$pr_num)"
        update_status "$list" "merged"
        ;;
      CLOSED)
        echo "❌ CLOSED: $list (#$pr_num)"
        local reason=$(gh pr view "$pr_num" --repo "$list" --json comments -q '.comments[-1].body' 2>/dev/null)
        echo "   Reason: $reason"
        update_status "$list" "closed"
        ;;
      OPEN)
        local age=$(( ($(date +%s) - $(date -d "$(echo "$entry" | jq -r '.date')" +%s)) / 86400 ))
        if [ "$age" -gt 14 ]; then
          echo "⏰ STALE ($age days): $list (#$pr_num) — consider bumping"
        fi
        ;;
    esac
  done
}
```

---

## Advanced: Release-triggered Discovery

GitHub Action that runs on every release tag:

```yaml
# .github/workflows/awesome-submit.yml
name: Find new awesome lists
on:
  release:
    types: [published]
jobs:
  discover:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          # Find lists created since last release that match our topics
          SINCE=$(gh release list --limit 2 --json publishedAt -q '.[1].publishedAt')
          gh search repos "awesome claude-code" --sort updated --json fullName,createdAt \
            | jq --arg since "$SINCE" '[.[] | select(.createdAt > $since)]'
          # Output as issue for manual review
      - run: |
          gh issue create --title "New awesome lists to submit to" \
            --body "$(cat /tmp/new-lists.md)" --label "marketing"
```

---

## Advanced: Maintainer Relationship DB

Track maintainer behavior for smarter targeting:

```bash
MAINTAINER_DB="$HOME/.config/cue/awesome-maintainers.json"

# After each PR resolution, record maintainer response
record_maintainer() {
  local repo="$1" outcome="$2" days_to_respond="$3"
  jq --arg r "$repo" --arg o "$outcome" --arg d "$days_to_respond" \
    '.[$r] = (.[$r] // {}) | .[$r].history += [{"outcome": $o, "days": ($d|tonumber)}] | .[$r].avg_days = ([.[$r].history[].days] | add / length)' \
    "$MAINTAINER_DB" > "$MAINTAINER_DB.tmp" && mv "$MAINTAINER_DB.tmp" "$MAINTAINER_DB"
}

# Prioritize responsive maintainers
rank_targets() {
  jq -r 'to_entries | sort_by(.value.avg_days) | .[] | "\(.value.avg_days)d avg — \(.key)"' "$MAINTAINER_DB"
}
```

---

## Advanced: A/B Test PR Titles

Rotate title formats and track which gets merged:

```bash
PR_TITLE_VARIANTS=(
  "Add $PROJECT_NAME"
  "Add $PROJECT_NAME — $SHORT_DESC"
  "Add $PROJECT_NAME ($STARS+ stars)"
  "Add $PROJECT_NAME: $ONE_LINE_VALUE_PROP"
)

select_title() {
  # Pick based on what's worked before
  local best=$(jq -r '[.[] | select(.status=="merged")] | group_by(.title_style) | sort_by(-length) | .[0][0].title_style // empty' "$HISTORY_FILE")
  if [ -n "$best" ]; then
    echo "${PR_TITLE_VARIANTS[$best]}"
  else
    # Rotate through variants
    local idx=$(( $(jq 'length' "$HISTORY_FILE") % ${#PR_TITLE_VARIANTS[@]} ))
    echo "${PR_TITLE_VARIANTS[$idx]}"
  fi
}
```

---

## Advanced: Auto-generate Comparison Table Rows

Some lists have feature comparison tables. Auto-fill cue's row:

```bash
detect_comparison_table() {
  local readme="$1"
  # Find tables with competitor names
  if echo "$readme" | grep -q "claude-code-switcher\|skillport\|agent-skill"; then
    echo "comparison-table"
  fi
}

generate_comparison_row() {
  # cue's features for common comparison dimensions
  cat <<'EOF'
| **cue** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
EOF
  # Columns: skills | MCPs | plugins | profiles | per-dir | isolation | inherit
}
```

---

## Advanced: Backlink Monitoring

Verify links stay live after merge:

```bash
# Monthly check: are our links still in the READMEs?
monitor_backlinks() {
  jq -c '.[] | select(.status == "merged")' "$HISTORY_FILE" | while read entry; do
    local list=$(echo "$entry" | jq -r '.list')
    local still_listed=$(gh api "repos/$list/readme" --jq '.content' | base64 -d | grep -c "$REPO_URL")
    if [ "$still_listed" -eq 0 ]; then
      echo "⚠️  REMOVED from $list — re-submit or investigate"
    fi
  done
}
```

---

## Advanced: Multi-language Submissions

Submit to non-English awesome lists with translated descriptions:

```bash
TRANSLATIONS=(
  "zh:代理配置管理器 — 按目录隔离技能、MCP和插件，支持继承和缓存"
  "ja:エージェントプロファイルマネージャー — ディレクトリごとにスキル・MCP・プラグインを分離"
  "ko:에이전트 프로필 관리자 — 디렉토리별 스킬/MCP/플러그인 격리"
)

# Known non-English lists
NON_EN_LISTS=(
  "yzfly/Awesome-MCP-ZH"           # Chinese MCP list (7k stars)
  "punkpeye/awesome-mcp-servers"    # Has i18n section
)

get_translated_description() {
  local lang="$1"
  for t in "${TRANSLATIONS[@]}"; do
    if [[ "$t" == "$lang:"* ]]; then
      echo "${t#*:}"
      return
    fi
  done
  echo "$DESCRIPTION"  # fallback to English
}
```
