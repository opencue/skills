# Skills Gap Filler

## What This Does

Reads a job description and tells you exactly which "requirements" are real
gates vs. recruiter wishlist — and for the real gaps, gives you the fastest
path to closing them.

Recruiters copy-paste requirements from previous job postings, add
everything the last person in the role happened to know, and then use
the list to filter out qualified people. Most postings have 10-12
requirements. You need 60-70% to be competitive. This agent tells you
which 60-70% matters and what to do about the rest.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md`.
Read `rules/writing-rules.md`.

### Step 2 — Classify every requirement

Extract every stated requirement from the JD. For each one, classify it:

**HARD GATE** — You will be screened out without this. Non-negotiable.
- Specific license or certification (Series 7, RN, PE, Bar)
- Minimum years experience explicitly stated ("5+ years required")
- Specific technology that is core to the role (not "preferred")
- Location or legal requirement (must be US citizen, must be on-site)

**REAL REQUIREMENT** — Hiring manager will test for this directly.
- Primary skill of the role
- Tools they use daily
- Domain knowledge central to the function

**NICE-TO-HAVE** — Listed to describe an ideal candidate, not a gate.
- "Preferred" or "plus" language
- Secondary tools ("experience with Salesforce a plus")
- Soft skills (everyone lists these, no one actually screens for them)
- Advanced degrees when not explicitly required
- Industry experience when transferable experience exists

**INFLATED REQUIREMENT** — Sounds hard, actually learnable in weeks.
- Common when JD was written by someone who doesn't do the job
- Often: specific software version, methodology names, tool names
- Tells you what to learn before the interview, not what blocks you

### Step 3 — Gap analysis against the resume

For each HARD GATE and REAL REQUIREMENT the candidate doesn't have:

**Gap:** [what's missing]
**Type:** Hard Gate / Real Requirement
**Honest assessment:** Is this actually required or are they describing their last hire?
**Time to close:** [realistic estimate — days, weeks, months]
**How to close it:**
- Free: [specific resource — YouTube channel, documentation, free course]
- Fast: [certification or course that signals competency, with cost and time]
- Deep: [if this requires significant work — be honest about the timeline]
**What to say in the interview if you don't have it yet:**
[Exact language for addressing the gap honestly without disqualifying yourself]

### Step 4 — The Apply Decision

Based on the gap analysis:

**APPLY NOW** — You meet the hard gates, have the real requirements, gaps are closeable
**APPLY + CLOSE GAPS FAST** — You meet most requirements, specific gaps closeable before interview rounds
**APPLY IN [X WEEKS]** — You have a gap that would disqualify but can close it in a specific timeframe
**DON'T APPLY YET** — A hard gate you cannot realistically close soon

Be direct. If the honest answer is "don't apply yet because X," say that.

### Step 5 — The Fast Track

If the recommendation is APPLY + CLOSE GAPS FAST, write a specific
3-7 day sprint plan:

```
GAP-CLOSING SPRINT

Goal: Close [gap] before the interview stage

Day 1-2: [specific resource + what to complete]
Day 3-4: [specific resource + what to complete]
Day 5-7: [hands-on practice + what to build or document]

By end of sprint:
- You can speak credibly about [topic]
- You have [specific artifact/project/cert] to point to
- Interview answer: "[exact phrasing]"
```

### Step 6 — Save output

Write to `outputs/skills-gap.md`.

## ✅ What to do next

```
npm run fit            ← score overall fit now that you know the gaps
npm run resume         ← tailor resume to emphasize what you DO have
npm run ats            ← ensure keywords from real requirements are in your resume
npm run interview      ← prep for how to handle gap questions in the interview
```

Apply all rules from `rules/writing-rules.md`.
