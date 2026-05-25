---
name: autoplan
description: |
  Compose the full plan-stage pipeline: /office-hours → /plan-ceo-review →
  /plan-eng-review. Auto-skips stages where the design doc already has
  a section, so it's safe to re-run. Surfaces only taste decisions for
  user approval; everything else runs straight through.
  Use when the user says "autoplan", "run the full plan", "plan
  pipeline", or has a fresh idea and wants the whole sprint up to code.
allowed-tools: [Read, Write, Edit, Skill, AskUserQuestion]
triggers:
  - autoplan
  - run the full plan
  - plan pipeline
  - full plan review
---

# /autoplan — chained plan review

The plan-stage pipeline in one command:

1. **`/office-hours`** — premise-question + write design doc
2. **`/plan-ceo-review`** — scope challenge, four-mode framework
3. **`/plan-eng-review`** — architecture, data flow, tests, blockers

Each stage reads what the previous stage wrote. Each stage skips itself
if its section already exists in the design doc (idempotent re-runs).

## Step 1 — find or create the design doc

Look for `.cue/design-docs/*.md` modified in the last 7 days. If one or
more exist, ask via `AskUserQuestion`:

> Which design doc should autoplan run against?
> - <doc1> (most recent, <age>)
> - <doc2>
> - Start fresh — run /office-hours first

If none exist, start with `/office-hours`.

## Step 2 — orchestrate

Invoke each skill via the `Skill` tool in order. Between stages:

- Read the design doc.
- If the next stage's section already exists, ask: "Skip stage X
  (already in doc) or re-run?"
- Default: skip.
- If the previous stage produced blockers, stop and surface them. Do
  not chain into the next stage on top of unresolved blockers.

## Step 3 — final hand-off

After all three stages, summarize:

```
autoplan complete.

Design doc: <path>
- office-hours: <one-line outcome>
- ceo review:   <mode + one-line outcome>
- eng review:   <ready | N blockers>

Ready to build? (Yes → exit plan mode. No → resolve blockers above.)
```

## Anti-patterns

- ❌ Running the pipeline silently. Tell the user where you are at
  each stage transition.
- ❌ Forcing the user through `/office-hours` when they already have
  a design doc — ask first.
- ❌ Skipping the blocker check between stages. An unresolved scope
  ambiguity should stop the eng review, not feed it bad input.
- ❌ Writing code at the end. `/autoplan` ends *before* implementation.
  The user exits plan mode to start the build.
