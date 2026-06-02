# Scan algorithm

How to discover spawn sites, locate the spawned agent, parse both sides, and run
the 7 checks. Cue-native: no `ccw` CLI, no Gemini evaluator, no `.workflow/`
paths, no `ccw-tools` MCP. Plain Read / Grep / Glob / Bash, plus an optional
`Agent` for a fresh-context second pass on a large scan.

## 1. Determine scan scope

Parse the user's request into a scope.

| Signal | Scope |
|---|---|
| Path to a skill `SKILL.md` or command `.md` | That file plus every agent it spawns |
| Path to an agent `.md` | That agent plus every spawn site that targets it |
| A directory | Every `SKILL.md` and command file under it |
| "all" or no argument | Every `resources/skills/skills/**/SKILL.md`, `.claude/commands/*.md`, `.claude/agents/*.md` |

If the scope is unclear, ask with `AskUserQuestion`: one skill, one command-agent
pair, or a full scan.

## 2. Find spawn sites

Grep the in-scope skill and command files for spawn patterns. Both the current
`Agent(` form and the legacy `Task(` form, plus `subagent_type` dispatches.

```bash
grep -rn 'Agent(\|Task(\|subagent_type' "$SCOPE"
```

For each spawn site, extract three things:
- the `subagent_type` value (the agent name, or `general-purpose`)
- the full prompt string passed to the spawn
- the line range of that prompt

Many cue skills dispatch a `subagent_type: "general-purpose"` agent with an inline
prose prompt rather than a named agent file (see `gstack/ship`,
`review/code-review-deep`). For those, there is no agent file to cross-check, so
D1 to D6 score against the *inline role text inside the prompt itself* and D7 asks
whether the prompt states its own return contract. A `general-purpose` spawn with
no stated identity and no return contract is not a violation, it is the norm.

## 3. Locate the agent definition

For each named `subagent_type`, look in the standard spots.

```bash
ls .claude/agents/${AGENT}.md 2>/dev/null
ls resources/skills/skills/*/agents/${AGENT}.md 2>/dev/null
```

If no file is found and the type is not `general-purpose`, record a `MISSING_AGENT`
finding. That is itself a D7 error: the skill spawns an agent that does not exist.

## 4. Parse the prompt

Pull structured intent and anti-patterns out of the prompt string.

Intent blocks to find: objective, input file list, runtime parameters, output
location, expected return markers, downstream consumer, per-invocation quality
gate, revision instructions.

Anti-patterns to flag (these feed D1, D2, D5, D6):
- identity statements ("You are a...", "Your role is...")
- domain tables, heuristics, good/bad comparison pairs
- numbered process steps outside a revision block
- philosophy statements ("always prefer...", "never do...")
- technical decision nouns (library or pattern names) in free text

## 5. Parse the agent

From the agent file (or the system prompt of a named subagent type), pull:
identity, spawner list, responsibilities, guiding principles, return contract
(the full set of markers it emits), self-check quality gate, domain sections,
anti-patterns.

## 6. Run the 7 checks

For each spawn-site / agent pair, run D1 to D7 from
[separation-rules.md](separation-rules.md). Record severity and a one-line detail
for each dimension. Respect the exceptions: mode references, cross-cutting policy
blocks, and user-decision passthrough are not violations.

## 7. Aggregate and report

Per pair, show the 7 dimensions as PASS / WARN / ERROR with a short detail each.
Roll up to a verdict per the table in separation-rules.md (CLEAN / REVIEW /
CONFLICT). For every error and warning, give a fix: file and line, what is wrong,
which owner the content should move to, and a before/after snippet when short.

### Report shape

```
DELEGATION-CHECK > SCAN COMPLETE

Scope: <description>
Pairs checked: <N>
Findings: <E> errors, <W> warnings, <I> info
Verdict: CLEAN | REVIEW | CONFLICT

| Pair | D1 | D2 | D3 | D4 | D5 | D6 | D7 |
|------|----|----|----|----|----|----|----|
| <skill> -> <agent> | ok | warn | ok | ok | err | ok | ok |

Fix priority:
1. <highest-severity fix, file:line, owner to move to>
2. <next fix>
```

## Optional fresh-context pass

On a full-repo scan, dispatch the per-pair judging to a `general-purpose` agent
via the `Agent` tool so the parent context stays clean. The subagent reads one
pair, runs D1 to D7, and returns only the verdict row plus any fix lines. Skip
this for a single-pair check, the cost is not worth it.

## Success criteria

- Scope resolved and every in-scope file read
- Every spawn site found, with its full prompt string and target agent
- Every named agent located or recorded as `MISSING_AGENT`
- 7 dimensions scored per pair
- No false positive on mode references, cross-cutting policy, or user-decision passthrough
- A fix given for every error and warning
- Per-pair table shown and an overall verdict reached
