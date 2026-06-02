# Content separation rules

Rules for the boundary between **delegation prompts** (the `prompt` string passed
to an `Agent(...)` / `Task(...)` spawn, or a `subagent_type` dispatch in a cue
skill or `.claude/commands/` file) and **agent role definitions** (the spawned
agent's own file under `.claude/agents/<name>.md`, or the system prompt of a
named `subagent_type`).

Adapted from the CCW delegation-check spec. Same algorithm, cue-native targets:
cue skills live in `resources/skills/skills/**/SKILL.md`, commands in
`.claude/commands/*.md`, agents in `.claude/agents/*.md`.

## Core principle

**The spawner owns WHEN and WHERE. The agent owns WHO and HOW.**

A delegation prompt tells the agent what to do *this time*. The agent definition
tells the agent who it *always* is. When the prompt restates identity, embeds
domain knowledge, or dictates process, it duplicates or fights the agent file.
They drift apart over time and the agent's self-understanding gets confused.

## Ownership matrix

### The delegation prompt owns

| Concern | Example |
|---|---|
| What to accomplish this run | "Audit test coverage for the diff on branch X" |
| Input file paths for this run | "Read src/foo.ts and the plan at .cue/plan.md" |
| Runtime parameters | "Mode: revision. Phase: 5." |
| Output location | "Write findings to /tmp/coverage.md" |
| Expected return markers (routing) | "Return `## PASS` or `## ISSUES FOUND`" |
| Who consumes the output | "Parent skill /ship reads your conclusion" |
| Revision context | "What changed: the checker flagged 3 gaps. Address them." |
| User interaction | `AskUserQuestion` calls |
| Banners / status display | "=== SHIP > coverage audit ===" |

### The agent role definition owns

| Concern | Example |
|---|---|
| Identity | "You are a coverage auditor." |
| Spawner list | "Spawned by: /ship, /code-review-deep" |
| Responsibilities | "Find untested branches in the changed lines." |
| Mandatory read protocol | "Read every file in the input list before judging." |
| Guiding principles | "Prefer false negatives over noise." |
| Domain expertise | Decision tables, heuristics, good/bad examples |
| Return protocol | The full set of return markers it can emit |
| Self-check | Permanent quality checks run on every invocation |
| Anti-patterns | "Do not flag generated files." |

## The 7 conflict dimensions

### D1 Role re-definition

**Question:** does the prompt redefine the agent's identity?

**Detect:** scan the prompt string for `You are a`, `You are the`, `Your role is`,
`Your job is to`, `Your responsibility is`, `Core responsibilities:`, or any line
that contradicts the agent's identity section.

**Allowed:** referencing a mode the agent already lists ("run in revision mode").

**Severity:** `error` if the prompt redefines the role. `warning` if it adds
responsibilities the agent file does not list.

### D2 Domain expertise leak

**Question:** does the prompt embed domain knowledge that belongs in the agent?

**Detect:**
- Decision or routing tables (`| Condition | Action |`) in the prompt
- Good-vs-bad comparison pairs (`| TOO VAGUE | JUST RIGHT |`)
- Heuristic rules ("If X then Y", "Always prefer Z")
- Anti-pattern lists ("DO NOT...", "NEVER...")
- Numbered rule lists over 3 items that are not revision instructions

**Exception:** a cross-cutting policy block (uniform rules applied to every agent
a skill spawns, such as anti-shallow-execution rules) is structural policy, not
domain knowledge. Flag it `info` unless its content duplicates an agent domain
section word for word.

**Severity:** `error` if the prompt holds domain tables or examples that duplicate
agent content. `warning` for heuristics not present in the agent.

### D3 Quality gate duplication

**Question:** do the prompt's quality checks overlap or fight the agent's own
self-check list?

**Detect:** fuzzy-match quality items between prompt and agent (over 60% token
overlap is a duplicate).
- **Duplicate:** same check in both. `warning`. They can diverge later.
- **Conflict:** contradictory limits (prompt says "max 3 tasks", agent says "max 5"). `error`.
- **Gap:** prompt expects a check the agent lacks. `info`.

**When duplication is fine:** the prompt adds an *invocation-specific* check not in
the agent's permanent gate (for example "phase 5 requirement IDs all covered").

### D4 Output format conflict

**Question:** does the prompt's expected output fight the agent's return contract?

**Detect:** extract return-marker strings from both sides and compare the sets.
- Prompt routes on `## DONE` but agent emits `## TASK COMPLETE` → markers differ.
- Prompt expects file output, agent contract defines only markers (or the reverse).

**Why it matters:** the spawner routes on markers. If they do not match, routing
breaks silently. The skill may hang or misread the result.

**Severity:** `error` if return markers conflict. `warning` if either side leaves
the format unspecified.

### D5 Process override

**Question:** does the prompt dictate HOW the agent works?

**Detect:** scan for step-by-step process outside a revision block:
- Numbered steps ("Step 1:", "First..., Then..., Finally...")
- Process flow beyond the objective
- Tool instructions ("Use grep to...", "Run this bash command...")
- Execution ordering that fights the agent's own flow

**Allowed:** a revision block telling the agent *what changed*, not *how to work*.

**Severity:** `error` if the prompt overrides the agent's process. `warning` for
process hints.

### D6 Scope authority conflict

**Question:** does the prompt make decisions the agent's domain should own?

**Detect:** technical nouns (library names, architecture patterns) in prompt free
text, outside an input-path description.
- Prompt picking the implementation (which library, which pattern) → conflict.
- Prompt passing through a user-locked decision from a context file → correct.
- Agent interpreting that locked decision → correct.

**Severity:** `error` if the prompt makes a domain decision the agent should own.
`info` if it passes through a user decision (the right behavior).

### D7 Missing contracts

**Question:** are the handoff points complete?

| Missing element | Impact |
|---|---|
| Agent has no return contract | Spawner cannot route on markers |
| Spawner ignores some agent return markers | BLOCKED / CHECKPOINT silently dropped |
| Agent expects input files but prompt omits them | Agent starts without context |
| Agent's spawner list omits this command | Agent may not expect this call pattern |
| Agent expects a structured input the prompt does not match | Agent misreads input |

**Severity:** `error` if return-marker handling is missing. `warning` if the agent
expects input the prompt does not provide.

## Severity classification

| Severity | When | Action |
|---|---|---|
| `error` | Actual conflict: contradictory content across prompt and agent | Must fix. Move content to the right owner. |
| `warning` | Duplication or boundary blur without contradiction | Should fix. Consolidate to one source of truth. |
| `info` | Acceptable pattern that looks like a violation but is not | No action. Note why it is fine. |

## Verdict

| Verdict | Condition |
|---|---|
| **CLEAN** | 0 errors, 0 to 2 warnings |
| **REVIEW** | 0 errors, 3 or more warnings |
| **CONFLICT** | 1 or more errors |

## Quick reference: is this content in the right place?

| Content | In prompt? | In agent? |
|---|---|---|
| "You are a..." | No, never | Yes, always |
| File paths for this run | Yes | No |
| Phase number, mode | Yes | No |
| Decision tables | No, never | Yes, always |
| Good/bad examples | No, never | Yes, always |
| "Write to: {path}" | Yes | No |
| Return-marker handling | Yes (routing) | Yes (definition) |
| Quality gate | Per-invocation only | Permanent self-check |
| "Read files first" | No, agent owns this | Yes, always |
| Cross-cutting policy block | OK as uniform policy | Preferred |
| Revision instructions | Yes (what changed) | No |
| Heuristics, philosophy | No, never | Yes, always |
| Banner display | Yes | No, never |
| `AskUserQuestion` | Yes | No, never |
