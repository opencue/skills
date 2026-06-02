---
name: skill-simplify
description: Use when the user says "simplify skill", "optimize skill", "shrink this skill", or "skill-simplify". Shrinks a SKILL.md without losing behavior, verified by a before/after functional count.
tags: [meta, cue, skills, quality, refactor]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: Bash(Bash:*), Read, Write, Edit, Grep, Glob, AskUserQuestion
---

# Skill Simplify

Cut a SKILL.md down to size without changing what it does. The safety net is
a count-based integrity check: every functional element present before the
edit must still be present after, or the change reverts.

Run three phases in order. Each phase has a detail file you read on demand,
not up front:

| Phase | Document | Job |
|-------|----------|-----|
| 1 | [phases/01-analysis.md](phases/01-analysis.md) | Build the functional inventory, classify every code block, flag format issues |
| 2 | [phases/02-optimize.md](phases/02-optimize.md) | Delete descriptive content, merge equivalent variants, fix format |
| 3 | [phases/03-check.md](phases/03-check.md) | Re-extract the inventory, compare counts, PASS / WARN / FAIL, revert on FAIL |

## When to activate

- User says "simplify skill", "optimize skill", "shrink this skill"
- User says "compress SKILL.md", "make this skill smaller", "skill-simplify"
- User hands you a bloated SKILL.md and asks to trim it without breaking it

## Input

Resolve the target to an absolute path. A bare directory means the SKILL.md
inside it.

```bash
TARGET="$1"
case "$TARGET" in
  *.md) FILE="$TARGET" ;;
  *)    FILE="$TARGET/SKILL.md" ;;
esac
test -f "$FILE" || { echo "Target not found: $FILE"; exit 1; }
wc -l "$FILE"   # original line count, the Phase 3 before/after anchor
```

Snapshot the original before any edit so Phase 3 can revert:

```bash
cp "$FILE" "$FILE.simplify.bak"
```

## The contract

1. **Preserve every functional element.** Logic blocks, routing branches,
   schemas, agent and skill calls, error handling, input modes, output
   artifacts, AskUserQuestion blocks stay verbatim.
2. **Delete only descriptive content.** ASCII art, flowcharts that duplicate a
   table, "When to use" prose, examples that just repeat logic shown elsewhere,
   verbose comments.
3. **Never summarize algorithm logic.** If-else branches, function bodies, and
   schema fields are copied, not paraphrased.
4. **Classify every code block** as `functional` or `descriptive`. Only
   `descriptive` blocks may be removed. When unsure, mark it `functional` and
   keep it.
5. **Merge only equivalent variants.** Two templates that differ by one
   parameter collapse to one template plus a variant comment that names the
   dropped case.
6. **Counts are the gate.** Phase 3 re-extracts the same inventory. Critical
   categories must not decrease, or the edit reverts.

The critical categories, the ones that trigger a FAIL on any decrease:

```
functionalCodeBlocks  dataStructures  routingBranches  errorHandlers
conditionalLogic  askUserQuestions  inputModes  outputArtifacts
skillInvocations
```

Descriptive decreases are the whole point and pass clean. Merge-aware
categories (`agentCalls`, total `codeBlocks`) WARN on a decrease so you verify
the merged version still covers every original case.

## Error handling

| Situation | What to do |
|-----------|------------|
| Target file not found | Report the path, stop |
| Phase 3 FAIL: a critical category dropped | Restore from `.simplify.bak`, report which category and which elements were lost |
| Phase 3 FAIL: a new format issue appeared | Restore from `.simplify.bak`, report the new issue |
| Phase 3 WARN: merge-aware drop | Keep the edit, show the merge justification, ask the user to confirm coverage |
| Phase 3 PASS | Keep the edit, delete the backup, report lines saved |

## Example

Input: "simplify skill resources/skills/skills/meta/foo" (220-line SKILL.md
with an ASCII flowchart, a "Best Practices" section restating Core Rules, and
two AskUserQuestion blocks that differ only by header text).

Process:
- Phase 1 inventory finds 6 functional code blocks, 2 askUserQuestions, 1
  routing branch, 3 descriptive blocks (the flowchart and two duplicate
  examples). Format scan finds one nested-backtick issue.
- Phase 2 deletes the flowchart and the "Best Practices" section, merges the
  two AskUserQuestion blocks into one with a `// variant: review mode` comment,
  fixes the nested backticks. File drops to 150 lines.
- Phase 3 re-extracts: functional blocks still 6, askUserQuestions now 1 but
  the merge comment names the dropped variant so it WARNs not FAILs, routing
  branch still 1. Status PASS with one WARN.

Output: "Reduced foo/SKILL.md from 220 to 150 lines (-32%). PASS. 1 WARN: two
AskUserQuestion blocks merged into one, variant preserved in comment. Verify
the merged block still asks both headers."

## Rules

- Run the phases in order. Phase 3 is not optional. A simplification you did
  not verify is a regression you have not found yet.
- Keep the backup until Phase 3 reports PASS. Revert on FAIL, do not patch.
- Do not touch function signatures, variable names, or schema field names.
  Those are functional even inside a block you are compressing.
- When a decrease is real and not merge-covered, that is a FAIL. Do not argue
  the count down, restore and report.

## What this skill does NOT do

- Rewrite descriptions for activation (use `meta/description-optimizer`)
- Score or audit a skill end to end (use `meta/skill-reviewer`)
- Split one skill into several (that changes behavior, out of scope)
- Run the skill being simplified
