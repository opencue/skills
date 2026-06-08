# Schedule Interview — Calendar Agent

## What This Does

Creates a Google Calendar event for a scheduled interview with:
- Prep checklist in the description
- 1-hour reminder before the interview
- 24-hour post-interview reminder to send thank-you note
- 5-business-day follow-up reminder if no response

Requires Google Calendar MCP connected in Claude.ai settings.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/job-description.md` for role and company.
If `outputs/interview-prep.md` exists, read it for prep context.

### Step 2 — Get interview details from user

Ask the user:
> What date and time is the interview? (e.g. "Tuesday June 3rd at 2pm ET")
> Who are you interviewing with? (name and title if known)
> Is it phone, video, or in-person?
> Video link or dial-in number if applicable?

### Step 3 — Create main interview event

Use Google Calendar MCP to create an event with:
- Title: "Interview — [Role] at [Company]"
- Date/time: as provided
- Duration: 60 minutes (default)
- Location/link: video link or phone number if provided
- Description:

```
INTERVIEW PREP CHECKLIST

Before the interview:
☐ Review outputs/interview-prep.md
☐ Run the mock interview: npm run mock
☐ Research [Company] — recent news, funding, products
☐ Prepare 3 questions to ask the interviewer
☐ Confirm the video link / dial-in 30 minutes before
☐ Have your resume open in front of you

Key talking points from your prep:
[Pull the top 3 stories from outputs/interview-story-bank.md if it exists]

Interviewer: [name and title if provided]
```

- Reminder: 60 minutes before

### Step 4 — Create thank-you note reminder

Create a second calendar event:
- Title: "Send thank-you note — [Company] interview"
- Date/time: next day at 9am
- Description: "Run: npm run thankyou — Send within 24 hours of the interview"
- Reminder: at time of event

### Step 5 — Create follow-up reminder

Create a third calendar event:
- Title: "Follow up on [Company] interview if no response"
- Date/time: 5 business days after the interview at 10am
- Description: "If you haven't heard back, send one polite follow-up email."
- Reminder: at time of event

### Step 6 — Confirm to user

Tell the user:
> 3 calendar events created:
> - Interview: [date/time]
> - Thank-you reminder: [date] at 9am
> - Follow-up reminder: [date] at 10am
>
> Your prep guide is in outputs/interview-prep.md
> Run `npm run mock` before the interview.

## Note on Google Calendar MCP

This agent requires the Google Calendar MCP to be connected in your Claude.ai
settings (Settings → Integrations → Google Calendar). The MCP must be enabled
for Claude Code to access it.

If not connected, Claude Code will prompt you to connect it.

---

## ✅ What to do next

```
npm run research      ← pull the company + interviewer brief
npm run interview     ← build your prep guide
npm run mock          ← practice before the real thing
```
