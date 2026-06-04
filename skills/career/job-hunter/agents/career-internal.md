# Internal Job Application

## What This Does

Applies for an internal role differently than an external one. You know people,
you have context, you have a reputation — and you have more to lose if it goes
sideways. This agent accounts for all of that.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md` for the internal role.
Read `rules/writing-rules.md`.

### Step 2 — Gather internal context

Ask:
> A few things I need to know about the internal situation:
> 1. Does your current manager know you're applying?
> 2. Do you have a relationship with the hiring manager for this role?
> 3. Who else might be applying internally?
> 4. What's the general perception of you in the company — strong performer, under the radar, known for specific things?
> 5. Why are you moving — growth, better fit, comp, or getting out of a bad situation? (be honest, this affects strategy)
> 6. What would your current manager say about you if the hiring manager asked?

### Step 3 — Strategy assessment

Based on their answers, assess:

**Visibility advantage** — what does this person's internal reputation add to
their application that an external candidate can't match?

**Political considerations** — is there anything that needs to be handled before
or during the application? (informing current manager, managing relationships)

**The real pitch** — internal applications should reference institutional knowledge,
existing relationships, and demonstrated cultural fit. External candidates can't do this.

### Step 4 — Internal resume tailoring

Tailor the resume for this role with internal framing:
- Lead experience bullets with company-specific impact where possible
- Reference internal initiatives, products, or teams by name where relevant
- Quantify with internal metrics the hiring manager will recognize

### Step 5 — Internal cover letter

Write an internal cover letter (shorter than external — 150-200 words):
- Opens differently than an external letter — no need to introduce yourself
- References the internal context: "Having spent [X] years building [thing] here..."
- Names something specific about why this role is the right next move internally
- Does not apologize for applying or over-explain the move
- Ends with confidence — you know this company, you know what you're getting into

### Step 6 — The conversation to have first

Before submitting: who should the user talk to before the application goes in?

Write a short script for:
1. The conversation with their current manager (if not already had)
2. A conversation with the hiring manager if they have a relationship
   ("I wanted to let you know I'm planning to apply for the [role]...")

These conversations, done right, are often more important than the application itself.

### Step 7 — What's different about the interview

Flag 3 things that are different about an internal interview:
- They already know your reputation — the interview validates it or contradicts it
- You can reference internal context that external candidates can't
- The stakes are higher if you don't get it — have a plan for that scenario

### Step 8 — If you don't get it

Write 2-3 sentences on how to handle not getting the role with your reputation intact:
What to say to the hiring manager, what to say to your current manager, and
how to use the feedback constructively.

### Step 9 — Save output

Write to `outputs/internal-application.md`.

---

## ✅ What to do next

Have the conversation with your current manager before submitting — if you haven't already.
Then submit. Then prepare as you would for any interview:
```
npm run research      ← pull context on the team and hiring manager
npm run interview     ← build your prep guide
```
