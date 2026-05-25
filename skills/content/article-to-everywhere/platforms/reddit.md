# Platform converter: Reddit

**Output**: title + body markdown + recommended subreddit list.
**Lint**: title length + TL;DR presence + subreddit-rule check.
**Postiz path**: yes (if `reddit` integration connected), with `settings.subreddit[]` config.

## Title rules

- 60-120 chars. Reddit shows up to ~300 on desktop but mobile truncates at ~80.
- Lead with the news + a specific number where possible:
  - ✓ "China's rare-earth exports to Japan have been zero since December — 80% of EU industrial firms are 3 hops away from the same supply chain"
  - ✗ "Thoughts on the rare-earth situation"
- No clickbait (Reddit downvotes hard) — be specific, not provocative.
- Capitalize properly (title case OR sentence case — pick one and stick with it across submissions).

## Body structure (REQUIRED order)

```
1. **TL;DR** — 2-3 bullets at the very top. Reddit readers scroll past anything without one.

2. **Context** — 1 paragraph naming the news + the date + the source.

3. **The facts** — 4-7 numbered points with sources linked inline (markdown).

4. **Why it matters** — 1-2 paragraphs on implications.

5. **What to watch** — 1 paragraph naming next dated events.

6. **Sources** — list at bottom with links.

Total: 400-1200 words depending on subreddit norms.
```

## Subreddit picker by topic class

| Topic class | Primary subs | Secondary |
|---|---|---|
| Crypto / RWA | `r/CryptoCurrency`, `r/CryptoMarkets` | `r/ethfinance`, `r/Bitcoin` (audience-dependent) |
| Macro / markets | `r/investing`, `r/SecurityAnalysis` | `r/StockMarket`, `r/wallstreetbets` (caution: meme culture) |
| Geopolitics / supply chain | `r/geopolitics`, `r/IRstudies` | `r/europe` (for EU angle), `r/economics` |
| AI / compute | `r/MachineLearning`, `r/artificial` | `r/singularity`, `r/LocalLLaMA` (technical depth) |
| Defense industrial | `r/CredibleDefense` (strict moderation), `r/LessCredibleDefence` | `r/WarCollege` |
| Energy / EV | `r/electricvehicles`, `r/energy` | `r/RenewableEnergy`, `r/oil` |
| Hungarian / CEE | `r/hungary`, `r/europe` | `r/CentralEuropeans` |

**Hard rules per sub:**
- `r/CredibleDefense`: cite primary sources for every claim. Comment moderation is strict.
- `r/investing`: no penny-stock or memes. Substance-only.
- `r/wallstreetbets`: opposite. Memes, brevity, position-disclosure. Different writing entirely.
- `r/europe`: politically sensitive — keep claims sourced and neutral.

Pick 1-3 subs per article, never the same set twice in a week (looks like spam).

## Self-promo gate

Most subs have rules against self-promotion. Read each sub's wiki BEFORE submitting:
- `r/investing` — no blog/Substack/Twitter links. Link to primary sources only.
- `r/CryptoCurrency` — strict no-promo. Original analysis only.
- `r/europe` — link rules vary, but blog self-promo is downvoted.

If the article links back to your Substack/X, **strip those links** from the Reddit body. Reference sources directly.

## Postiz JSON shape (Reddit-specific settings)

```json
{
  "type": "draft",
  "posts": [{
    "integration": {"id": "<reddit integration id>"},
    "value": [{"content": "<body>", "image": [], "delay": 0}],
    "settings": {
      "subreddit": [{
        "value": {
          "subreddit": "<chosen-sub>",
          "title": "<title>",
          "type": "text",
          "url": "",
          "is_flair_required": false
        }
      }]
    }
  }]
}
```

If the sub requires flair: set `is_flair_required: true` and add `flair_id` to the settings.

## Lint rules

```bash
# title 60-120 chars
# body must start with **TL;DR** (case-insensitive ok)
# at least 2 inline markdown source links
# no self-promo Substack/X links (lint warns)
# subreddit name validated against picker map
```

## Anti-patterns

- ❌ No TL;DR → downvoted within minutes
- ❌ Wall of text without paragraph breaks → mobile users skip
- ❌ Capitalized title ("BREAKING:" / "SHOCKING:") → flagged as low-quality
- ❌ Posting to the same sub more than once a week → throttled or shadowbanned
- ❌ Copy-paste of the X thread in Reddit body → wrong tone, gets downvoted
- ❌ Posting to a sub where your topic isn't aligned (`r/wallstreetbets` for a 1800-word geopolitics piece) → ignored
