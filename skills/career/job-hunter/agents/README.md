# Agents

19 prompt files — one per tool. Each one is a standalone instruction set
for Claude Code or the local server.

## How to run any agent

**Terminal (npm):**
```bash
npm run resume
npm run interview
# etc — see package.json for all commands
```

**Claude Code directly:**
```bash
claude "follow agents/apply-resume.md"
claude "follow agents/interview-mock.md"
```

**Via local server:**
```bash
npm start   # then use the web UI at http://localhost:3000
```

---

## apply-* — Job application tools

| File | Command | What it does |
|---|---|---|
| `apply-reality-check.md` | `npm run reality-check` | Honest market assessment — what tier you're in, what roles you'll win |
| `apply-fit-score.md` | `npm run fit` | Score a specific role 1-10 before applying — Apply / Don't Apply verdict |
| `apply-resume.md` | `npm run resume` | Tailor resume to a specific JD |
| `apply-cover-letter.md` | `npm run cover-letter` | Write a cover letter |
| `apply-ats-scan.md` | `npm run ats` | Scan for ATS issues |
| `apply-decode-jd.md` | `npm run decode` | Decode a JD — red flags, real pay, subtext |
| `apply-linkedin-audit.md` | `npm run linkedin` | Audit your LinkedIn profile |
| `apply-linkedin-scrape.md` | `npm run linkedin-scrape` | Scrape LinkedIn by URL (advanced) |
| `apply-portfolio-brief.md` | `npm run portfolio` | Build a one-page project case study |

**Run reality-check first — once. Then fit before every application.**

## search-* — Job search tools

| File | Command | What it does |
|---|---|---|
| `search-jobs.md` | `npm run jobs` | Search job boards |
| `search-salary.md` | `npm run salary` | Research market comp |
| `search-company-research.md` | `npm run company` | Deep company due diligence before pursuing |
| `search-referral-finder.md` | `npm run referrals` | Find warm intro paths and write outreach per tier |
| `search-follow-up.md` | `npm run follow-up` | Follow-up messages for every stage |
| `search-outreach.md` | `npm run outreach` | Cold message a recruiter |
| `search-inbox-scan.md` | `npm run inbox` | Scan Gmail for recruiter emails, flag urgent, draft responses |
| `search-send-email.md` | `npm run send-email` | Send drafted responses via Gmail MCP |

## interview-* — Interview prep tools

| File | Command | What it does |
|---|---|---|
| `interview-prep.md` | `npm run interview` | Story bank + coached answers |
| `interview-mock.md` | `npm run mock` | Live mock with real-time grading |
| `interview-research.md` | `npm run research` | Pre-interview company brief |
| `interview-question-bank.md` | `npm run questions` | 15 smart questions to ask — ranked and prioritized |
| `interview-debrief.md` | `npm run debrief` | Grade yourself right after the interview |

## offer-* — Offer and post-interview tools

| File | Command | What it does |
|---|---|---|
| `offer-negotiate.md` | `npm run negotiate` | Practice the negotiation conversation |
| `offer-counteroffer.md` | `npm run counter` | Write the actual counter-offer email |
| `offer-compare.md` | `npm run compare` | Compare two offers |
| `offer-schedule.md` | `npm run schedule` | Schedule interview via Google Calendar |
| `offer-thankyou.md` | `npm run send-thankyou` | Send thank-you via Gmail |

## career-* — Career growth tools

| File | Command | What it does |
|---|---|---|
| `career-promote.md` | `npm run promote` | Build your promotion case |
| `career-review.md` | `npm run review` | Prep for performance review |
| `career-internal.md` | `npm run internal` | Apply for an internal role |
| `career-network-message.md` | `npm run network` | Stay warm with your network |
| `career-linkedin-content.md` | `npm run linkedin-post` | 5 posts that build credibility — not hustle content |
| `career-linkedin-scanner.md` | `npm run linkedin-scan` | Scan LinkedIn for posts worth commenting on — draft, approve, post |

---

## Customizing agents

Every agent is plain markdown. Open any file and edit the instructions —
changes take effect on the next run. No rebuild needed.

The rules engine in `rules/writing-rules.md` is injected automatically
into every agent. You don't need to add it manually.
