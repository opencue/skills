# Offer Comparison Tool

## What This Does

Compares two or more job offers side by side — beyond just the numbers.
Total compensation, growth trajectory, risk profile, culture signals, and
a recommended decision with honest reasoning.

Most people compare offers on base salary alone and miss the full picture.

## Instructions for Claude Code

### Step 1 — Gather offer details

Ask the user to provide details for each offer. Collect all at once:

> For each offer provide:
> - Company name and role title
> - Base salary
> - Bonus structure (target % or fixed amount)
> - OTE if sales role
> - Equity (options or RSUs — amount and vesting schedule if known)
> - Signing bonus (if any)
> - Benefits (health, 401k match, PTO)
> - Location / remote policy
> - Start date flexibility
> - Stage of company (startup / growth / public / enterprise)
> - Why you're excited about it
> - What concerns you about it

### Step 2 — Calculate total compensation

For each offer calculate:
- Year 1 total cash (base + signing bonus prorated + target bonus)
- Year 1 total comp (cash + equity year 1 value if determinable)
- Year 3 total cash (base assuming 5% annual raise + bonus)
- Year 3 total comp (cash + remaining equity)

Note assumptions made where data is missing.

### Step 3 — Score each offer across dimensions

Score each offer 1-10 on:

**Compensation** — total comp vs market rate for this role/location
**Growth trajectory** — where does this role lead in 2-3 years?
**Stability** — how likely is this company/role to exist in 2 years?
**Culture fit** — based on what the user shared about each company
**Learning** — will this role build skills that compound?
**Flexibility** — remote, hours, autonomy
**Upside** — equity, commission, promotion velocity

### Step 4 — The comparison

```
─────────────────────────────────────────────────────
OFFER COMPARISON
─────────────────────────────────────────────────────

                        [OFFER A]       [OFFER B]
Base                    $X              $X
Target bonus            $X              $X
OTE / total cash Y1     $X              $X
Equity Y1 value         $X              $X
Signing (prorated Y1)   $X              $X
TOTAL COMP YEAR 1       $X              $X
TOTAL COMP YEAR 3 est.  $X              $X

Compensation score:     X/10            X/10
Growth trajectory:      X/10            X/10
Stability:              X/10            X/10
Learning:               X/10            X/10
Upside:                 X/10            X/10

OVERALL SCORE:          X/10            X/10

─────────────────────────────────────────────────────
```

### Step 5 — The honest recommendation

Give a direct recommendation — not "it depends on your priorities."

State which offer to take and why. Then explain:
- The one thing that makes Offer A better than Offer B
- The one thing that makes Offer B better than Offer A
- The scenario in which the other choice would be right
- What to negotiate on the recommended offer before accepting

### Step 6 — What to negotiate before deciding

For the recommended offer, identify 2-3 things worth asking for before signing:
- What is likely moveable?
- What is the ask and how to make it?

### Step 7 — The question to sleep on

End with one honest question the user should sit with before deciding:
Something they may be glossing over or rationalizing — a real concern worth
examining before committing.

### Step 8 — Save output

Write to `outputs/offer-comparison.md`.

## Tone

Direct. Give a recommendation. "It depends" is not useful when someone is
deciding between two offers with a deadline. Make the call with the information
available and explain the reasoning clearly.

---

## ✅ What to do next

Sit with the recommendation overnight before deciding.
The question at the end is the one worth answering honestly.
