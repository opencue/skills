# Promotion Case Builder

## What This Does

Builds the written case for your promotion. The hardest part of getting promoted
is articulating your own value in the language your manager needs to sell it
upstairs. Most people either undersell, ramble, or make it about tenure instead
of impact.

This agent builds the case your manager can take to their manager.

## Instructions for Claude Code

### Step 1 — Gather context

Ask the user for the following (collect all at once, not one at a time):

> To build your promotion case I need:
> 1. Your current title and the title you're targeting
> 2. How long you've been in your current role
> 3. Your top 5 accomplishments since your last review or promotion — with numbers where you have them
> 4. What your manager has said about your performance (informal feedback, review language, anything)
> 5. Who else might be considered for this promotion (if anyone) — no names needed, just context
> 6. What the biggest objection to promoting you might be
> 7. What company or team goal you've contributed to most directly

Wait for their answers before proceeding.

### Step 2 — Analyze the case

Silently assess:
- How strong is the accomplishment set? Does it demonstrate impact at the next level, or just doing the current job well?
- What is the likely objection and how strong is it?
- Is the timing right based on what they've shared?
- What framing will resonate most with a manager pitching this upstairs?

### Step 3 — Build the promotion document

Write a 1-page promotion case the user can share with their manager or use
to structure the conversation. Format:

```
PROMOTION CASE — [Current Title] → [Target Title]
[Name] | [Date]

THE ONE-LINE CASE:
[The single sentence that summarizes why this promotion is right, now.
Not "I've been here X years." Impact-based.]

IMPACT AT THE NEXT LEVEL:
[3-4 bullet points showing they're already operating at the target level.
Each bullet: specific accomplishment + quantified result + connection to
company or team goal. Past tense — things already done, not things they plan to do.]

WHAT CHANGES WITH THE TITLE:
[2-3 bullets on what expanded scope, responsibility, or ownership looks like.
This is the forward-looking section — brief.]

THE NUMBERS:
[A tight summary of quantified impact: revenue influenced, costs reduced,
team outcomes, customer metrics — whatever is most relevant and strongest.]

WHY NOW:
[1-2 sentences on timing. What has changed or been demonstrated recently
that makes this the right moment? Not "I've been patient." Something earned.]
```

### Step 4 — Talking points for the conversation

Write 5 talking points for the actual conversation with the manager:
- How to open it (not "I wanted to talk about my compensation")
- How to present the case without sounding like you're reading from a document
- How to handle the most likely objection
- How to ask directly without being aggressive
- How to close — what you're asking for and by when

### Step 5 — What to fix first

If the accomplishment set is weak or the case isn't ready yet, say so directly:
> "Your case isn't ready yet. Here's what you need before this conversation
> will land: [specific gaps]. Come back when you have [specific thing]."

Don't build a weak case. A bad promotion conversation is worse than no promotion
conversation.

### Step 6 — Save output

Write to `outputs/promotion-case.md`.

## Tone

Honest. If the case is strong, say so and build it. If it's not ready, say so
and explain why. Getting promoted requires making a real argument — not just
showing up and asking. This agent builds the real argument.

---

## ✅ What to do next

If the case is ready — schedule the conversation. Don't wait for review season.

If the case isn't ready yet — the agent told you what's missing. Go build it.
