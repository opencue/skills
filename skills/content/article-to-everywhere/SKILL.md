---
name: article-to-everywhere
description: >-
  Use when user says "/article-to-everywhere", "repurpose this article",
  "make a thread + LinkedIn from this", "derive social copy", "send everywhere",
  "X+LinkedIn+Substack+Reddit", or has a finished long-form article and wants
  the per-platform derivatives. Takes a markdown article, outputs platform-shaped
  copy + (where Postiz integration exists) draft posts.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# article-to-everywhere — one article, four platforms

Takes a finished long-form article (typically from `/article` in the `article-writer` skill) and derives platform-shaped copy for X, LinkedIn, Substack, and Reddit. Where Postiz integration exists for the platform, it also submits a draft post directly. Where it doesn't, it writes a paste-ready .md to drafts/.

**Not the same as `/trend-to-thread`.** That skill takes a *topic* and produces an X thread end-to-end. This skill takes a *finished article* and derives 4-platform deliverables.

## When to use

- Long-form Q&A or sector-analysis just landed and you want maximum surface area in one pass.
- A particularly important article warrants more than just an X thread.
- You're testing which platforms actually move the needle (engagement loop, see future-work).

## Invocation

```
/article-to-everywhere <draft-path> [--platforms x,linkedin,substack,reddit] [--postiz draft|schedule|skip] [--brand volaria|none]
```

Defaults:
- `--platforms`: `x,linkedin,substack,reddit` (all four)
- `--postiz`: `draft` (no auto-publish, ever)
- `--brand`: `volaria` (the account's default brand)

Examples:
- `/article-to-everywhere ~/Documents/cue/drafts/2026-05-25-rare-earth-japan-halt.md`
- `/article-to-everywhere <path> --platforms x,linkedin --postiz draft`
- `/article-to-everywhere <path> --platforms substack --postiz skip` (just produce the .md, no posting)

## Pipeline (6 phases)

### Phase 1 — read + validate the source article

```python
article = read(<draft-path>)
fm, body = parse_frontmatter(article)
assert fm.get("status") in ("linted", "published"), "Article must pass article-writer's source + slop gates before repurposing."
```

If status is `draft`, refuse — run `/article` Phase 5 gates first.

### Phase 2 — detect available Postiz integrations

```bash
postiz integrations:list -o json
```

Parse the response; map `identifier` → `id`. Cache the map for Phase 5.

Known identifier strings: `x`, `linkedin`, `threads`, `bluesky`, `reddit`, `facebook`, `instagram`, `youtube`, `tiktok`, `pinterest`, `discord`, `slack`, `mastodon`, `farcaster`.

**Substack is not a Postiz integration** — Postiz doesn't drive Substack. Substack output is always a paste-ready .md you copy into the Substack composer.

**Reddit via Postiz** requires the per-post subreddit settings (see `platforms/reddit.md` for the settings JSON shape).

### Phase 3 — per-platform derivation

For each platform in `--platforms`, read the converter at `platforms/<name>.md` and follow its runbook. Each converter is opinionated about:

- character/word length envelope
- tone shift (X = punchy, LinkedIn = professional, Substack = conversational-long, Reddit = narrative-long)
- hashtag/cashtag/tagging conventions
- image attachment recommendation
- CTA / closer style

Each derivative writes to `~/Documents/cue/drafts/<slug>-everywhere/<platform>.md` (and Postiz-ready JSON where applicable).

### Phase 4 — platform-specific lint

| Platform | Lint |
|---|---|
| `x` | `x-thread-lint.py` (≤280 chars/tweet, ≤1 `$TICKER`/tweet) — exit 0 required |
| `linkedin` | Word count 200-300 visible before "see more" expander, ≤1300 total. No `$cashtag`. Hashtags ≤5. |
| `substack` | Subject line ≤55 chars, preheader ≤90 chars, body 600-1000 words. No raw URLs in body — use markdown links. |
| `reddit` | Title 60-120 chars, body 400-1200 words, subreddit rules respected (no self-promo if rule-restricted), TL;DR at top. |

Lint failures STOP the platform's submission but don't abort the others. Surface the failure per-platform.

### Phase 5 — Postiz submission (where applicable)

For each platform with `--postiz draft` AND a detected Postiz integration:

```bash
postiz posts:create --json <slug>-everywhere/<platform>-postiz.json
```

The JSON shape is the same as `trend-to-thread` — verified against the Postiz CLI source on this machine. Reuse the Volaria brand kit (`brands/volaria/`) for image attachments if `--brand volaria`.

**Substack: no Postiz path.** The skill produces a final .md with subject + body, opens a note in the conversation: *"Substack .md ready at <path> — paste into the Substack composer manually."*

**Reddit: subreddit choice matters.** The converter (`platforms/reddit.md`) picks 1-3 subreddit candidates per topic class. Surface the choices, ask user to confirm before submission.

### Phase 5b — back-write postIds into source article frontmatter (MANDATORY)

After every Postiz draft creation in Phase 5, append the resulting postId to the source article's `postiz:` frontmatter block, keyed by platform:

```yaml
postiz:
  x: <postId>
  linkedin: <postId>
  reddit: <postId>
```

If the block doesn't exist, create it. If it exists, merge — never overwrite an existing key (that would lose engagement history from a previous publish).

This back-write is what allows `/engagement-report` to correlate Postiz analytics with article-level choices (voice mix, preset, primary keyword) downstream. Without it, the engagement-feedback loop is broken.

### Phase 6 — summary

Print a per-platform status line:

```
✅ x        → Postiz draft cmpl...
✅ linkedin → Postiz draft cmpl...
✅ substack → drafts/.../substack.md (paste manually)
⚠️  reddit   → drafts/.../reddit.md (no integration, paste manually)
```

Include lint results, link to each derivative file.

## What this skill does NOT do

- **No auto-publish.** All Postiz submissions are `type: draft`. User flips draft→schedule in UI.
- **No engagement-feedback loop.** That's a future skill (`/repurpose-by-engagement`).
- **No bilingual derivation.** EN-only or HU-only, matching the source article's `lang:` frontmatter. Bilingual is a future skill.
- **No Substack scheduling.** Substack output is paste-ready text; submission is manual.

## Failure modes

| Symptom | Cause | Fix |
|---|---|---|
| "Article must pass source + slop gates" | source article `status: draft` | Run `/article` Phase 5 first |
| `postiz integrations:list` returns only `x` | other platforms not yet connected in Postiz UI | Connect via http://localhost:4007 → Integrations |
| LinkedIn lint fails on cashtag | `$TICKER` in LinkedIn body | LinkedIn doesn't surface cashtags; drop the `$` |
| Reddit subreddit-rule violation | each sub has different rules around self-promo, links, formatting | Read the subreddit's wiki; `platforms/reddit.md` has a starting map |

## Sister tooling

- `~/Documents/cue/resources/skills/skills/content/article-writer/SKILL.md` — upstream source
- `~/Documents/cue/scripts/x-thread-lint.py` — Phase 4 X-platform gate
- `~/Documents/cue/scripts/article-sources-lint.py` — pre-condition for Phase 1
- `ai-slop-detector` skill — pre-condition for Phase 1 (re-run if any derivative re-phrases substantively)
