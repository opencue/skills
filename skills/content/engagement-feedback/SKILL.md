---
name: engagement-feedback
description: >-
  Use when user says "/engagement-report", "which posts worked", "engagement loop",
  "what's getting traction", "audit which voices land", or wants Postiz analytics
  cross-referenced with article voice / preset / topic choices. Closes the loop
  between content choices and actual reader response.
allowed-tools:
  - Bash
  - Read
---

# engagement-feedback — close the content-strategy loop

After enough posts have shipped through `/trend-to-thread` + `/article-to-everywhere`, this skill answers the questions that intuition can't: **which voices, presets, and topics are actually getting engagement, and which are noise?**

The mechanism is dead-simple: every Postiz draft is created from an article that already has voices / preset / keywords in its frontmatter. When the draft becomes a real post and accumulates engagement, this skill correlates the engagement back to the article-level choices. After 8-12 posts you start seeing real signal; after 30+, the recommendations harden.

## Pre-condition: postiz back-write

For the correlation to work, downstream skills (`/trend-to-thread`, `/article-to-everywhere`) MUST back-write the Postiz post ID into the source article frontmatter immediately after creating the draft:

```yaml
---
title: "..."
date: 2026-05-25
preset: qa-interview
voices: [hk-allocator, eu-policy-analyst, jp-trade-neg]
keywords:
  primary: "rare-earth halt"
  secondary: ["dysprosium", "EU exposure"]
postiz:
  x: cmpl7hgf60011r38gaoraiqr1
  linkedin: cmpl...
---
```

The back-write is the single integration point. Without it, this skill has nothing to correlate. With it, everything else is free.

## Invocation

```
/engagement-report [--days N] [--out path.md]
```

Defaults:
- `--days 30` — Postiz analytics window
- no `--out` — print to console only

Examples:
- `/engagement-report` — last 30 days, console output
- `/engagement-report --days 7` — last week only
- `/engagement-report --days 90 --out ~/Documents/cue/reports/2026-Q2.md` — quarterly report

Under the hood:

```bash
python3 ~/Documents/cue/scripts/engagement-report.py --days 30
```

## Output

Three ranked tables:

1. **Per-post detail** — one row per (article, platform) pair, sorted by engagement.
2. **Ranked by voice mix** — which composite-persona combinations drive total + average engagement.
3. **Ranked by preset** — qa-interview vs. op-ed vs. sector-analysis vs. listicle vs. breaking-news.
4. **Ranked by primary keyword** — which topics resonate.

For each ranked table: `n` (sample size), `avg`, `total`.

## How to use the output

After 8-12 posts:
- A voice combination with `n=3` and `avg=4×` baseline is a recommendation, not just noise.
- A preset with consistently low engagement (across multiple topics) is a candidate for retirement.
- A keyword that's been used 3× and is still climbing in engagement → publish again.
- A keyword that's been used 2× with declining engagement → cooldown longer than the default 14d (see topic-cooldown).

After 30+ posts:
- Voice + preset interaction effects become visible (e.g. `defense-procurement` reads better in `breaking-news` than `qa-interview`).
- Topic-class engagement patterns show platform asymmetry (e.g. macro topics underperform on Reddit but overperform on Substack).
- The recommendations harden into a content calendar.

## Pairing with topic-cooldown

`engagement-feedback` tells you **what worked**. `topic-cooldown.py` (next door at `~/Documents/cue/scripts/topic-cooldown.py`) tells you **what's burnt out**. Run both before deciding the next article's angle:

```bash
# 1) what's been working?
/engagement-report --days 30

# 2) given the proposed primary, is it too recent?
python3 ~/Documents/cue/scripts/topic-cooldown.py --primary "rare-earth" --cooldown-days 14
```

## Failure modes

| Symptom | Cause | Fix |
|---|---|---|
| "no articles with `postiz:` back-write found" | downstream skills haven't been wired yet, or no drafts shipped | Check `/trend-to-thread` Phase 7 back-write step |
| `postiz analytics:post <id>` errors for all posts | posts still in draft mode (not published) | Engagement only accrues on scheduled/published posts |
| Engagement numbers look identical across posts | analytics returning cached or 0-data | Increase `--days`, verify Postiz integration is healthy |
| Empty voice-mix ranking | older drafts pre-date the voice library | Older drafts without `voices:` frontmatter aggregate under `(none)` — they're just legacy data |

## Sister tooling

- `~/Documents/cue/scripts/engagement-report.py` — the implementation
- `~/Documents/cue/scripts/topic-cooldown.py` — companion gate (what's burnt out)
- `~/Documents/cue/resources/skills/skills/content/article-writer/voices.md` — the persona universe being audited
