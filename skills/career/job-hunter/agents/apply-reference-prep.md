# Reference Prep

## What This Does

Briefs your references so they say the right things for this specific role
— without coaching them to be dishonest.

Most candidates send their references a "heads up" email and hope for the
best. The difference between a reference that helps and one that hurts is
usually preparation. A reference who emphasizes the wrong project, misses
the key theme, or gets caught off guard on a weakness can cost you an
offer.

This agent builds a one-page brief for each reference: what the role needs,
which of your shared work to emphasize, the one thing to say unprompted,
and how to handle the hard questions.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md`.
Read `rules/writing-rules.md`.

Ask the user:

```
For each reference, tell me:

1. Name and title
2. Your relationship (direct manager, skip-level, peer, client, direct report)
3. How long and when you worked together
4. The top 2-3 projects or moments they witnessed firsthand
5. What they're most likely to say (their natural read of you)
6. Any concern — is there anything in your history with them that could come up?
```

Collect info for up to 3 references.

### Step 2 — Analyze the role requirements

From the JD, extract the 3-4 most important themes the hiring company
cares about. These become the lens for each reference brief.

Common themes: revenue impact, team leadership, cross-functional execution,
specific technical skills, cultural fit, growth trajectory.

### Step 3 — Write a brief for each reference

Format:

---

**REFERENCE BRIEF**
**For:** [Reference name] — [Title] — [Company]
**Prepared for:** [Role] at [Company]
**Your relationship:** [Summary]

---

**WHAT THIS ROLE CARES ABOUT**
[3-4 bullet points — the themes that will drive the reference call]

**PROJECTS TO EMPHASIZE**
For each relevant project or experience:

*[Project name or description]*
What they saw: [what the reference witnessed firsthand]
How to frame it: [exact language connecting it to what the role cares about]
The number or outcome to mention: [specific if available]

**THE ONE THING TO SAY UNPROMPTED**
[The single most important thing this reference should volunteer without
being asked — connected directly to the top requirement of this role]

**HOW TO HANDLE THE HARD QUESTIONS**

Likely hard questions:
- "What's their biggest weakness?"
- "Would you hire them again?"
- "Were there any performance concerns?"
- "Why did they leave?"

For each: coaching on how to answer honestly and helpfully.
A weakness that shows growth is better than no weakness.
"Would hire again" with a specific reason is better than a flat yes.

**WHAT NOT TO BRING UP**
[Anything from your shared history that is ambiguous, outdated, or
context-dependent — and doesn't serve this reference call]

**LOGISTICS**
- Reference check calls are typically 15-20 minutes
- Companies call within 24-48 hours of making the offer decision
- They will ask for context, not just yes/no answers
- They often take notes — be specific and memorable

---

### Step 4 — Write the heads-up email

Write the email to send each reference before they get called:

---

Subject: Reference call coming — a few minutes of context

[Name],

I'm in final stages for [role] at [company] and listed you as a reference.
You may get a call in the next few days.

A quick brief on what they're looking for and what would be most relevant
from our time together:

[2-3 sentences summarizing the role and the key themes]

The work I'd suggest highlighting most is [specific project] — particularly
[specific outcome or quality you want them to mention].

If they ask about [likely hard question], the honest answer is [honest
framing that works for both of you].

Thank you for doing this. It means a lot.

[Name]

---

### Step 5 — Save output

Write to `outputs/reference-prep.md`.

One file with briefs for all references.

Tell the user:
> Reference briefs ready. outputs/reference-prep.md
>
> Send the heads-up email to each reference today — not the day
> before the call. Give them a week to absorb it.

## ✅ What to do next

```
npm run counter        ← negotiate the offer while references are being checked
npm run follow-up      ← if you haven't heard back after references were given
```

Apply all rules from `rules/writing-rules.md`.
