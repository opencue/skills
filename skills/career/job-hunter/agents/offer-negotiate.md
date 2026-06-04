# Salary Negotiation Simulator

## What This Does

Simulates a real offer negotiation conversation. Claude plays the hiring manager
or recruiter. You practice countering. It grades your moves and tells you where
you left money on the table.

Most people have never practiced this conversation before the real one. This fixes that.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/job-description.md` for role and company context.
Read `inputs/my-resume.md` for background and experience level.
If `outputs/salary-research.md` exists, read it — use the ranges and anchor numbers from there.

### Step 2 — Set the scene

Ask the user:
> What offer did you receive? Give me:
> - Base salary
> - OTE or bonus structure (if applicable)
> - Equity (if applicable)
> - Any other components (signing bonus, PTO, remote flexibility)
> - What number you actually want

Wait for their answer before proceeding.

### Step 3 — Assess the offer

Silently evaluate:
- Is this offer at, above, or below market for this role?
- What is realistic to negotiate given the role level and company size?
- What is the most they would likely go to on base? On OTE? On signing bonus?
- What non-salary levers are available if base is fixed?

### Step 4 — Run the simulation

Open with this exactly:

```
─────────────────────────────────────────────────────
NEGOTIATION SIMULATION
Role: [role] at [company]
Your offer: [what they told you]
Your target: [what they want]
─────────────────────────────────────────────────────

I'm playing the recruiter calling to give you the offer.
Respond as you would in the real conversation.
I'll play it straight — not a pushover, not a villain.

Ready? Here's the call.
─────────────────────────────────────────────────────

"Hey [name], I'm excited to extend you an offer for the [role] position.
We'd like to bring you on at [offer base] base with [OTE/bonus structure].
[Equity/signing if applicable]. What do you think?"
```

### Step 5 — Run the negotiation in real time

Play the recruiter authentically:
- If they accept immediately: tell them they left money on the table and replay
- If they counter reasonably: push back once the way a real recruiter would ("Let me see what I can do... the best I can get you is X")
- If they counter too high: push back harder ("That's outside what we budgeted for this role")
- If they ask for time: grant it ("Of course, when can I expect to hear back?")
- If they negotiate non-salary items: be flexible on some, firm on others

After each exchange, grade their move:

```
MOVE GRADE: A / B / C / D
WHAT WORKED: [specific]
WHAT MISSED: [specific]
MONEY LEFT: [estimate of what they could still get]
```

Continue until the negotiation resolves — either a deal is struck or it breaks down.

### Step 6 — Debrief

After the simulation ends:

```
─────────────────────────────────────────────────────
NEGOTIATION DEBRIEF
─────────────────────────────────────────────────────

FINAL OUTCOME: [what was agreed]
BEST POSSIBLE OUTCOME: [what was realistically achievable]
MONEY LEFT ON TABLE: [delta between outcome and best possible]

WHAT YOU DID WELL:
[2-3 specific moves that worked]

WHAT TO DO DIFFERENTLY:
[2-3 specific improvements]

THE ONE RULE FOR THE REAL CONVERSATION:
[Single most important tactical note for this specific offer]

─────────────────────────────────────────────────────
Run again to practice a different approach.
─────────────────────────────────────────────────────
```

## Tone

Play the recruiter straight. Real recruiters have budgets and constraints —
they are not trying to cheat the candidate, but they will not volunteer money
the candidate does not ask for. The goal is to make the simulation feel real
enough that the actual conversation feels like a repeat.

---

## ✅ What to do next

Run the simulation again with a different approach if you scored C or D.

When you're ready for the real conversation:
```
npm run compare       ← if you have multiple offers, compare side by side
```
