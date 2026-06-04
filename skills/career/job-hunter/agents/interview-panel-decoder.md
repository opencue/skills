# Interview Panel Decoder

## What This Does

Tells you what each person in a multi-stage interview is actually evaluating,
what their veto power looks like, and how to play each room differently.

Every interviewer in a process wants something different. The hiring manager
wants to know if you can do the job. The peer panel wants to know if they'll
like working with you. The skip-level wants to know if you'll create problems.
HR wants to know if you'll fit the comp band and culture. Playing all of
them the same way is why candidates who perform well technically still lose.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md`.
Read `inputs/interview-context.md` if it exists.
Read `outputs/interview-prep.md` if it exists.
Read `rules/writing-rules.md`.

Ask the user:
```
Tell me what you know about the interview process:

1. How many stages / rounds?
2. For each round: who is in it? (title, role, their relationship to this position)
3. What format? (video, phone, panel, case study, presentation, technical)
4. What have they told you to prepare for?
5. How long is each stage?
```

Wait for their answer.

### Step 2 — Decode each interviewer's agenda

For each interviewer or round, build a decoder:

---

**[ROUND N] — [Who's in the room]**

**Their hidden agenda:**
What this person actually cares about — not what they'll ask, but what they're
trying to figure out. Based on their title and relationship to the role.

**Their veto power:**
Can they kill your candidacy alone, or do they just provide input?
How much does their opinion weight in the final decision?

**What a YES looks like to them:**
The specific signal they're looking for. Not generic.

**What a NO looks like to them:**
What would make them vote against you — even if you're technically qualified.

**How to play this room:**
The specific adjustments to make for this interviewer's perspective.
Not a different person — a different emphasis.

**Questions they're likely to ask:**
3-5 questions this specific person (by title/role) typically asks.

**Questions you should ask them:**
2-3 questions specific to their perspective and level that will land well
with this person specifically.

---

### Step 3 — Common panel archetypes

Apply these profiles based on what the user tells you:

**The Hiring Manager**
Agenda: Can you do the job and will you make my life easier?
Veto power: Yes — usually final say
YES signal: Specific examples of doing the work. Numbers. Ownership.
NO signal: Vague answers, credit-sharing, no clear impact
Play: Lead with impact. Mirror their language from the JD.

**The Peer / Future Teammate**
Agenda: Will I enjoy working with this person? Will they make me look bad?
Veto power: Partial — strong peer rejections often kill candidates
YES signal: Collaborative examples. Giving credit. Asking for their input.
NO signal: Coming across as a know-it-all, minimizing others' contributions
Play: Be a peer, not a candidate. Ask them questions you genuinely want answered.

**The Skip-Level / Senior Leader**
Agenda: Is this person a cultural fit? Will they cause problems at scale?
Veto power: Rarely hard veto, but can delay or kill with influence
YES signal: Strategic thinking. Big picture. Awareness of how decisions affect others.
NO signal: Too tactical, can't zoom out, doesn't understand how the org works
Play: Demonstrate you think about the company, not just the job.

**HR / People Team**
Agenda: Comp fit. Cultural fit. References. Legal exposure.
Veto power: Rarely on competency — often on process, comp, or red flags
YES signal: Enthusiasm for the company specifically. No red flags on background.
NO signal: Comp misalignment, anything concerning in background check, attitude
Play: Be warm, be direct about comp expectations, don't overshare.

**The Technical / Functional Interviewer**
Agenda: Do you actually know what you claim to know?
Veto power: High in technical orgs — a technical no is usually fatal
YES signal: Depth. Specific examples. Admitting what you don't know.
NO signal: Surface-level answers, overconfidence on things you can't back up
Play: Be precise. Don't bluff. Say "I haven't used X but I'd approach it by..."

**The Case / Presentation Round**
Agenda: How do you think? How do you communicate under pressure?
Veto power: High — often a key differentiator at final stage
YES signal: Structured thinking. Clear assumptions. Direct recommendation.
NO signal: Trying to cover every angle without taking a position
Play: Recommend something. They want to see you make a call, not hedge.

### Step 4 — The process survival guide

Write a guide for this specific process:

```
YOUR PROCESS MAP

[Round 1]: [Who] — [What they want] — [How long] — [Key move]
[Round 2]: [Who] — [What they want] — [How long] — [Key move]
...

ACROSS ALL ROUNDS:
- The consistent thread to carry through every conversation
- The one thing NOT to change between rounds
- Red flags to watch for that tell you something is off

IF YOU GET TO FINAL ROUND:
- What the final decision usually comes down to
- The last impression that matters most
```

### Step 5 — Save output

Write to `outputs/panel-decoder.md`.

## ✅ What to do next

```
npm run mock           ← practice for the specific round you're most concerned about
npm run questions      ← build tailored questions for each interviewer
npm run research       ← pull deeper background on specific interviewers
npm run debrief        ← capture what actually happened after each round
```

Apply all rules from `rules/writing-rules.md`.
