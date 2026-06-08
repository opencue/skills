# Assessment Prep

## What This Does

Prepares you for the specific type of assessment standing between you
and the interview — HireVue, take-home projects, case studies, technical
screens, personality assessments, skills tests.

Companies use assessments to filter candidates before investing recruiter
time. Most candidates treat them as afterthoughts. The ones who do the
work to understand what's actually being tested pass at dramatically
higher rates.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md`.
Read `rules/writing-rules.md`.

Ask the user:
```
What type of assessment are you facing?

1. HireVue / video interview (AI-analyzed responses)
2. Take-home project or assignment
3. Case study / business case
4. Technical screen (coding, SQL, data, etc.)
5. Psychometric / personality assessment
6. Skills test (writing sample, Excel, etc.)
7. Presentation to the team
8. Not sure — here's what they told me: [let them describe]
```

Wait for their answer. Then ask:
```
What did they tell you about it?
How long do you have?
What's the role / company?
```

### Step 2 — Assess-specific prep

---

**IF: HireVue / AI Video Interview**

What's actually being measured:
- Word choice and vocabulary (lexical diversity)
- Speaking pace and clarity
- Eye contact with camera (not screen)
- Facial expression consistency
- Response structure (they score whether you answer the actual question)

What most candidates get wrong:
- Looking at their own video instead of the camera
- Taking too long to start (hesitation is scored negatively)
- Meandering answers without a clear structure
- Ambient noise or poor lighting that triggers lower AI scores

Prep:
1. Answer format: Situation (10%) → Action (60%) → Result (30%). Every answer.
2. Practice specific to the questions they're likely to ask (from JD)
3. Camera setup: eye level, good light, minimal background noise
4. First 3 seconds: look at camera, state your answer directly, then support it

Write 5 practice questions specific to this role. For each, write a
model answer in the correct structure.

---

**IF: Take-Home Project**

What's actually being measured:
- Quality of thinking, not just output
- Ability to scope and constrain
- How you communicate tradeoffs
- Whether you followed the instructions exactly

What most candidates get wrong:
- Over-engineering: 3 hours of work is usually enough, not 20
- Not explaining decisions: show your thinking, not just your answer
- Ignoring constraints: if they say 2 pages, 2 pages
- Not asking clarifying questions upfront (if allowed)

Prep:
Based on the role and the assignment described:
1. Clarifying questions to ask before starting (if allowed)
2. Suggested scope: what to include, what to consciously exclude
3. Structure for the deliverable
4. What to write as a cover note explaining your approach

---

**IF: Case Study / Business Case**

What's actually being measured:
- Structured thinking under pressure
- Ability to make a recommendation with incomplete information
- How you handle pushback
- Communication clarity

The MECE framework still dominates. Use it.

Prep:
1. The specific framework to use for this type of case
2. Common traps in this type of case (over-analyzing, refusing to commit)
3. How to handle "what if your data was wrong?"
4. The 60-second summary structure to use at the end
5. 2-3 practice cases specific to this industry/function

---

**IF: Technical Screen**

What's actually being measured:
- Problem decomposition
- How you handle being stuck
- Communication while working
- Verification behavior (do you test your own work?)

What most candidates get wrong:
- Going silent while thinking (narrate everything)
- Not asking clarifying questions before starting
- Getting stuck and freezing instead of thinking out loud
- Not checking edge cases

Based on the role, write:
1. The specific topics most likely to be tested
2. The most common questions for this role type
3. How to handle the question you don't know
4. What to say and do when you're stuck

---

**IF: Psychometric / Personality Assessment**

What's actually being measured (honestly):
- Role fit based on their internal models
- Consistency (if you contradict yourself across similar questions, you fail)
- Extremity checking (most assessments flag "always" and "never" responses)

What to know:
- There are no universally right answers — they're normed to the role
- Read the JD before taking it: answer as the person who would thrive in this role
- Be consistent — same question asked two ways should get the same answer
- Avoid extreme responses unless they're genuinely true

Prep:
1. The likely dimensions being tested for this role type
2. Which direction to lean on ambiguous questions (based on JD language)
3. Common trap questions where inconsistency is easy

---

**IF: Skills Test / Writing Sample**

For writing: apply `rules/writing-rules.md` in full
For Excel/data: specific functions and approaches for the likely task
For other: describe the task, get specific prep

---

### Step 3 — The Calibration Note

End every assessment prep with:

```
THE RIGHT AMOUNT OF EFFORT

More time does not mean better output.
Most take-homes: 3-4 hours is the signal. 20 hours is noise.
Most case studies: clear thinking in 30 minutes beats exhaustive in 90.
Most technical screens: communicating clearly > perfect code.

The assessment is testing whether you can do the job,
not whether you can prove you want it by working yourself to exhaustion.

Put in the right amount. Then stop.
```

### Step 4 — Save output

Write to `outputs/assessment-prep.md`.

## ✅ What to do next

```
npm run mock           ← practice for the follow-up interview after the assessment
npm run panel-decode   ← understand who evaluates your assessment and what they weight
npm run research       ← understand the company context before a case study
```

Apply all rules from `rules/writing-rules.md`.
