# Interview Debrief

## What This Does

Captures what just happened in your interview before the memory fades —
what they asked, how you answered, what landed and what didn't, what to
do differently next round.

Most candidates walk out of interviews and don't process them. The ones
who improve fast are the ones who debrief every single one. This agent
runs the debrief while it's still fresh.

Run this within 30 minutes of leaving the interview.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md`.
Read `outputs/interview-prep.md` if it exists — compare what you prepared
against what actually came up.
Read `rules/writing-rules.md`.

### Step 2 — Capture what happened

Ask the user these questions one at a time. Wait for each answer before
asking the next. Don't rush.

```
1. How long was the interview and who was in the room?
   (title/role of each interviewer, not necessarily their names)

2. Walk me through the questions they asked — in order if you can remember.
   Don't edit yourself. Just list them.

3. Which question caught you off guard?

4. Which answer felt strongest?

5. Which answer felt weakest or incomplete?

6. Did they seem most interested in any particular part of your background?

7. Were there any awkward moments, long pauses, or places where
   the energy shifted?

8. What did they say about next steps and timeline?

9. Overall gut feel: is this a role you want? Does this company feel right?
```

### Step 3 — Grade the performance

Based on what they shared, assess the interview honestly:

**OVERALL: A / B / C / D**

One paragraph honest assessment. What did this interview actually accomplish?

**WHAT LANDED**
2-4 specific things from the conversation that played well.

**WHAT MISSED**
2-4 specific things that could have been stronger.
For each: what the better answer would have been.

**THE QUESTION THAT MATTERED MOST**
One question from the interview that likely carries the most weight in the
decision. Why it matters. Whether the answer was strong enough.

**RED FLAGS TO MONITOR**
Anything in the conversation that should make the candidate think harder
about whether they want this role — culture signals, vague answers about
growth, anything that felt off.

### Step 4 — Build next-round prep

If there's a next round:

**IF CALLED BACK — PREPARE FOR:**
- The follow-up on your weakest answer (they'll probe it)
- A deeper dive on the most-interested topic
- Any open question you left unresolved
- Likely addition of a new interviewer (different perspective coming)

### Step 5 — Update the pipeline

Tell the user:
```
Based on this debrief:

WHAT TO DO IN THE NEXT 24 HOURS:
1. Send a thank-you that addresses [specific thing from debrief]
2. [Specific prep for next round if applicable]
3. [Any follow-up you promised in the interview]
```

### Step 6 — Save output

Write to `outputs/interview-debrief.md`.

Tell the user:
> Debrief complete. outputs/interview-debrief.md
>
> The most important thing right now:
> [Single most important follow-up action]

## ✅ What to do next

```
npm run send-thankyou  ← send your thank-you note within 24 hours
npm run follow-up      ← if you haven't heard back in 5 days
npm run interview      ← if called back, use this debrief to prep harder
```

Apply all rules from `rules/writing-rules.md`.
