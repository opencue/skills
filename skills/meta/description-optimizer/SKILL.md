---
name: description-optimizer
description: >-
  Optimize a skill's description field for maximum activation rate.
  Generates 20 trigger/no-trigger eval queries, tests them mentally,
  iterates the description until activation is reliable. Use when user
  says "optimize description", "fix triggering", "skill not activating",
  "improve activation", or "why doesn't this skill fire".
tags: [meta, cue, skills, optimization]
category: meta
version: 1.1.0
requires_mcps: []
allowed-tools: Bash
---

# Description Optimizer

Optimizes the `description:` field in SKILL.md frontmatter. The single
most impactful lever for skill activation (20% → 50% → 90%).

Shared references (read on demand):

- [../skill-reviewer/references/decision-brief-format.md](../skill-reviewer/references/decision-brief-format.md) —
  use the D-numbered brief before applying any description rewrite that
  changes the skill's trigger surface.
- [../skill-reviewer/references/voice.md](../skill-reviewer/references/voice.md) —
  no em dashes, no banned AI vocabulary, lead with the verb.

## When to activate

- User says "optimize description", "fix triggering", "improve activation"
- User says "this skill never fires", "skill not activating"
- User says "why doesn't this skill trigger?"
- After writing a new skill (as a finishing step)

## Step 1 — Read the current description

```bash
head -20 <path-to-SKILL.md>
```

Identify issues:
- Missing "Use when..." clause?
- Written in 1st/2nd person?
- Too vague (no specific keywords)?
- Too short (missing trigger conditions)?
- Too long (>1024 chars)?

## Step 2 — Generate 20 eval queries

Create a mental test set — 10 should-trigger + 10 should-not-trigger:

**Should-trigger queries (10):**
- Mix formal and casual phrasings
- Include cases where user doesn't name the skill explicitly
- Include uncommon use cases
- Use realistic language: file paths, typos, abbreviations, context

**Should-not-trigger queries (10):**
- Near-misses that share keywords but need a different skill
- Adjacent domains where naive matching would false-positive
- Queries that touch the skill's domain but in wrong context

**Quality bar for eval queries:**

```
# BAD — too obvious, tests nothing
"Process a PDF"                    (should-trigger for pdf skill)
"Write a fibonacci function"       (should-not-trigger for pdf skill)

# GOOD — realistic, tests edge cases
"ok my boss sent me this contract.pdf and I need to pull out all the
 dollar amounts from the tables on pages 3-7"  (should-trigger)

"can you help me write a script that generates PDF reports from our
 database? I'm thinking reportlab or weasyprint"  (should-not-trigger
 — this is code generation, not PDF extraction)
```

## Step 3 — Score the current description

For each eval query, ask: "Given ONLY the description field, would Claude
pick this skill?"

```
Current description: "<current>"

Should-trigger (target: 10/10):
  ✓ Query 1 — would trigger (keyword match + context)
  ✗ Query 4 — would NOT trigger (missing "contract" keyword)
  ✗ Query 7 — would NOT trigger (casual phrasing not covered)
  Score: 7/10

Should-not-trigger (target: 10/10):
  ✓ Query 2 — correctly ignored
  ✗ Query 5 — would FALSE POSITIVE (shares "PDF" keyword)
  Score: 8/10

Overall: 15/20 (75%)
```

## Step 4 — Rewrite the description

Apply the optimization rules:

1. **Structure:** `[WHAT it does]. [Secondary capabilities]. Use when [triggers].`
2. **3rd person only** — "Processes..." not "I process..."
3. **Be pushy** — "Make sure to use this skill whenever..."
4. **Include 5+ trigger keywords** from the should-trigger queries that failed
5. **Add boundary keywords** to prevent false positives from should-not-trigger failures
6. **Under 1024 chars**

### Template:

```yaml
description: >-
  [Primary capability]. [Secondary capability]. [Third if needed].
  Use when user asks to [action1], [action2], or mentions
  "[keyword1]", "[keyword2]", "[keyword3]". Also use when
  [context trigger]. Do not use for [boundary — prevents false positive].
```

## Step 5 — Re-score and iterate

Score the new description against the same 20 queries. Target: 18/20 (90%).

If <90%:
- Identify which queries still fail
- Add their keywords/context to the description
- Check you haven't exceeded 1024 chars
- Re-score

Iterate max 3 times. If still <90% after 3 iterations, the skill may
need body changes (examples, boundaries) not just description fixes.

## Step 6 — Present before/after as a decision brief

Apply the format from
[../skill-reviewer/references/decision-brief-format.md](../skill-reviewer/references/decision-brief-format.md).
A description rewrite that changes which prompts trigger the skill is
not a cosmetic edit — the user owns the trigger surface, so show them
what they're trading.

```
D1 — Apply description rewrite for meta/pdf-extractor?
Project/branch/task: optimizing the PDF skill's trigger surface.
ELI10: Right now the description is so vague that Claude only picks this
skill ~75% of the time when you actually want it. The rewrite below pulls
in the specific words real users say ("contract", ".pdf", "extract data")
and adds a guard against firing on requests to GENERATE pdfs, which is a
different job. Activation goes from 15/20 to 19/20 in mental eval.
Stakes if we pick wrong: keep the vague one and Claude keeps asking
clarifying questions instead of running the skill; apply the new one
and one more should-not-trigger case (#5) might false-positive on the
boundary phrasing.
Recommendation: A — apply the rewrite. The +4 should-trigger wins
outweigh the one boundary risk.
Completeness: A=9/10, B=5/10 (current keeps the gap)
A) Apply the rewrite (recommended)
  ✅ Activation jumps 75% → 95% on the 20-query eval
  ✅ Adds the explicit "Do not use for X" boundary
  ❌ One should-not-trigger query (#5) is now borderline
B) Keep the current description
  ✅ Zero risk of new false positives
  ❌ Skill keeps under-triggering on the casual "pull data from this PDF"
  ❌ User keeps having to repeat themselves to get the skill to fire
Net: The rewrite trades a marginal false-positive risk for a meaningful
activation gain. Apply unless we have evidence query #5's domain matters.

Before:
"Helps process PDF documents"

After:
"Extract text, tables, and form data from PDF files. Fill PDF forms
 and merge multiple PDFs. Use when user asks to read a PDF, extract
 data from documents, fill out forms, or mentions .pdf files,
 contracts, invoices, or scanned documents. Do not use for generating
 PDFs from scratch (use document-generation instead)."
```

## Rules

- Never exceed 1024 chars — hard limit
- Always write in 3rd person
- Always include both WHAT and WHEN
- Include at least 5 trigger keywords from real user language
- Add one boundary ("Do not use for X") to prevent the top false-positive
- Don't use XML tags in descriptions
- Don't use reserved words "anthropic" or "claude" in skill names
- Test against casual/typo-laden queries — real users don't write formally
