---
name: skill-discovery
description: >-
  End-of-session analysis. When user says "what skills would have helped",
  "session review", or when a long session ends, analyze what was done manually
  and suggest skills that could automate it next time.
tags: [meta, cue, optimization]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: Bash
---

# Skill Auto-Discovery

Analyze the current session's work and suggest skills that would have helped.

## When to activate

- User says "what skills would have helped?" or "session review"
- User says "optimize" or "what could be automated?"
- End of a long session (10+ tool calls) when user says "done" or "that's all"

## What to do

### 1. Analyze session patterns

Look at what you did in this session:

```bash
# What file types were edited?
git diff --stat HEAD 2>/dev/null || true

# What commands were run?
# (reflect on your own tool calls this session)
```

Categorize the work:
- **File types**: .tsx/.jsx (frontend), .ts API routes (backend), Dockerfile (devops), .md (docs)
- **Commands run**: docker, kubectl, npm, pytest, etc.
- **Patterns**: repeated similar edits, manual config writing, boilerplate generation

### 2. Cross-reference with available skills

```bash
cue skills available 2>/dev/null | head -60
cue skills search "<detected-pattern>" 2>/dev/null
```

### 3. Present findings

Format:

```
📋 Session Review — Skills that could have helped:

  🔧 You manually wrote 3 Dockerfile configs
     → Skill: `deployment/docker` — generates Dockerfiles from project detection
     Add: cue skills add-to-profile deployment/docker

  🔧 You ran security checks on 4 API endpoints by hand
     → Skill: `review/security-review` — automated security audit
     Add: cue skills add-to-profile review/security-review

  🔧 You wrote repetitive test boilerplate
     → No existing skill found. Consider creating: `meta/test-scaffold`
     Scaffold: cue skills new testing/test-scaffold

  ✅ Skills you used well this session:
     - ui-ux-pro-max (3 invocations)
     - caveman-commit (2 invocations)
```

### 4. Offer to apply

```
Apply suggestions? I can run:
  cue skills add-to-profile deployment/docker
  cue skills add-to-profile review/security-review
```

## Rules

- Only suggest skills that clearly match repeated manual work (≥2 instances)
- Don't suggest skills for one-off tasks
- Show what the skill would have automated (concrete example from this session)
- If no skill exists for the pattern, suggest creating one
- Keep it to max 3-4 suggestions — don't overwhelm
