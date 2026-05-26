# ROI Scoring Model for Skill Improvements

Reference file for the skill-reviewer's Step 6. Loaded on-demand when
performing ROI analysis.

## The formula

```
ROI = (frequency × impact × reach) / effort
```

Maximum possible ROI: (10 × 10 × 10) / 1 = 1000
Typical high-ROI fix: 30-80
Typical low-ROI fix: 1-10

## Factor definitions

### Frequency (1-10): How often is this skill invoked?

| Score | Meaning | How to measure |
|-------|---------|----------------|
| 1 | <1×/month | `cue skills rank` shows 0-1 uses |
| 3 | 1-3×/week | |
| 5 | Daily use | |
| 7 | Multiple times/day | |
| 10 | Every session | Core skills like caveman, code-review |

**Data source:** `cue skills rank 50` reads `~/.claude/projects/**/*.jsonl`

### Impact (1-10): How much better does the output get?

Derived from the skill's current score:

| Current score | Impact of fixing | Reasoning |
|---------------|-----------------|-----------|
| 1/5 (dead) | 10 | Skill doesn't activate at all → fixing = creating capability from nothing |
| 2/5 (weak) | 8-9 | Activates rarely, output unreliable |
| 3/5 (ok) | 5-6 | Works sometimes, missing examples or boundaries |
| 4/5 (good) | 2-3 | Minor polish, diminishing returns |
| 5/5 (excellent) | 1 | Already optimal, don't touch |

**Activation-specific impact multipliers:**
- Description has no WHEN clause: +3 impact (the #1 fix)
- No examples section: +2 impact (72-90% activation boost)
- >500 lines without progressive disclosure: +2 impact

### Reach (1-10): How many contexts benefit?

| Score | Meaning | How to measure |
|-------|---------|----------------|
| 1 | Used in 1 profile only | `grep -rl "<skill>" profiles/` |
| 3 | Used in 2-3 profiles | |
| 5 | Used in 4-6 profiles | |
| 7 | Used in 7-10 profiles | |
| 10 | Core skill (all profiles inherit) | Skills in `core` profile |

**Bonus reach:** Skills from `core` profile get automatic 10 because
every other profile inherits them.

### Effort (1-10): How hard is the fix?

| Score | Time | Example fix |
|-------|------|-------------|
| 1 | <2 min | Add "Use when..." to description |
| 2 | 2-5 min | Rewrite description with triggers |
| 3 | 5-10 min | Add examples section |
| 4 | 10-20 min | Rewrite body with concrete steps |
| 5 | 20-30 min | Split into SKILL.md + reference files |
| 6 | 30-60 min | Full rewrite with new structure |
| 7 | 1-2 hours | Write from scratch + test |
| 8 | 2-4 hours | Complex skill with scripts + fixtures |
| 9 | Half day | Multi-file skill with eval scenarios |
| 10 | Full day+ | Skill requiring new MCP or CLI tooling |

## Decision matrix: what to suggest

### Priority 1: Quick wins (ROI > 30, effort ≤ 2)

These are always worth doing immediately:
- Add "Use when..." clause to descriptions
- Remove dead skills (score 1, usage 0) from profiles
- Fix 3rd-person violations in descriptions

### Priority 2: High-impact rewrites (ROI > 20, effort 3-5)

Suggest these as the main next action:
- Rewrite descriptions with WHAT + WHEN + keywords
- Add input/output examples
- Add "What this skill does NOT do" section

### Priority 3: Structural improvements (ROI > 10, effort 5-7)

Suggest when the user has time:
- Split bloated skills into SKILL.md + references
- Bundle repeated scripts
- Add feedback loops to quality-critical skills

### Priority 4: New skills (ROI varies, effort 7+)

Only suggest when gap analysis reveals a clear need:
- Profile description implies capability not covered
- User repeatedly does manual work a skill could automate
- Adjacent profiles have a skill this one lacks

## Output format

Always present as a ranked table with:
1. ROI score (so user can see the math)
2. One-line description of the fix
3. Concrete action (what you'll do)
4. Effort estimate (in minutes)
5. One "yes/no" question to proceed

End with a "Quick wins" section for anything under 2 minutes — offer
to batch-apply all of them in one go.

## Anti-patterns in ROI analysis

- **Don't suggest fixing score-5 skills** — diminishing returns, leave them alone
- **Don't suggest removing skills with >0 usage** without asking — the user may value them
- **Don't overweight reach** — a skill used in 10 profiles but invoked 0 times is still dead
- **Don't underweight frequency** — a skill used 20×/day in 1 profile beats one used 1×/week in 10
- **Don't suggest effort-10 fixes as "quick wins"** — be honest about time cost
