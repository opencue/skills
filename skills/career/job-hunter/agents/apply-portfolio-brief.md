# Portfolio Brief Builder

## What This Does

Turns a project you've worked on into a one-page brief that explains
what you did, why it mattered, and why it's relevant to the role you're
applying for.

For product managers, designers, marketers, engineers, and anyone in a
role where work samples or case studies are expected — this is what you
send alongside your resume to make the application tangible.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md` if available.
Read `rules/writing-rules.md`.

Ask the user:

```
Tell me about the project:

1. What was the problem you were solving? (1-2 sentences)
2. What was your specific role? Were you leading it, contributing to it, or both?
3. What did you actually do? (specific actions, not vague)
4. What was the outcome? (numbers if possible — revenue impact, time saved,
   users affected, conversion lift, whatever is measurable)
5. How long did this take?
6. What was the hardest part?
7. What would you do differently?

Optional:
8. Do you have any links, screenshots, or artifacts to reference?
9. Is there anything you can't share publicly? (IP, NDA)
```

Wait for their answers.

### Step 2 — Build the brief

Structure the brief in this exact format:

---

**[PROJECT TITLE]**
*[Role] · [Company] · [Year/Duration]*

---

**THE PROBLEM**
[2-3 sentences. What was broken, missing, or needed? Quantify the pain if possible — how many people affected, what it was costing, why it mattered now.]

**WHAT I DID**
[3-5 bullet points. Specific actions in past tense.
Action verb + what you did + who/what it affected.
No vague bullets: not "led cross-functional team" but
"partnered with 3 engineering leads and 2 designers to rebuild the
onboarding flow from scratch over 6 weeks."]

**THE OUTCOME**
[Quantified results. If you don't have exact numbers, give ranges or proxies.
"Reduced time-to-activate from 14 days to 3" is better than "improved onboarding."
"Contributed to $2M in pipeline in Q3" is better than "supported revenue growth."]

**WHAT I LEARNED**
[1-2 sentences. What would you do differently? This shows self-awareness
and makes the brief feel real rather than polished PR.]

---

### Step 3 — Relevance frame

If a target JD is available, add a short paragraph at the top:

**WHY THIS IS RELEVANT TO [ROLE]**
[2-3 sentences connecting this project directly to what the target role requires.
Be specific — if the JD asks for "cross-functional collaboration", point to it.
If it asks for "0-to-1 product experience", make that connection explicit.]

### Step 4 — Format guidance

Write a note to the user:

```
HOW TO USE THIS

For email applications:
  Attach as a PDF titled "[Your Name] — [Project Name] Case Study.pdf"
  Reference it in your cover letter: "I've attached a brief case study
  from my time at [Company] that's directly relevant to this role."

For portfolio sites:
  Use this as the written component. Add screenshots or links to the
  work itself. Keep the written brief exactly as-is — don't pad it.

For interviews:
  This is your "tell me about a project you're proud of" answer in
  written form. Know it cold. The interview version should match this.
```

### Step 5 — Save output

Write to `outputs/portfolio-brief.md`.

Tell the user:
> Portfolio brief ready. outputs/portfolio-brief.md
>
> Convert to PDF before sending.
> Keep it to one page. If it runs long, cut the What I Learned section
> and shorten the bullets.

## ✅ What to do next

```
npm run resume         ← tailor your resume to match the same language
npm run cover-letter   ← write the cover letter that references this brief
npm run ats            ← check ATS score with the tailored resume
```

Apply all rules from `rules/writing-rules.md`.
