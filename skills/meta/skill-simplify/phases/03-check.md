# Phase 3: Integrity check

Re-extract the inventory from the optimized file with the same logic as Phase
1, compare counts category by category, validate format, and report PASS,
WARN, or FAIL. Revert on FAIL. This phase is the entire reason the skill is
safe to run, do not skip it.

## Objective

- Re-run the Phase 1 extraction on the optimized content.
- Compare counts with role-aware classification.
- Confirm no new format issues appeared.
- Report a result with actionable detail.
- Restore the original when a critical element is missing.

## Step 3.1: Re-extract

```bash
NEW_LINES=$(wc -l < "$FILE")
```

Read the optimized file fresh and rebuild the inventory using the exact same
rules from `01-analysis.md` steps 1.2, 1.2.1, 1.2.2, 1.2.3. Same extraction,
same role classification, same counting. A different method here would make
the comparison meaningless.

## Step 3.2: Compare, role-aware

Diff each category as `after - before`. The category decides the verdict.

**CRITICAL**, must not decrease, any drop is a FAIL:

```
functionalCodeBlocks  dataStructures  routingBranches  errorHandlers
conditionalLogic  askUserQuestions  inputModes  outputArtifacts
skillInvocations
```

**MERGE_AWARE**, a decrease is a WARN that needs coverage proof:

```
agentCalls  codeBlocks
```

**EXPECTED_DECREASE**, a decrease is the goal, always OK:

```
descriptiveCodeBlocks  todoWriteBlocks  phaseHandoffs  tables  schemas
```

Verdict per category:

```
for each category:
  diff = after - before
  if CRITICAL:     status = diff < 0 ? FAIL : OK   ; FAIL sets hasCriticalLoss
  if MERGE_AWARE:  status = diff < 0 ? WARN : OK   ; WARN sets hasWarning
  else:            status = OK
```

## Step 3.3: Deep verification

**CRITICAL drop**: name exactly what was lost. For each FAIL category, list the
before-items that have no match in the after-inventory using the matching
rules below. That list is what you report to the user.

**MERGE_AWARE drop**: check the merged version covers every original variant.
For each dropped item, look for a merge comment in a surviving item that names
it, for example `// variant: multi adds Perspective`. If a dropped item has no
such comment anywhere, it is truly lost. Promote that category to FAIL and set
`hasCriticalLoss`. Otherwise the WARN stands and the merge is fine.

## Step 3.4: Format validation

Re-scan the optimized `functional` blocks for format issues. Any issue that
exists now but did not exist in the Phase 1 list is a NEW issue introduced by
the edit, and a new issue is a FAIL.

| Check | Detection | On failure |
|-------|-----------|------------|
| Bracket matching | Count `{([` vs `})]` per block | FAIL, fix or revert |
| Variable consistency | `${var}` used but never declared | WARNING, note it |
| Structural completeness | Body has an entry but no return, Write, or output | WARNING |
| Nested backticks | Backtick literal inside a code fence | WARNING if pre-existing, FAIL if new |
| Schema field preservation | After fields match before fields | FAIL if any field lost |

## Step 3.5: Report

```
status = hasCriticalLoss ? FAIL : (hasWarning ? WARN : PASS)
```

Show a table with every category: before, after, delta, status. Highlight the
FAIL and WARN rows. Add a one-line format summary: issues resolved, new issues
(should be zero). Report lines before, lines after, and the percentage saved.

## Step 3.6: Act on the result

```bash
case "$STATUS" in
  FAIL)
    cp "$FILE.simplify.bak" "$FILE"        # restore the original
    echo "FAIL: critical element lost or new format issue. Reverted."
    ;;
  WARN)
    echo "WARN: merge or descriptive decrease. Verify the merge covers every case."
    # keep the edit, show the merge justification from optimizationRecord
    ;;
  PASS)
    rm -f "$FILE.simplify.bak"             # safe to drop the backup
    echo "PASS: every functional element preserved. ${SAVED} lines saved."
    ;;
esac
```

On FAIL, restore and report which category dropped and which elements were
lost. Do not patch in place after a FAIL, restore first, then a human decides.

## Element matching rules

How a before-element is judged present in the after-inventory:

| Element | Match on |
|---------|----------|
| codeBlocks | Same language plus first meaningful line, ignoring whitespace and comments |
| agentCalls | Same agentType plus prompt keyword overlap above 60% |
| dataStructures | Same variable name, or same field set |
| routingBranches | Same condition, normalized |
| errorHandlers | Same error type or pattern |
| conditionalLogic | Same condition plus same outcome set |
| askUserQuestions | Same question count plus similar option labels |
| inputModes | Same mode identifier |
| outputArtifacts | Same file path pattern or artifact name |
| skillInvocations | Same skill name |
| todoWriteBlocks | Same phase names, order-independent |
| phaseHandoffs | Same target phase reference |
| tables | Same column headers |
| schemas | Same schema name or field set |

Merge coverage (`coversElement`):

- Agent calls: a surviving template carries a `// For multi:` or
  `// variant:` comment naming the missing variant.
- Code blocks: a surviving block carries a comment noting the alternative was
  folded in.
