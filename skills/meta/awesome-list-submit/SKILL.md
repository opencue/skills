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
