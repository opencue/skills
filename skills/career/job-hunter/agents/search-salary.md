# Salary Research Agent

## What This Does

Researches current market compensation for a specific role and location.
Gives you a realistic range, a negotiation anchor, and talking points for
the comp conversation — before you get on a screening call.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/job-description.md` for role title and company.
Read `inputs/my-resume.md` for years of experience and background context.

### Step 2 — Extract role details

From the JD identify:
- Exact role title
- Seniority level (entry / mid / senior / director / VP)
- Location (remote or specific city)
- Industry
- Company size if mentioned

### Step 3 — Research compensation

Use web search to find current salary data from:
- Glassdoor (search: "[role title] salary [city] site:glassdoor.com")
- LinkedIn Salary (search: "[role title] salary [city] site:linkedin.com/salary")
- Levels.fyi for tech roles (search: "[role title] [company] salary site:levels.fyi")
- Payscale (search: "[role title] salary [city] site:payscale.com")
- Indeed Salary (search: "[role title] salary [city] site:indeed.com")

Run at least 3 searches. Collect the ranges returned.

### Step 4 — Calculate ranges

From all data collected, determine:
- Floor: 25th percentile (low end, likely entry-level or low-cost market)
- Midpoint: 50th percentile (market rate for this role/location)
- Ceiling: 75th percentile (experienced candidate or HCOL market)
- Stretch: 90th percentile (for negotiation anchor — never open here, use as ceiling)

For sales roles, also calculate:
- Base salary range
- OTE (On-Target Earnings) range
- Commission structure norms for this role type

### Step 5 — Assess where the user lands

Based on their resume, assess where in the range they realistically sit:
- Years of experience in this role type
- Industry background alignment
- Geographic market (HCOL vs MCOL vs LCOL)
- Whether they're targeting a step up, lateral, or step down

### Step 6 — Write negotiation strategy

Produce a short negotiation playbook:

OPENING NUMBER: [specific number — not a range]
Why: Opening with a range anchors to the bottom. Opening with a number anchors higher.

ACCEPTABLE RANGE: [floor] to [ceiling]

WALK-AWAY NUMBER: [the number below which this role doesn't make sense]

IF THEY COME IN BELOW YOUR FLOOR:
[2-3 sentences on how to respond — what to say, what to ask for instead]

IF THEY ASK "WHAT ARE YOU LOOKING FOR" BEFORE AN OFFER:
"I'm focused on finding the right fit first. I'm confident we can get to a
number that works for both sides once we get there." — then redirect.

NON-SALARY LEVERS:
List 5 things to negotiate if base salary is fixed:
signing bonus, equity/RSUs, remote flexibility, start date, PTO, title bump,
performance review timing, expense account, equipment budget.

### Step 7 — Save output

Write to `outputs/salary-research.md`.

Tell the user:
> Market rate for [role] in [location]: [floor]-[ceiling] base, [OTE if applicable]
> Your anchor: [opening number]
> Full research saved to outputs/salary-research.md

---

## ✅ What to do next

```
npm run decode        ← decode the JD — red flags, what they really want
npm run ats           ← check your resume clears the ATS screener
```
