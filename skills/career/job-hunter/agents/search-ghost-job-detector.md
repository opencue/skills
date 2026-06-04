# Ghost Job Detector

## What This Does

Scores a job posting for signals that it's not a real, active opening —
and tells you whether to invest time applying.

Ghost jobs are real and widespread. Companies post roles they have no
immediate intention of filling: to build a talent pipeline, to justify
headcount requests, to collect competitive intelligence on who's looking,
or because the system auto-renewed a posting. Applying to a ghost job
wastes hours of your time and skews your rejection analysis.

Run this before investing time tailoring an application.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/job-description.md`.
Read `rules/writing-rules.md`.

Also ask the user:
```
A few things to check — if you know them:

1. When was this posting first listed? (check LinkedIn "posted X days ago")
2. Have you seen this exact role posted before at this company?
3. Do you know anything about this company's current hiring status?
   (recent layoffs, hiring freeze news, funding news)
```

### Step 2 — Score 8 ghost job signals

Check every signal. Each one that fires adds to the ghost score.

---

**SIGNAL 1 — Posting age**

- Under 2 weeks: Low concern
- 2-4 weeks: Mild concern — most roles fill faster than this
- 4-8 weeks: Moderate concern — ask why it's still open
- 8+ weeks: High concern — either very hard to fill or not actively hiring

**SIGNAL 2 — JD specificity**

Real open roles tend to be specific: they describe actual challenges,
name the team, mention what the previous person did or why the role exists.

Ghost job signals:
- Generic language that could apply to any company
- No mention of team size, reporting structure, or company stage
- JD that reads like it was written by committee or copied from a template
- Every bullet uses vague corporate language with no specifics

**SIGNAL 3 — Requirements inflation**

Real roles list what they actually need. Ghost jobs or roles frozen in
approval list everything anyone could ever want:
- 12+ bullet requirements
- Years of experience doesn't match the seniority level offered
- Requires skills that don't obviously connect to the role
- Lists 3-4 competing technologies as all required (a real team uses one)

**SIGNAL 4 — Multiple simultaneous postings**

Search LinkedIn/Indeed for the same company + similar role title.
If the same company is posting:
- The same role in 5+ cities: often pipeline building, not active hire
- 3+ near-identical roles at once: either real growth OR approval limbo
- The same role repeatedly over 6+ months: high churn warning

**SIGNAL 5 — Company health signals**

Look for:
- Recent layoffs mentioned in news (check company name + "layoffs 2024 2025")
- Hiring freeze announcements
- Recent acquisition (hiring often pauses post-acquisition)
- Series A or earlier startup with no recent funding news (runway concern)
- Public company with recent earnings miss mentioning cost cuts

**SIGNAL 6 — Application friction mismatch**

Real companies with real openings usually want to make it easy to apply.

Ghost job signals:
- ATS-only application with no human contact anywhere
- No recruiter name on LinkedIn associated with this role
- Application asks for full project portfolios or lengthy assessments upfront
  before any human has seen your resume (screening out, not selecting in)
- Application form asks for salary history (in states where this is legal —
  often used to pre-screen based on comp, not competency)

**SIGNAL 7 — Social proof check**

Check LinkedIn:
- Are there real employees in this department? Do they exist?
- Has anyone listed this company on their profile recently?
- Does the company LinkedIn page look active or dormant?
- Does the hiring manager listed actually exist and work there?

**SIGNAL 8 — The "always hiring" pattern**

Some companies permanently post certain roles because turnover is so high
that they're always looking. This is not a ghost job — it's a warning sign.
Different problem, same outcome: your time is better spent elsewhere.

---

### Step 3 — Score and verdict

**Ghost Score: X/8 signals fired**

**0-1: APPLY** — Looks like a real, active opening
**2-3: APPLY WITH HEDGE** — Probably real but verify before heavy investment
**4-5: VERIFY FIRST** — Check LinkedIn for a real recruiter, reach out before tailoring
**6-8: SKIP OR INVESTIGATE** — Strong ghost signals. Reach out directly to verify before applying.

### Step 4 — The verification move

For any score 3+, write the exact LinkedIn message to verify:

---
[To: Recruiter or hiring manager at the company, found via LinkedIn]

Saw the [Role] posting at [Company] and I'm genuinely interested. Before I
put together a full application, I wanted to confirm the role is actively
being filled right now — I've been caught by stale postings before. Is
this a current search?

[Name]
---

30 seconds. If they respond, it's real. If they don't within a week, it's likely not.

### Step 5 — Save output

Write to `outputs/ghost-check.md`.

Tell the user:
> Ghost score: [X]/8 — [APPLY / APPLY WITH HEDGE / VERIFY FIRST / SKIP]

## ✅ What to do next

```
npm run fit            ← score your fit if this is a real role
npm run decode         ← decode what the JD actually means
npm run company        ← research the company before investing in an application
```

Apply all rules from `rules/writing-rules.md`.
