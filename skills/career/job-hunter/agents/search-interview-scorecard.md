# Your Interview Scorecard

## What This Does

Builds your personal scorecard for evaluating a company — the specific
things that would make you say no to this role, before you get swept up
in the excitement of being wanted.

Candidates spend all their energy trying to impress. The companies that
are worth your time are also trying to impress you. This agent builds
the criteria you'll use to evaluate them, so when the offer comes you're
deciding with your head, not your relief.

Run this before the first interview. Use it to evaluate throughout the process.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md`.
Read `outputs/company-research.md` if it exists.
Read `outputs/salary-research.md` if it exists.
Read `rules/writing-rules.md`.

Ask the user:
```
A few questions to build your scorecard:

1. Why are you looking? (leaving something specific, or seeking something specific)
2. What went wrong in your last role? (this is often what you need to avoid repeating)
3. What's non-negotiable for you right now?
   (comp floor, remote/hybrid, manager quality, growth path, culture, stability, industry)
4. What have you compromised on before that you regret?
5. What does "this was the right move" look like in 2 years?
```

Wait for their answers.

### Step 2 — Build the scorecard

Create a personal evaluation scorecard with 6-8 criteria specific to this person.

For each criterion:

**[CRITERION NAME]**
Why it matters to you: [from their answers — make it personal]
What good looks like: [specific, not vague]
What bad looks like: [specific signals to watch for]
How to verify it: [the question to ask, the person to ask it to, the signal to watch for]
Current signal from what I know: [based on JD and company research if available]
Weight: Critical / Important / Nice-to-have

---

Common criteria to consider (adapt to their specific situation):

**Compensation**
Not just base — total comp, bonus structure, equity, benefits, trajectory.
Question: "Can you walk me through the comp structure and how it progresses?"

**Manager Quality**
Your direct manager determines 80% of your day-to-day experience.
Question: "How would you describe your management style? What do your direct reports say about working with you?"
Signal: Do they ask you questions? Do they talk about their team's success or their own?

**Growth Path**
Is there a real path from this role or is it a terminal position?
Question: "Where have people who held this role previously gone within the company?"
Signal: Can they name 2-3 people?

**Team Stability**
Constant churn destroys productivity and signals dysfunction.
Question: "How long has the current team been together? Has there been significant turnover recently?"
Signal: How they answer, not just what they say.

**Real Autonomy**
The difference between "you'll own this" in the JD and what it actually means.
Question: "Walk me through how a decision gets made in this role. When do I need approval?"
Signal: Specificity of their answer.

**Culture Honesty**
Every company says "great culture." What they mean varies.
Question: "What's something about working here that surprised you — good or bad?"
Signal: Are they willing to name something real?

**Financial Stability**
Is this company going to be here in 2 years?
From company research — funding runway, revenue signals, layoff history.

**Work-Life Sustainability**
Realistic expectations for hours, availability, urgency culture.
Question: "What does a typical week look like for someone in this role?"
Signal: "We work hard but we play hard" = red flag.

### Step 3 — The go/no-go framework

Write a clear decision guide:

```
YOUR GO / NO-GO FRAMEWORK

MUST HAVE (any of these missing = decline):
[List their critical criteria]

STRONG PREFERENCE (2+ missing = serious concern):
[List their important criteria]

NICE TO HAVE (factor in but not deciding):
[List their lower-weight criteria]

THE ONE QUESTION THAT DECIDES IT:
[Based on their specific situation — the single question they need answered]
```

### Step 4 — Evaluation tracker

Create a scorecard table to fill in after each round:

```
EVALUATION TRACKER

Criterion          | Weight    | What I learned | Score (1-5) | Questions remaining
─────────────────────────────────────────────────────────────────────────────────────
[criterion 1]      | Critical  |                |             |
[criterion 2]      | Critical  |                |             |
[criterion 3]      | Important |                |             |
...
─────────────────────────────────────────────────────────────────────────────────────
OVERALL:                                        |             |
```

### Step 5 — The reality check note

End with this:

```
A NOTE ON THE OFFER HIGH

When an offer comes — if it comes — you will feel relieved. That relief
will make everything look better than it is. That's normal. That's human.

Before you say yes, fill in the scorecard completely.
The criteria you set before you knew you had the offer
are more reliable than the judgment you'll have after.

If 2 of your Critical criteria are unfilled or concerning —
that's information. Take 24 hours before deciding.
```

### Step 6 — Save output

Write to `outputs/interview-scorecard.md`.

## ✅ What to do next

```
npm run panel-decode   ← understand who you're evaluating and who's evaluating you
npm run questions      ← build your question bank to fill in your scorecard
npm run debrief        ← update your scorecard after each round
npm run compare        ← compare this offer against others using your criteria
```

Apply all rules from `rules/writing-rules.md`.
