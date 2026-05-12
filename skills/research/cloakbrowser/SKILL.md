---
name: cloakbrowser
description: >-
  Use when user says "cloakbrowser", "stealth chromium", "bypass bot detection", "anti-bot scraping", "fingerprint spoof", or needs to scrape sites that block headless browsers (Cloudflare, FingerprintJS, reCAPTCHA, sannysoft). Docker-packaged stealth Chromium with rotating fingerprints. Verified 5/6 on the standard bot-detection battery (sannysoft 56/56, BrowserScan clean, reCAPTCHA v3 score 0.9, deviceandbrowserinfo not-bot, incolumitas 35/36).
---

# cloakbrowser

Stealth Chromium for automation, distributed as a Docker image (`cloakhq/cloakbrowser`). Drop-in replacement for headless Chrome / Puppeteer / Playwright when a site has anti-bot detection that ordinary headless browsers trip.

> Source: <https://github.com/CloakHQ/CloakBrowser> · Image: `cloakhq/cloakbrowser:latest`

## When to load this skill

- User says: cloakbrowser, stealth chromium, bypass bot detection, anti-bot, fingerprint spoof, cloak
- Target site blocks normal headless Chrome / Puppeteer / Playwright (Cloudflare, PerimeterX, DataDome, FingerprintJS, reCAPTCHA v3)
- A previous scrape returned a challenge page, JS-only body, or `403`
- User needs a randomized browser fingerprint (UA, platform, screen, GPU, IP)

## When NOT to load

- Static HTML — use `WebFetch` + `defuddle`.
- JS-rendered but uncloaked sites — `obscura` is lighter (30 MB RAM, no Docker).
- One-off URL inspection — `curl -sL <url>` is enough.
- The site only needs auth, not stealth — `playwright` directly is simpler.

## Smoke test

```bash
docker run --rm cloakhq/cloakbrowser cloaktest
```

Runs the 6-site battery (sannysoft, incolumitas, BrowserScan, deviceandbrowserinfo, FingerprintJS, reCAPTCHA v3). Expected: 5/6 pass; FingerprintJS "NO FLIGHTS" is the known fail.

Useful flags:

- `cloaktest --headed` — show the browser (debug fingerprint visually)
- `cloaktest --screenshots` — save per-test PNGs
- `cloaktest --proxy http://user:pass@host:port` — route through a proxy (recommended for IP-based detectors)

## Running your own automation

The image bundles a Chromium that exposes the Chrome DevTools Protocol — connect any existing Puppeteer/Playwright client unchanged.

```bash
docker run --rm -p 9222:9222 cloakhq/cloakbrowser \
  cloakbrowser --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0
```

Then from the host:

```js
import { chromium } from 'playwright';
const browser = await chromium.connectOverCDP('http://localhost:9222');
const page = await browser.newPage();
await page.goto('https://target.example');
```

Persist fingerprint across runs by mounting a profile dir:

```bash
docker run --rm -v "$PWD/profile:/profile" cloakhq/cloakbrowser \
  cloakbrowser --user-data-dir=/profile https://target.example
```

## Anti-detection coverage (verified 2026-05-12)

| Suite                          | Result |
|--------------------------------|--------|
| bot.sannysoft.com              | 56/56 |
| bot.incolumitas.com            | 35/36 (WEBDRIVER false positive) |
| BrowserScan bot-detection      | 19 normal / 0 abnormal |
| deviceandbrowserinfo.com       | isBot: False |
| FingerprintJS web-scraping     | NO FLIGHTS (fails) |
| reCAPTCHA v3                   | score 0.9 |

FingerprintJS is the only consistent miss — fingerprint canvas/audio entropy still ties multiple runs together. If targeting FingerprintJS-protected sites, rotate the Docker container plus the proxy IP per session.

## Tips

- **Rotate IPs.** Stealth handles the browser; it does not hide the source IP. Pair with residential proxies for serious anti-bot targets.
- **Stick to one fingerprint per session.** Switching mid-session is itself a detection signal.
- **Mount `/profile`** to keep cookies and the fingerprint stable across runs of the same job.
- **Use `--headed` while debugging.** Headless-mode signals are the most common detection failure mode.
- **Donate / star.** Project asks for it at startup; cheap karma for the rig.
