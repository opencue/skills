# Job Fit Scorer

## What This Does

Scores how competitive you actually are for a specific role before you apply.
Not the ATS match score — that's software. This is the human judgment score.

The ATS scanner tells you if software will filter you out.
This tells you if a hiring manager will care.

Paste your resume and a job description. Get a 1-10 fit score, an honest
breakdown of where you're strong and where you're not, a clear Apply /
Don't Apply / Apply With Caveats recommendation, and exactly what to address
in the cover letter and interviews if you do apply.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md`.
Read `rules/writing-rules.md`.

If `outputs/reality-check.md` exists, read it — use the market positioning
already established there to inform this assessment.

### Step 2 — Analyze fit across five dimensions

Score each dimension 1-10 and explain the score specifically.

**Dimension 1 — Experience Match**
Does the candidate have relevant experience doing the same or similar work?
- 9-10: Almost identical role at a comparable company
- 7-8: Closely related role, similar scope
- 5-6: Adjacent experience, some overlap
- 3-4: Thin overlap, significant stretch
- 1-2: Little to no relevant experience

**Dimension 2 — Level Match**
Is the candidate at the right seniority level for this role?
- Over-qualified, Under-qualified, or Right-qualified?
- Over-qualified is not automatically good — companies often reject people
  they think will leave once something better comes along

**Dimension 3 — Industry / Domain Match**
Does their background map to the industry, buyer type, or domain?
- Selling healthcare software to hospital CFOs vs. selling retail POS to SMBs
  are different skills even if both are "sales"
- Be specific about the mismatch or match

**Dimension 4 — Track Record Match**
Does their quantified performance align with what this role expects?
- If the JD implies $2M quota and their biggest was $500K — flag it
- If the JD wants enterprise and they've done SMB — flag it
- If their numbers are strong and directly relevant — note it

**Dimension 5 — Culture / Company Stage Match**
Does their background suggest they'd thrive in this environment?
- Startup vs. enterprise
- High-growth vs. stable
- Founder-led vs. professionally managed
- Infer from JD language and company signals

### Step 3 — Fit Score Report

Write the report in this exact structure:

---

```
JOB FIT SCORE
Role: [title] at [company]
─────────────────────────────────────────────────────
```

**OVERALL FIT: [X]/10**

**RECOMMENDATION: APPLY / DON'T APPLY / APPLY WITH CAVEATS**

One sentence explaining the recommendation. Direct.

---

**SCORECARD**

| Dimension | Score | Summary |
|---|---|---|
| Experience Match | X/10 | one line |
| Level Match | X/10 | one line |
| Industry / Domain | X/10 | one line |
| Track Record | X/10 | one line |
| Culture / Stage | X/10 | one line |

---

**WHERE YOU'RE STRONG FOR THIS ROLE**

2-4 specific things from the resume that directly match what this role needs.
These are your selling points — use them in the cover letter and interviews.

---

**WHERE YOU'RE WEAK FOR THIS ROLE**

2-4 specific gaps between what the JD requires and what the resume shows.
Be precise — not "limited experience" but "JD requires enterprise deals over $500K,
resume shows largest deal was $180K at mid-market."

---

**IF YOU APPLY: HOW TO FRAME IT**

If the recommendation is Apply or Apply With Caveats:

- The angle — the single most compelling reason to hire this person despite the gaps
- What to emphasize in the cover letter (2-3 specific points)
- What to prepare to address in the screening call (the objections they'll raise)
- What NOT to bring up or volunteer

---

**IF YOU DON'T APPLY: WHY NOT AND WHAT INSTEAD**

If the recommendation is Don't Apply:

- The specific reason this application will likely fail
- What this role would actually require (honest gap assessment)
- 2-3 alternative role types that would be a better use of this application effort
- What would need to change to make this role viable in 12-18 months

---

### Step 4 — Save output

Write to `outputs/fit-score.md`.

Tell the user:
> Fit score complete: [X]/10 — [APPLY/DON'T APPLY/APPLY WITH CAVEATS]
> Saved to outputs/fit-score.md

If the score is 7 or above, continue automatically:
> Score is [X]/10 — running ATS scan next.
Then execute `agents/apply-ats-scan.md` against the same resume and JD.

### Step 5 — Pipeline continuation

If APPLY or APPLY WITH CAVEATS and score >= 7:
Tell the user the recommended next sequence:
```
npm run ats           ← check ATS issues
npm run resume        ← tailor resume
npm run cover-letter  ← write cover letter
```

If DON'T APPLY or score < 5:
Tell the user:
```
npm run reality-check ← get a broader picture of where you're competitive
npm run jobs          ← find roles that fit your actual profile
```

## ✅ What to do next

**Score 7-10 / Apply:**
```
npm run ats           ← fix ATS issues before submitting
npm run resume        ← tailor resume to this specific role
npm run cover-letter  ← write the cover letter
```

**Score below 7 / Don't Apply:**
```
npm run reality-check ← understand your actual market before applying anywhere
npm run jobs          ← find roles you're genuinely competitive for
```

## Tone

Honest. A 4/10 is a 4/10. Don't soften it to a 6 to spare feelings.
A candidate who applies to a 4/10 role wastes time they could spend on a 8/10.
The most useful thing this tool can do is tell someone not to apply.

Apply all rules from `rules/writing-rules.md` to all written content.
