---
name: job-hunter
description: Run a whole job-search campaign, not a one-off document. Use when the user says "find me jobs", "run my job search", "job hunt", "am I competitive for this role", "build my application package", "prep me for interviews", or "negotiate this offer". Routes live search, fit-scoring, ATS resume and cover letter, interview prep, and offer negotiation across four stages. For a single resume rewrite use resume-tailor; for JD scoring use jdfit.
allowed-tools: Read, Write, Glob, Grep, WebSearch, WebFetch, Bash(docker:*)
argument-hint: [stage or goal, e.g. "search recruiter roles Budapest" or "tailor for <JD url>"]
tags: [career, job-search, resume, interview, recruiting]
metadata:
  author: opencue
  version: "1.0.0"
  category: career
---

# Job Hunter

Run an end-to-end job-search campaign. This skill orchestrates a directory of
focused agents (`agents/*.md`) across four stages. Read the agent file that
matches the user's step and follow it. Do not duplicate a point tool: for a
single resume rewrite use `resume-tailor`, for JD-versus-resume scoring use `jdfit`.

## When to use

Use when the user runs a whole job hunt: sourcing live roles, deciding what they
are competitive for, building tailored application packages, preparing for
interviews, and negotiating offers. One-off document edits belong to the point
skills above.

## Example

> "Find me junior recruiter roles in Budapest and build my applications."

Run the Search stage (`agents/search-jobs.md`) for a fit-scored shortlist, then
for each target role run `agents/apply-reality-check.md` and
`agents/apply-fit-score.md` before `agents/apply-resume.md` and
`agents/apply-cover-letter.md`. Read the full job description first: board
"entry-level" tags routinely hide a 2 to 3 year experience gate.

## Inputs

Read the user's data from `inputs/` before any stage:
- `inputs/my-resume.md` (or a CV path the user gives)
- `inputs/job-search-criteria.md` (location, role, seniority, remote or onsite)
- `inputs/job-description.md` (for a specific role)
- `rules/writing-rules.md` (voice and formatting rules for all outputs)

## The four stages and their agents

Route to the agent that matches the step. Each agent file is self-contained.

1. **Search**: `agents/search-jobs.md` (live shortlist plus fit score),
   `search-company-research.md`, `search-referral-finder.md`,
   `search-ghost-job-detector.md`, `search-salary.md`, `search-tracker-update.md`.
2. **Apply**: `agents/apply-fit-score.md`, `apply-reality-check.md`,
   `apply-decode-jd.md`, `apply-resume.md`, `apply-cover-letter.md`,
   `apply-ats-scan.md`, `apply-bias-audit.md`, `apply-skills-gap-filler.md`,
   `apply-reference-prep.md`, `apply-rejection-analysis.md`.
3. **Interview**: `agents/interview-research.md`, `interview-prep.md`,
   `interview-mock.md`, `interview-question-bank.md`,
   `interview-panel-decoder.md`, `interview-debrief.md`.
4. **Offer**: `agents/offer-compare.md`, `offer-negotiate.md`,
   `offer-counteroffer.md`, `offer-deadline-manager.md`, `offer-thankyou.md`.

## How to run

1. Confirm the stage from the user's request (search, apply, interview, offer).
2. Read the matching `agents/*.md` plus the relevant `inputs/`.
3. Follow that agent's steps and write outputs to `outputs/`.
4. Reality-check before volume: run `apply-reality-check.md` and
   `apply-fit-score.md` so the user targets roles they can win.

## Prerequisites

Live multi-board search (`search-jobs.md`) uses the JobSpy MCP. Start it with:

```bash
docker run -p 9423:9423 borgius/jobspy-mcp-server
```

Fallback when JobSpy is unavailable or a board blocks scraping: search a national
board directly with `WebSearch` plus `WebFetch` (this is how the Hungarian
`profession.hu` flow was run), and hand the user direct search URLs for boards
that block automated fetch (LinkedIn, most remote boards).

## Rules

- Reality first. Score fit and market tier before mass applying.
- Never invent metrics on a resume. Mark missing numbers and have the user fill them.
- Read the full job description, not the board summary. Board "entry-level" tags
  routinely hide a 2 to 3 year experience gate; classify each role as realistic
  fit or stretch and say which.
- Match the output language to the employer and the job description.
- Keep personal data in the user's own folder, never in this shared skill.
