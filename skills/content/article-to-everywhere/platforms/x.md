# Platform converter: X (Twitter)

**Output**: 8-10 tweet thread + Postiz JSON.
**Lint**: `x-thread-lint.py` mandatory.

## Derivation rules

- Tweet 1 = hook from the article's TL;DR bullet 1, rewritten for X (more punch, less hedging).
- Tweets 2-8 = one per Q&A section's strongest claim. Pull the most quotable line, condense to ≤280 chars.
- Last tweet = the article's closer, distilled.
- Total: 8-10 tweets.

## Char + cashtag rules (HARD)

- ≤ 280 chars per tweet (Premium-grade limit ignored — design for the basic tier).
- ≤ 1 `$TICKER` per tweet. If a section discusses 3 companies, distribute across 3 tweets or drop the `$` from 2.
- The thread should contain 2-4 cashtags total. More = looks spammy.
- 🧵 emoji at end of tweet 1 only.

## Structure pattern (mirrors a proven thread)

```
T1 — hook + 🧵 (claim + why-now in 2-3 sentences)
T2 — the central counter-intuitive fact
T3-T7 — section-by-section, one claim per tweet, with source attribution in plain text
T8 — implications / investable thesis (this is where cashtags concentrate)
T9 — closer (aphorism, no cashtag, no link)
T10 — (optional) "Full piece: <link>" — only if you have a public URL
```

## Postiz JSON shape

```json
{
  "type": "draft",
  "creationMethod": "CLI",
  "date": "<placeholder ~2 days out>",
  "shortLink": true,
  "tags": [],
  "posts": [{
    "integration": {"id": "<x integration id>"},
    "value": [
      {"content": "<tweet 1>", "image": [<hero kép, ha brand>], "delay": 0},
      {"content": "<tweet 2>", "image": [], "delay": 0},
      ...
    ],
    "settings": {"who_can_reply_post": "everyone"}
  }]
}
```

If `--brand volaria`, generate per-tweet Volaria card images using the `cue/resources/prompts/hero/volaria-news-card.md` template. Otherwise, hero image on T1 only, plain text replies.

## Cost / time

- Lint: <1 sec
- Higgsfield images (brand mode): 1-2 sec per card preflight + 10-20 sec per generation
- Postiz upload + create: 2-5 sec
- Total: ~3-5 min for a full Volaria-branded 10-card thread

## Anti-patterns

- ❌ Numbered tweets ("Tweet 3/10:") — modern X readers find the visual cue from indent + thread connector
- ❌ Hashtags ("#crypto #investing") — they read as spam on X. Cashtags only.
- ❌ Quote tweets of the article hero in the thread body — only Postiz UI handles quote-tweet structure; the CLI doesn't
- ❌ Polls at the end — Postiz CLI doesn't drive polls; add them manually if needed
