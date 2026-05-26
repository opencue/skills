---
name: code-review-deep
description: |
  Pre-landing two-pass diff review. Pass 1 (CRITICAL) catches SQL safety,
  race conditions, LLM trust-boundary violations, shell injection, and
  enum completeness. Pass 2 (INFORMATIONAL) covers everything else.
  Optionally launches parallel specialist sub-reviews (security, perf,
  testing, maintainability, api-contract, data-migration, red-team).
  Use when the user says "deep review", "pre-landing review", "review
  my diff", or before opening a PR.
allowed-tools: [Bash, Read, Edit, Write, Grep, Glob, Agent, AskUserQuestion]
triggers:
  - deep review
  - pre-landing review
  - review my diff
  - check my pr
  - review before merge
---

# /code-review-deep — pre-landing diff review

This is the heavyweight cousin of `/code-review`. It runs two passes
against `git diff <base-branch>` and produces a structured findings
report with auto-fixes for the mechanical issues.

## Iron contract — every finding is grounded; CRITICAL is never auto-fixed silently

Two non-negotiables:

1. **Every finding cites file:line.** A finding without a file path and
   line number is a vibe, not a review. Drop it or grep until you have
   the citation.
2. **CRITICAL findings (Pass 1) are never auto-applied without the user
   seeing the diff first.** Mechanical INFORMATIONAL fixes (Pass 2) may
   batch-apply; SQL/auth/injection fixes never do. A wrong auto-fix on
   a critical bug ships a worse bug than the original.

## Setup

1. **Determine base branch.** Default to `main`. If the repo uses
   `master` or a release branch, ask once via `AskUserQuestion`.
2. **Capture diff.** `git diff <base>...HEAD --no-color | wc -l`. If
   diff is > 2000 lines, warn the user — quality drops on huge diffs;
   suggest splitting.

## Pass 1 — CRITICAL (always run)

Run the checks in [`checklist.md`](checklist.md), section "Pass 1".

Categories:
- SQL & data safety
- Race conditions & concurrency
- LLM output trust boundary
- Shell injection
- Enum / value completeness

For each finding, output:
- `file:line`
- One-line description of the problem
- One-line recommended fix

## Pass 2 — INFORMATIONAL

Same checklist, section "Pass 2". Lower-severity issues — async/sync
mixing, column-name safety, dead code, magic numbers, etc.

## Optional: parallel specialist sub-reviews

If the diff is non-trivial (> 200 lines or > 5 files), offer to launch
specialists in parallel via the `Agent` tool. Each reads a specialist
prompt from `specialists/`:

| Specialist | When to launch |
|---|---|
| `security` | New endpoints, auth changes, user-controlled input |
| `performance` | Hot-path edits, new queries, bundle changes |
| `testing` | New code without new tests |
| `maintainability` | Large refactors, deep nesting, new abstractions |
| `api-contract` | Public API shape changes (OpenAPI/GraphQL/RPC) |
| `data-migration` | Schema changes, backfills, irreversible writes |
| `red-team` | Anything touching authz, secrets, or production data |

To launch one specialist, send a single `Agent` call with `description`
"Review for <area>", `subagent_type: claude` (or general-purpose), and
the specialist prompt as the body. Run them in parallel via multiple
tool calls in one message.

## Output format

```
Deep Review: N issues (X critical, Y informational)

**AUTO-FIXED:** (mechanical issues fixed without asking)
- src/foo.py:42 — typo in error message → fixed

**NEEDS INPUT:** (ambiguous, batch into one question)
- src/bar.py:108 — `session.execute(f"SELECT … {user_id}")` is SQL
  injection. Recommended: parameterized query with `:user_id`.
- …

**SPECIALIST FINDINGS:** (only if specialists ran)
- [security] src/auth.py:55 — new endpoint missing authz check
- [performance] src/loader.py:88 — N+1 in `load_users` loop
```

If no issues found: `Deep Review: No issues found.` and stop.

## Auto-fix policy

You may apply a fix **without asking** only when ALL are true:
- The fix is mechanical (typo, missing import, wrong format string)
- The intent is unambiguous from context
- The fix is < 5 lines and touches one file

Everything else gets batched into one `AskUserQuestion` at the end.

## Anti-patterns

- ❌ "Looks good overall." → either flag something or output the
  "No issues found" line.
- ❌ Per-issue back-and-forth. Batch the input prompts at the end.
- ❌ Refactoring on the way through. Flag opportunities — don't take
  them yourself.
- ❌ Skipping Pass 1 because Pass 2 caught some things.

## After this skill

If issues are fixed, suggest: "Run your test suite, then `/code-review`
(the lighter version) to double-check, then ship the PR."

## Capture learnings

If a category of finding kept appearing across this review (same
antipattern in multiple files, same missed test convention, recurring
SQL escape mistake), log it so future reviews of this project flag the
pattern earlier:

```bash
bin/cue-learnings log --type pitfall \
                     --key <project-slug>-<short-pattern-name> \
                     --insight "<one-line: where it lives, what to check>" \
                     --confidence 1-10 \
                     --source observed
```

Only log patterns that span 2+ files or repeat in 2+ reviews. One-off
bugs go in the PR description, not the learnings log. Convention:
[../../meta/skill-reviewer/references/learnings.md](../../meta/skill-reviewer/references/learnings.md).
