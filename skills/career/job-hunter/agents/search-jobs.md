# Job Search Agent

## What This Does

Searches for live job postings across Indeed, LinkedIn, Glassdoor, and other
platforms using JobSpy MCP. Scores each posting against your resume and outputs
a ranked shortlist with match scores and recommended next steps.

## Prerequisites

JobSpy MCP server installed:
```bash
pip install jobspy-mcp-server
```
(Requires Python 3.10+.)

Or via Docker (recommended fallback — works on any Python version):
```bash
docker run -p 9423:9423 borgius/jobspy-mcp-server
```

## Instructions for Claude Code

### Step 1 — Load inputs

Read `inputs/my-resume.md`.
Read `inputs/job-search-criteria.md`. This contains the user's search preferences.
Read `rules/writing-rules.md`.

### Step 2 — Start JobSpy MCP server

First check if a server is already running:
```bash
curl -s http://localhost:9423/health && echo "SERVER ALREADY UP"
```

If not running, try to start locally:
```bash
python3 -m jobspy_mcp_server --port 9423 &
MCP_PID=$!
sleep 3
curl -s http://localhost:9423/health && echo "SERVER UP" || echo "SERVER DOWN"
```

If the local server does not start, try Docker:
```bash
docker run -d -p 9423:9423 --name jobspy-mcp borgius/jobspy-mcp-server
sleep 5
curl -s http://localhost:9423/health && echo "DOCKER SERVER UP" || echo "DOCKER SERVER DOWN"
```

If neither is available, tell the user to install JobSpy MCP first (see Prerequisites)
and stop here.

### Step 3 — Parse search criteria

From `inputs/job-search-criteria.md` extract:
- Role titles to search (may be multiple)
- Locations (city, state, or remote)
- Keywords to include
- Keywords to exclude
- Date posted preference (last 7 days default)
- Full-time vs contract preference

### Step 4 — Execute searches

Use the JobSpy MCP server at `http://localhost:9423` to search for jobs.
Run one search per role title. Collect all results.

For each search, use these parameters:
- search_term: role title
- location: from criteria
- results_wanted: 20
- hours_old: 168 (7 days)
- site_name: ["indeed", "linkedin", "glassdoor"]

### Step 5 — Score each posting against resume

For each job posting returned, score it 1-10 against the resume on:
- Title match (does the role title align with the user's background?)
- Keyword overlap (how many JD keywords appear in the resume?)
- Experience level match (seniority alignment)
- Industry match (does the company industry align with their background?)

Discard any postings scoring below 5.

### Step 6 — Output ranked shortlist

Write `outputs/job-shortlist.md` with:

```
JOB SEARCH RESULTS
Searched: [date]
Criteria: [role] in [location]
Total found: [n] | After scoring: [n]

─────────────────────────────────────
RANK 1 — SCORE: 9/10
Role: [title]
Company: [company]
Location: [location]
Posted: [date]
Source: [indeed/linkedin/glassdoor]
URL: [link]

WHY IT SCORES HIGH:
- [specific reason from resume match]
- [specific reason]

GAPS TO PREPARE FOR:
- [requirement in JD not in resume]

RECOMMENDED ACTION: Apply now / Research first / Skip
─────────────────────────────────────
[repeat for each posting, ranked by score]
```

### Step 7 — Stop MCP server
```bash
kill $MCP_PID 2>/dev/null || pkill -f jobspy_mcp_server 2>/dev/null
docker stop jobspy-mcp 2>/dev/null && docker rm jobspy-mcp 2>/dev/null
```

### Step 8 — Prompt next steps

Tell the user:
> Found [n] matches. Top result: [role] at [company] — score [x]/10.
> Your shortlist is saved to outputs/job-shortlist.md
>
> To apply to any of these:
> 1. Copy the job URL into inputs/job-description.md
> 2. Run: npm run resume
> 3. Run: npm run cover-letter
> 4. Run: npm run ats

## Running

```bash
npm run jobs
```

---

## ✅ What to do next

```
npm run decode    ← decode the top posting before applying
npm run salary    ← research comp for the role before any screening call
```
