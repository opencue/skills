<p align="center">
  <img src="web/logo.svg" alt="Job Hunter" width="600" />
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="MIT License" /></a>
  <a href="docs/CHANGELOG.md"><img src="https://img.shields.io/badge/version-1.0.0-green.svg" alt="Version 1.0.0" /></a>
  <a href="docs/CONTRIBUTING.md"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome" /></a>
</p>

> I searched for months and got nowhere. The turning point wasn't working harder — it was getting honest about what I was actually competitive for, and stopping the spray-and-pray. Then I built tools to sharpen every step of the process. Wrapped up the search in under two months. This is everything I learned, packaged so you don't have to figure it out the hard way.

---

## What is this?

Job Hunter is a free AI toolkit that helps you:

**Beat the filters before they beat you:**
- Bias audit scans your resume for the 8 signals that get you auto-rejected before a human sees your name
- Ghost job detector scores postings for fake or stale roles before you waste hours applying
- Skills gap filler tells you which JD requirements are real gates vs. recruiter wishlist — with a sprint plan to close the real ones
- ATS scanner catches what gets you filtered before it happens
- Rejection analyzer finds the pattern when you're not getting through

**Find and win the right roles:**
- Reality check gives your honest market tier. Fit scorer tells you if this specific role is worth your time.
- Company research covers financial health, hiring velocity, and leadership stability before you invest in applying
- Referral finder builds your warm path in — referrals convert at 3-5x cold applications
- Inbox monitor catches recruiter emails and drafts responses so you never miss a window

**Write applications that get through:**
- Tailored resume, cover letter, portfolio case study, reference briefs — all in the same voice
- Assessment prep for HireVue, take-homes, case studies, and technical screens

**Survive and win a 4-round interview process:**
- Panel decoder tells you what each interviewer actually wants and how to play each room differently
- Interview scorecard builds your personal criteria so you're evaluating them too
- Story bank, coached answers, live mock with grading, question bank, debrief after every round

**Handle offers without leaving money on the table:**
- Negotiate the conversation. Write the counter-offer. Manage competing deadlines. Compare side by side.

**Stay energized through a long search:**
- Weekly momentum check measures your real metrics against benchmarks — and tells you honestly when to take a day off

**It's free.** You bring an Anthropic API key (~$5 covers ~100 uses). Or use the [hosted version](#-just-want-to-use-it-no-setup) if you don't want to deal with any of that.

---

## Just want to use it? No setup.

A hosted version is coming. Star this repo to get notified when it launches.

---

## I want to set it up myself

### Option 1 — Open in browser (easiest self-hosted)

1. Download [`web/index.html`](web/index.html) from this repo (right-click → Save As)
2. Open it in any browser
3. When prompted, enter your Anthropic API key

**Getting an Anthropic API key:**
1. Go to **[console.anthropic.com](https://console.anthropic.com)** → sign up free
2. Go to **Billing** → add $5
3. Go to **API Keys** → Create Key → copy it

That's it. Paste, click, copy your output.

---

### Option 2 — Run locally with Node.js

```bash
# 1. Get the code
git clone https://github.com/owlguardco/job-hunter.git
cd job-hunter

# 2. Add your API key
cp .env.example .env
# Open .env in any text editor and paste your key after ANTHROPIC_API_KEY=

# 3. Start
npm start
```

Open **http://localhost:3000** in your browser. Same web UI, but prompts now load
from the local agent files — any edits you make to `agents/` take effect immediately.

---

### Option 3 — Terminal commands (power users)

```bash
git clone https://github.com/owlguardco/job-hunter.git
cd job-hunter
cp .env.example .env    # add your ANTHROPIC_API_KEY

# Not sure where to start?
npm run guide           # asks where you are and tells you what to run

# Or jump straight in
npm run ats             # scan your resume before applying
npm run resume          # tailor resume to a specific job
npm run interview       # build your interview prep guide
npm run mock            # practice with live grading
```

**All commands:**

| Stage | Command | What it does |
|---|---|---|
| **Reality Check** | `npm run reality-check` | Honest assessment of where you stand — what roles you'll actually win |
| | `npm run fit` | Score how competitive you are for a specific role before applying |
| **Apply** | `npm run linkedin` | Audit your LinkedIn profile |
| | `npm run portfolio` | Build a one-page project case study |
| | `npm run decode` | Decode a JD — red flags, real pay, subtext |
| | `npm run ats` | Scan resume for ATS issues before submitting |
| | `npm run resume` | Tailor resume to a specific role |
| | `npm run cover-letter` | Write a cover letter that sounds human |
| **Search** | `npm run jobs` | Search Indeed, LinkedIn, Glassdoor |
| | `npm run salary` | Research market comp |
| | `npm run company` | Deep company due diligence before pursuing |
| | `npm run referrals` | Find warm intro paths — who to contact and what to say |
| | `npm run follow-up` | Follow-up message for any stage |
| | `npm run outreach` | Cold message a recruiter |
| | `npm run inbox` | Scan Gmail for recruiter emails — flag urgent, draft responses |
| | `npm run send-email` | Send drafted responses via Gmail |
| **Interview** | `npm run research` | One-page company + interviewer brief |
| | `npm run interview` | Story bank + coached answers |
| | `npm run mock` | Live mock interview with grading |
| | `npm run questions` | 15 smart questions to ask — ranked by impact |
| | `npm run debrief` | Grade yourself right after the interview |
| **Offer** | `npm run negotiate` | Practice the negotiation conversation |
| | `npm run compare` | Compare two offers side by side |
| | `npm run send-thankyou` | Send thank-you via Gmail |
| **Career** | `npm run promote` | Build your promotion case |
| | `npm run network` | Stay warm with your network between searches |
| | `npm run review` | Prep for your performance review |
| | `npm run internal` | Apply for an internal role |

---

### Option 4 — Claude Code (developers)

```bash
git clone https://github.com/owlguardco/job-hunter.git
cd job-hunter
claude "follow agents/apply-resume.md"
```

Every file in `agents/` is a standalone prompt. No `.env` needed — Claude Code
uses its own API connection. See [CLAUDE.md](CLAUDE.md) for project conventions.

---

## The right order for a job application

```
reality-check ← do this once before anything else — know your actual market
fit           ← score this specific role before spending time on it
decode        ← understand the JD before doing anything else
ats           ← fix resume issues before tailoring
resume        ← tailor to this specific role
cover-letter  ← write the letter
```

If `fit` scores below 6 — stop. Find a better role with `npm run jobs`.
If `fit` scores 7 or above — continue down the pipeline.

## The right order for interview prep

```
research      ← pull the company brief the morning before
interview     ← build story bank + coached answers
mock          ← practice until you're scoring A's and B's
send-thankyou ← within 24 hours after the interview
```

---

## How it works

```
job-hunter/                        (main branch — open source)
│
├── CLAUDE.md                      project context for Claude Code sessions
├── README.md · LICENSE · server.js · package.json
│
├── agents/                        44 prompt files — one per tool
│   ├── apply-*   (14)             reality-check, fit-score, bias-audit, rejection-analysis,
│   │                              reference-prep, skills-gap-filler, assessment-prep,
│   │                              resume, cover-letter, ats-scan, decode-jd,
│   │                              portfolio-brief, linkedin-audit, linkedin-scrape
│   ├── search-*  (12)             jobs, salary, company-research, ghost-job-detector,
│   │                              referral-finder, follow-up, interview-scorecard,
│   │                              momentum-check, outreach, inbox-scan, send-email, tracker-update
│   ├── interview-* (6)            prep, mock, research, question-bank, debrief, panel-decoder
│   ├── offer-*   (6)              negotiate, counteroffer, deadline-manager,
│   │                              compare, schedule, thankyou
│   └── career-*  (6)              promote, review, internal, network-message, linkedin-content, linkedin-scanner
│
├── inputs/                        paste your stuff here (git-ignored)
│   ├── my-resume.md
│   ├── job-description.md
│   └── ...
│
├── outputs/                       results land here (git-ignored)
│
├── rules/
│   └── writing-rules.md           tone rules injected into every agent
│
├── web/
│   ├── index.html                 browser UI — standalone or via server
│   └── logo.svg
│
├── scripts/
│   ├── guide.js                   interactive first-run guide (npm run guide)
│   ├── preflight.js               validates inputs before running agents
│   └── job-search.py              JobSpy search (pip3.11 install jobspy)
│
├── examples/                      sanitized before/after examples
│
├── automation/                    Hermes + OpenClaw pipeline configs
│   ├── hermes-job-hunter.yaml
│   ├── pipeline-daily-search.md
│   └── pipeline-interview-prep.md
│
└── docs/
    ├── ONBOARDING.md              setup guide for all three paths
    ├── CHANGELOG.md
    ├── CONTRIBUTING.md
    ├── SECURITY.md
    ├── AUDIT.md
    ├── advanced-automation.md
    └── templates/
        └── JOB-TRACKER.md
```

```
job-hunter/                        (commercial branch — adds hosted layer)
│
├── everything in main, plus:
│
├── COMMERCIAL.md                  open core license stance
├── start.js                       entry point — routes open source vs commercial
├── railway.toml · Procfile        deployment configs
│
├── commercial/
│   ├── server/
│   │   ├── index.js               Clerk auth · Stripe billing · Postgres · 20+ API routes
│   │   ├── memory.js              Mem0 persistent memory layer
│   │   └── inbox.js               Gmail polling · classification · draft responses
│   ├── db/
│   │   ├── schema.sql             9 tables: users · credits · purchases · usage ·
│   │   │                          profiles · sessions · inbox_alerts · tracked_companies · audit_log
│   │   └── migrate.js
│   ├── web/
│   │   └── index.html             26-tool dashboard · landing · inbox monitor ·
│   │                              purchase modal · memory panel
│   └── .env.example
│
└── docs/
    ├── commercial-setup.md        Railway · Clerk · Stripe deployment guide
    └── legal/
        ├── privacy-policy.md
        ├── terms-of-service.md
        └── refund-policy.md
```

All three paths (browser, terminal, Claude Code) use the same `agents/` files.
Update a prompt once and it works everywhere.

---

## The rules engine

Every tool runs your output through [`rules/writing-rules.md`](rules/writing-rules.md)
before returning it. These rules exist because AI-generated job content has tells
that kill credibility with recruiters.

The short version: no em dashes, no "Hi", no "proven track record", no bullets
that start with "Responsible for." See the full list in the rules file.

---

## Automation (advanced)

Connect Hermes + OpenClaw to run Job Hunter on a schedule — new jobs scored
every morning, results in your Discord. See [docs/advanced-automation.md](docs/advanced-automation.md).

---

## Hosting it yourself commercially

Job Hunter is MIT licensed. The `commercial` branch contains a full
hosted version with Clerk auth, Stripe billing, Postgres, and Mem0 memory.

```bash
git checkout commercial
```

See [`COMMERCIAL.md`](https://github.com/owlguardco/job-hunter/blob/commercial/COMMERCIAL.md)
and [`docs/commercial-setup.md`](https://github.com/owlguardco/job-hunter/blob/commercial/docs/commercial-setup.md).

---

## Contributing

The most useful contributions:
- Writing rules from your own job search
- Sanitized before/after examples
- Agent prompt improvements with before/after evidence

See [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md).

---

## License

MIT — use it, fork it, build on it.
