# Pre-Interview Research Agent

## What This Does

Pulls everything worth knowing before an interview — company news, the
interviewer's background, product positioning, financials, and competitive
landscape. Outputs a one-page brief you read in the 30 minutes before the call.

Walking in knowing something specific about the interviewer or a recent company
win is the single thing that most separates memorable candidates from forgettable ones.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/job-description.md` for company name, role, and any context.
Read `inputs/interview-context.md` if it exists — interviewer name and title.
Read `inputs/my-resume.md` for background context.

If `inputs/interview-context.md` doesn't exist, ask:
> Who are you interviewing with? (name and title if known — leave blank if not)
> What type of interview is this? (screening / hiring manager / panel / final round)

### Step 2 — Research the company

Use web search to find — search each of these separately:

1. "[Company name] news 2025 2026" — recent announcements, funding, layoffs, launches
2. "[Company name] product" — what they actually sell and who buys it
3. "[Company name] competitors" — who they compete with
4. "[Company name] revenue OR funding OR valuation" — financial health
5. "[Company name] glassdoor reviews" — culture signals, management patterns,
   common complaints (look for patterns, not individual reviews)
6. "[Company name] SEC filing OR annual report" — if public, pull key metrics

### Step 3 — Research the interviewer

If a name was provided:
1. Search "[Interviewer name] [Company name] LinkedIn" — background, tenure, previous companies
2. Search "[Interviewer name] [Company name]" — any articles, talks, posts
3. Note: how long have they been at the company? Where did they come from?
   What's their likely priority in this interview?

If no name provided: research the hiring manager role type based on the JD —
what does someone in that position typically care about most?

### Step 4 — Build the brief

Write a tight one-page brief. Not a dump of everything found — a curated
set of things that are actually useful to know walking into this specific interview.

```
─────────────────────────────────────────────────────
PRE-INTERVIEW BRIEF
[Role] at [Company]
Prepared: [date]
─────────────────────────────────────────────────────

THE COMPANY IN THREE SENTENCES:
[What they do, who they sell to, how they make money — in plain language]

WHAT'S HAPPENING RIGHT NOW:
[2-3 recent developments that are relevant — funding, expansion, product launch,
leadership change, competitive pressure. These are your conversation openers.]

THEIR BUSINESS MODEL:
[How they make money. What metrics they care about. What a win looks like for them.]

THE COMPETITIVE LANDSCAPE:
[Who they compete with and how they're positioned. Knowing this signals you
understand their market, not just their job description.]

FINANCIAL HEALTH:
[Public: key metrics from latest earnings. Private: funding stage, last round,
investors. Early-stage: burn rate signals if available. Stable/growing/declining?]

GLASSDOOR SIGNALS:
[3-4 patterns from reviews — not individual complaints. What do people consistently
say about management, culture, and growth? What do people consistently leave for?]

─────────────────────────────────────────────────────
THE INTERVIEWER
─────────────────────────────────────────────────────

[Name] — [Title]
Tenure: [how long at company]
Background: [where they came from, what they've built]
Likely priority in this interview: [what they're evaluating based on their role]

ONE SPECIFIC THING TO REFERENCE:
[A real detail from their background or the company's recent news that you can
work naturally into the conversation. Not a compliment — a connection.]

─────────────────────────────────────────────────────
YOUR TALKING POINTS FOR THIS COMPANY SPECIFICALLY
─────────────────────────────────────────────────────

Why this company (not just the role):
[1-2 sentences grounded in the research — something real, not "I admire your mission"]

The question they'll almost certainly ask — "Why us?":
[A coached answer using the research. Specific. Not generic.]

─────────────────────────────────────────────────────
5 QUESTIONS TO ASK — BASED ON THE RESEARCH
─────────────────────────────────────────────────────

[5 questions that signal you've done your homework. Each one grounded in
something from the research — a recent news item, a Glassdoor pattern,
a competitive dynamic, a product question.]

─────────────────────────────────────────────────────
RED FLAGS TO PROBE
─────────────────────────────────────────────────────

[Any signals from the research worth validating in the interview:
Glassdoor patterns, recent leadership changes, financial stress, competitive
pressure. Phrase these as questions, not concerns.]

─────────────────────────────────────────────────────
```

### Step 5 — Save output

Write to `outputs/interview-brief.md`.

Tell the user:
> Brief ready. Read it once through, then close it.
> The goal is to walk in knowing the material — not to reference notes.
> The one thing to remember: [the single most useful thing from the research]

## Tone

This is a preparation tool, not a flattery generator. If the Glassdoor reviews
are concerning, say so. If the company financials look shaky, flag it. The
candidate should walk into the interview with clear eyes — not just enthusiasm.

---

## ✅ What to do next

Read the brief once through, then close it.
Don't reference notes in the interview — know the material.

```
npm run interview     ← build story bank + coached answers
npm run mock          ← practice before the real thing
```
