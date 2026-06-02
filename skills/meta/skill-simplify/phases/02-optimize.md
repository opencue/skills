# Phase 2: Optimize

Apply the Phase 1 plan with Edit, in priority order, then write the result.
Preserve every functional element. When in doubt, keep the original.

## Objective

- Run every operation in order: delete, merge, simplify, format.
- Keep every functional element from the Phase 1 inventory.
- Fix the flagged format issues.
- Write the optimized content back to the target file.

## Step 2.1: Apply operations in order

**Priority 1, delete** (safest, highest impact):

| Target | Action |
|--------|--------|
| Duplicate Overview | Remove `## Overview` if it restates the frontmatter description |
| ASCII flowchart | Remove if a phase table or structure already covers it |
| "When to use" / "Use Cases" | Remove |
| Best Practices section | Remove if it duplicates Core Rules |
| Duplicate folder tree | Remove the ASCII tree if an Output Artifacts table covers it |
| "Next Phase" prose | Remove when a table or TodoWrite handles flow |
| Standalone example sections | Remove if the logic is already shown inline |
| Descriptive code blocks | Remove if nearby prose or a table covers the content |

**Priority 2, merge** (structural):

| Target | Action |
|--------|--------|
| Similar AskUserQuestion blocks | One block with a mode parameter |
| Repeated Option A/B/C routing | One dispatch |
| Sequential single-line commands | One code block |
| Repeated TodoWrite blocks | Template once, the rest as one-line comments |
| Duplicate error handling | One `## Error handling` table |
| Equivalent template variants | One template plus a comment naming the dropped variant, for example `// variant: multi-perspective adds Perspective` |
| Multiple output-artifact tables | One combined table with a phase column |

**Priority 3, simplify** (compress descriptive content):

| Target | Action |
|--------|--------|
| Verbose comments | One line, drop obvious restatements |
| Display-format blocks | Convert a logging-only block to a prose sentence describing the output shape |
| Wordy intros | Drop the preamble |
| Prompt padding | Drop generic advice from agent or exploration prompts |
| Long success-criteria lists | Trim to the essential 5 to 7, drop the obvious |

**Priority 4, format fixes**:

| Target | Action |
|--------|--------|
| Nested backtick literals | Convert the block to prose, or use a four-backtick fence |
| Hardcoded option lists | Replace with dynamic generation: name the source and the generation logic |
| Handoff without steps | Add concrete steps referencing the target command's interface |
| Unclosed brackets | Match the brackets |
| Undefined variables | Add the declaration or link the source |

## Step 2.2: Language unification (only if needed)

If the file mixes languages in functional comments, unify the non-functional
text to the majority language. Never change variable names, function names,
schema fields, or error message strings inside code.

## Step 2.3: Write the result

Apply edits with Edit on the target file. After writing, record the new line
count for the report:

```bash
NEW_LINES=$(wc -l < "$FILE")
SAVED=$(( ORIGINAL_LINES - NEW_LINES ))
PCT=$(( SAVED * 100 / ORIGINAL_LINES ))
echo "Reduced $FILE: $ORIGINAL_LINES -> $NEW_LINES (-${PCT}%)"
```

## Step 2.4: Keep a change record

Track what changed so Phase 3 can explain a WARN and a human can audit:

```
optimizationRecord = {
  deletedSections: [ ... ],          // section names removed
  mergedGroups:    [ { from, to } ], // what folded into what
  simplifiedAreas: [ { section, strategy } ],
  formatFixes:     [ { line, type, fix } ],
  linesBefore: ORIGINAL_LINES,
  linesAfter:  NEW_LINES
}
```

## Key rules

1. Never modify a functional code block beyond compressing its comments and
   whitespace.
2. Descriptive blocks may be deleted only when prose or a table covers them.
3. Never change a function signature, variable name, or schema field.
4. A merge must keep every original branch. The unified version handles every
   case the originals did.
5. When uncertain, keep the original. Conservative beats clever here.
6. Format fixes change presentation only, never semantics.

Hand Phase 3 the `optimizationRecord` and the original snapshot path.
