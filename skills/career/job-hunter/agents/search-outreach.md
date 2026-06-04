# Recruiter Cold Outreach

## What This Does

Writes a cold message to a recruiter or hiring manager at a company you want
to work at — even when there's no open role posted. Harder than a cover letter
because there's no job description to anchor to. Most people either never send
these or send generic ones that get ignored.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md` for background and experience.
Read `inputs/search-outreach-target.md` for target company and contact details.
Read `rules/writing-rules.md`.

### Step 2 — Research the target

Use web search to find:
- What the company does and who they sell to / serve
- Recent news, funding, launches, or expansions (last 90 days)
- The contact's LinkedIn title and background (if name provided)
- Any job postings at the company that signal what teams are growing
  (even if not the exact role — hiring in sales means the sales team is growing)

### Step 3 — Find the angle

The angle is the single most specific reason this person should respond.
It must be one of:
- A mutual connection (strongest — always lead with this if it exists)
- A specific recent company event that connects to the candidate's background
- A specific problem the company likely has that the candidate has solved before
- A genuine specific reason for wanting this company over others

Generic angles ("I admire your company's mission") are not angles. They are
the reason cold messages get deleted.

### Step 4 — Write three versions

**Version 1 — LinkedIn message (300 characters max)**
LinkedIn has a character limit. This version is brutally short.
One sentence on who you are, one sentence on why you're reaching out, one ask.
No filler. No "I hope this message finds you well."

**Version 2 — Email (under 100 words)**
Slightly more room but still disciplined.
- Line 1: The angle — something specific, not generic
- Line 2-3: Who you are in one or two sentences with one number
- Line 4: The ask — specific and low-friction ("15 minutes" not "a meeting")
- No subject line clichés: not "Exploring Opportunities" not "Quick Question"
  Subject line should be specific: "Ex-HealthStream AE — interested in [Company]'s expansion into Southeast"

**Version 3 — Referral message (if a mutual connection exists)**
Shorter and warmer. Reference the mutual connection in line one.
Ask the mutual to forward or make an intro — not the target directly.

### Step 5 — What not to do

Flag any of the following if they appear in the drafts and rewrite:
- "I came across your profile and was impressed..."
- "I would love to connect..."
- "I am passionate about..."
- "I believe I would be a great fit..."
- Attaching a resume in a cold message (never do this — ask if they want it)
- Asking for a job in a cold message (ask for a conversation, not a job)

### Step 6 — Save output

Write all three versions to `outputs/cold-outreach.md` with context on when
to use each.

## Tone

The best cold messages read like they were written by a confident person who
did their homework — not a desperate job seeker. The goal is curiosity, not sympathy.

---

## ✅ What to do next

Send the message. Then:
```
npm run research      ← when they respond and book a call, prep the company brief
```
