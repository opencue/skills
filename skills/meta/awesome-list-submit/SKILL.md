---
name: awesome-list-submit
description: >-
  When user says "submit to awesome lists", "add cue to awesome repos",
  or "promote on GitHub lists" — find relevant awesome-* repos, draft PRs
  to add the project, and submit them.
tags: [meta, marketing, github, promotion]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: Bash(gh:*), Bash(curl:*), Bash(git:*), WebSearch, Read(*), Write(*)
---

# Submit to Awesome Lists

Find relevant awesome-* GitHub repos and submit PRs to add a project.

## When to activate

- User says "submit to awesome lists" or "add to awesome repos"
- User says "promote on GitHub" or "get listed"
- User says "find awesome lists for X"

## Workflow

### 1. Find relevant awesome lists

```bash
# Search GitHub for awesome lists related to the project's domain
gh search repos "awesome-claude-code" --sort stars --limit 5 --json fullName,stargazersCount,description
gh search repos "awesome-ai-tools" --sort stars --limit 5 --json fullName,stargazersCount,description
gh search repos "awesome-mcp" --sort stars --limit 5 --json fullName,stargazersCount,description
gh search repos "awesome-developer-tools" --sort stars --limit 5 --json fullName,stargazersCount,description
```

### 2. Check each list's contribution guidelines

```bash
# For each candidate list:
gh api repos/{owner}/{repo}/contents/CONTRIBUTING.md --jq '.content' | base64 -d
# Or check the README for submission rules
gh api repos/{owner}/{repo}/readme --jq '.content' | base64 -d | head -50
```

### 3. Draft the entry

Format the entry to match the list's style. Typical format:

```markdown
- [cue](https://github.com/recodeee/cue) - Agent profile manager for Claude Code & Codex. Per-directory profiles scope skills, MCPs, and plugins. No daemon, sub-5ms overhead.
```

### 4. Submit PRs

```bash
# Fork, branch, add entry, PR
gh repo fork {owner}/{repo} --clone
cd {repo}
git checkout -b add-cue
# Edit README.md to add the entry in alphabetical order
git add README.md
git commit -m "Add cue — agent profile manager for Claude Code & Codex"
gh pr create --title "Add cue" --body "cue is an agent profile manager that scopes skills, MCPs, and plugins per-directory for Claude Code & Codex.

- GitHub: https://github.com/recodeee/cue
- npm: https://www.npmjs.com/package/cue-ai
- 2k+ stars, MIT licensed
- Works with 10 agents (Claude Code, Codex, Cursor, Cline, Gemini, etc.)"
```

### 5. Track submissions

Report what was submitted:

```
📋 Awesome List Submissions:

  ✅ PR opened: awesome-claude-code — github.com/owner/awesome-claude-code/pull/123
  ✅ PR opened: awesome-ai-tools — github.com/owner/awesome-ai-tools/pull/456
  ⏳ Pending: awesome-mcp — needs 100+ stars (we have 2k ✓)
  ❌ Skipped: awesome-devtools — archived repo
```

## Known targets for cue

| List | Category | Entry section |
|------|----------|---------------|
| `awesome-claude-code` | Claude Code tools | Tools / Profile Management |
| `awesome-mcp` | MCP ecosystem | Tools / Configuration |
| `awesome-ai-coding` | AI dev tools | CLI Tools |
| `awesome-developer-tools` | Dev tools | AI / Automation |
| `awesome-cli-apps` | CLI apps | Developer Tools |

## Rules

- Only submit to lists with >100 stars (worth the effort)
- Match the existing format exactly (alphabetical, same markdown style)
- Don't spam — max 5 submissions per session
- Check if already listed before submitting
- Include star count and key differentiator in PR body
- Be honest about what cue does — no hype
