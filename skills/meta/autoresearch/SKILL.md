---
name: autoresearch
description: 'Autonomous loop that optimizes a measurable metric (coverage, bundle size, lint errors) one change at a time. Use when repeated experiments can be judged by a mechanical score.'
category: meta
license: MIT
metadata:
  attribution: "Core patterns from autoresearch by Udit Goenka (MIT); adapted for cue"
  version: "1.0.0"
---

# Autoresearch: Autonomous Optimization Loop

> Constraint + mechanical metric + fast verification = autonomous improvement.

Run N iterations that each make one atomic change, measure a single number, and keep or discard based on the score. Git is the memory and the rollback.

## When to use

- Improve a measurable metric: test coverage, bundle size, ESLint error count, Lighthouse score.
- Autonomous execution over many iterations without manual steering.
- Git-tracked experiments where you want automatic rollback on regression.

## When NOT to use

| Situation | Better tool |
|-----------|-------------|
| Subjective goals ("make it cleaner") | `just` with an approved direction |
| Bug fix with a known root cause | `investigate` then a direct fix |
| One-shot task, no repetition | `just` |
| No mechanical metric to score progress | `autoplan` / normal flow |

## Prerequisites

- A git repository with a clean working tree before starting.
- A `Verify` command that prints a single number to stdout and finishes in under ~30 seconds.

## Configuration

Parse from the user message. Missing required fields trigger one batched `AskUserQuestion`.

Required: `Goal` (what to improve), `Scope` (glob of editable files), `Verify` (shell command printing one number).

Optional: `Guard` (regression check, exit 0 = pass), `Iterations` (default 10), `Noise` (low/medium/high), `Min-Delta` (default 0), `Direction` (higher/lower, default higher).

## Core protocol

See `references/autonomous-loop-protocol.md` for the full 8-phase spec. Key invariants:

- One atomic change per iteration. Test: can you describe it in one sentence with no "and"?
- Commit before verify. Git is memory, not just a safety net.
- Guard files are read-only. Never edit files in the guard command's scope.
- Prefer `git revert` over `git reset` to preserve history.

## Results logging

Each iteration appends a TSV row to `loop-results.tsv` in the working directory: iteration, commit, metric, delta, status (baseline/keep/discard), description. Full schema in `references/results-logging.md`.

## Stuck detection

- 5 consecutive discards: analyze patterns, shift strategy (different files or approach).
- 10 consecutive discards: stop, report findings, surface to the user.

## References

- `references/autonomous-loop-protocol.md` full 8-phase loop, decision matrix, anti-patterns
- `references/git-memory-pattern.md` git as cross-iteration memory, revert vs reset
- `references/guard-and-noise.md` regression guard pattern, noise-aware verification
- `references/results-logging.md` TSV format and progressive summaries
- `references/metric-library.md` common verify commands by domain

## Example

```
Goal: Increase test coverage in src/utils from ~60% to 80%
Scope: src/utils/**/*.ts, tests/utils/**/*.test.ts
Verify: npx jest tests/utils --coverage --coverageReporters=json-summary 2>/dev/null | node -e "console.log(require('./coverage-summary.json').total.lines.pct)"
Guard: npx tsc --noEmit && npx jest --passWithNoTests
Iterations: 15
Direction: higher
```

The loop commits each kept change, reverts each regression, and logs every iteration to `loop-results.tsv`.

## Limitations

Cannot optimize subjective goals, cannot edit files outside `Scope` or files the `Guard` reads, cannot guarantee improvement (metrics have ceilings), and runs sequentially by design so each iteration learns from the last.
