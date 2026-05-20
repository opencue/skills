---
name: playwright
description: Use when verifying storefront or admin UI changes visually, when the user asks "does it work?" / "screenshot the page" / "show me the form" / "check the checkout flow", when reproducing UI bugs reported by a user, when testing Medusa shop dev servers running on localhost ports, or when exploring a third-party site to understand its DOM/behavior.
---

# Playwright MCP — driving a real browser

## Core principle

When code touches anything rendered (Medusa storefronts, admin dashboards, Coolify UI, third-party docs), running tests or reading source isn't enough — load the page in a real browser, see what users see. Playwright MCP exposes `navigate`, `screenshot`, `click`, `fill`, `evaluate`, `accessibility_snapshot`, `network_log`, and friends so Claude can drive Chromium, Firefox, or WebKit from inside a conversation.

## When to use

- "Does the storefront still build after my change?" → navigate to the local dev URL, screenshot above-the-fold, check console errors.
- "I changed the checkout button text — confirm it shows up." → navigate, screenshot the cart, verify the text in the accessibility snapshot.
- "Reproduce the 500 on /blog/some-post" → navigate, capture the network_log, surface the failing request.
- "What does marvahome.com look like in mobile viewport?" → navigate with viewport override, screenshot.
- "Inspect the DOM of the Stripe Checkout page after redirect" → drive through the checkout, evaluate JS to dump the DOM.

## When NOT to use

- Pure data / API checks → use `curl` via Bash. Playwright is overkill and slow for JSON endpoints.
- Reading documentation pages → `WebFetch` is faster (no browser cold-start).
- Anything that needs a logged-in real user session against production → use Chrome DevTools MCP attached to your own Chrome instead (Playwright is incognito-clean by design).

## Tool surface (after MCP loads)

After restart, tools appear as `mcp__playwright__*`. The most-used:

| Tool | Use |
|---|---|
| `navigate` | go to a URL |
| `screenshot` | PNG bytes of viewport, full page, or a specific element |
| `accessibility_snapshot` | tree of all visible elements with roles + labels (lighter than DOM) |
| `click`, `fill`, `select_option`, `press_key` | drive forms |
| `wait_for` | wait for selector / URL / network-idle |
| `evaluate` | run arbitrary JS in the page context |
| `network_log` | capture all requests + responses since navigate |
| `console_log` | capture console output |
| `set_viewport` | resize (mobile / tablet / desktop) |
| `tab_new`, `tab_select`, `tab_close` | manage tabs |

## Quick reference

```javascript
// Verify the marva storefront homepage renders
await playwright.navigate({ url: "http://localhost:3001" })
await playwright.screenshot({ fullPage: false })
await playwright.accessibility_snapshot()   // for assertions

// Reproduce a checkout failure
await playwright.navigate({ url: "http://localhost:3001/checkout" })
await playwright.fill({ selector: "[name=email]", value: "test@example.com" })
await playwright.click({ selector: "button[type=submit]" })
await playwright.wait_for({ url_pattern: "**/payment" })
await playwright.network_log()             // see what fired
await playwright.console_log()             // see errors
```

## Shop-specific patterns

### Verifying a Medusa storefront change locally

```bash
# In one terminal — backend on its assigned port (see medusa-local-dev skill)
medusa-dev start marva back

# In another — storefront
medusa-dev start marva front
```

Then ask Claude to:
> "Open http://localhost:3001 in Playwright, screenshot it, then click the first product card and screenshot the PDP."

### Comparing admin design changes side-by-side

```javascript
// before
await playwright.navigate({ url: "http://localhost:9001/app/booking" })
await playwright.screenshot({ filename: "before.png" })

// apply change, restart backend, then
await playwright.navigate({ url: "http://localhost:9001/app/booking" })
await playwright.screenshot({ filename: "after.png" })
```

### Capturing what an end user sees after Stripe checkout

```javascript
await playwright.navigate({ url: "http://localhost:3001/cart" })
// ... drive to Stripe redirect, fill 4242 4242 4242 4242 ...
await playwright.wait_for({ url_pattern: "**/order/confirmed" })
await playwright.screenshot({ fullPage: true })
await playwright.console_log()    // any client-side errors?
```

## MCP registration

Already added to `~/.claude.json` (under `mcpServers.playwright`). The entry uses `npx -y @playwright/mcp@latest --headless` so the package auto-updates and runs in headless mode by default. Drop `--headless` if you want the browser window to appear (useful when *you* want to watch what's happening).

To restart Claude Code so the new MCP tools load:
```
# Just exit and re-run `claude` — the MCP comes up automatically.
```

## Browser binaries

Chromium is installed at first use (or pre-installed via `npx playwright install chromium`). Adding Firefox/WebKit:
```bash
npx playwright install firefox webkit
```

Browsers live under `~/.cache/ms-playwright/`.

## Common mistakes

| Symptom | Cause | Fix |
|---|---|---|
| `Target page, context or browser has been closed` | session timed out between calls | `navigate` again — Playwright MCP creates a new context per task |
| Screenshots are blank / white | page hasn't finished rendering | `wait_for({ load_state: "networkidle" })` first |
| Selector matches nothing | shadow DOM or iframe | use `accessibility_snapshot` to find the right role/name; for iframes pass `frame: "name"` |
| Slow first navigate | Chromium cold-start (~2s) | normal; subsequent calls reuse the browser |
| Network log empty | `network_log` only captures since the last `navigate` | call after the page settles |

## When to escalate to Chrome DevTools MCP

If you need to interact with your *already-open*, *already-logged-in* Chrome session (e.g., the Coolify dashboard with your live token), Playwright won't help — it always starts a fresh incognito-style context. For that, install `@modelcontextprotocol/server-chrome-devtools`, launch Chrome with `--remote-debugging-port=9222`, and use that MCP. Both can coexist.

## When to escalate to Computer Use

If the task crosses applications (browser ↔ terminal ↔ Stripe Dashboard ↔ Coolify UI all in one go), Anthropic's Computer Use loop is a better fit. Slower per step, but no MCP boundary.
