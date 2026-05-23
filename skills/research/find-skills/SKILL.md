---
name: find-skills
description: >-
  When user says "find skills for X", "search for skills", "what skills exist for Y",
  or "add SVG/diagram/testing/etc skills to my profile" — search GitHub for open-source
  Claude Code skills, evaluate them, and add the best ones to the active profile.
tags: [meta, cue, research, skills]
category: research
version: 1.0.0
requires_mcps: []
allowed-tools: Bash(curl:*), Bash(gh:*), WebFetch, WebSearch, Read(*), Write(*)
---

# Find & Install Open-Source Skills

Search GitHub for Claude Code / Codex skills that match a user's need, evaluate quality, and add them to the active cue profile.

## When to activate

- User says "find skills for X" or "search for X skills"
- User says "what open-source skills exist for Y?"
- User says "add diagram/testing/deployment/etc skills to my profile"
- User describes a capability gap and you think a public skill could fill it

## Workflow

### 1. Search GitHub for skills

Use multiple search strategies:

```bash
# Strategy A: GitHub topic search (most reliable)
curl -sL "https://api.github.com/search/repositories?q=topic:claude-code-skill+topic:$TOPIC&sort=stars&per_page=10" \
  -H "Accept: application/vnd.github.v3+json" | jq '.items[] | {name: .full_name, stars: .stargazers_count, desc: .description, url: .html_url}'

# Strategy B: Search for SKILL.md files (catches skills not tagged)
curl -sL "https://api.github.com/search/code?q=filename:SKILL.md+$KEYWORD&per_page=10" \
  -H "Accept: application/vnd.github.v3+json" | jq '.items[] | {repo: .repository.full_name, path: .path}'

# Strategy C: Topic-based discovery
curl -sL "https://api.github.com/search/repositories?q=$KEYWORD+claude+skill+in:name,description,readme&sort=stars&per_page=10" \
  -H "Accept: application/vnd.github.v3+json" | jq '.items[] | {name: .full_name, stars: .stargazers_count, desc: .description}'
```

Also search for known high-quality skill collections:
- `anthropics/skills` — official Anthropic skills
- `daymade/claude-code-skills` — curated collection
- `levnikolaevich/claude-code-skills` — delivery workflow skills
- `yizhiyanhua-ai/fireworks-tech-graph` — SVG diagram generation
- `cathrynlavery/diagram-design` — editorial diagrams
- `oh-my-mermaid/oh-my-mermaid` — architecture diagrams from code

### 2. Evaluate each candidate

For each promising repo, check:

```bash
# Check if it has a SKILL.md (required for cue compatibility)
curl -sL "https://api.github.com/repos/$REPO/contents/" \
  -H "Accept: application/vnd.github.v3+json" | jq '.[].name' | grep -i "skill"

# Check stars, last commit, license
curl -sL "https://api.github.com/repos/$REPO" \
  -H "Accept: application/vnd.github.v3+json" | jq '{stars: .stargazers_count, updated: .updated_at, license: .license.spdx_id, archived: .archived}'
```

**Quality criteria (score 1-5):**
- ⭐ Stars: >1k = 5, >500 = 4, >100 = 3, >20 = 2, <20 = 1
- 📅 Last updated: <1 month = 5, <3 months = 4, <6 months = 3, <1 year = 2, >1 year = 1
- 📄 Has SKILL.md: required (skip if missing)
- 📜 License: MIT/Apache/ISC = ✓, no license = ⚠️ warn user
- 🏗️ Structure: has references/, templates/, or examples/ = bonus

### 3. Present findings to user

Format results as a ranked table:

```
🔍 Found 4 skills for "SVG diagrams":

  ⭐⭐⭐⭐⭐ yizhiyanhua-ai/fireworks-tech-graph (7k stars)
  "Generate production-quality SVG+PNG technical diagrams from natural language"
  7 styles, 14 diagram types, AI/Agent patterns
  License: MIT | Updated: 2 weeks ago
  Install: npx ref → yizhiyanhua-ai/fireworks-tech-graph

  ⭐⭐⭐⭐ cathrynlavery/diagram-design (2.4k stars)
  "Thirteen editorial diagram types for Claude Code. Self-contained HTML+SVG."
  Brand-aware, no Mermaid, editorial quality
  License: MIT | Updated: 1 month ago
  Install: npx ref → cathrynlavery/diagram-design

  ⭐⭐⭐ oh-my-mermaid/oh-my-mermaid (800 stars)
  "Turn complex codebases into clear architecture diagrams"
  Mermaid-based, auto-generates from code
  License: MIT | Updated: 3 weeks ago
  Install: npx ref → oh-my-mermaid/oh-my-mermaid

  ⚠️ some-user/svg-tool (15 stars)
  Skipped: too few stars, no SKILL.md found
```

### 4. Add to profile (with user confirmation)

After user picks which skills to add:

```bash
# Check current profile
PROFILE=$(cat .cue-profile 2>/dev/null || cue current --json 2>/dev/null | jq -r '.profile')

# Show what will be added
echo "Adding to profile: $PROFILE"
echo "  npx:"
echo "    - repo: yizhiyanhua-ai/fireworks-tech-graph"
echo "      skills: [fireworks-tech-graph]"
```

Then edit the profile YAML:

```bash
# Read current profile
cat profiles/$PROFILE/profile.yaml

# Add the npx entry under skills.npx
# (use the agent to edit the YAML properly)
```

Or use the cue CLI if available:

```bash
cue skills add-to-profile --npx "yizhiyanhua-ai/fireworks-tech-graph:fireworks-tech-graph" --profile $PROFILE
```

### 5. Verify installation

```bash
# Validate the updated profile
cue validate $PROFILE

# Show the updated skill count
cue current
```

## Search Shortcuts

Common searches the user might ask for:

| User says | Search terms |
|-----------|-------------|
| "diagram skills" | `svg diagram architecture claude-code-skill` |
| "testing skills" | `testing test-runner claude skill` |
| "deployment skills" | `deploy docker kubernetes claude skill` |
| "documentation skills" | `readme docs markdown claude skill` |
| "security skills" | `security audit owasp claude skill` |
| "API skills" | `api rest graphql openapi claude skill` |
| "database skills" | `database postgres migration claude skill` |
| "frontend skills" | `react nextjs frontend ui claude skill` |

## Rules

- Always show stars, last update, and license before recommending
- Never add a skill without user confirmation
- Prefer skills with >100 stars and recent activity
- Warn if a skill has no license (legal risk)
- Warn if a skill is archived or >1 year stale
- Show max 5 results, ranked by quality score
- If no good skills found, suggest creating one with `cue skills-new`
- Always verify the skill has a SKILL.md — repos without one won't work with cue
