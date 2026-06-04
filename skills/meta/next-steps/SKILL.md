---
name: next-steps
description: >-
  Use when finishing a substantive task, or the user says "what's next" or
  "next steps". Close with a ranked Next steps block: <=3 specific items tied
  to what changed, and offer the top one.
tags: [meta, output-format, workflow]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: []
triggers:
  - "what's next"
  - "next steps"
  - "what should i do now"
  - "follow ups"
  - "follow-up suggestions"
  - "what now"
---

# next-steps

When you finish a substantive task, the last thing you say is the user's launch pad for what comes next. Default closings fail in three ways: they vanish, they go vague ("let me know if you need anything"), or they dump every conceivable move. This skill replaces that with a short, ranked, specific Next steps block, and offers to do the top one.

Treat the closing as the most useful sentence in the turn, not filler: the user reads it last and acts on it first.

## When to activate

Apply automatically right after you:

- built, fixed, refactored, or shipped something,
- produced a recommendation, plan, audit, or comparison,
- completed a multi-step request.

Concretely, the turn was substantive if you used Edit, Write, or a mutating command this turn, or produced a recommendation, a plan, or a list of three or more items. That is a signal a hook can see too, not a vibe.

Also when the user says "what's next", "next steps", "what should I do now", or "follow-ups".

Do not apply on trivial one-line answers, pure factual lookups, or mid-conversation clarifying questions. Under caveman or brief mode, collapse to a single terse line.

## The rubric

1. **Source every item from a real artifact this turn.** Each follow-up must trace to something concrete you can point at: a file you changed, a deferral you actually stated ("we'll do X later"), an error you hit, or the user's stated goal. If you cannot name its source, cut it. This is the line between "the freshness-guard path has no test, add one" and a generic "add tests."
2. **Rank by the three flavors, in this fixed order:**
   1. **Continuation:** the obvious next step in this thread.
   2. **Loose end or risk:** something this work created or exposed (an untested path, an implied follow-up, a risk you introduced).
   3. **Upside:** optional polish or an adjacent win, marked optional.
   The order is the priority. Lead with the continuation, never with the upside. Drop a flavor when nothing real fills it rather than padding.
3. **Cap at three.** More than three means you are dumping, not suggesting. One or two is the honest count more often than you think.
4. **Offer the top one as a do-it-now.** End with one question: "Want me to X?" One question, not a menu. The user should be able to reply "yes" and have you proceed.
5. **Be willing to say nothing pressing.** If the task is genuinely closed, say so in one line. Do not manufacture follow-ups to fill the block. "Nothing needed here, ready to ship" is a valid Next steps.
6. **Never re-suggest what you just did,** and never suggest a path you already know is blocked, out of scope, or declined this session.
7. **ROI tags are optional.** Only when the follow-ups are improvement-like and ranking by impact genuinely helps, borrow `meta/roi-estimator` tags (dimension, percent, tier). For a normal closing, the flavor order is the rank and ROI math is overkill.

## Pick the pattern by task type

Starting templates per task type. Always source the specifics from what actually happened (rubric item 1); these are scaffolds, not scripts.

| You just… | Typical Next steps |
|---|---|
| Fixed a bug | add a regression test for it; check whether the same bug exists elsewhere; state the root cause if it is not obvious |
| Built a feature | wire it into the caller or UI; add tests; document it; the one edge case you skipped |
| Refactored | run the suite to prove behavior held; the adjacent module with the same smell; delete code your change orphaned |
| Researched or answered | the one claim worth verifying independently; the obvious follow-up question; where to go deeper |
| Reviewed a diff | fix the top finding; re-review after fixes; the risk you flagged but did not block on |
| Set up or configured | the smoke test that proves it works; the next config step; document the setup |

## Format

Default, after a substantive task:

> **Next steps**
> 1. <recommended specific action>: <one-clause why>
> 2. <loose end or risk>
> 3. <optional upside>
>
> Want me to <top action>?

One or two items is fine when that is the honest count. For a single item, drop the list and just ask.

Caveman or brief mode:

> Next: <one action>. Want it?

## Anti-patterns

- **Vague filler.** "Let me know if you need anything else." Ranks nothing, offers nothing.
- **The dump.** Six bullets covering every branch. Now the user has to re-rank them, which was your job.
- **Generic follow-ups.** Items that fit any task ("add tests", "write docs") with no tie to what actually changed.
- **Manufactured urgency.** Inventing a next step when the task is closed. Padding erodes trust faster than silence.
- **Burying the offer.** Listing options but not offering to act. Keep the top item one "yes" away.

## When to skip

- Trivial or single-fact answers.
- Mid-conversation: the user asked a question and wants the answer, not a roadmap.
- The user explicitly asked for output only, no commentary.
- You already offered next steps this turn. Do not stack two blocks.
- The user is **accepting** a step you just offered ("yes", "do #1", "go"). That
  is your cue to *execute*, not to open a new block. Finish the accepted action,
  then a fresh Next steps block is fine. One block per completed action, never
  two in flight.

## Example

After wiring a new profile and validating it:

> **Next steps**
> 1. Commit the three files on a branch off main: `cue validate` is green, so it is safe to land.
> 2. Wire `/goal` into the profile, the one piece we deferred earlier.
> 3. Optional: feature it in the picker so it shows under Featured.
>
> Want me to commit them?

Bad version of the same closing, for contrast:

> Let me know if you need anything else or want to make changes!

The bad one ranks nothing, ties to nothing, and offers no action to accept.

## Linking

- Related: [[roi-estimator]], the ranking discipline this skill borrows when follow-ups are improvement-like.
- Related: [[retro]], end-of-session process reflection (next-steps is per-task, retro is per-session).
