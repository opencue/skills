# Network Message Generator

## What This Does

Writes context-aware messages to stay warm with your professional network
between job searches — not "just checking in" noise, but specific messages
people actually respond to.

The people who get calls before they need them are the ones who stayed
visible. This agent helps you do that without it feeling transactional
or awkward.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `rules/writing-rules.md`.

Ask the user:

```
Tell me about who you're reaching out to:

1. Who is this person? (role, company, how you know them)
2. How long since you've been in touch?
3. What's changed in your world since then?
4. Is there anything happening in their world you know about?
   (new role, company news, something they posted, conference, etc.)
5. What do you want from this interaction?
   - Stay warm (no ask)
   - Get their read on a company or role
   - Get introduced to someone
   - Get referred for a specific job
   - Reconnect before you start a search
```

Wait for their answers.

### Step 2 — Generate the right message

**If the goal is Stay Warm (no ask):**
- Lead with something specific to them — a post they made, news about their company, something they'd care about
- Share one genuine update about yourself — what you're working on or thinking about
- End with a low-friction question they'd enjoy answering
- 60-80 words max
- Medium: LinkedIn DM or email depending on relationship warmth

**If the goal is Get Their Read:**
- Brief context on what you're exploring
- One specific question that respects their time and expertise
- Make it clear you value their perspective, not their connections
- 80-100 words
- Email or LinkedIn depending on recency of relationship

**If the goal is Get an Introduction:**
- Be explicit about who you want to meet and why
- Give them the context they need to make the intro
- Make it easy — offer to write the intro email yourself
- 80-120 words
- Only ask if you have an established relationship

**If the goal is Get Referred:**
- Be direct about the specific role
- Tell them why you're a strong fit in one sentence
- Make it easy — link to the job, offer to send your resume
- Never put them in an awkward position — ask if they're comfortable, don't assume
- 80-100 words

**If the goal is Reconnect Before a Search:**
- Don't lead with "I'm looking"
- Reconnect genuinely first
- Only mention the search if the conversation goes there
- 60-80 words
- Follow up with the search context in a second message

### Step 3 — Write 2 versions

**Version A — LinkedIn DM** (shorter, more casual, no subject line)
**Version B — Email** (slightly more formal, needs subject line)

### Step 4 — Subject lines (email version)

Write 3 options:
- One referencing something specific to them
- One referencing a shared history or connection
- One direct and minimal

### Step 5 — Sequence guidance

If this is a cold reconnect after 1+ years:
Write a 2-message sequence:
- Message 1: Reconnect with no ask
- Message 2 (if they respond): The real purpose

### Step 6 — Save output

Write to `outputs/network-message.md`.

## ✅ What to do next

```
npm run send-email     ← send the message via Gmail
npm run referrals      ← if you want to find who to reach out to at a target company
npm run outreach       ← if this is a cold contact with no prior relationship
```

Apply all rules from `rules/writing-rules.md`.
