# Bias Audit

## What This Does

Reads your resume through the lens of every known screening bias and tells
you exactly what signals are triggering filters — before a human ever sees
your name.

This is different from the ATS scanner. The ATS scanner looks for keyword
gaps. This looks for signals that get you auto-rejected based on age, name,
employment gaps, geography, graduation year, gendered language, school
prestige, and the patterns AI screening tools have been proven to penalize.

99% of Fortune 500 companies use AI screening. 85% of AI screeners show
racial name preference. 64% of workers over 50 experience age discrimination.
Employment gaps trigger automatic flags. This agent finds every signal and
tells you how to neutralize each one without misrepresenting yourself.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md` if available.
Read `rules/writing-rules.md`.

### Step 2 — Scan for 8 bias vectors

Check every vector. For each one: is it present, what is the risk, and
what is the exact fix.

---

**VECTOR 1 — Age Signals**

Look for:
- Graduation years (calculate implied age range — flag if implying 40+)
- Work history starting before 2005 (flags to ATS as 20+ year career)
- References to technology, tools, or methods that became obsolete pre-2015
- Listing more than 4 jobs or 20+ years of experience
- Phrases that signal long tenure: "over 20 years", "since the 90s", "veteran"

The tension: omitting graduation years can flag incomplete applications.
Including them reveals age. Give the specific recommendation for this resume.

Fix options:
- Remove graduation years (works in most states — NYC legally cannot require them)
- Trim work history to last 15 years
- Reframe tenure as depth, not length
- Remove obsolete technology references

---

**VECTOR 2 — Name and Identity Signals**

Look for:
- Name on the resume: research suggests non-Anglo names receive 50% fewer callbacks
- Address or location that signals specific demographics
- Nationality or citizenship status visible in the resume
- Languages listed (can trigger or suppress depending on role)
- Alumni associations, cultural organizations, or affinity groups in activities

This is legally protected. The agent does NOT recommend changing a name.
It flags the reality so the candidate can make an informed choice — and
recommends strategies that reduce the name's impact on the screening stage
(e.g. getting past ATS to human review via referrals).

---

**VECTOR 3 — Employment Gaps**

Look for:
- Any gap of 3+ months in the last 10 years
- Gaps that overlap 2020-2021 (COVID — less concerning but still flagged)
- Gaps post-2022 (AI screening treats these more harshly)
- Freelance or consulting listed without specific clients (signals cover for gap)

For each gap found:
- How long it is
- How AI screening will interpret it
- How to reframe it: exact language for the resume, and what to say if asked

Legitimate reframes (never fabricate):
- Caregiving (parent, child, spouse)
- Medical leave
- Continuing education
- Freelance / consulting
- Job market conditions (especially 2020, 2023-2024 tech layoffs)

---

**VECTOR 4 — Gendered Language**

Look for known masculine-coded words: competitive, dominant, driven,
aggressive, independent, analytical, decisive, determined

Look for known feminine-coded words: collaborative, supportive, warm,
nurturing, empathetic, sensitive

Research shows masculine-coded resumes get more callbacks for technical
and leadership roles; feminine-coded resumes get penalized in those same
roles. Neither is "bad" language — but the mismatch with the JD is the risk.

Compare to JD language if available. Flag where resume language diverges
from the register of the job posting.

---

**VECTOR 5 — School Prestige Signals**

Look for:
- Schools that are regionally specific and unknown nationally
- For-profit institutions (flagged heavily by AI screening)
- Community college credentials listed prominently
- Degrees that don't match industry expectations

This is not about elitism — it's about what AI screening tools penalize.
Provide specific reframing strategies.

---

**VECTOR 6 — Address and Geography**

Look for:
- Full street address (provides neighborhood demographic signals)
- Zip codes in areas with known demographic patterns
- Out-of-state address for a local role (triggers relocation cost concern)
- Rural address for a major metro role

Fix: replace full address with City, State only.
For remote roles: replace with "Remote — [City, State]" or remove entirely.

---

**VECTOR 7 — Photo, Age, or Appearance Signals**

Look for:
- Any mention of a photo or link to one
- LinkedIn URL that leads to a profile photo (some ATS pull LinkedIn data)
- Profile headshots mentioned anywhere

Note: In the US, photos on resumes are not standard and can expose employers
to bias claims — which means some ATS systems are trained to flag resumes
that include photos.

---

**VECTOR 8 — Disability and Protected Status**

Look for:
- Any mention of accommodations, accessibility needs, or disability
- Medical history or leave descriptions that reveal health conditions
- Volunteer work with disability organizations (can signal personal connection)
- Military service (protected class — but also triggers veteran benefit
  screening in some systems, which can be positive or negative)

For military: translate all military titles, units, and terminology into
civilian equivalents. ATS systems frequently fail to parse military resumes.

---

### Step 3 — Write the Bias Audit Report

```
BIAS AUDIT REPORT
─────────────────────────────────────────────────────
```

For each vector, rate it:
🔴 HIGH RISK — actively working against you, fix before applying
🟡 MODERATE — worth addressing, lower urgency
✅ CLEAN — no issues found

For every HIGH and MODERATE finding:
- What the signal is (exact text from resume)
- Why it triggers bias (specific mechanism — AI, human, or both)
- The exact fix (rewording, removal, or reframe — specific text)

```
─────────────────────────────────────────────────────
OVERALL BIAS EXPOSURE: High / Moderate / Low
─────────────────────────────────────────────────────

[n] signals found: [n] high risk, [n] moderate
```

### Step 4 — The Referral Recommendation

At the end of the report, add:

```
THE MOST EFFECTIVE BIAS MITIGATION

Fixing resume signals reduces filter risk. But the most effective way to
overcome screening bias is bypassing the ATS entirely via referral.

A referred candidate skips the AI screening layer and goes directly to
human review. For candidates facing age, name, or gap bias — this is not
optional, it's strategic.

Run: npm run referrals
```

### Step 5 — Save output

Write to `outputs/bias-audit.md`.

## ✅ What to do next

```
npm run resume         ← apply the bias fixes to your tailored resume
npm run ats            ← check keyword gaps after fixing bias signals
npm run referrals      ← build warm paths to bypass AI screening entirely
npm run reality-check  ← if you're not getting callbacks despite strong experience
```

## Tone

This is a factual analysis of documented screening patterns. It is not
about whether bias is right or fair — it is about what is real, what the
candidate can control, and what to do about it. Be specific. Be direct.
Do not soften findings that need action.

Apply all rules from `rules/writing-rules.md`.
