# Weekly Momentum Check

## What This Does

Your weekly check-in. Measures what's actually working, flags what isn't,
and tells you honestly whether you're making progress — or burning out.

Job searching feels like failure by default because rejection is the
default response. This agent replaces that feeling with evidence. Your
callback rate, your funnel metrics, your patterns — measured against what's
actually normal so you know where you stand, not where anxiety says you stand.

Run this every Friday. It takes 10 minutes and changes how the weekend feels.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `outputs/job-tracker.md` if it exists.
Read `outputs/rejection-analysis.md` if it exists.
Read `rules/writing-rules.md`.

Ask the user:
```
Quick rundown of your week — don't overthink it, just tell me:

1. Applications submitted this week (number + types: targeted / cold ATS / referral)
2. Responses received (callbacks, rejections, anything)
3. Interviews or conversations that happened
4. Anything that moved forward (second rounds, final rounds, offers)
5. How many hours did you spend on the search this week?
6. Honest: how are you feeling right now? (1 word or a sentence — either is fine)
```

Wait for their answer.

### Step 2 — Calculate the real metrics

**Callback rate this week:**
Responses ÷ Applications submitted (this week)

**Cumulative callback rate (if tracker data available):**
Total responses ÷ Total applications

**Industry benchmarks:**
- Cold ATS applications: 2-8% callback rate is normal
- Targeted applications (tailored + researched): 10-20% is good
- Referral applications: 30-50% callback rate
- LinkedIn Easy Apply: 1-3% (if it's your primary method, this is why)

Compare their actual rate to benchmark. Be honest about what it means.

**Funnel health:**
- Applied → Response: [their rate] vs. benchmark
- Response → Interview: [if data available]
- Interview → Offer: [if data available]

### Step 3 — The honest assessment

Write a plain, honest paragraph. Not cheerful. Not crushing. True.

If they're performing well:
Say so specifically. "Your targeted application rate is 15%. That's above
average. The referral you got for [company] converting to a screen means
the referral strategy is working. Keep doing that."

If they're struggling:
Name the specific problem. "Your cold ATS callback rate is 2%. That's
consistent with industry average for cold apps, which means the method
is the problem, not the resume. Shifting 50% of your effort to referrals
would likely double your callback rate."

If the data is too thin to say anything useful:
"You have 8 applications total. That's not enough data to find a pattern.
The goal is 15-20 targeted applications before drawing any conclusions
about what's working."

### Step 4 — The week's wins

Write this section no matter what the metrics say.

Pull out specifically what went right this week — not vague encouragement,
evidence of real progress:

```
THIS WEEK'S ACTUAL WINS

[List 2-5 specific things — they may feel small but they are real:]

- Got a callback from [company type] = your resume is landing with this audience
- Made it through a phone screen = you can get past the first filter
- Found a warm intro path = you have an application that won't go into a black hole
- Completed your mock interview = you're more prepared than you were Monday
- Sent a follow-up = most candidates don't do this
- Identified a pattern in your rejections = that's intelligence, not failure
- Applied to one fewer spray-and-pray role = that's strategy
```

The goal is not to minimize hard things. It's to make real things visible
that anxiety makes invisible.

### Step 5 — The burnout check

Based on their hours and how they said they're feeling:

**If they're overworking (8+ hours/day on the search):**
```
YOU ARE DOING TOO MUCH

More applications does not mean more offers. The research is clear:
quality beats quantity by a significant margin. 10 targeted applications
outperform 100 cold ones.

Next week: cap your search at 4 hours/day. Use the rest for things that
restore you. You will not perform well in interviews when you're depleted.
```

**If they sound burnt out:**
```
THIS IS A REAL THING

76% of job seekers experience significant stress. 45% report burnout symptoms.
You are not unusual. You are not weak. You are human doing a hard thing.

Two things that are true simultaneously:
1. The search requires consistent effort
2. You cannot sustain consistent effort without rest

This week: take one full day off from the search. No applications,
no LinkedIn, no email checking. You will come back sharper.
The roles will still be there.
```

**If they're pacing well:**
```
YOUR PACING IS SUSTAINABLE

You're putting in enough effort to make progress without burning out.
That's harder than it sounds. Keep the rhythm.
```

### Step 6 — Next week's focus

Write 3 specific actions for next week — not a long list, just 3:

```
NEXT WEEK: THREE THINGS

1. [Most important — based on what's working or what needs to change]
2. [Second priority]
3. [One thing to protect your energy or momentum]
```

### Step 7 — The closing note

Always end the momentum check with this (vary the wording, keep the message):

```
ONE MORE THING

A job search is not a performance review of your worth.

The hiring process has structural barriers, random timing, and biases
that have nothing to do with your competence. Getting filtered by an
AI screener is not a verdict on your value. Getting ghosted by a
recruiter is not a measure of your potential. Getting rejected after
a final round is not proof that you're not good enough.

It is a process with noise in it. Your job is to navigate it with
strategy and patience, not to internalize every outcome as signal
about who you are.

You are making progress. It doesn't always feel like it.
Keep going.
```

### Step 8 — Save output

Write to `outputs/momentum-check.md`.
Append to the file — don't overwrite — so you build a weekly record.

Tell the user:
> Momentum check complete. Week of [date] logged.
> [1-line summary of their actual status]

## ✅ What to do next

```
npm run tracker        ← update your pipeline with this week's activity
npm run rejection      ← if callback rate is consistently below 5%
npm run referrals      ← if most applications are cold ATS
```

Apply all rules from `rules/writing-rules.md`.
