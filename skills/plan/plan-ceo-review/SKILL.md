---
name: plan-ceo-review
description: |
  CEO/founder-tier scope review of a feature plan. Four modes — Expansion,
  Selective Expansion, Hold Scope, Reduction — and a 10-section challenge
  walking through demand, scope, simplest version, and metric. Reads the
  design doc from /office-hours; writes back recommended scope changes.
  Use when the user says "ceo review", "scope review", "is this the right
  scope", or before committing to build a feature.
allowed-tools: [Read, Write, Edit, Grep, Glob, AskUserQuestion]
triggers:
  - ceo review
  - scope review
  - plan review
  - is this the right scope
  - rethink the plan
---

# /plan-ceo-review — scope challenge before code

Read the design doc (typically `.cue/design-docs/<latest>.md`) and apply
a four-mode framework to challenge the scope. The job is **not** to
rubber-stamp — it's to find the 10-star product hiding inside the
request, or the unnecessary 80% that can be cut.

## The four modes

Pick one. Stating the mode out loud forces a clear recommendation.

| Mode | When to use | What it does |
|---|---|---|
| **Expansion** | Demand is real; the plan is too small | Adds capabilities the user underspecified — same product, bigger reach |
| **Selective Expansion** | Some parts are too small, others fine | Expands one specific dimension, holds the rest |
| **Hold Scope** | The plan is right-sized | Confirm and move on. This is a legit outcome. |
| **Reduction** | The plan is bloated for the actual demand | Cuts the 80% that doesn't matter for the wedge |

## The 10-section challenge

Walk through these in order. For each, state what you found in one
sentence. If nothing's wrong, say so and move on.

1. **Demand reality** — does the design doc cite a real user, or is it
   self-generated? Self-generated isn't fatal, but the scope should be
   smaller until validated.
2. **Status quo** — what does the doc say users do today? If "nothing,"
   the urgency may be weak.
3. **Wedge clarity** — does the doc name a single sentence wedge? If
   it's three sentences, force a pick.
4. **Scope/effort match** — does the proposed effort match the demand
   evidence? 3-month projects for one user request is a Reduction
   signal.
5. **Success metric** — is there one number? Vague metrics ("user
   satisfaction") drift; concrete metrics ("daily active in week 2 >
   30%") don't.
6. **Hidden product** — is the user describing a tool but actually
   building a platform? Surface it.
7. **Competition** — has the doc said how the result is different from
   what already exists? If "we'll just be better," that's not a
   strategy.
8. **Risk** — what's the single biggest reason this fails? Should be
   one paragraph, not a list of 12.
9. **Future-fit** — if this works for 10× users, what breaks first?
10. **Ship date** — does the plan have one? If not, force a pick.

## Output format

After the 10 sections, write one paragraph titled **Recommendation** in
the design doc:

```markdown
## CEO review — <YYYY-MM-DD>

**Mode**: <Expansion | Selective Expansion | Hold Scope | Reduction>

**Findings** (one line each, only flag what's actually off):
1. <…>
…
10. <…>

**Recommendation**:
<one paragraph>

**Concrete scope edits**:
- <change to the wedge>
- <add/remove from "in" or "out">
- <new open question for /plan-eng-review>
```

Save this as a new section at the bottom of the design doc — don't
rewrite the doc.

## Style

- Be direct. "This is too big" beats "you might consider whether the
  scope is right-sized."
- One mode, one recommendation. Don't hedge.
- It's OK to say "Hold Scope — the plan is right-sized as written."
  That's a real outcome, not a cop-out.

## After this skill

Tell the user: "Next: `/plan-eng-review` to lock architecture, then exit
plan mode and build."
