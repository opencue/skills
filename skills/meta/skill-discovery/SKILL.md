---
name: skill-discovery
description: >-
  Analyzes what was done manually in the current session and suggests
  skills that could automate it next time — an end-of-session retro for
  skill coverage gaps. Use when user says "what skills would have helped",
  "session review", "skill discovery", "audit my session", or "missing
  skills".
tags: [meta, cue, optimization]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: Bash
---

# Skill Auto-Discovery

Analyze the current session's work and suggest skills that would have helped.

## Iron contract — never recommend a skill that doesn't exist

Every suggestion must reference a real skill (already in the registry) or
be explicitly framed as "scaffold a new skill for X." Suggesting an
imagined skill that doesn't exist is worse than suggesting nothing — it
sends the user looking for something they can't install. Also: cap
suggestions at 3 per session. More than that is noise; the user stops
reading.

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

## Capture learnings

If you noticed a recurring pattern this session that future-you should
know about (a skill that always gets suggested but never adopted, a
profile that keeps missing the same capability, a CLI quirk), log it:

```bash
bin/cue-learnings log --type pattern \
                     --key <short-slug> \
                     --insight "<one-line description>" \
                     --confidence 1-10 \
                     --source observed
```

Only log genuine discoveries. A good test: would this insight save time
in a future session? If yes, log it. If you can't pass that test, don't.
Convention details: [../skill-reviewer/references/learnings.md](../skill-reviewer/references/learnings.md).
