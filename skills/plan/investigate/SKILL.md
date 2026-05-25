---
name: investigate
description: |
  Systematic root-cause debugging. Four phases: investigate → analyze →
  hypothesize → implement. Iron Law: no fix without a root cause. Stops
  after 3 failed fixes and reassesses. Use when the user reports an
  error, 500, stack trace, "it was working yesterday", or asks to "debug
  this", "fix this bug", "why is X broken", or "root cause analysis".
allowed-tools: [Bash, Read, Write, Edit, Grep, Glob, AskUserQuestion, WebSearch]
triggers:
  - debug this
  - fix this bug
  - why is this broken
  - root cause analysis
  - investigate this error
  - it was working yesterday
---

# /investigate — root-cause debugging

The single most common failure mode in AI-assisted debugging is the agent
jumping to a fix before understanding the cause. This skill enforces the
opposite: **investigate first, hypothesize second, fix third.**

## Iron Law

> No fix is committed without a stated root cause and a stated reason
> the fix addresses it. If the agent can't articulate the cause, the
> agent isn't fixing yet — it's guessing.

## Stop-after-3 rule

After **3 failed fix attempts** on the same bug, stop. Reassess. The
working hypothesis is wrong. Don't keep patching — go back to Phase 1.

## Optional: scope-lock the investigation

Before diving in, ask: "Should I lock edits to one module while I
investigate? (`/freeze <dir>`)" — prevents the agent from "helpfully"
modifying unrelated code mid-investigation. Decline is fine.

## Phase 1 — investigate (no fixes yet)

Goal: a concrete, reproducible failure. No "it probably is the cache."

1. **Reproduce.** Get a stack trace, error message, or failing command
   that you can run on demand. If you can't reproduce, ask the user for
   the exact steps that triggered it.
2. **Read the immediate code.** Open the file at the top of the trace.
   Read the function. Read the function that calls it. Don't skim.
3. **Trace inputs.** Where do the function's inputs come from? What
   shape are they in this case vs. the working case?
4. **Diff against working.** If the user said "it was working
   yesterday," run `git log --since='2 days ago'` on the affected paths.
   Read the diffs. Don't assume — read.

Output of Phase 1: a one-paragraph **observation** in your reply.
Example: "Endpoint `POST /api/x` 500s when `body.tier == 'mega'`. Trace
points at `compute_tier_price` (`src/pricing.py:142`), which assumes
`tier in ('quick','lfg')`. 'mega' was added to the enum yesterday in
`schema.py:34` but `compute_tier_price` was not updated."

## Phase 2 — analyze

Now that you have an observation, ask: **why does this specific code
produce this specific failure for this specific input?**

- Don't list possibilities. Pick the most likely one and explain *why*
  it's most likely.
- If multiple causes are plausible, rank them and say which evidence
  would distinguish them.
- Update your mental model: when you find data that contradicts your
  hypothesis, the hypothesis loses, not the data.

## Phase 3 — hypothesize the root cause

State the root cause in **one sentence**. Examples:

- ✅ "`compute_tier_price` switches on tier name and falls through to
  the `KeyError` default when an unrecognized tier reaches it; the
  'mega' enum value was added without updating the switch."
- ❌ "Something about tier handling is broken." — not a root cause.
- ❌ "The cache was stale." — say *why* it was stale and how the code
  permitted stale data in this case.

Then state how the fix addresses the cause:
- "Add 'mega' to the switch in `compute_tier_price`, returning the
  price formula from the spec at `docs/pricing-tiers.md:18`."

## Phase 4 — implement

Now and only now: write the fix.

- **Smallest change.** Don't refactor on the way through.
- **Add a test that reproduces the bug.** Run it first — confirm it
  fails for the right reason. Then apply the fix and confirm it passes.
- **Run the full test suite, not just the new test.** Look for
  regressions.
- **Document the cause in the commit message.** Future-you needs to
  know why this line exists.

## Failure mode handling

| What happened | What to do |
|---|---|
| Reproduced, but the cause isn't where the trace points | Trust the data, expand search. Often the call site is the actual bug. |
| Fix made the test pass but seems unrelated | You're patching a symptom. Go back to Phase 2. |
| Three fixes in a row didn't work | Stop. Restate the observation. Your hypothesis is wrong. |
| User pressuring you to "just try something" | Politely refuse. Patches without causes accumulate into a worse bug. |

## Anti-patterns

- ❌ Editing five files before stating the cause.
- ❌ "Let me try X" without saying why X would work.
- ❌ Skipping the failing-test-first step.
- ❌ Closing the investigation when the test passes but the cause is
  still "probably the cache."
- ❌ Treating a stack trace as a wishlist — only fix what the trace
  actually implicates.

## Hand-off

When done, summarize in one message:

> Root cause: <one sentence>
> Fix: <one sentence>
> Test added: <path:line>
> Verified: <how you confirmed>

Then stop. Don't refactor adjacent code.
