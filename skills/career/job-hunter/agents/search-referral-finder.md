# Referral Finder

## What This Does

Builds a targeted outreach list for a specific role — people who can
get your resume in front of the hiring manager before it hits the ATS.

Referrals convert at 3-5x the rate of cold applications. Most candidates
skip this step because they don't know who to reach out to or what to say.
This agent finds the right people and writes the right message for each one.

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-description.md`.
Read `rules/writing-rules.md`.

Extract from the JD:
- Company name
- Role title and department
- Seniority level
- Key skills and tools mentioned

### Step 2 — Build the target list

Identify 5 types of people worth reaching out to for this specific role:

**Tier 1 — Highest conversion (contact first)**
1. Former employees of the company who now work elsewhere
   - They know the culture, the team, and can give you an honest read
   - They may still have relationships inside
   - Best found on LinkedIn: search "[Company] Alumni"

2. Current employees in the same department
   - Peer-level contact, not the hiring manager
   - Can refer you internally or at minimum answer questions about the role
   - Search LinkedIn: "[Company] + [Department/Role Title]"

**Tier 2 — Warm path**
3. People in your network who work at the company in any role
   - Even a weak tie is better than a cold application
   - Search your LinkedIn 1st and 2nd connections filtered by company

4. People who made the same career transition you're making
   - Someone who moved from your current role/company type to this type of role
   - They can tell you what the transition actually looks like and who helped them

**Tier 3 — Long shot but worth it**
5. The hiring manager (if identifiable)
   - Only reach out directly if you have a specific, compelling reason
   - Most effective when you can reference shared work, a specific project of theirs, or a mutual connection

### Step 3 — Write outreach messages

For each tier, write a message template tailored to this specific role and company.

**Format for each message:**

---
**[TIER] — [Who to target]**
**Find them:** [Specific LinkedIn search or method]
**What to say:**

[Message — 60-90 words max. No "Hi". No "I hope this message finds you well."
Lead with a specific, genuine reason for reaching out. Ask one clear question.
Never ask for a referral in the first message — build the relationship first.]

---

### Step 4 — Write the search strategy

Provide a step-by-step search playbook:

```
REFERRAL SEARCH PLAYBOOK
Company: [name]
Role: [title]
─────────────────────────────────────────

STEP 1 — LinkedIn search (do this first, 20 minutes)
[Specific search strings to use]

STEP 2 — Check your existing network
[Who to look for in 1st/2nd connections]

STEP 3 — Alumni networks
[Relevant schools, companies, or communities]

STEP 4 — Outreach sequence
Week 1: Contact Tier 1 targets (2-3 people)
Week 2: Follow up + contact Tier 2 (2-3 people)
Week 3: Follow up on warm responses
─────────────────────────────────────────

WHAT TO DO IF THEY RESPOND
[Specific guidance on how to move the conversation forward]

WHAT NOT TO DO
- Don't ask for a referral before building any relationship
- Don't message more than 3 people at the same company simultaneously
- Don't send the same message to multiple people
```

### Step 5 — Save output

Write to `outputs/referral-finder.md`.

Tell the user:
> Referral playbook ready. outputs/referral-finder.md
>
> Start with Tier 1. One warm intro from a former employee
> is worth 20 cold applications.

## ✅ What to do next

```
npm run outreach       ← write the cold message if no warm path exists
npm run decode         ← understand the role before reaching out
npm run fit            ← confirm this is worth your outreach effort first
```

Apply all rules from `rules/writing-rules.md` to all messages.
