---
name: office-hours
description: |
  Premise-questioning before code. Six forcing questions that reframe a product
  idea, expose hidden demand assumptions, and find the narrowest wedge to ship.
  Writes a design doc the user can hand to /plan-ceo-review or /plan-eng-review.
  Use when the user says "brainstorm this", "I have an idea", "help me think
  through", "office hours", "is this worth building", or describes a product
  idea before any code exists.
allowed-tools: [Bash, Read, Grep, Glob, Write, Edit, AskUserQuestion, WebSearch]
triggers:
  - brainstorm this
  - is this worth building
  - help me think through
  - office hours
  - I have an idea
---

# /office-hours — premise-questioning before code

Adapted from YC Office Hours methodology. Two modes:

- **Startup mode** (default): six forcing questions for product/business ideas
- **Builder mode**: design-thinking for side projects, hackathons, learning, OSS

The job is to **push back on the framing** before code is written. The user
said "daily briefing app." What they described is a personal chief-of-staff
AI. The model's job is to surface that mismatch.

## Iron rules

1. **Do not skip to implementation.** No code, no architecture, no `cd` into
   the repo. The output of `/office-hours` is a markdown design doc, full
   stop.
2. **One question at a time** via `AskUserQuestion`. Six questions max. The
   user can answer "skip" to any of them.
3. **Specifics, not hypotheticals.** Push for concrete examples: "Tell me the
   last time this happened. What did you do? How long did it take?"
4. **Generate alternatives.** End with 3 implementation approaches at
   different scope levels, not just one.

## Step 0 — detect mode

Ask which mode applies:

- **Startup**: real users, real demand, you'd ship this to strangers
- **Builder**: hackathon, learning project, OSS tool, side weekend thing

The questions are similar; tone shifts (startup is harsher on demand).

## Step 1 — the six questions

Ask one at a time, in order. Skip any the user already answered upstream.

### Q1. Demand reality
> "Who specifically asked for this? Name the person or paste the message.
> If nobody asked — what makes you sure the demand is real?"

If the answer is hypothetical ("I think people would want X"), push back:
"That's a guess. What's the smallest version you could ship to find out
if you're right?"

### Q2. Status quo
> "What do they do today, without you? Walk me through the workaround
> step by step."

If there is no workaround, demand may be weak. If the workaround is
"nothing — they just live with it," the pain may not be real.

### Q3. Desperate specificity
> "Tell me the last specific incident. When, what triggered it, what did
> the user do, how long did it take, how much did it cost?"

Generic answers ("it's slow", "people complain") are not specific enough.
Push until you have one concrete story.

### Q4. Narrowest wedge
> "What is the smallest thing you could ship tomorrow that would prove or
> disprove this is worth building?"

Force a single sentence. If the wedge is more than one sentence, it's
too big.

### Q5. Observation
> "Once it's shipped, how do you know it's working? What's the one number
> you'd check?"

If there's no number, success is undefined — and the project will drift.

### Q6. Future-fit
> "If this works for 100 users, what breaks? Is the next thing on the
> roadmap actually the same product, or a different product wearing the
> same name?"

Catch the "and-then-it-becomes-a-platform" hand-wave.

## Step 2 — reframe back to the user

After Q6, summarize what you heard. Then **state the mismatch** if there
is one:

> "You said you're building X. From your answers, what you're actually
> building is Y. Here's why I think that..."

Three possible outcomes:

1. **User agrees** — the reframe is the new working spec.
2. **User disagrees** — they explain why X is right; you update your model.
3. **User adjusts** — they pick something between X and Y.

## Step 3 — generate three implementation alternatives

After the reframe, write three approaches at different scopes:

| Scope | Effort | What ships |
|---|---|---|
| Narrowest wedge | 1–3 days | Smallest thing that tests the premise |
| Useful product | 1–2 weeks | What a focused user would actually use |
| Full vision | 1–3 months | The thing the user originally described |

For each: one sentence on what's in, one sentence on what's out, one
sentence on the risk.

## Step 4 — write the design doc

Save to `.cue/design-docs/<slug>-<YYYYMMDD>.md`. Format:

```markdown
# <product name> — office-hours design doc
*Generated <date> by /office-hours.*

## What the user said they wanted
<one paragraph, in the user's words>

## What they actually described
<one paragraph, reframed>

## Demand evidence
- Who asked: <name or "self-generated">
- Last concrete incident: <story>
- Status quo workaround: <one sentence>

## Success metric
<one number to watch>

## Three approaches
### Narrowest wedge
- In: <one sentence>
- Out: <one sentence>
- Risk: <one sentence>

### Useful product
...

### Full vision
...

## Recommendation
<one paragraph: pick a scope and say why>

## Open questions
<list any premises the user couldn't answer — these become followups>
```

## Step 5 — hand off

After writing the doc, tell the user:

> "Design doc saved to `.cue/design-docs/<slug>-<date>.md`. Next steps:
>  - `/plan-ceo-review` to challenge scope
>  - `/plan-eng-review` to lock architecture
>  - `/autoplan` to run both"

Stop there. Do not start coding.

## Anti-patterns

- ❌ Skipping to "let me sketch the architecture"
- ❌ Asking all six questions in one giant `AskUserQuestion`
- ❌ Generating one approach instead of three
- ❌ Burying the reframe in a wall of text instead of stating it cleanly
- ❌ Writing the design doc without the user's answers (don't make them up)
