# LinkedIn Content Generator

## What This Does

Writes 5 LinkedIn posts built around your real experience and target
positioning — posts that build credibility with the people who hire for
the roles you want.

Posting on LinkedIn during a job search increases inbound recruiter contact
meaningfully. But most job seeker LinkedIn content is either too generic
("5 lessons from my career") or too obviously desperate ("open to work —
DM me"). Neither builds authority.

This agent writes posts that demonstrate expertise, not availability. The
goal is to become recognizable to the right people before you need them.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md` if available — use target role as positioning lens.
Read `rules/writing-rules.md`.

Ask the user:

```
A few questions to write posts that sound like you:

1. What's the most counterintuitive thing you've learned in your career?
   Something most people in your field get wrong.

2. What's a story from your work that you find yourself telling a lot?
   The one you use when explaining what you do.

3. What do you know about [your industry/function] that took you years
   to figure out but seems obvious now?

4. What are you genuinely interested in right now — a trend, a problem,
   a debate in your field?

5. What's something you did that failed, and what did you actually learn?
   (not the polished failure story — the real one)
```

### Step 2 — Generate 5 posts

One post per type. Each one is based on their answers — not generic.

---

**POST TYPE 1 — The Counterintuitive Take**

Format: Lead with the counterintuitive claim. Explain why most people
think the opposite. 3-4 sentences of evidence or reasoning. One
practical implication.

Length: 150-200 words
Hook: Starts with the claim, not setup
Tone: Direct. Confident. Not preachy.
No: "In my experience..." "I've learned that..." "Here's the thing:"

---

**POST TYPE 2 — The Story Post**

Format: Open in the middle of the story (not "once upon a time").
Build to the insight. The lesson comes last — and it's one sentence.

Length: 200-250 words
Hook: First line is a moment, not a setup
Tone: Specific. Human. The reader should feel like they were there.
No: Emojis as bullets. Ellipsis cliffhangers. Manufactured suspense.

---

**POST TYPE 3 — The Hard-Won Insight**

Format: State the insight plainly. Back it with one specific example
from their career. Three implications, stated briefly.

Length: 150-175 words
Hook: The insight, stated as a declarative sentence
Tone: Earned authority. Not arrogant, but confident.
No: "I used to think X but now I know Y" (overused)

---

**POST TYPE 4 — The Industry Take**

Format: Name the debate or trend. Take a clear position.
One supporting argument. One honest acknowledgment of the counterargument.
Close with what you're watching.

Length: 175-225 words
Hook: The position, stated directly
Tone: Informed. Specific to their industry/function.
No: Fence-sitting. Generic observations. "It depends."

---

**POST TYPE 5 — The Useful Failure**

Format: What happened (briefly). What you thought you knew.
What actually happened. What you changed. One sentence on why it matters.

Length: 200-250 words
Hook: The moment it went wrong — specific
Tone: Self-aware without self-flagellation. The lesson should be useful,
not a confession.
No: "I failed and it was the best thing that ever happened to me" framing.
No: Vague lessons. The takeaway should be specific enough to be actionable.

---

### Step 3 — Posting strategy

Add a one-page strategy:

```
POSTING STRATEGY

Cadence: 2-3 posts per week during active search. 1 per week otherwise.
Best days: Tuesday, Wednesday, Thursday
Best time: 8-9am or 5-6pm in your target market's time zone

Post order (recommended):
Week 1: Counterintuitive Take (establishes POV)
Week 2: Story Post (builds trust)
Week 3: Hard-Won Insight (demonstrates depth)
Week 4: Industry Take (signals relevance)
Week 5: Useful Failure (earns credibility)
Repeat with fresh angles.

What to do after posting:
- Reply to every comment in the first hour
- Do not reply with "Thanks!" — add something to the conversation
- Connect with everyone who engages who might be relevant

What NOT to post:
- Anything about being "open to work" or "exploring new opportunities"
- Vague inspiration content: hustle culture, grind mindset, motivational quotes
- Anything with a poll that has no real stakes
- Job application status updates
```

### Step 4 — Profile optimization note

Add a brief note:
If their LinkedIn headline or About section doesn't match the target
positioning, flag it and suggest they run `npm run linkedin` first.

### Step 5 — Save output

Write to `outputs/linkedin-content.md`.

Tell the user:
> 5 posts ready. outputs/linkedin-content.md
>
> Post Type 1 first — it's the fastest way to establish a POV.
> Schedule them out, don't post all at once.
> The goal is recognition, not virality.

## ✅ What to do next

```
npm run linkedin       ← audit your profile before you start posting
npm run network        ← warm up specific contacts once you're posting
npm run referrals      ← leverage the visibility for warm intros
```

Apply all rules from `rules/writing-rules.md`.
No em dashes in any post. Posts should sound like a person talking, not writing.
