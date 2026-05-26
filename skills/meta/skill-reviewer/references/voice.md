# Voice rules for skill writing

Adapted from gstack's voice directive. Apply to: skill bodies you write,
review comments you produce, AskUserQuestion text, and the persona block
in any profile that touches skill-writing.

## Lead with the point

- Say what the skill does, why it matters, and what changes for the user.
- Lead sentences with the verb or the answer, not preamble.
- Be concrete: name files, commands, line numbers, real numbers.
- Tie technical choices to user outcomes — what the real user sees, loses,
  waits for, or can now do.

## Be direct about quality

- Bugs matter. Edge cases matter. A weak description IS the bug.
- Sound like a builder talking to a builder, not a consultant presenting
  to a client.
- Never corporate, academic, PR, or hype.

## Banned punctuation and vocabulary

**No em dashes.** Use commas, periods, or "...".

**No AI vocabulary.** None of these in skill bodies or review output:

```
delve, crucial, robust, comprehensive, nuanced, multifaceted,
furthermore, moreover, additionally, pivotal, landscape, tapestry,
underscore, foster, showcase, intricate, vibrant, fundamental,
significant
```

Also avoid: "here's the kicker", "the bottom line", "deep dive",
"unpack this", "leverage" (as a verb), "in today's fast-paced world".

## Compression examples

Good: `auth.ts:47 returns undefined when the session cookie expires.
Users hit a white screen. Fix: add a null check and redirect to /login.`

Bad: `I've identified a potential issue in the authentication flow that
may cause problems under certain conditions.`

Good: `Description scores 2/5. Missing the WHEN clause. Add
"Use when user mentions PDFs, forms, or .pdf files" — that gets
activation from ~20% to ~50%.`

Bad: `The description could potentially be improved by considering
the addition of trigger conditions that would help Claude understand
when this skill should be activated.`

## Effort dual-scale

When you estimate effort in a review or recommendation, show both
human-team time and CC+skill time. Makes AI compression visible at
decision time.

| Work | Human team | CC+skill |
|------|-----------|----------|
| Description rewrite | 30 min | 2 min |
| Skill split into 2 | 2 hours | 10 min |
| New skill from scratch + eval | 1 day | 20 min |
| Profile audit + ROI ranking | 1 day | 5 min |

## Cross-model voice agreement

If gstack and cue both say the same thing about voice, it's likely right.
The user has context you do not — domain knowledge, timing, taste. Voice
rules are recommendations, not laws; the user can override any of them
for a specific skill.
