---
name: agent-browser
description: Use when you need to drive a real browser to open a page, fill forms, click, screenshot, scrape, or test a login flow. Triggers on "automate the browser", "test the page", "scrape this site".
triggers:
  - "automate the browser"
  - "test the page"
  - "scrape this site"
  - "drive a browser"
allowed-tools: Bash(agent-browser:*)
category: browser
tags: [browser, automation, scraping, testing, cdp]
metadata:
  version: 1.0.0
  homepage: https://agent-browser.dev
---

# agent-browser

Browser automation CLI for AI agents (vercel-labs/agent-browser). A fast native
Rust CLI over a persistent daemon, so commands chain cheaply. The optimal flow
is ref-based: take a `snapshot`, then act on stable `@e1`/`@e2` refs instead of
guessing CSS selectors.

## Prerequisites

```bash
agent-browser --version || npm install -g agent-browser
agent-browser install        # one-time: Chrome for Testing (auto-detects existing Chrome)
agent-browser doctor         # verify: headless launch + environment
```

On Linux, if a launch fails with shared-library errors: `agent-browser install --with-deps`.

## When to activate

- "open / navigate / scrape this URL", "fill the form", "click the button",
  "screenshot the page", "test the login flow".
- A task needs real browser behavior: JS-rendered content, auth, multi-step UI.
- Prefer this over hand-rolled Puppeteer/Playwright scripts for one-off agent runs.

## Example

User: "log into the staging dashboard and screenshot it."

```bash
agent-browser open https://staging.example.com/login
agent-browser snapshot -i --json        # interactive elements + refs
agent-browser fill @e3 "user@example.com" && agent-browser fill @e4 "$PASS"
agent-browser find role button click --name "Sign in"
agent-browser wait --url "**/dashboard" && agent-browser screenshot dash.png
agent-browser close
```

## Optimal AI workflow

1. **Navigate**, then snapshot to discover refs:

   ```bash
   agent-browser open <url>
   agent-browser snapshot -i --json   # -i = interactive only; refs @e1, @e2, ...
   ```

2. **Act on refs** (deterministic, no DOM re-query):

   ```bash
   agent-browser click @e2
   agent-browser fill @e3 "text"
   agent-browser get text @e1
   ```

3. **Re-snapshot after the page changes**: refs are tied to the last snapshot.

Chain steps that don't need intermediate output with `&&` (the daemon persists),
or send many in one call with `agent-browser batch "open …" "snapshot -i" "click @e1"`.

## Core commands

```bash
agent-browser open <url>              # launch + navigate (aliases: goto, navigate)
agent-browser snapshot -i [--urls]    # accessibility tree with refs (best for AI)
agent-browser click|fill|type|hover @ref [text]
agent-browser find role <role> click --name "<label>"   # semantic locator
agent-browser screenshot [path] [--full] [--annotate]   # --annotate labels refs on the image
agent-browser get text|html|value|url @ref
agent-browser wait <selector|ms> | --text "…" | --url "**/x" | --load networkidle
agent-browser eval "<js>"             # run JS in the page
agent-browser close [--all]           # close session(s)
```

## Sessions and auth

```bash
agent-browser --session <name> open <url>      # isolated browser instance
agent-browser --profile Default open <url>     # reuse your real Chrome login (read-only snapshot)
agent-browser --session-name <n> open <url>    # auto save/restore cookies + localStorage
agent-browser --headers '{"Authorization":"Bearer <token>"}' open <api-url>  # skip login, origin-scoped
```

For agent safety on untrusted pages: `--content-boundaries`, `--allowed-domains "example.com,*.example.com"`,
`--max-output 50000`.

## Rules

- Always `snapshot -i` before interacting, and re-snapshot after any navigation
  or DOM change, since stale refs point at the wrong element.
- Use `--json` for every command when an agent parses the output.
- Prefer refs (`@e1`) over CSS selectors; fall back to `find role … --name` for
  semantic targets, CSS only as a last resort.
- Close sessions when done (`agent-browser close`) so daemons don't linger; set
  `AGENT_BROWSER_IDLE_TIMEOUT_MS` to auto-shutdown.
- Overlaps `browser/lightpanda` and `browser/playwright`. Pick one per task:
  agent-browser for rich ref-based automation, lightpanda for the lightest
  headless fetch. Don't run three browser stacks for one job.
- Never paste secrets into commands; use `--headers`/env or the auth vault
  (`agent-browser auth save … --password-stdin`).
