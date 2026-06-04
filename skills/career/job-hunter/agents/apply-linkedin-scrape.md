# LinkedIn MCP Scraper — Setup & Auto-Audit

## What This Does

Installs and configures `linkedin-mcp-server`, scrapes your LinkedIn profile by URL,
formats it into Job Hunter's standard input format, then runs the LinkedIn audit
automatically — no copy-paste required.

**This is the advanced path.** If you just want to paste your profile text, use
`npm run linkedin` instead.

---

## Prerequisites Check

Before doing anything else, verify the following are installed:

```bash
python3 --version    # needs 3.8+
uv --version         # needs uv package manager
google-chrome --version || chromium-browser --version   # needs Chrome or Chromium
```

If `uv` is missing, install it:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

If Chrome is missing, download from https://www.google.com/chrome/

---

## Instructions for Claude Code

You are setting up the LinkedIn MCP scraper and running a full profile audit.
Follow each step in order. If any step fails, report the exact error before stopping.

### Step 1 — Check prerequisites

Run the following and report results:

```bash
python3 --version
uv --version
which google-chrome || which chromium-browser || which chromium
```

If `uv` is not found, run:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.cargo/env 2>/dev/null || source $HOME/.local/bin/env 2>/dev/null || true
```

If Chrome/Chromium is not found, stop and tell the user to install Chrome from
https://www.google.com/chrome/ before continuing.

### Step 2 — First-time login (only needed once)

Check if a LinkedIn session already exists:

```bash
ls ~/.linkedin-mcp/profile/Default/Cookies 2>/dev/null && echo "SESSION EXISTS" || echo "NO SESSION"
```

If NO SESSION, run the login command to open a browser window:

```bash
uvx linkedin-scraper-mcp@latest --login
```

Tell the user:
> A Chrome window has opened. Log into LinkedIn normally — use your regular
> username and password. Once you're logged in and can see your LinkedIn feed,
> come back here and press Enter to continue.

Wait for the user to confirm they've logged in before proceeding.

If SESSION EXISTS, skip this step and tell the user their session is already saved.

### Step 3 — Read the LinkedIn URL

Read the file `inputs/apply-linkedin-url.txt`. This should contain a single LinkedIn
profile URL, e.g. `https://www.linkedin.com/in/yourname/`

If the file is empty or missing, stop and tell the user:
> Please create the file `inputs/apply-linkedin-url.txt` and paste your LinkedIn
> profile URL into it (just the URL, nothing else), then run this agent again.

### Step 4 — Start the MCP server

Start the LinkedIn MCP server in the background:

```bash
uvx linkedin-scraper-mcp@latest --transport streamable-http \
  --host 127.0.0.1 --port 8765 --path /mcp \
  --user-data-dir ~/.linkedin-mcp/profile \
  --headless true \
  --log-level WARNING &

MCP_PID=$!
echo "MCP server PID: $MCP_PID"
sleep 5
```

Verify it started:
```bash
curl -s http://127.0.0.1:8765/mcp/health 2>/dev/null && echo "SERVER UP" || echo "SERVER NOT RESPONDING"
```

If SERVER NOT RESPONDING after 10 seconds, try increasing the wait and checking again.
If it still fails, stop and report the error output.

### Step 5 — Scrape the profile

Read the URL from `inputs/apply-linkedin-url.txt`.

Use the MCP server at `http://127.0.0.1:8765/mcp` to call the `get_person_profile`
tool with:
- `profile_url`: the URL from the file
- `sections`: `["main", "experience", "education", "skills", "contact_info"]`

If the scrape returns a captcha challenge or login error:
> LinkedIn is asking for verification. Run `uvx linkedin-scraper-mcp@latest --login`
> to re-authenticate, then run this agent again.

### Step 6 — Format into Job Hunter input

Take the scraped profile data and write it to `inputs/my-linkedin.md` using this
exact structure:

```markdown
# My LinkedIn Profile

## Headline
[scraped headline]

## About
[scraped about/summary section]

## Experience

### [Job Title] | [Company] | [Start Date] - [End Date or Present]
[bullet points from description]

[repeat for each role]

## Skills
[comma-separated list of top skills]

## Education
### [Degree] | [School] | [Year]
```

Tell the user:
> Profile scraped successfully. Saved to inputs/my-linkedin.md — here's a preview
> of the first few lines:

Show the first 20 lines of `inputs/my-linkedin.md`.

### Step 7 — Shut down the MCP server

```bash
kill $MCP_PID 2>/dev/null || pkill -f "linkedin-scraper-mcp" 2>/dev/null
echo "MCP server stopped"
```

### Step 8 — Check for job description

Check if `inputs/job-description.md` has been filled in (more than 200 characters
of non-template content).

If it's empty or still a template, tell the user:
> Your LinkedIn profile has been scraped and saved. Before running the audit,
> paste a job description into `inputs/job-description.md`, then run:
> `npm run linkedin`

If it's filled in, proceed directly to Step 9.

### Step 9 — Run the LinkedIn audit

Read `inputs/my-linkedin.md` (just scraped).
Read `inputs/job-description.md`.
Read `rules/writing-rules.md`.

Now perform the full LinkedIn audit as defined in `agents/linkedin-analyzer.md`.

Execute every step in that agent and write the output to `outputs/linkedin-audit.md`.

Tell the user:
> Audit complete. Your results are in outputs/linkedin-audit.md

Show the Priority Action List section of the output so the user sees their top
5 actions immediately.

---

## Running This Agent

```bash
# First time — reads URL, logs in, scrapes, audits
claude "follow agents/linkedin-scraper-setup.md"

# After first login — just scrape and audit
claude "follow agents/linkedin-scraper-setup.md"
```

Or with npm:
```bash
npm run linkedin-scrape
```

---

## Troubleshooting

**Captcha / login errors**
```bash
uvx linkedin-scraper-mcp@latest --login
```
Log in manually in the browser window, then re-run the agent.

**Server won't start**
```bash
pkill -f linkedin-scraper-mcp
uvx linkedin-scraper-mcp@latest --transport streamable-http --host 127.0.0.1 --port 8765 --path /mcp --headless true
```

**Profile not found / empty sections**
Some profiles are private or have restricted visibility. The scraper can only
access what LinkedIn shows to logged-in users. If your own profile comes back
empty, make sure you're logged into the correct account.

**uv command not found after install**
```bash
source $HOME/.local/bin/env
```
Then re-run the agent.

---

## Privacy Note

Your LinkedIn credentials are stored locally in `~/.linkedin-mcp/profile/` —
the same place Chrome stores any browser profile. They never leave your machine.
The scraper runs Chrome on your computer; it does not proxy through any third-party
service.

---

## ✅ What to do next

Your profile is saved to `inputs/my-linkedin.md`. Run the audit:
```
npm run linkedin      ← full audit against your target role
```
