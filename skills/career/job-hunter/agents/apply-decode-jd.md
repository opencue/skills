# Job Description Decoder

## What This Does

Reads between the lines of a job description. What are they really asking for?
What do the red flags mean? What does this role actually pay? What kind of
manager posts like this?

Most job seekers read a JD at face value. This reads it the way a recruiter
or insider would.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/job-description.md`.
Read `inputs/my-resume.md` for context on fit assessment.

### Step 2 — Decode the JD

Produce the following sections:

---

### WHAT THEY'RE ACTUALLY LOOKING FOR

Strip away the corporate language and say what this role really needs.
Not "5+ years of experience in enterprise sales" — but "they had someone
leave who owned a specific segment and they need someone who can hit the ground
running without hand-holding."

2-4 sentences of plain-language translation.

---

### RED FLAGS

Flag any of the following language patterns if present, and explain what they
usually mean in practice:

- "Fast-paced environment" — often means disorganized or understaffed
- "Wear many hats" — often means no clear role definition and scope creep
- "Self-starter" / "entrepreneurial" — often means minimal support or training
- "Competitive salary" without a number — often means below market
- "Must be comfortable with ambiguity" — often means leadership doesn't have a plan
- "Rock star" / "ninja" / "guru" — often signals culture problems
- "Like a family here" — often means poor boundaries and unpaid overtime expectations
- "Unlimited PTO" — often means pressure not to take it
- "Results-oriented" without defining results — often means undefined success metrics
- Long list of requirements for a mid-level role — often means they've burned through people
- Requirements that span 3 different job families — often means they want one person to do three jobs

For each red flag found: quote the exact phrase, explain what it usually signals,
and rate the concern: Minor / Worth asking about / Significant.

---

### WHAT THIS ROLE ACTUALLY PAYS

Based on:
- The role title and seniority level
- The company size and industry (infer from JD if not stated)
- The location
- Whether a range is posted (if yes, note that posted minimums are often negotiable up 10-20%)

Produce:
- Likely base range
- Likely OTE range (if sales/commission role)
- What the posting language signals about comp philosophy
  (e.g. "competitive compensation" with no number = likely underpaying vs market)

---

### WHAT KIND OF MANAGER POSTED THIS

Based on the language, structure, and emphasis of the JD, characterize the
likely manager or culture:

- Heavy on requirements, light on what you'll get = transactional culture
- Detailed about growth and learning = likely invests in people
- Lots of buzzwords = likely leadership-by-trend
- Clear metrics and outcomes = likely data-driven, good or bad
- Vague about success metrics = likely unclear expectations

Be direct. This section should help the candidate decide whether to invest
time applying.

---

### FIT ASSESSMENT

Based on the resume:
- Where this candidate is strong for this role (specific)
- Where they have gaps (specific)
- The one thing they need to nail in the screening call to get past the JD concerns

---

### QUESTIONS TO ASK IN THE INTERVIEW

5 questions this JD specifically warrants asking — to validate or disprove
the red flags and get the real story on the role.

---

### Save output

Write to `outputs/jd-decoded.md`.

---

## ✅ What to do next

```
npm run ats           ← check your resume against the ATS before tailoring
npm run resume        ← tailor resume to this specific role
```
