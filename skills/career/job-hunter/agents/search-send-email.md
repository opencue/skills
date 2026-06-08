# Send Email — Job Search Response Sender

## What This Does

Takes a drafted response from the inbox scan and sends it via Gmail MCP.
Always shows you the draft before sending — never sends without confirmation.

## Prerequisites

Gmail MCP connected in Claude.ai settings.

## Instructions for Claude Code

### Step 1 — Load drafted responses

Read `outputs/inbox-scan.md`. Find all DRAFTED RESPONSE sections.

If the file doesn't exist or has no drafts, tell the user:
> Run `npm run inbox` first to scan for emails and generate drafts.

### Step 2 — Present options

List all available drafted responses:

```
Available drafted responses:

1. Re: [subject] → [recipient] ([company])
2. Re: [subject] → [recipient] ([company])
...

Which would you like to send? (enter number, or 'all' for all HIGH priority)
```

Wait for the user's answer.

### Step 3 — Show draft for approval

Show the complete draft:

```
─────────────────────────────────────────────────────
TO:      [email address]
SUBJECT: Re: [original subject]
─────────────────────────────────────────────────────
[draft body]
─────────────────────────────────────────────────────

Send this? (yes / edit / skip)
```

If they say **edit**: ask what to change, update the draft, show again.
If they say **skip**: move to next draft.
If they say **yes**: proceed to send.

### Step 4 — Send via Gmail MCP

Use Gmail MCP to:
1. Find the original thread by message ID or subject
2. Create a draft reply to that thread
3. Send the draft

Tell the user:
> Sent to [name] at [company]
> Subject: Re: [subject]
> Sent at: [timestamp]

### Step 5 — Log the send

Append to `outputs/inbox-scan.md`:

```
─────────────────────────────────────────────────────
SENT: [timestamp]
To: [recipient]
Subject: Re: [subject]
─────────────────────────────────────────────────────
```

### Step 6 — Next steps

After all sends:
> All responses sent.
>
> If any of these lead to an interview:
>   npm run research    ← company + interviewer brief
>   npm run interview   ← story bank + coached answers
>   npm run schedule    ← add to calendar

## Running

```bash
npm run send-email
```

## Tone

Do not change the tone or content of drafted responses without the user
explicitly asking for edits. The drafts were written by the inbox scanner
with the right tone already applied.

## ✅ What to do next

```
npm run research    ← if an interview is scheduled, pull the company brief
npm run interview   ← build story bank + coached answers
npm run schedule    ← add the interview to your calendar
npm run mock        ← practice before the real thing
```
