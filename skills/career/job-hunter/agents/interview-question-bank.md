# Interview Question Bank

## What This Does

Generates 15 smart questions to ask at the end of an interview — questions
that signal genuine research, not the ones everyone asks.

The questions you ask in an interview are as important as how you answer.
"Do you have any questions for me?" is not small talk. It's the last
impression you make. Generic questions ("What does success look like?")
signal you didn't do your homework. Specific, researched questions signal
you're already thinking like someone who works there.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/job-description.md`.
Read `inputs/interview-context.md` if it exists — use interviewer role/title.
Read `outputs/interview-prep.md` if it exists.
Read `outputs/company-research.md` if it exists.
Read `rules/writing-rules.md`.

Extract:
- Company name
- Role title and department
- Interviewer title(s) if known
- Any specific signals from company research

### Step 2 — Generate 15 questions across 5 categories

Write 3 questions per category. Each question should:
- Be specific to this company and role (not generic)
- Invite a real answer, not a yes/no
- Signal that you've done real research
- Surface information you actually need to make a decision

---

**CATEGORY 1 — The Role Itself**
Questions about what this role actually does day-to-day and what success looks like.

*Good:* "The JD mentions ownership of the enterprise segment — what does that territory look like today and what's the biggest obstacle to growing it?"
*Bad:* "What does a typical day look like?"

3 questions that get at: real scope, real metrics, real challenges.

---

**CATEGORY 2 — The Team and Manager**
Questions about who you'd work with and how.

*Good:* "This role seems to sit between product and revenue — how do those two functions collaborate here, and where do they usually create friction?"
*Bad:* "How would you describe the team culture?"

3 questions that get at: team dynamics, how decisions get made, management style signals.

---

**CATEGORY 3 — The Company Direction**
Questions about where the company is going and how this role fits.

*Good:* "You announced the Series C six months ago — how has that changed what this team is focused on in the next 12 months?"
*Bad:* "Where do you see the company in 5 years?"

3 questions that get at: strategic priorities, what's actually changing, where investment is going.

---

**CATEGORY 4 — The Hire**
Questions that get at why this role is open and what they really need.

*Good:* "Is this a backfill or a new seat on the team? If it's a backfill, what happened to the person who had it?"
*Good:* "If the person who takes this role knocks it out of the park in year one, what did they do?"
*Bad:* "What are you looking for in an ideal candidate?"

3 questions that get at: why it's open, what they've tried, what failure looks like.

---

**CATEGORY 5 — The Honest Questions**
Questions you genuinely need answered before you'd accept this role.

These are the questions based on whatever showed up as Neutral or Concerning
in the company research. Ask the hard ones here — diplomatically.

*Example if there's been leadership turnover:* "I noticed a few exec departures in the last year on LinkedIn — how has that affected the team's direction?"
*Example if Glassdoor shows management concerns:* "What's the best way to give direct feedback up the chain here?"

3 questions based on what actually needs to be verified.

---

### Step 3 — Prioritize

Tell the user which 5 to actually ask (you'll never get through all 15):

**ASK THESE FIRST:**
[5 questions ranked by impact — the ones that will get the most revealing answers
and leave the best impression]

**SAVE THESE IF TIME:**
[3 backup questions]

**SKIP UNLESS IT COMES UP:**
[Anything you'd only ask if the conversation goes there organically]

### Step 4 — Listening guidance

For each of the top 5 questions, add one line:

*Watch for: [what a good answer looks like vs. a concerning one]*

### Step 5 — Save output

Write to `outputs/question-bank.md`.

Tell the user:
> Question bank ready. outputs/question-bank.md
>
> Don't read from a list. Know your top 5 cold.
> The best questions come from listening to what they say in the interview
> and asking the follow-up that shows you were actually paying attention.

## ✅ What to do next

```
npm run mock           ← practice the full interview including your questions
npm run research       ← pull the company brief to inform better questions
npm run debrief        ← capture what happened right after the interview
```

Apply all rules from `rules/writing-rules.md`.
