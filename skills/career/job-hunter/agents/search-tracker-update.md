# Job Tracker Auto-Fill

## What This Does

Reads all your outputs and automatically rebuilds your job tracker with
current data — so your pipeline is always up to date without manual copying.

The job tracker in `docs/templates/JOB-TRACKER.md` never stays current
because updating it manually is friction. This agent reads everything in
`outputs/` and reconstructs the tracker automatically.

## Instructions for Claude Code

### Step 1 — Load all available outputs

Read every file in `outputs/` that exists:
- `job-shortlist.md` — companies and roles from the job search
- `fit-score.md` — most recent fit score
- `reality-check.md` — target tier and competitive roles
- `company-research.md` — companies researched
- `referral-finder.md` — companies with active referral outreach
- `inbox-scan.md` — companies that have emailed you
- `follow-up.md` — companies in follow-up stage
- `interview-brief.md` — companies with scheduled interviews
- `interview-debrief.md` — companies post-interview
- `salary-research.md` — comp benchmarks
- `offer-comparison.md` — active offers
- `rejection-analysis.md` — patterns and insights

Read `docs/templates/JOB-TRACKER.md` for the template format.

### Step 2 — Reconstruct the pipeline

Build a complete picture of where each company stands:

**Stages:**
1. RESEARCHING — in job shortlist or company research, not yet applied
2. APPLIED — application submitted, no response
3. SCREENING — phone screen or recruiter conversation
4. INTERVIEWING — one or more interview rounds
5. FINAL ROUND — last stage before decision
6. OFFER — offer received, negotiating or deciding
7. CLOSED — rejected, declined, or accepted

For each company: infer stage from which output files mention it and
what stage they're described at.

### Step 3 — Write the updated tracker

Format:

```markdown
# Job Search Tracker
Last updated: [today's date]

## Pipeline Summary
Total active: [n] | Applied: [n] | Screening: [n] | Interviewing: [n] | Offers: [n]
Callback rate: [n]% ([n] responses from [n] applications)

─────────────────────────────────────────────────────

## Active Pipeline

| Company | Role | Stage | Applied | Last Contact | Next Action | Notes |
|---|---|---|---|---|---|---|
[one row per company, populated from outputs]

─────────────────────────────────────────────────────

## Offers
[If any offers exist — full detail from salary research and comparison]

─────────────────────────────────────────────────────

## Closed
| Company | Role | Outcome | Date | Notes |
|---|---|---|---|---|
[rejections, declines, accepted offers]

─────────────────────────────────────────────────────

## Search Health
Target roles: [from reality check]
Strong callback sources: [from rejection analysis if available]
Market comp range: [from salary research if available]

─────────────────────────────────────────────────────

## Next Actions (this week)
[5-7 specific action items pulled from all outputs — follow-ups due,
interviews to prep for, references to brief, responses to send]
```

### Step 4 — Flag urgent items

At the top of the output, list anything time-sensitive:

```
⚠️  URGENT — needs action today or tomorrow:
- [anything with a deadline from deadline-manager output]
- [unanswered inbox alerts from inbox-scan]
- [follow-ups more than 5 days old]
```

### Step 5 — Save output

Write to `outputs/job-tracker.md` (not the template — the live version).

Also update `docs/templates/JOB-TRACKER.md` if the template format is stale.

Tell the user:
> Tracker updated. outputs/job-tracker.md
>
> [n] companies in pipeline. [n] items need action this week.
> [If urgent:] ⚠️  [n] items need attention today.

Run this weekly. The more outputs you have, the more accurate it gets.

## ✅ What to do next

```
npm run inbox          ← scan for new recruiter emails first
npm run follow-up      ← generate follow-up for anything stale
npm run deadline       ← if any offers have deadlines
```

Apply all rules from `rules/writing-rules.md`.
