# Platform converter: LinkedIn

**Output**: single long-form post (~1000-1300 chars visible) + 3-5 hashtags + image suggestion.
**Lint**: word count + hashtag count + no cashtag check.

## Derivation rules

LinkedIn is **professional voice**, not Twitter voice. The article gets reframed for a B2B / industry audience:

- **First 2 sentences (≈200 chars)** are the "hook above the fold" — what appears before LinkedIn's "see more" expander. Must stand alone as a complete claim.
- Body: 800-1100 chars expanding the claim with 2-3 concrete data points from the article.
- Closer: a question or call-to-action that prompts discussion (e.g. *"Which exposure are you watching most closely?"*).

## Tone shift from X

| X | LinkedIn |
|---|---|
| "Not a slowdown. A halt." | "What's notable here is that the December 2025 export volume to Japan dropped to zero — not a gradual decline." |
| `$NVDA` | "Nvidia" |
| "Beijing's leverage is structural. They don't need a deal." | "The structural asymmetry is what stakeholders should focus on: Beijing has demonstrated the toolkit; the timeline pressure now sits on the importing side." |
| 🧵 | (no emoji) |

LinkedIn rewards completeness + nuance. X rewards punch + brevity. Same facts, different cadence.

## Hashtag rules

- 3-5 hashtags max. More = penalized by the algo.
- Place hashtags at the end, on a separate line, separated by spaces.
- Use established topical hashtags: `#supplychain`, `#criticalminerals`, `#eumeu`, `#geopolitics`, `#ai`, `#fintech`, `#crypto`, `#defense`, `#energy`, `#ev`, `#trade`.
- Avoid: branded hashtags unless they're already trending; ALL CAPS hashtags; >2-word hashtags; hashtags inside body.

## NO cashtags

LinkedIn does NOT surface `$TICKER` as cashtags. Drop the `$`, write the company name + parenthetical ticker:

> Lockheed Martin (NYSE: LMT)
> Mitsubishi Heavy (TYO: 7011)
> MP Materials (NYSE: MP)

## Image attachment

LinkedIn favors **a single landscape image** (1.91:1 or 1200×627). Reuse the article's hero image (16:9 crop) if available. If brand=volaria, use the volaria-news-card template at 1.91:1 aspect.

## Postiz JSON shape

```json
{
  "type": "draft",
  "creationMethod": "CLI",
  "date": "<placeholder>",
  "shortLink": true,
  "tags": [],
  "posts": [{
    "integration": {"id": "<linkedin integration id>"},
    "value": [{
      "content": "<full LinkedIn body, with line breaks and hashtags>",
      "image": [{"id": "<uploaded image>", "path": "..."}],
      "delay": 0
    }]
  }]
}
```

## Anti-patterns

- ❌ "I'm excited to share..." / "Today I'm thinking about..." — leads as filler, LinkedIn readers scroll past
- ❌ Threads/multiple posts (Postiz can chain LinkedIn replies but the algo doesn't push them) — single post performs better
- ❌ Tagging people in body without permission — looks spammy if they don't engage
- ❌ Generic CTAs ("What do you think?") — be specific ("Which CEE OEM has the strongest buffer?")
- ❌ Auto-pasting the X thread verbatim — X voice on LinkedIn reads as inappropriate
