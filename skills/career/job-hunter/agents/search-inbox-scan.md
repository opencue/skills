# Inbox Scanner — Job Search Email Monitor

## What This Does

Scans your Gmail for emails from companies you've applied to, flags anything
that needs a response, drafts replies ready to review and send.

Recruiters send emails with short windows. A reply that comes 3 hours after
they reach out is very different from one that comes 3 days later.
This agent makes sure you never miss the window.

## Prerequisites

Gmail MCP must be connected in your Claude.ai settings:
**Settings → Integrations → Gmail**

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md` for background context.
Read `JOB-TRACKER.md` or `outputs/job-shortlist.md` if they exist —
these contain the companies you've applied to or are tracking.

### Step 2 — Parse tracked companies

Extract a list of company names and domains from:
- `JOB-TRACKER.md` — Active Pipeline table (Company column)
- `outputs/job-shortlist.md` — any companies in the shortlist

If neither file has content, ask the user:
> Paste a list of companies you've applied to or are tracking (one per line):

Build a list of company names and likely email domains
(e.g. "Veeva Systems" → `veeva.com`, `Salesforce` → `salesforce.com`).

### Step 3 — Scan Gmail

Use Gmail MCP to search for recent emails from tracked companies.

Run these searches in order:

**Search 1 — Direct recruiter outreach**
Query: `from:(recruiter OR talent OR hiring OR careers OR noreply) newer_than:14d`
Limit: 50 results

**Search 2 — Company domain matches**
For each tracked company domain, search:
Query: `from:*@[domain] newer_than:30d`
Limit: 10 per company

**Search 3 — Application status**
Query: `subject:(application OR interview OR opportunity OR position OR role) newer_than:30d`
Limit: 30 results

Deduplicate results across all three searches by thread ID.

### Step 4 — Classify each email

For each email found, classify it:

| Type | Description | Urgency |
|---|---|---|
| **RECRUITER OUTREACH** | Recruiter reaching out about a role | 🔴 HIGH — respond within 24hr |
| **INTERVIEW INVITE** | Request to schedule an interview | 🔴 HIGH — respond same day |
| **APPLICATION STATUS** | Update on an application | 🟡 MEDIUM — review, may need reply |
| **OFFER / NEXT STEPS** | Offer letter or next steps request | 🔴 HIGH — respond same day |
| **REJECTION** | Application declined | ⚪ LOW — no reply needed |
| **AUTO-CONFIRM** | Automated application receipt | ⚪ LOW — no action needed |
| **FOLLOW-UP NEEDED** | You haven't replied in 48+ hours | 🔴 HIGH — draft reply now |

Flag any email older than 48 hours that hasn't been replied to as
**FOLLOW-UP NEEDED** regardless of original type.

### Step 5 — Draft responses

For every HIGH urgency email, draft a response.

**For RECRUITER OUTREACH:**
- Express genuine interest (not "I'm excited" — that's a tell)
- Reference the specific role if mentioned
- Propose 2-3 specific time slots for a call in the next 48 hours
- Keep it under 100 words
- Apply all rules from `rules/writing-rules.md`

**For INTERVIEW INVITE:**
- Confirm availability immediately
- If times given don't work, propose alternatives the same day
- Include any prep questions if appropriate (role details, format, who attending)
- Under 80 words

**For OFFER / NEXT STEPS:**
- Acknowledge receipt
- Ask for 24-48 hours to review if needed
- Do not negotiate in email — that happens on a call
- Under 60 words

**For FOLLOW-UP NEEDED (you haven't replied):**
- Acknowledge the delay briefly without over-apologizing
- Re-engage with genuine interest
- Propose next steps
- Under 100 words

### Step 6 — Write the inbox report

Write `outputs/inbox-scan.md` with this structure:

```
INBOX SCAN REPORT
Scanned: [date and time]
Companies tracked: [n]
Emails found: [n] | Action required: [n]

─────────────────────────────────────────────────────

🔴 HIGH PRIORITY — RESPOND NOW
─────────────────────────────────────────────────────

[For each high-priority email:]

FROM: [sender name and email]
COMPANY: [company name]
SUBJECT: [subject line]
RECEIVED: [time ago — e.g. "3 hours ago", "2 days ago"]
TYPE: [classification]

SUMMARY:
[2-3 sentence summary of what they said]

DRAFTED RESPONSE:
─────────────────────────────────────
[full drafted response ready to copy]
─────────────────────────────────────

─────────────────────────────────────────────────────

🟡 REVIEW — MAY NEED RESPONSE
─────────────────────────────────────────────────────

[For each medium-priority email:]
FROM / SUBJECT / RECEIVED / SUMMARY
[Draft response if reply is warranted]

─────────────────────────────────────────────────────

⚪ NO ACTION NEEDED
─────────────────────────────────────────────────────
[List: rejections, auto-confirms — company, subject, date]
```

### Step 7 — Summary

Tell the user:
> Inbox scan complete.
> 🔴 [n] emails need a response now
> 🟡 [n] emails to review
> ⚪ [n] no action needed
>
> Full report: outputs/inbox-scan.md
>
> To send any of the drafted responses:
>   npm run send-email    ← opens Gmail MCP sender

If there are HIGH priority emails, show the first drafted response
immediately in the terminal so the user can act on it without opening a file.

## Running

```bash
npm run inbox
```

Or directly:
```bash
claude "follow agents/search-inbox-scan.md"
```

## ✅ What to do next

```
npm run send-email     ← send a drafted response via Gmail
npm run research       ← if an interview is scheduled, pull the company brief
npm run interview      ← if a screening call is coming up, build prep guide
npm run schedule       ← add the interview to your calendar
```

## Tone

Responses should sound like a person who is interested but not desperate.
Specific beats generic. Prompt replies signal respect for the recruiter's time.
Never start with "Hi" or "Thank you for reaching out" — both are tells.

Apply all rules from `rules/writing-rules.md` to all drafted responses.
