# Follow-Up Generator

## What This Does

Writes the right follow-up message for the right stage at the right time.

Most candidates either never follow up or follow up wrong — too soon, too
desperate, too generic. This agent generates the exact message for your
specific situation: after applying, after a screen, after a final round,
or when you've heard nothing for too long.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md`.
Read `inputs/interview-context.md` if it exists.
Read `rules/writing-rules.md`.

Ask the user:
```
What stage are you following up from?
1. Applied but haven't heard back
2. After a phone screen / initial interview
3. After a final round interview
4. Waiting on an offer decision
5. Offer accepted — following up on start date / onboarding
6. Rejected — keeping the relationship warm
```

Wait for their answer. Then ask:
```
How long ago did the last contact happen?
```

### Step 2 — Generate the right follow-up

**Stage 1 — Applied, no response (7-14 days after applying)**

Goal: Get your application noticed without being annoying.
Tone: Confident, brief, adds value.
Do: Reference something specific about the company or role.
Don't: "Just checking in." "I wanted to follow up on my application."

Length: 50-70 words max.

**Stage 2 — After phone screen (24-48 hours after the call)**

Goal: Reinforce your interest and address anything that came up.
Tone: Warm, specific, forward-moving.
Do: Reference one specific thing from the conversation.
Do: Reiterate one concrete reason you're the right fit.
Don't: Repeat what was already said. Don't be effusive.

Length: 80-120 words.

**Stage 3 — After final round (24 hours after)**

Goal: Differentiate yourself one last time before the decision.
Tone: Confident, substantive.
Do: Address the hardest question they asked. Show you thought about it.
Do: Reference something specific about the company's direction or challenge.
Don't: "I think I'd be a great fit." Don't restate your resume.

Length: 100-150 words.

**Stage 4 — Waiting on offer decision (5+ business days, no word)**

Goal: Stay top of mind without pressure.
Tone: Calm, professional, one option offered.
Do: Mention if you have competing offers or a decision deadline (if true).
Don't: Express anxiety. Don't demand an update.

Length: 50-75 words.

**Stage 5 — Offer accepted, onboarding follow-up**

Goal: Confirm logistics, build relationship before day 1.
Tone: Warm, organized, enthusiastic without being cloying.
Do: Confirm start date. Ask one practical question. Express genuine excitement.

Length: 80-100 words.

**Stage 6 — After rejection**

Goal: Keep the door open. People move roles. Companies rehire.
Tone: Gracious, brief, no bitterness.
Do: Thank them genuinely for their time. Express continued interest in the company.
Do: Ask for feedback (they rarely give it but worth asking once).
Don't: Push back on the decision. Don't express disappointment directly.

Length: 60-80 words.

### Step 3 — Write 2 versions

Write two versions of the follow-up:
- **Version A** — Standard: appropriate for most situations
- **Version B** — Assertive: slightly more direct, use if you're competing for time

Label them clearly. Tell the user which to default to.

### Step 4 — Subject line

If email, write 3 subject line options:
- One referencing the role title
- One referencing a specific conversation point
- One direct and minimal

### Step 5 — Timing guidance

Tell the user exactly when to send:
- Best time: Tuesday-Thursday, 9-11am recipient's time zone
- Avoid: Monday AM, Friday PM, any time around major holidays
- If they don't respond: one more follow-up after 5 business days, then stop

### Step 6 — Save output

Write to `outputs/follow-up.md`.

## ✅ What to do next

```
npm run send-email     ← send the follow-up via Gmail
npm run interview      ← if they respond and want to move forward
npm run research       ← if a new interview is scheduled
```

Apply all rules from `rules/writing-rules.md`.
