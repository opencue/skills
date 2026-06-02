# Phase 1: Functional analysis

Read the target, build a quantitative functional inventory with code-block
classification, find redundancy with line ranges, flag format issues, and
produce an optimization plan. These counts are the baseline Phase 3 verifies
against, so be exact.

## Objective

- Build the functional inventory with role classification (the Phase 3 anchor).
- Find redundancy categories with specific line ranges.
- Detect format issues.
- Produce an ordered optimization plan with estimated line savings.

## Step 1.1: Read and measure

```bash
ORIGINAL_LINES=$(wc -l < "$FILE")
```

Read the whole file into context. You classify and count by reading, not by
running a parser. The structures below describe what to track; hold them as
a mental ledger or jot them in scratch notes.

## Step 1.2: Extract the functional inventory

Count and catalog every functional element. Track each category with enough
location detail to match it again in Phase 3.

```
inventory = {
  codeBlocks:        [ { startLine, endLine, language, purpose, role } ],  // role = functional | descriptive
  agentCalls:        [ { line, agentType, description, mergeGroup? } ],
  dataStructures:    [ { line, name, type } ],                             // object | array | schema
  routingBranches:   [ { line, condition, outcomes[] } ],
  errorHandlers:     [ { line, errorType, resolution } ],
  conditionalLogic:  [ { line, condition, trueAction, falseAction } ],
  askUserQuestions:  [ { line, questionCount, headers[], optionType } ],   // static | dynamic
  inputModes:        [ { line, mode, description } ],
  outputArtifacts:   [ { line, artifact, format } ],
  todoWriteBlocks:   [ { line, phaseCount } ],
  phaseHandoffs:     [ { line, fromPhase, toPhase } ],
  skillInvocations:  [ { line, skillName, hasExecutionSteps } ],
  tables:            [ { startLine, endLine, columns } ],
  schemas:           [ { line, schemaName, fields[] } ],
  formatIssues:      [ { line, type, description, severity } ],            // error | warning
  counts:            {}                                                    // computed totals
}
```

Extraction cues:

- **Code blocks**: every fenced pair. Record start, end, language, first
  meaningful line as the purpose.
- **Agent calls**: `Agent(`, `Task(`, `subagent_type=`, or a Skill tool call
  spawning a sub-agent.
- **Data structures**: `const x = {`, `const x = [`, JSON schema objects.
- **Routing branches**: `if` / `else`, `switch` / `case`, meaningful ternaries.
- **Error handlers**: `catch`, error-table rows (`| Error |`), fallback blocks.
- **AskUserQuestion**: `AskUserQuestion(` blocks, record the questions array
  length and the option headers.
- **Input modes**: `Mode 1/2/3`, `--flag`, argument parsing.
- **Output artifacts**: `Write(`, `Output:`, file paths in comments.
- **Phase handoffs**: `Read("phases/`, `Skill(`, "proceed to next phase".
- **Skill invocations**: `Skill(` or a named `/skill` call with its steps.
- **Tables**: markdown `| header |` blocks.
- **Schemas**: named JSON structure definitions and their fields.

### Step 1.2.1: Classify each code block

| Role | Criteria | Examples |
|------|----------|----------|
| `functional` | Algorithm logic, routing, conditionals, agent calls, schemas, data processing, AskUserQuestion, Skill, Read, Write, Bash | `if (...)`, `Agent({...})`, `const schema = {...}` |
| `descriptive` | ASCII art, usage examples, display templates, good vs bad comparisons, folder trees | box-drawing chars, `# Example usage`, a bad / good pair, `dir/file.ts` trees |

Rules:

- Contains any of `Agent(`, `Bash(`, `AskUserQuestion(`, `if (`, `switch`,
  `Skill(`, `Write(`, `Read(`, `TodoWrite(` then it is `functional`.
- A `bash` block that is only example invocations, no logic, is `descriptive`.
- A block with no language tag holding only box-drawing characters is
  `descriptive`.
- A block under an "Example" heading is `descriptive`.
- Default to `functional`. Conservative wins, a kept block costs lines, a
  dropped functional block costs behavior.

### Step 1.2.2: Validate format

Scan the `functional` blocks only:

| Check | Detection | Severity |
|-------|-----------|----------|
| Nested backticks | A backtick template literal inside a fenced code block | warning |
| Unclosed brackets | Unmatched `{`, `(`, `[` in a block | error |
| Undefined references | `${var}` never declared in this or a prior block | warning |
| Inconsistent indentation | Mixed tabs and spaces, or jumpy nesting | warning |
| Dead code | Commented-out blocks spanning 5+ lines | warning |
| Missing output | A function-like block with no return, Write, or log | warning |

### Step 1.2.3: Compute totals

Total every category, plus the two derived code-block splits:

```
counts = {
  codeBlocks, functionalCodeBlocks, descriptiveCodeBlocks,
  agentCalls, dataStructures, routingBranches, errorHandlers,
  conditionalLogic, askUserQuestions, inputModes, outputArtifacts,
  todoWriteBlocks, phaseHandoffs, skillInvocations,
  tables, schemas, formatIssues
}
```

`functionalCodeBlocks` and `descriptiveCodeBlocks` come from the role split in
1.2.1. These are the numbers Phase 3 reads.

## Step 1.3: Find redundancy

Record line ranges for each, so Phase 2 edits surgically.

**Deletable** (remove entirely, zero functional loss):

| Pattern | Detection |
|---------|-----------|
| Duplicate Overview | `## Overview` restating the frontmatter description |
| ASCII flowchart | A flowchart duplicating a phase table or structure |
| "When to use" section | Usage prose not needed to execute |
| Best Practices section | Advice that duplicates Core Rules |
| Duplicate examples | Examples repeating logic shown elsewhere |
| Folder-tree duplicate | An ASCII tree repeating an Output Artifacts table |
| "Next Phase" prose | Phase glue when TodoWrite or a table already handles flow |
| Descriptive code blocks | Blocks classed `descriptive` covered by nearby prose or tables |

**Simplifiable** (compress, keep meaning):

| Pattern | Strategy |
|---------|----------|
| Verbose comments | Reduce to one line, keep only non-obvious notes |
| Multi-line logging | Collapse to a single template line |
| Wordy intros | Drop "In this phase we will..." preambles |
| Prompt bloat | Trim agent or exploration prompts to the essential instruction |
| Display-format blocks | Convert a block that only defines output shape to a prose sentence |

**Mergeable** (combine related structures):

| Pattern | Strategy |
|---------|----------|
| Similar AskUserQuestion blocks | One shared block with a mode parameter |
| Repeated Option routing | One dispatch |
| Sequential single-line commands | One code block |
| Repeated TodoWrite blocks | Template once, the rest as one-line deltas |
| Duplicate error tables | One table |
| Equivalent template variants | One template plus a variant comment naming the dropped case |
| Multiple output-artifact tables | One combined table with a phase column |

**Format fixes**:

| Pattern | Fix |
|---------|-----|
| Nested backtick literals | Convert the block to prose, or use a four-backtick fence |
| Hardcoded option lists | Add a comment: generate dynamically from the named source |
| Handoff without steps | Add concrete steps referencing the target command's real interface |
| Unclosed brackets | Match the brackets |

## Step 1.4: Build the plan

Order operations delete then merge then simplify then format. Delete is
safest and highest impact, format is last so it sees the final structure.

Report a short summary: category counts, estimated reduction percentage, and
the sections you will NOT touch (the functional core). Carry forward
`analysisResult = { inventory, redundancyMap, plan, originalContent,
originalLines }` for the next phases.
