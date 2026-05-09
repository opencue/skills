---
name: obscura
description: >-
  Headless browser written in Rust for AI agents and web scraping. Use when
  user says "scrape", "headless browser", "web scrape", "puppeteer", "cdp",
  "stealth scrape", "obscura", or needs JavaScript-rendered content from
  a URL. Drop-in replacement for headless Chrome with built-in
  anti-detection, 30 MB RAM, 85 ms page load. NOT for static pages
  without JS — use `defuddle` or `curl + jq` instead.
---

# obscura

Headless browser engine in Rust. Replaces headless Chrome / Puppeteer / Playwright for scraping and agent browsing. Implements the Chrome DevTools Protocol so existing Puppeteer/Playwright clients work unchanged.

> No upstream SKILL.md found at h4ckf0r0day/obscura on 2026-05-09. Authored locally from the project README. Re-check upstream periodically — adopt theirs if/when they publish one.
>
> Source: <https://github.com/h4ckf0r0day/obscura> · License: Apache-2.0

## When to load this skill

- User says: scrape, scraping, headless browser, render JS, puppeteer, playwright, CDP, stealth, obscura
- User asks to extract data from a JS-heavy site (SPA, dashboard, login-required)
- A `gh search` or `WebFetch` returned an obviously JS-rendered page (empty HTML, scripts only)

## When NOT to load

- Static HTML pages — use `WebFetch` + `defuddle` instead (cheaper, no browser).
- One-off URL inspection — `curl -sL <url>` is enough.
- Reading a known-good markdown file — direct `WebFetch`.

## Why Obscura over headless Chrome

| Metric        | Obscura | Headless Chrome |
|---------------|---------|-----------------|
| Memory        | 30 MB   | 200+ MB         |
| Binary size   | 70 MB   | 300+ MB         |
| Page load     | 85 ms   | ~500 ms         |
| Startup       | instant | ~2s             |
| Anti-detect   | built-in | none            |
| Puppeteer     | yes     | yes             |
| Playwright    | yes     | yes             |

## Install (Linux x86_64)

```bash
mkdir -p ~/.local/bin
curl -LO https://github.com/h4ckf0r0day/obscura/releases/latest/download/obscura-x86_64-linux.tar.gz
tar xzf obscura-x86_64-linux.tar.gz
mv obscura obscura-worker ~/.local/bin/
rm obscura-x86_64-linux.tar.gz
obscura --version
```

`obscura-worker` must live next to `obscura` for the parallel `scrape` subcommand. Linux release builds target Ubuntu 22.04 (glibc 2.35+).

## CLI cheatsheet

### Single-page fetch

```bash
obscura fetch https://example.com --eval "document.title"
obscura fetch https://example.com --dump links
obscura fetch https://news.ycombinator.com --dump html
obscura fetch https://example.com --wait-until networkidle0
obscura fetch https://example.com --timeout 10
obscura fetch https://example.com --selector ".product-grid"
```

| Flag | Default | Notes |
|------|---------|-------|
| `--dump` | `html` | `html` / `text` / `links` |
| `--eval` | — | JS expression to evaluate inside page |
| `--wait-until` | `load` | `load` / `domcontentloaded` / `networkidle0` |
| `--timeout` | `30` | Max navigation seconds |
| `--selector` | — | Wait for CSS selector |
| `--stealth` | off | Anti-detection mode |
| `--quiet` | off | Suppress banner |

### Parallel scrape

```bash
obscura scrape url1 url2 url3 \
  --concurrency 25 \
  --eval "document.querySelector('h1').textContent" \
  --format json
```

| Flag | Default | Notes |
|------|---------|-------|
| `--concurrency` | `10` | Parallel workers |
| `--eval` | — | JS expression per page |
| `--format` | `json` | `json` / `text` |

### CDP server (for Puppeteer/Playwright)

```bash
obscura serve --port 9222
obscura serve --port 9222 --stealth
```

| Flag | Default | Notes |
|------|---------|-------|
| `--port` | `9222` | WebSocket port |
| `--proxy` | — | HTTP/SOCKS5 URL |
| `--stealth` | off | Anti-detect + tracker blocking |
| `--workers` | `1` | Parallel worker processes |
| `--obey-robots` | off | Respect robots.txt |

## Puppeteer client

```js
import puppeteer from 'puppeteer-core';

const browser = await puppeteer.connect({
  browserWSEndpoint: 'ws://127.0.0.1:9222/devtools/browser',
});
const page = await browser.newPage();
await page.goto('https://news.ycombinator.com');
const stories = await page.evaluate(() =>
  Array.from(document.querySelectorAll('.titleline > a'))
    .map(a => ({ title: a.textContent, url: a.href }))
);
await browser.disconnect();
```

## Playwright client

```js
import { chromium } from 'playwright-core';

const browser = await chromium.connectOverCDP({ endpointURL: 'ws://127.0.0.1:9222' });
const page = await browser.newContext().then(ctx => ctx.newPage());
await page.goto('https://en.wikipedia.org/wiki/Web_scraping');
console.log(await page.title());
await browser.close();
```

## Stealth mode (`--stealth`)

Built from source with `cargo build --release --features stealth` OR pass `--stealth` to `serve` / `fetch`. Provides:

- Per-session fingerprint randomization (GPU, screen, canvas, audio, battery)
- `navigator.userAgentData` matching Chrome 145
- `event.isTrusted = true` for dispatched events
- `navigator.webdriver = undefined` (matches real Chrome)
- Native function masking
- Tracker blocking: 3,520 domains (analytics, ads, fingerprinting)

Use stealth for sites that fingerprint or rate-limit. Skip it for benign internal scraping (faster).

## Decision tree — which tool for which scrape

| Page type | Tool |
|-----------|------|
| Static HTML, no JS | `WebFetch` + `defuddle` |
| Markdown URL | `WebFetch` (raw) |
| Known REST/GraphQL API | `curl` + `jq` |
| JS-rendered, no anti-bot | `obscura fetch` |
| JS-rendered + login/cookies | `obscura serve` + Puppeteer/Playwright |
| Anti-bot / Cloudflare | `obscura serve --stealth` |
| Many URLs (>20) | `obscura scrape --concurrency N` |

## Sister skills

- `defuddle` — clean HTML → readable markdown (use AFTER obscura returns HTML)
- `playwright` — Playwright-CLI wrapper (works with obscura's CDP server)
- `keyword-research` — feed scraped content into SEO analysis

## Common workflows

**1. Quick title/metadata extraction:**
```bash
obscura fetch <url> --eval "JSON.stringify({title: document.title, desc: document.querySelector('meta[name=description]')?.content})"
```

**2. Crawl a category page → product URLs → product details:**
```bash
# Phase 1: collect product URLs
obscura fetch https://shop/cat --eval "Array.from(document.querySelectorAll('a.product')).map(a=>a.href)" > urls.json

# Phase 2: scrape each
jq -r '.[]' urls.json | xargs obscura scrape --concurrency 25 --eval "..." --format json
```

**3. Logged-in scraping:** start `obscura serve`, connect with Puppeteer, perform login, persist cookies to a file with `page.cookies()`, reload them on subsequent runs.
