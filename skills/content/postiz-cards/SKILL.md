---
name: postiz-cards
description: 'Use when user says "build a branded card", "make a postiz card", "schedule a branded post", "composite the logo on this card", "lint my post copy". Brand-aware card pipeline for Postiz. Lints post copy (cashtag/em-dash/stat gates), composites the brand logo band onto Higgsfield cards (with OCR text-check), and pulls analytics. For building or scheduling branded image-card posts for ANY postizz brand (volaria, etc.). Pairs with /post-as.'
allowed-tools: Bash(Bash:*), Read
category: content
---

# postiz-cards

The reusable toolkit behind `/post-as`, the card-building and pre-publish discipline, generalized so any brand under `profiles/postizz/brands/<brand>/` can use it. Volaria is the reference implementation.

## Why this exists

Hand-rolling generate → composite → lint → upload → schedule for every card is slow and error-prone (cashtag-limit failures, em-dashes, garbled headline text, logo redraws). These scripts make each step one command.

## Scripts (`scripts/`)

### `lint.py`, pre-publish gate
```
python3 scripts/lint.py <draftfile>      # tweets separated by a line: ===
```
Per tweet enforces **≤1 cashtag** (X rejects 2+ as nonRetryable), **0 em-dashes**, char count; warns on **uncited stats** (numbers with no source link). Exit 1 on FAIL. Run before every schedule.

### `card.sh`, logo composite + OCR check + upload
```
scripts/card.sh <raw.png> [out.png] [--brand <name>] [--check "HEADLINE WORDS"] [--upload]
```
Composites the brand's logo band onto a raw Higgsfield card (defaults: 220px band, logo `-resize x180` at `north +0+20`, override via `BAND_H`/`LOGO_H`/`LOGO_OFF` env). `--check` OCRs the rendered card (tesseract) to catch text errors like a dropped word. `--upload` pushes to Postiz and prints the media URL.
**Never** pass the logo to image-gen as a reference, it redraws. Always composite post-gen.

### `analytics.sh`, performance report
```
scripts/analytics.sh [--brand <name>] [--int <integration_id>]
```
Postiz platform + recent-post metrics. **Caveat:** Postiz analytics lag X by ~30× on fresh posts, use for trend, cross-check X-native (the account's per-post analytics or Premium export).

## Standing pipeline (per post)
research/verify → draft copy → `lint.py` → generate card (EMPTY top band) → `card.sh --check --upload` → schedule via the `postiz` CLI with a first-reply CTA, at a peak slot → reply within 30 min.

## Brand config (per brand, under `profiles/postizz/brands/<brand>/`)
- `logo.png`, composited onto every card (the band recipe; tune via env if a brand differs).
- `brand.md`, palette/voice/card templates + the content plan (pillars, cadence, levers).
- `accounts.yaml`, integration IDs (or pass `--int` / `POSTIZ_INT`).

## Related
- Command: `/post-as <brand>` (wraps this end-to-end). `/trend-to-thread`, `/article-to-everywhere`.
- Rules: `rules/postiz/x-cashtag-limit.md`.
