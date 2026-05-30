---
name: lightpanda
description: Use when the user says "lightpanda", "scrape this page", "headless browse", or "dump the DOM". Fast headless browser for rendering URLs without Chromium, scraping, and CDP automation.
metadata:
  category: browser
  domain: browser-automation
  tags: [browser, headless, cdp, scraping, mcp, lightpanda]
---

# Lightpanda: fast headless browser for agents

Lightpanda is a lightweight, JavaScript-capable headless browser (CDP-compatible)
built for AI agents and automation. It starts far faster and uses far less memory
than Chromium because it renders the DOM and runs JS but does **not** paint pixels.
Treat it as the default engine for headless navigation, scraping, and DOM
extraction. Reach for full Chromium (Webwright or `browser/playwright`) only when
you need a real pixel screenshot to visually verify a page.

The binary lives at `/home/deadpool/lightpanda`. Move it to `~/.local/bin/lightpanda`
to put it on PATH. Confirm it works with `lightpanda version`.

## Three modes

| Mode | Command | Use it for |
|---|---|---|
| `mcp` | `lightpanda mcp` | MCP server over stdio. Claude gets browser tools directly. This is how the `lightpanda` MCP is wired into the browser profile. |
| `serve` | `lightpanda serve --port 9222` | WebSocket CDP server. Point Playwright, Puppeteer, or Webwright at it via `connectOverCDP` as a low-memory Chromium replacement. |
| `fetch` | `lightpanda fetch <url> --dump markdown` | One-shot: render a page and dump HTML, Markdown, or a semantic tree to stdout. No server, no session. Fastest path for scraping. |

## When to use lightpanda (default)

- "Scrape this page" or "what's on this URL" maps to `lightpanda fetch <url> --dump markdown`.
- "Give me the cleaned text of this article" maps to `--dump semantic_tree_text`.
- "Drive this site headlessly" or CDP automation maps to `serve` plus a CDP client.
- Any headless navigation where you do **not** need a pixel screenshot.

## When NOT to use lightpanda

- **Visual verification** ("does the button look right?", "screenshot the checkout"):
  use Webwright or `browser/playwright`. Lightpanda does not paint pixels.
- Pure JSON or API checks: `curl` via Bash is faster.
- Reading a docs page for its text: `WebFetch` is fine and needs no binary.

## Example

> User: "scrape get-ryze.ai and give me the clean text"

```bash
/home/deadpool/lightpanda fetch https://get-ryze.ai --dump semantic_tree_text
```

> User: "drive the checkout flow headlessly with Playwright"

```bash
# Terminal 1: start the CDP backend
/home/deadpool/lightpanda serve --port 9222
```
```js
// Your Playwright script connects instead of launching Chromium
const browser = await chromium.connectOverCDP("ws://127.0.0.1:9222");
```

## Mode 1: fetch (one-shot scrape)

```bash
/home/deadpool/lightpanda fetch https://example.com --dump markdown
/home/deadpool/lightpanda fetch https://example.com --dump semantic_tree_text
/home/deadpool/lightpanda fetch https://example.com --dump html --strip-mode js,css,ui
/home/deadpool/lightpanda fetch https://example.com --dump markdown --json
```

`--dump` values: `html`, `markdown`, `semantic_tree`, `semantic_tree_text`.
`--strip-mode` removes noise: `js`, `css`, `ui`, or `full`.

## Mode 2: serve (CDP backend)

```bash
/home/deadpool/lightpanda serve --host 127.0.0.1 --port 9222
```

The CDP endpoint is discoverable at `http://127.0.0.1:9222/json/version`. Connect
Playwright with `chromium.connectOverCDP("ws://127.0.0.1:9222")` or Puppeteer with
`puppeteer.connect({ browserWSEndpoint: "ws://127.0.0.1:9222" })`. Preload cookies
read-only with `--cookie <path.json>`.

## Mode 3: mcp (tools inside Claude)

The browser profile registers `lightpanda mcp`. After a Claude restart its tools
appear as `mcp__lightpanda__*`. Prefer these for headless navigation and extraction
over shelling out, since they keep one browser session warm across tool calls.
Persist cookies across runs with `lightpanda mcp --cookie-jar ~/.lightpanda/cookies.json`.

## Rules

- Default to lightpanda for headless work. Switch to Chromium (Webwright or playwright) the moment the task needs a real screenshot, since lightpanda cannot paint pixels.
- One action per step when driving via CDP. Verify the DOM or semantic tree before declaring success.
- Confirm with the user before any login, form submit, or destructive action. Lightpanda hits real sites and real accounts just like Chromium.
- When fetching untrusted or user-supplied URLs, add `--block-private-networks` to avoid SSRF into internal services.
- Never enable `--insecure-disable-tls-host-verification` without explicit user consent.
