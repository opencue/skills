---
name: delegation-check
description: 'Lint that Agent()/subagent_type delegation prompts do not conflict with or duplicate the spawned agent role. Use when the user says "check delegation" or "delegation conflict".'
tags: [meta, cue, skills, delegation, quality]
category: meta
version: 1.0.0
---

# Delegation Check

Check that delegation prompts and agent role definitions respect content
ownership. When a skill spawns an agent (`Agent(...)`, legacy `Task(...)`, or a
`subagent_type` dispatch), the prompt should state WHAT to do this run while the
agent file states WHO it is and HOW it works. This skill finds where the two
fight or repeat each other, across 7 conflict dimensions.

Ported from the CCW `delegation-check` skill. The algorithm is preserved. The
CCW machinery (`ccw` CLI, Gemini evaluator, `.workflow/` paths, `ccw-tools` MCP)
is dropped in favor of Read, Grep, Glob, Bash, and an optional `Agent` pass.

## When to activate

- User says "check delegation", "delegation conflict", "prompt vs role check"
- User says "audit my Agent() calls" or "do my prompts fight the agent"
- User is reviewing a skill that spawns a `subagent_type` and wants it clean
- Proactively, when writing or reviewing a skill that dispatches an agent

## The 7 dimensions

| # | Dimension | The bad smell |
|---|---|---|
| D1 | Role re-definition | Prompt says "You are a..." that the agent already owns |
| D2 | Domain expertise leak | Decision tables, heuristics, good/bad examples in the prompt |
| D3 | Quality gate duplication | Same self-check in both, or a contradictory limit |
| D4 | Output format conflict | Prompt routes on markers the agent never emits |
| D5 | Process override | Prompt dictates step-by-step HOW, not just WHAT |
| D6 | Scope authority conflict | Prompt picks the library or pattern the agent should pick |
| D7 | Missing contracts | No return contract, or a spawn of an agent that does not exist |

Full rule text, exceptions, and severities live in
[specs/separation-rules.md](specs/separation-rules.md). Read it before judging,
the exceptions matter (mode references, cross-cutting policy, user-decision
passthrough are not violations).

## Steps

### Step 1 - Set scope

Map the user's request to a scope: one skill, one command-agent pair, a
directory, or a full scan. If it is unclear, ask with `AskUserQuestion`. Scope
rules are in [specs/scan-algorithm.md](specs/scan-algorithm.md).

### Step 2 - Find the spawn sites

Grep the in-scope files for spawn patterns.

```bash
grep -rn 'Agent(\|Task(\|subagent_type' "$SCOPE"
```

For each hit, pull the `subagent_type`, the full prompt string, and its line
range.

### Step 3 - Locate the agent

For each named agent, look in the standard spots.

```bash
ls .claude/agents/${AGENT}.md resources/skills/skills/*/agents/${AGENT}.md 2>/dev/null
```

No file and the type is not `general-purpose` means a `MISSING_AGENT` finding,
which is a D7 error. A `general-purpose` spawn has no agent file, so judge D1 to
D6 against the inline role text in the prompt itself.

### Step 4 - Parse both sides

Parse the prompt for intent blocks and anti-patterns. Parse the agent for
identity, return contract, self-check, and domain sections. Field lists are in
[specs/scan-algorithm.md](specs/scan-algorithm.md).

### Step 5 - Run D1 to D7

Score each dimension PASS / WARN / ERROR per pair, with a one-line detail. Apply
the exceptions so legit patterns do not get flagged.

### Step 6 - Report

Show a per-pair table, a verdict (CLEAN / REVIEW / CONFLICT), and a ranked fix
list. Each fix names the file and line, what is wrong, and which owner the
content moves to.

## Example

Input: "check delegation on resources/skills/skills/gstack/ship/SKILL.md"

The scan finds a `subagent_type: "general-purpose"` dispatch at the coverage-audit
step. Output:

```
DELEGATION-CHECK > SCAN COMPLETE

Scope: gstack/ship/SKILL.md
Pairs checked: 1 (ship -> general-purpose coverage audit)
Findings: 0 errors, 1 warning, 0 info
Verdict: CLEAN

| Pair | D1 | D2 | D3 | D4 | D5 | D6 | D7 |
|------|----|----|----|----|----|----|----|
| ship -> general-purpose | ok | ok | ok | warn | ok | ok | ok |

Fix priority:
1. D4 (line 590): prompt says "report the conclusion" but states no return
   marker the parent routes on. Add an explicit "Return `## COVERAGE OK` or
   `## GAPS FOUND`" so /ship can branch on the result.
```

A second example, a conflict:

Input: a skill spawns `subagent_type: "plan-checker"` with a prompt that opens
`You are a code quality expert. Always prefer 2-3 task plans.`

Output flags D1 (error: prompt redefines the agent identity that
`.claude/agents/plan-checker.md` already owns) and D2 (error: the "2-3 task"
heuristic belongs in the agent's domain section, not the prompt). Verdict:
CONFLICT. Fix: strip both lines from the prompt, keep them in the agent file.

## Rules

- Read [specs/separation-rules.md](specs/separation-rules.md) before scoring. The
  exceptions stop false positives.
- A `general-purpose` spawn with inline role text is the cue norm, not a D1
  violation. Judge it against itself.
- Passing through a user-locked decision from a context file is correct (D6
  info), not a scope conflict. Do not flag it.
- A cross-cutting policy block applied to every spawn uniformly is `info`, not an
  error, unless it copies an agent domain section word for word.
- Never auto-edit the skill or agent. Report findings and a fix, let the user
  apply it.
- Cite file and line for every error and warning, no vague verdicts.

## What this skill does NOT do

- Run or test the agents. It reads the prompt and the role, not the runtime.
- Score skill quality or activation. Use `meta/skill-reviewer` for that.
- Optimize a description field. Use `meta/description-optimizer`.
- Find or wire MCP servers. Use `meta/mcp-finder`.
- Edit files. It is read-only, it outputs findings and fixes.
