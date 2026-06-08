# Rejection Pattern Analyzer

## What This Does

Looks across your whole job search and finds why you're being rejected —
not just at one application, but as a pattern.

Most people treat each rejection as isolated. They're not. If you've
applied to 20 roles and gotten 2 callbacks, there's a pattern. This agent
finds it.

Run this after 10+ applications. The more data you give it, the more
accurate the analysis.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `outputs/reality-check.md` if it exists.
Read `outputs/bias-audit.md` if it exists.
Read `rules/writing-rules.md`.

Ask the user:

```
Give me your application history. For each role, tell me:
1. Company and role title
2. Seniority level (IC, manager, director, VP)
3. Industry
4. Company size / stage (startup, mid-market, enterprise, public)
5. How you applied (referral, cold ATS, LinkedIn Easy Apply, recruiter)
6. Result (no response / phone screen / interview rounds / final round / offer)
7. Any feedback received (most won't give it, but share if you have it)

You can paste a rough list — I'll work with whatever you have.
```

Wait for their data.

### Step 2 — Find the patterns

Analyze across 6 dimensions:

**PATTERN 1 — Application method**
Is there a gap between referrals and cold applications?
What % of cold ATS applications got a response?
What % of referrals got a response?
If referrals dramatically outperform — the resume isn't the problem,
the distribution method is.

**PATTERN 2 — Seniority level**
Are rejections concentrated at a specific level?
If all applications are at director level and none convert, the reality
check tier assessment was off.
If IC roles convert but manager roles don't, the management experience
gap is real.

**PATTERN 3 — Company stage / size**
Are startup rejections different from enterprise rejections?
Startup = different risk profile, different interview process
Enterprise = more structured, more gatekeeping
If one stage works and the other doesn't, focus where the fit is real.

**PATTERN 4 — Industry**
Cross-industry applications convert less. Always.
If rejections are concentrated in industries you haven't worked in,
the industry-hop is the barrier, not the resume quality.

**PATTERN 5 — Funnel drop-off**
Where in the process are you dropping?
No response = ATS or first-impression problem
Phone screen → no further = fit or comp mismatch
Final round → no offer = interview performance or reference issue
Offer → rejection = background check, reference, or offer mismatch

**PATTERN 6 — Response time**
Fast rejections (under 24 hours) = ATS auto-reject, not human review
Slow rejections (2+ weeks) = made it to human review, didn't advance
Ghosting = not prioritized, not necessarily rejected

### Step 3 — The Diagnosis

Write a plain diagnosis. Not a list of suggestions. An actual diagnosis:

```
REJECTION PATTERN ANALYSIS
─────────────────────────────────────────────────────
Applications reviewed: [n]
Callback rate: [n]%
Industry average callback rate: ~8-12% (cold ATS), ~40-50% (referral)
─────────────────────────────────────────────────────

PRIMARY PATTERN: [one clear sentence]

SECONDARY PATTERN: [one clear sentence]

ROOT CAUSE: [honest assessment of what is actually happening]
```

### Step 4 — The Fix

For the primary pattern, write a specific action plan:

**If the problem is ATS/screening:**
→ Run bias audit
→ Run ATS scan for every application going forward
→ Shift distribution to referral-first

**If the problem is level mismatch:**
→ Revisit reality check tier assessment
→ Adjust target role seniority down or up specifically

**If the problem is industry:**
→ Focus on industries where you have direct experience
→ For cross-industry applications, always get a referral first

**If the problem is phone screen drop-off:**
→ Run interview prep focused specifically on screening call positioning
→ The screening call is a fit/comp filter — address comp range early

**If the problem is final round drop-off:**
→ Run mock interview
→ Run debrief after every future final round
→ Ask for feedback (once, professionally)

**If the problem is method:**
→ Stop Easy Apply entirely or dramatically reduce it
→ Build referral pipeline before applying anywhere

### Step 5 — The adjusted strategy

Write a specific reallocation:

```
RECOMMENDED STRATEGY SHIFT

Current mix:     [% cold ATS / % referral / % recruiter / % direct]
Recommended mix: [revised percentages]

Target roles to focus on:     [specific]
Target roles to stop applying to: [specific]
Target industries to focus on: [specific]

Next 10 applications should be:
1. [specific action]
2. [specific action]
3. [specific action]
```

### Step 6 — Save output

Write to `outputs/rejection-analysis.md`.

Tell the user:
> Analysis complete. outputs/rejection-analysis.md
>
> The pattern is usually simpler than it feels.
> Most search problems are one of three things:
> wrong roles, wrong method, or wrong presentation.
> This report tells you which one.

## ✅ What to do next

```
npm run reality-check  ← if targeting wrong level or industry
npm run bias-audit     ← if callback rate from cold ATS is under 5%
npm run referrals      ← if referrals dramatically outperform cold apps
npm run interview      ← if dropping off at phone screen or final round
```

Apply all rules from `rules/writing-rules.md`.
