---
name: plan-eng-review
description: |
  Engineering-manager review of a feature plan before code. Locks in
  architecture, data flow, state machines, edge cases, and a test
  matrix. Forces hidden assumptions into the open via ASCII diagrams.
  Reads the design doc; writes back architectural decisions. Use when
  the user says "eng review", "architecture review", "lock the plan",
  or before exiting plan mode.
allowed-tools: [Read, Write, Edit, Grep, Glob, Bash, AskUserQuestion]
triggers:
  - eng review
  - architecture review
  - lock the plan
  - engineering review
  - plan-eng
---

# /plan-eng-review — architecture lock before code

Read the design doc (and the CEO review section if present). Produce
the architectural layer: how the thing actually works on disk, in
memory, over the network. The goal is **no surprises during build**.

## What to lock down

### 1. Data flow diagram (ASCII)

For any non-trivial feature, sketch the flow as ASCII. Example:

```
[user] --POST /briefing--> [api] --query--> [calendar.gcal]
                              \\
                               +-> [llm.summarize] --tokens--> [redis.cache]
                              /
                          [render]
                              |
                              v
                          [HTML/email]
```

Naming each box forces the question: "what handles failure on this
edge?" If you can't draw the diagram in 6 boxes or fewer, the scope is
probably too big — flag it.

### 2. State machine

If the feature has state transitions (job queues, payment status,
auth flow), enumerate states + transitions:

```
draft --submit--> pending --approve--> active --expire--> archived
                       \\--reject--> rejected
```

For each transition, name the trigger and the failure mode.

### 3. Data model

What new tables / collections / files? What columns / fields / types?
What indexes? What's nullable? Foreign keys? Migration plan if this
touches an existing schema.

State migration safety up front:
- Is the migration backwards-compatible?
- Can it run while the old code is still serving traffic?
- Rollback plan if it goes wrong.

### 4. API surface

For every new endpoint / function / CLI flag:

| Name | Inputs | Outputs | Errors | Auth |
|---|---|---|---|---|
| `POST /briefing` | `{date, userId}` | `{html, sourceCount}` | 400 invalid date, 401 no auth, 502 upstream | session cookie |
| … | … | … | … | … |

### 5. Test matrix

| Scenario | Test type | What's verified |
|---|---|---|
| Happy path | integration | end-to-end response shape |
| Empty calendar | unit | renders "no events today" |
| Stale cache | integration | refetches when TTL elapsed |
| Upstream 5xx | unit | retries 3×, then returns 502 |
| Concurrent writes | integration | last-write-wins with atomic update |

This is the bare minimum. If the feature touches money, auth, or user
data, expand to 15+ rows.

### 6. Failure modes

For each external dependency (API, DB, queue, FS), name what happens
when it's unavailable:
- Hard fail (return 5xx)?
- Graceful degrade (serve stale)?
- Retry then fail?

If the answer is "we haven't decided," that's the most important
question to settle here.

### 7. Hidden assumptions

List the things the design doc treats as given but actually need to
be checked. Examples:
- "User has at most one calendar" — actually true?
- "LLM output is well-formed JSON" — actually true?
- "The cache fits in RAM" — actually true?

For each: state how the code handles the assumption being wrong.

### 8. Security review

One-liner check:
- User-controlled input that touches DB → parameterized?
- LLM output that touches DB → validated?
- New endpoints → authz checked?
- Secrets in env, not code?

If any of these is "not sure," it's a blocker.

## Output format

Append to the design doc as a new section:

```markdown
## Eng review — <YYYY-MM-DD>

### Data flow
<ASCII diagram>

### State machine
<diagram or "n/a — stateless">

### Data model
<schema sketch or migration plan>

### API surface
<table>

### Test matrix
<table>

### Failure modes
<list>

### Hidden assumptions
<list, with the resolution for each>

### Security review
<checklist with pass/fail/blocked per item>

### Blockers before code
<numbered list — empty list = ready to build>
```

If the "Blockers before code" list is non-empty, **do not** exit plan
mode. Loop back to the user with one question per blocker.

## Anti-patterns

- ❌ Drawing a 20-box data-flow diagram. If it doesn't fit on a
  screen, the design is too coupled.
- ❌ Writing "TBD" in the test matrix. If a scenario isn't tested, say
  why or add the test.
- ❌ Treating hidden assumptions as "we'll find out." That's how prod
  finds them for you.

## After this skill

If no blockers, tell the user: "Plan locked. Exit plan mode and I'll
build it." Then stop.
