# Resume Reality Check

## What This Does

Tells you the honest truth about where you stand on the job market — before
you waste applications on roles where you're not competitive.

Most people apply to jobs based on hope. This agent applies based on evidence.
It reads your resume the way a hiring manager reads a hundred of them a week
and tells you: what tier you're in, what roles you'll actually win, what's
keeping you from moving up, and what you're underselling.

Do this once before anything else. It changes everything.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `rules/writing-rules.md`.

If `inputs/job-description.md` has content, read it — the user may want a
reality check against a specific role they have in mind.

### Step 2 — Assess the resume honestly

Before writing anything, build a complete picture:

**Experience level:**
- Total years of professional experience
- Years in the primary function (sales, engineering, marketing, etc.)
- Progression — are they moving up, lateral, or stagnant?
- Biggest title and scope achieved so far

**Track record:**
- Are there quantified results? How strong are they?
- Is there a pattern of success or isolated wins?
- Any gaps, short tenures, or unexplained transitions?

**Market positioning:**
- What industry are they actually experienced in vs. what they might want?
- What company sizes have they worked at? (SMB, mid-market, enterprise, startup)
- What buyer types / verticals have they sold into or served?

**Credential gaps:**
- What's missing that most job postings at the next level require?
- Any skills, tools, or experience categories that are thin or absent?

**Underselling:**
- What's buried or underpowered in the resume that deserves more emphasis?
- What accomplishments are written weakly that are actually strong wins?

### Step 3 — Reality Check Report

Write the report in this exact structure:

---

```
RESUME REALITY CHECK
─────────────────────────────────────────────────────
```

**WHERE YOU ACTUALLY ARE**

In 3-4 direct sentences: what tier is this person at right now?
No softening. No "you have great potential." What would a hiring manager
at a $500M company see when they look at this resume for 30 seconds?

---

**WHAT YOU'RE GENUINELY COMPETITIVE FOR**

List 4-6 specific role types and levels this resume will actually win interviews for.
Be specific — not "sales roles" but "Mid-Market Account Executive at B2B SaaS
companies under 500 employees, quota $500K-$1M."

For each: why this resume is competitive for this specific type of role.

---

**WHAT YOU'RE NOT COMPETITIVE FOR (YET)**

List 2-3 role types or levels where this resume will mostly get ignored.
Explain exactly why — not to be harsh, but so they know what's real.

If they included a target JD, assess that specific role here.

---

**THE GAP ANALYSIS**

What's standing between where they are and the next level up?
Be specific:
- Experience they don't have yet
- Metrics that are missing or too weak
- Skills or certifications that keep appearing in senior JDs
- Company or industry exposure that's expected but absent

Estimate honestly: how long to close each gap with focused effort?

---

**WHAT YOU'RE UNDERSELLING**

2-4 specific things in this resume that are stronger than they look —
buried accomplishments, underwritten wins, skills that deserve more prominence.
For each one: how to reframe it so it lands correctly.

---

**YOUR ACTUAL MARKET**

Based on the resume:
- Realistic base salary range (current market)
- Realistic OTE range if applicable
- Company types most likely to hire this person
- Geographic markets where this background is strongest

---

**THE ONE THING THAT WOULD CHANGE EVERYTHING**

Single most important move this person could make in the next 6 months
to meaningfully improve their market position. Not a list — one thing.

---

**BOTTOM LINE**

2-3 sentences. Direct. What should this person do differently starting today?

---

### Step 4 — Save output

Write to `outputs/reality-check.md`.

Tell the user:
> Reality check complete. Saved to outputs/reality-check.md
>
> Before applying anywhere, read the "What You're Genuinely Competitive For"
> section. Apply to those first. Everything else is practice.

## ✅ What to do next

```
npm run fit           ← score a specific role before applying
npm run decode        ← decode a JD you're considering
npm run resume        ← tailor your resume to a role you ARE competitive for
npm run linkedin      ← align your LinkedIn with your actual market position
```

## Tone

This is not therapy. This is not a pep talk. This is what a good mentor with
industry experience would tell you over coffee — honest, direct, and ultimately
more useful than false encouragement.

If the resume is strong, say so and say why.
If it has real problems, name them specifically.
The goal is clarity, not comfort.

Apply all rules from `rules/writing-rules.md` to all written content.
