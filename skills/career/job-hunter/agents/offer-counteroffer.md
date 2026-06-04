# Counter-Offer Builder

## What This Does

Builds a written counter-proposal — the actual document or email you send
back when you want to negotiate an offer.

The negotiation sim (`npm run negotiate`) is the practice conversation.
This is the artifact. A written counter changes the dynamic — it forces
clarity on both sides, reduces the chance of miscommunication, and signals
you're serious and organized.

Most candidates negotiate verbally and leave things vague. A written counter
with rationale for each ask is both more professional and more effective.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `outputs/salary-research.md` if it exists — use the comp data.
Read `rules/writing-rules.md`.

Ask the user:

```
Tell me about the offer you received:

1. Base salary offered
2. Bonus / OTE (if applicable)
3. Equity (options, RSUs — amount and vesting schedule if known)
4. Signing bonus
5. PTO and remote/hybrid policy
6. Start date
7. Any other notable terms

Then tell me:
8. What's your target base?
9. Is there anything non-salary that matters as much or more?
   (start date, remote flexibility, title, equity, signing bonus)
10. Do you have a competing offer or a current compensation anchor?
    (having a number to reference makes every ask stronger)
```

Wait for their answers.

### Step 2 — Build the counter strategy

Before writing anything, assess:

**LEVERAGE CHECK**
- Do they have a competing offer? (strong leverage)
- Are they a rare skill set for this role? (strong leverage)
- Is the company in growth mode or tightening mode? (from company research if available)
- How long has the role been open? (longer = more flexible)
- Is this a replacement hire or new headcount? (new headcount = harder to flex)

**WHAT TO ASK FOR vs. WHAT TO LET GO**
Rank each potential ask:
- Base salary (always ask — the primary number)
- Signing bonus (easier to grant than base — companies love one-time costs)
- Equity (depends heavily on company stage)
- Remote flexibility (often non-negotiable but worth asking)
- Title (sometimes easy, often meaningful for future comp)
- Start date (usually flexible)
- PTO (harder to flex at most companies)

Recommend: ask for 2-3 things, not everything. Prioritize the ones most
likely to be granted AND most valuable to this person.

### Step 3 — Write the counter

Format as a professional email:

---

**SUBJECT:** Re: [Role Title] Offer — [First Name]

[2-sentence opener — acknowledge the offer genuinely without being effusive.
Something specific about the opportunity. Not "I'm so excited."]

I'd like to explore whether there's room to adjust a few terms before I sign.

**Base Salary**
The offer is $[X]. Based on [comp research / market data / current comp],
I'm targeting $[Y]. I believe this reflects [1 specific reason — your
experience level, the market for this skill set, or the scope of the role].

**[Second ask if applicable]**
[Same format — specific ask, specific rationale. One sentence.]

**[Third ask if applicable — only if high confidence it's grantable]**
[Same format.]

These are my priorities. I'm not looking to nickel-and-dime — I want
to get to yes. If the base is genuinely fixed, I'd like to discuss
[signing bonus / additional equity / start date flexibility] as an
alternative.

[1-sentence close — reaffirm interest, give a reasonable timeline.]

[Name]

---

### Step 4 — Write the backup

Write a second version for if they come back with a partial yes:

**IF THEY MEET YOU HALFWAY:**
[Exact language for accepting a partial counter gracefully]

**IF THEY SAY THE NUMBER IS FIXED:**
[Language for pivoting to signing bonus or equity]

**IF THEY RESCIND THE OFFER:**
[This is extremely rare but worth noting — when to hold firm anyway]

### Step 5 — Anchoring language

Provide 3 specific phrases for the verbal conversation that follows
the written counter:
- One to open the negotiation call
- One to hold firm without creating friction
- One to close once you've reached agreement

### Step 6 — Save output

Write to `outputs/counteroffer.md`.

Tell the user:
> Counter-offer ready. outputs/counteroffer.md
>
> Send the email. Then be quiet. The next person to speak loses.

## ✅ What to do next

```
npm run negotiate      ← practice the conversation before the call
npm run compare        ← if you have multiple offers
npm run salary         ← if you need more comp data before sending
```

Apply all rules from `rules/writing-rules.md`.
