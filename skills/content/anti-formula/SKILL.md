---
name: anti-formula
description: >-
  Use when the user says "/anti-formula", "check this for formulas", "is this
  draft mechanical", "lint my post", "audit recent posts for repetition", or
  before scheduling any post drafted by article-writer / trend-to-thread.
  Detects mechanical writing patterns (duplicate sentence starts, forced ?
  closers, arrow-chain monotony, recycled closers, banned AI vocabulary)
  across one draft or a window of recent drafts. Gate, not suggestion.
allowed-tools:
  - Bash(grep:*)
  - Bash(rg:*)
  - Bash(awk:*)
  - Bash(wc:*)
  - Bash(ls:*)
  - Bash(find:*)
  - Bash(head:*)
  - Bash(tail:*)
  - Read
  - Write
  - Edit
tags: [content, lint, writing, social, formula-detection]
domain: content
category: lint
---

# anti-formula — kill the template before publishing

This skill exists because the same writer who can produce great copy
will, on the third draft of the day, ship a perfect template instead of
a piece of writing. The fix is a mechanical check that fires BEFORE
scheduling. Six rules, one verdict.

## Prerequisites

Standard Unix utilities — `grep`, `awk`, `wc`, `find`, `head`, `tail`.
All ship by default on macOS and Linux; no install needed. `ripgrep`
(`rg`) is optional but speeds up the rolling-window scans across
`~/Documents/cue/drafts/` if you have many drafts.

## When to run

| Trigger | What to check |
|---|---|
| Just finished a draft | the single draft |
| Scheduling a thread on X | the single draft + last 7 days of drafts |
| User asks "why does this feel off" | the single piece against all 6 rules |
| User asks "are we getting repetitive" | rolling 14-day window across all drafts |

## The 6 rules

### R1 — Duplicate sentence starts

**Fails if:** ≥3 tweets/paragraphs in the SAME draft open with the same
first word, OR ≥4 across the last 7 days of drafts open with the same
first word.

Example failure: thread opens tweet 1 with `Real AI usage is real.`,
tweet 2 with `Real AI revenue is debatable.`, tweet 3 with `Real free
cash flow is what breaks the loop.` Three `Real`s in a row = formula.

How to detect:

```bash
awk '/^[0-9]+\// {getline; print $1}' draft.md | sort | uniq -c | sort -rn | head -5
```

If any first-word count is ≥3 for the same draft, flag it.

### R2 — Forced `?` closer

**Fails if:** any sentence ending in `?` is NOT the visible completion
of a `[label] — [value]` pattern.

Examples of NATURAL `?` (passes): `2026 top — ?` (the visible list is
`1929 top — ~32 / 2007 top — ~27 / 1999 top — 44.19 / 2026 top — ?`),
`Open-price multiple — ?` (list of metrics with one missing).

Examples of FORCED `?` (fails): `Real new dollars in this loop — ?`
(no surrounding pattern), `Real free cash flow is — ?` (grammatically
broken), `Tomorrow — ?` (no list above it).

How to detect: search for `— ?` lines, then check the 3 lines above for
a parallel `— <value>` pattern. If none, fail.

### R3 — Arrow-chain monotony

**Fails if:** ≥4 consecutive lines in the same tweet start with the
same bullet style (`→`, `•`, `-`, `▎`).

Why it matters: a list of 4 arrows reads as monotone scroll. Mix the
bullet style or break with a prose line between arrows.

How to detect:

```bash
awk '/^[→•\-]/ {n++; if (n>=4) print NR": chain"} !/^[→•\-]/ {n=0}' draft.md
```

### R4 — Banned vocabulary

**Fails if:** the draft contains ANY of these words/phrases:

delve, leverage, robust, comprehensive, nuanced, multifaceted,
furthermore, moreover, pivotal, landscape, tapestry, crucial,
"it's worth noting", "in conclusion", "in summary", "navigate the",
"unlock the power of", "dive into", "take a deep look at",
"the world of", "at its core", "fundamentally speaking".

How to detect:

```bash
grep -niE 'delve|leverage|robust|comprehensive|nuanced|multifaceted|furthermore|moreover|pivotal|landscape|tapestry|crucial|it.{1,3}s worth noting|in conclusion|in summary|navigate the|unlock the power|dive into|take a deep look|the world of|at its core|fundamentally speaking' draft.md
```

Hit = flag. No exceptions.

### R5 — Recycled closers

**Fails if:** the draft's closing line appears in any draft from the
last 7 days.

Phrases that have already been used (rolling block-list, edit as new
ones get worn out):

- `Not financial advice.` — allowed once per day max, max 2/week, no
  back-to-back days as sole closer pattern.
- `Position sizing is a thesis. So is cash.` — cooldown 7 days from
  last use.
- `Both can be true.` — only when contradiction is load-bearing.
- `Same X. Different Y.` — cooldown 7 days.
- `Tomorrow it widens or it doesn't.` — cooldown 7 days.

How to detect:

```bash
# pull last line of each .md in drafts/ from the last 7 days
find ~/Documents/cue/drafts -name "*.md" -newermt "7 days ago" \
  -exec sh -c 'echo "$1:"; tail -1 "$1"' _ {} \;
```

Compare against the current draft's closing line. Substring match
counts as a fail.

### R6 — Concrete lead

**Fails if:** the first tweet/paragraph contains NO concrete element
(no number, no proper noun, no specific date, no specific object).

Why: abstractions ("AI is changing how we work") slide past the eye.
Specifics ("Microsoft put $13B into OpenAI") arrest it.

How to detect: scan the first paragraph for `[0-9]+`, ALLCAPS proper
nouns, or known entity names from a custom list. None present = flag.

## Invocation

```
/anti-formula <draft-path>           # check a single draft
/anti-formula --window 7              # check rolling 7-day window
/anti-formula --before-schedule       # full gate before postiz posts:create
```

## Output format

Always emit a structured verdict, NOT prose:

```
ANTI-FORMULA AUDIT — <draft-path>
─────────────────────────────────
R1 duplicate-starts:    PASS / FAIL — <evidence>
R2 forced-?-closer:     PASS / FAIL — <evidence>
R3 arrow-monotony:      PASS / FAIL — <evidence>
R4 banned-vocab:        PASS / FAIL — <evidence>
R5 recycled-closer:     PASS / FAIL — <evidence>
R6 concrete-lead:       PASS / FAIL — <evidence>
─────────────────────────────────
VERDICT: PASS / FAIL
```

If FAIL: produce the specific rewrite for each failing rule before
returning control. Do NOT just list the failure — show the fix.

## When to override

There is exactly one override scenario: the user EXPLICITLY says
"ship it as-is" after seeing the audit. Default behavior is to block
the schedule on any FAIL.

Do not override for "it's only one rule" or "the audience won't
notice." The audit exists because those exact rationalizations are
how the formulas slip in.

## Out of scope

- Style judgment beyond the 6 rules. Subjective ("this metaphor is
  weak") belongs in a separate review pass.
- Spelling / grammar. Use a spellchecker for those.
- Brand voice compliance — that's the brand kit's job (`brand.md`),
  not this skill's.
- Cashtag count enforcement — that's `x-thread-lint.py`, a different
  gate.

## Sister tooling

- `~/Documents/cue/scripts/x-thread-lint.py` — char-limit and cashtag
  gate. Runs alongside this skill, not instead of it.
- `ai-slop-detector` (from `aahl/skills`) — broader AI-tell detector;
  use both together. anti-formula catches the user's specific
  template; ai-slop-detector catches generic AI patterns.
- `content/article-writer/voices.md` — the variety source. When R5
  fires, pick a voice from there that wasn't used in the last 3 days.
