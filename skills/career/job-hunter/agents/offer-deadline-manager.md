# Offer Deadline Manager

## What This Does

Builds a playbook for the specific situation where you have an offer
expiring and you're waiting on another company.

This is one of the highest-stakes moments in a job search and most people
handle it badly — they either accept the first offer out of fear or blow
up the second opportunity by being too aggressive. This agent tells you
exactly what to say, when to say it, and what each company is actually
thinking.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `outputs/salary-research.md` if it exists.
Read `rules/writing-rules.md`.

Ask the user:

```
Tell me your situation:

1. What is Offer A? (company, role, comp, deadline)
2. What is Company B? (company, role, stage you're at — final round, offer pending, etc.)
3. How long until Offer A expires?
4. How far along is Company B? (days until decision, or unknown)
5. Which do you actually prefer? (be honest — it changes the strategy)
6. Have you told either company about the other?
```

Wait for their full answer.

### Step 2 — Assess the situation honestly

Before any recommendations, state clearly:

**THE REALITY**
- How much time pressure actually exists
- What each company is likely thinking right now
- What the realistic outcome is in each scenario
- Whether this is a real competition or perceived pressure

**YOUR LEVERAGE**
Rate it: Strong / Moderate / Weak — and explain why.
- Strong: Company B is actively interested, offer expected soon
- Moderate: Company B is moving but timeline uncertain
- Weak: Company B is early stage or you haven't heard back recently

### Step 3 — Build the playbook

**MOVE 1 — Ask Company A for an extension**

When: Immediately, within 24 hours of knowing you need it.
How much to ask for: 5-7 business days is reasonable. 2 weeks is a stretch.
The framing: You are not stalling. You are being responsible.

Write the exact email:

---
Subject: Re: [Role] Offer — Extension Request

[Opener that acknowledges the offer warmly without being over the top]

I'm genuinely excited about this opportunity and want to make a thoughtful
decision. I have a few final items I'm working through — [optional: briefly
name one legitimate item, e.g. outstanding questions from legal review,
relocation logistics] — and I'd appreciate [X] additional business days to
confirm.

I want to start this relationship on solid footing. Would that be possible?

[Name]
---

**MOVE 2 — Accelerate Company B**

When: Same day you request the extension from A.
What to say: Be honest that you have an offer and a decision date.
What NOT to say: Don't name Company A. Don't exaggerate the timeline.

Write the exact message:

---
[To: Company B recruiter or hiring manager]

I wanted to be transparent with you: I've received an offer from another
company with a decision deadline of [date]. [Role] at [Company B] is my
first choice, and I'd rather make this decision with full information
than under artificial time pressure.

Is there any way to expedite the timeline on your end, or can you give
me a sense of where things stand?

[Name]
---

**MOVE 3 — If Company B can't move fast enough**

Decision framework:
- If Offer A is strong and Company B is uncertain: take A
- If Company B is your clear preference and timeline is close: ask A for one more extension
- If you're genuinely torn: use the compare tool

Write the decline email for whichever offer you don't take — keep the
door open.

**MOVE 4 — If Company A won't extend**

You have a hard choice. Map it:
- What happens if you accept A and Company B comes through later? (you'd have to renege — assess that risk)
- What happens if you decline A and Company B falls through? (you're back to searching)
- Is there a third path? (ask A if you can start earlier to demonstrate commitment)

### Step 4 — Timeline map

Draw the exact timeline:

```
TODAY          OFFER A DEADLINE    TARGET DECISION
  |__________________|___________________|
  ↑                  ↑                   ↑
  Request extension  If no extension:    Full information
  Accelerate B       decide here         decision
```

### Step 5 — Save output

Write to `outputs/deadline-manager.md`.

Tell the user:
> Playbook ready. outputs/deadline-manager.md
>
> Move 1 first — ask for the extension today.
> Move 2 the same day — don't wait to see if A grants it.

## ✅ What to do next

```
npm run counter        ← if you're negotiating the offer terms too
npm run compare        ← full side-by-side comparison of both offers
npm run negotiate      ← practice the offer conversation
```

Apply all rules from `rules/writing-rules.md`.
