# Company Deep Research

## What This Does

Goes deeper than the pre-interview brief. This is what you run before you
decide whether to seriously pursue an opportunity — before investing hours
on applications and prep.

The pre-interview research (`npm run research`) is a one-pager for the
morning of the interview. This is the due diligence you do when you're
deciding whether the company is worth your time.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/job-description.md`.
Read `inputs/my-resume.md` for context on what matters to this person.
Read `rules/writing-rules.md`.

Extract the company name and role title.

### Step 2 — Research the company across 6 dimensions

For each dimension, give a rating (Strong / Neutral / Concerning) and 
specific evidence. No vague assessments — every rating needs a reason.

---

**DIMENSION 1 — Financial Health**

For public companies:
- Revenue trend (growing, flat, declining)
- Profitability and cash position
- Recent earnings calls — what are they prioritizing?
- Stock performance trend vs. sector

For private companies:
- Last funding round, amount, lead investor, date
- Runway estimate (when did they last raise and how much?)
- Revenue signals from job posting density and LinkedIn headcount trend
- Any recent layoffs or hiring freezes

Rating: Strong / Neutral / Concerning
Evidence: [specific numbers or signals]

---

**DIMENSION 2 — Hiring Velocity**

Look at LinkedIn headcount trend:
- Is the team growing, flat, or shrinking?
- Is this department specifically growing?
- How long has this specific role been posted? (stale = red flag)
- Are there multiple similar roles posted? (high churn = red flag)
- Any recent layoffs mentioned in news or Glassdoor?

Rating: Strong / Neutral / Concerning
Evidence: [headcount numbers, posting age, role count]

---

**DIMENSION 3 — Leadership Stability**

- CEO and executive team tenure
- Recent C-suite departures (look for exits in last 12 months)
- How long has the direct manager been in role?
- Glassdoor reviews mentioning leadership specifically

Rating: Strong / Neutral / Concerning
Evidence: [specific names, tenures, patterns]

---

**DIMENSION 4 — Culture and Environment**

Based on Glassdoor, LinkedIn, and news:
- Glassdoor overall score and trend (improving or declining?)
- Top themes in positive reviews (what do people actually like)
- Top themes in negative reviews (what keeps coming up)
- Work-from-home or hybrid policy signals from job postings
- Patterns in how long people stay in this type of role

Rating: Strong / Neutral / Concerning
Evidence: [Glassdoor score, specific review patterns]

---

**DIMENSION 5 — Competitive Position**

- Who are the top 3 competitors?
- Where does this company sit in its market?
- Any recent news: acquisitions, product launches, losses to competitors?
- Is the market they're in growing, stable, or contracting?

Rating: Strong / Neutral / Concerning
Evidence: [specific competitive signals]

---

**DIMENSION 6 — Role-Specific Signals**

- Is this a backfill or a new role? (new = growth, backfill = need to understand why)
- How does this role interact with the rest of the org?
- What does success look like in year 1 based on the JD language?
- Any concerning language: "fast-paced", "wear many hats", "self-starter" — what does it mean here?

Rating: Strong / Neutral / Concerning
Evidence: [JD language analysis]

---

### Step 3 — Overall Assessment

**PURSUE / PROCEED WITH EYES OPEN / DEPRIORITIZE**

Scoring:
- 5-6 Strong: PURSUE
- 3-4 Strong, some Neutral: PROCEED WITH EYES OPEN
- Any Concerning + pattern: DEPRIORITIZE unless role is exceptional

**THE THREE THINGS TO ASK IN THE INTERVIEW**
Based on the research, list the 3 most important things to verify directly
with the hiring manager. These should address whatever is Neutral or Concerning.

**NEGOTIATION CONTEXT**
Based on the financial and hiring signals, how strong is your leverage?
Is this a company in growth mode (you have leverage) or tightening mode (be careful)?

### Step 4 — Save output

Write to `outputs/company-research.md`.

Tell the user:
> Company research complete: [PURSUE / PROCEED WITH EYES OPEN / DEPRIORITIZE]
> Full report: outputs/company-research.md

## ✅ What to do next

```
npm run fit            ← score your fit for the specific role
npm run research       ← quick interview brief once you've decided to pursue
npm run decode         ← decode the JD before applying
```

Apply all rules from `rules/writing-rules.md`.
