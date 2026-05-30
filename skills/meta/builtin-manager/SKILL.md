---
description: "Manage built-in skills shared across every cue profile — promote, demote, list. Use when user says \"make X built-in\", \"add X to all profiles\", \"remove from built-in\", \"promote skill to built-in\", or \"what skills are built-in\". Also activates proactively when a skill has fired across 3+ profiles and should be promoted."
tags: [meta, builtin, optimization]
category: meta
version: 1.0.0
requires_mcps: []
---

# Built-in Skill Manager

## When to trigger

1. **User asks** to add/remove a built-in skill ("make X available everywhere", "add X to all profiles", "remove X from built-in")
2. **After sessions** where you notice a skill being used that isn't built-in but probably should be (used in 3+ different profiles)

## Commands

```bash
cue builtin                     # list current built-in skills
cue builtin add <skill-id>     # promote to built-in (all profiles get it)
cue builtin remove <skill-id>  # demote from built-in
cue skills rank                 # see most-used skills across sessions
cue skills audit                # find unused skills
```

## When to suggest promoting a skill to built-in

A skill should be built-in if ALL of these are true:
- Used in **3+ different profiles** (not just one)
- Referenced in **10+ sessions** (check `cue skills rank`)
- Is **generic** (not domain-specific like medusa/ or nvidia/)
- Is **small** (<1500 tokens — built-ins add overhead to every session)

## How to promote

```bash
# Check usage first
cue skills rank

# If a skill qualifies, promote it
cue builtin add review/code-review

# Verify
cue builtin
```

## When to suggest demoting a built-in

- Skill has **0 usage** across 20+ sessions (`cue skills audit`)
- Skill is **large** (>2000 tokens) and only relevant to specific work
- User says "I never use X"

```bash
cue builtin remove meta/unused-skill
```

## Current built-ins

Run `cue builtin` to see the list. These are in the `core` profile and inherited by every other profile.

## Rules

- Never remove `nvidia/skill-evolution` — it's the self-improvement engine
- Never remove `caveman/caveman` — it's the terse mode toggle
- Ask the user before promoting/demoting — don't auto-modify
- After changes, remind: "Run `/cue-reload` to apply"
