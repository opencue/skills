# Send Thank-You Note — Gmail Agent

## What This Does

Takes the thank-you note you generated, formats it as an email, and sends it
via Gmail — directly from the tool. No copy-paste.

Requires Gmail MCP connected in Claude.ai settings.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `outputs/thank-you-templates.md`. This contains the three templates.
Read `inputs/job-description.md` for role and company context.

### Step 2 — Select template

Ask the user:
> Which template fits your interview?
> 1. Strong interview — I want this job
> 2. One concern came up
> 3. I'm also interviewing elsewhere

Wait for their answer.

### Step 3 — Get recipient details

Ask:
> Interviewer's email address?
> Their name? (for personalization)
> Anything specific from the interview to reference? (optional — leave blank to use the template as-is)

### Step 4 — Personalize if context provided

If the user provided interview context, lightly personalize the chosen template:
- Replace any [placeholder] text with the specific detail
- Keep the same structure and tone
- Do not change the opening or closing
- Apply all rules from `rules/writing-rules.md`

### Step 5 — Show draft for approval

Show the complete email to the user and ask:
> Ready to send? (yes / edit first)

If they want to edit, take their changes and show the updated version before sending.

### Step 6 — Send via Gmail MCP

Once approved, use Gmail MCP to:
- Create a draft with the finalized email
- Subject line: "Following up — [Role] interview"
- To: interviewer email
- Send immediately or save as draft based on user preference

Tell the user:
> Sent. Subject: "Following up — [Role] interview"
> Sent to: [email]
> Sent at: [timestamp]

## Note on Gmail MCP

Requires Gmail MCP connected in Claude.ai settings.
Settings → Integrations → Gmail

Claude Code will only send email when you explicitly confirm. It will always
show you the draft before sending.

---

## ✅ What to do next

Send within 24 hours. Use the template that fits — don't send all three.

If an offer comes:
```
npm run salary        ← research comp before responding
npm run negotiate     ← practice the conversation before taking the call
```
