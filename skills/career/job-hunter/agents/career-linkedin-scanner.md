# LinkedIn Post Scanner

## What This Does

Scans your LinkedIn feed for posts worth commenting on — people talking
about job market struggles, hiring, layoffs, bad interview experiences,
resume tips, career pivots — and drafts a genuine comment for each one.

You review every comment before it goes anywhere. Nothing posts automatically.
The automation is in the finding and drafting. The judgment is yours.

One well-placed comment from the person who built a job search tool,
on a post with 500 likes, reaches more people than a cold post of your own.

## Prerequisites

LinkedIn MCP connected in Claude.ai settings:
**Settings → Integrations → LinkedIn**

Or use the LinkedIn scraper MCP:
```bash
uvx linkedin-scraper-mcp@latest --login
```

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md` for your background context.
Read `rules/writing-rules.md`.

Ask the user:
```
A few quick questions:

1. What's your LinkedIn profile URL?
   (so the comment sounds like you specifically)

2. What's the one-line description of Job Hunter you want to use?
   (e.g. "I built a free open source job search toolkit — jobhunter.ai")

3. Any topics to avoid commenting on?
   (e.g. specific companies, political topics, anything sensitive)
```

Wait for their answers.

### Step 2 — Define search targets

Look for posts matching these signals — high engagement, relevant topic,
comment window still open (under 48 hours old is ideal):

**Primary targets — highest value:**
- Posts about job market difficulty ("can't get callbacks", "100 applications")
- Posts about recruiter behavior (ghosting, ghost jobs, bias)
- Posts about resume and ATS struggles
- Posts about interview processes being too long
- Posts from recruiters giving job search advice (like the screenshot above)
- Posts about layoffs and career pivots
- Posts asking for resume feedback or job search advice

**Secondary targets — worth engaging:**
- Posts about LinkedIn optimization
- Posts about salary negotiation
- Posts about career growth and promotion
- Posts from hiring managers explaining their process

**Skip:**
- Anything political
- Posts from direct competitors
- Posts where top comments are already from tools/bots (signals low quality engagement)
- Posts older than 72 hours (engagement window mostly closed)
- Any topic the user said to avoid

### Step 3 — Scan the feed

Use LinkedIn MCP to:
1. Pull the user's home feed (last 24-48 hours)
2. Search LinkedIn for recent posts using these queries:
   - "job search" + high engagement filter
   - "job market" + recent posts
   - "resume" OR "ATS" + recruiter posts
   - "interview process" + frustration signals
   - "layoff" OR "laid off" + recent
   - "hiring" + recruiter perspective

For each post found, extract:
- Author name and title
- Post text (full)
- Engagement count (likes + comments)
- Posted time
- Post URL

### Step 4 — Score and filter

Score each post on 3 dimensions:

**Relevance (1-5):** How directly relevant is Job Hunter to this post?
- 5: Post is exactly about the problem Job Hunter solves
- 4: Adjacent topic where Job Hunter adds clear value
- 3: Tangentially related
- 1-2: Too far, skip

**Reach (1-5):** How many people will see this comment?
- 5: 500+ likes or the poster has 10k+ followers
- 4: 200-500 likes or 5k-10k followers
- 3: 100-200 likes
- 1-2: Under 100, skip (not worth the effort)

**Comment window (1-5):** Is there still time for the comment to get traction?
- 5: Under 6 hours old
- 4: 6-24 hours old
- 3: 24-48 hours old
- 1-2: Over 48 hours, skip

**Total score: 3-15. Surface anything scoring 9+.**

### Step 5 — Draft comments

For each qualifying post (score 9+), draft 2 comment options:

**Comment style rules:**
- 2-4 sentences maximum — LinkedIn comments reward brevity
- First sentence must add something specific to the conversation
- Not "Great post!" or "This is so true" — both are noise
- Reference something specific from the post text
- Mention Job Hunter naturally — not as an ad, as a genuine contribution
- Sound like a person who built something to solve this exact problem
- Never start with "Hi" or "I" as the first word
- No em dashes

**Option A — Contribution style:**
Add a specific insight or data point that extends the conversation,
then mention Job Hunter as context for why you know this.

*Example:*
"The ghost job problem is worse than most people realize — postings stay up
for months after hiring freezes because no one removes them. Built a ghost
job detector into an open source tool (jobhunter.ai) after getting burned
by this multiple times. Eight signals worth checking before you spend hours
tailoring an application."

**Option B — Solidarity + resource style:**
Acknowledge the specific frustration from the post, then offer
Job Hunter as a direct resource.

*Example:*
"100 applications, 2 callbacks — that math usually means the ATS is
filtering before a human sees the resume. Built a free tool specifically
for this after going through the same thing. jobhunter.ai if it's useful."

### Step 6 — Present for approval

Present each qualifying post and its draft comments in this format:

```
─────────────────────────────────────────────────────
POST [n] — Score: [X]/15
─────────────────────────────────────────────────────
Author: [Name] — [Title]
Posted: [X hours ago]
Engagement: [likes] likes · [comments] comments
URL: [url]

POST SUMMARY:
[2-3 sentence summary of what they said]

OPTION A — Contribution style:
─────────────────────
[Draft comment]
─────────────────────

OPTION B — Solidarity + resource style:
─────────────────────
[Draft comment]
─────────────────────

→ Use A / Use B / Edit / Skip
─────────────────────────────────────────────────────
```

Go through posts one at a time. Wait for the user's decision before
showing the next one.

### Step 7 — Approved comments queue

Keep a running list of approved comments:

```
APPROVED COMMENTS — Ready to post
─────────────────────────────────────────────────────
[n] comments approved

1. [Author] — [Post URL]
   [Approved comment text]
   [ ] Posted

2. [Author] — [Post URL]
   [Approved comment text]
   [ ] Posted
```

### Step 8 — Post queue

When the user has finished reviewing all posts, show the approved queue
and offer two paths:

**Path A — Post via LinkedIn MCP (if connected):**
"Ready to post [n] comments. Post them now? (yes / one at a time / save for later)"

If yes: post each approved comment via LinkedIn MCP to the correct thread.
Mark each as posted.

**Path B — Manual posting guide:**
If LinkedIn MCP isn't available for posting, generate a posting guide:
```
MANUAL POSTING GUIDE

For each comment below:
1. Open the URL
2. Click Comment
3. Paste the text
4. Post

[numbered list with URL + comment text]
```

### Step 9 — Save output

Write approved comments and status to `outputs/linkedin-scanner.md`.
Append each session — don't overwrite — so you build a record.

Tell the user:
> Scan complete. [n] posts found, [n] qualifying, [n] approved.
> [If posted:] [n] comments posted.
> [If manual:] Manual posting guide saved to outputs/linkedin-scanner.md

## Posting frequency guidance

```
SUSTAINABLE CADENCE

3-5 meaningful comments per day is enough to build real visibility.
More than 10/day starts to look like a bot — even when it isn't.

Best times: 8-10am and 5-7pm in your target market's time zone.
Best days: Tuesday through Thursday.

Track which comment styles get replies — those are the ones to do more of.
A comment that starts a real conversation is worth 10 that get ignored.
```

## ✅ What to do next

```
npm run linkedin-post  ← write original posts for your own feed
npm run linkedin       ← audit your profile so new visitors convert
npm run network        ← direct outreach to people who engage with your comments
```

Apply all rules from `rules/writing-rules.md`.
No em dashes in any comment. Sound like a person.
