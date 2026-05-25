---
name: article-writer
description: >-
  Use when user says "/article", "write me an article", "draft a long-form piece",
  "Q&A interview style article", "op-ed", "sector analysis", "listicle", "breaking news",
  "blog post about X", or asks for any topic-agnostic long-form English/Hungarian content.
  Topic-agnostic. Pairs with /trend-to-thread for the article → thread → social pipeline.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# article-writer — topic-agnostic long-form authoring

Five reusable presets, one shared voice library, mandatory source-discipline and slop-gate. Built so the next article doesn't get reproduced ad-hoc; it gets composed from parts that already have a proven cadence.

## When to use which preset

| Preset | When | Length |
|---|---|---|
| `qa-interview` | Topic has 2-3 distinct stakeholder perspectives. Need to surface tension. Reads like BeInCrypto / Bloomberg interview. | 1800-2500 words |
| `op-ed` | Single thesis, author voice forward, opinion-driven. Reads like FT comment / Stratechery. | 800-1400 words |
| `sector-analysis` | Map a market — players, drivers, risks, outlook. Reads like a16z / a-research note. | 1400-2200 words |
| `listicle` | 5-12 discrete items with shared logic. Reads like NotBoring / Wait But Why. | 1200-2000 words |
| `breaking-news` | News story today. Lede + context + implications. Reads like Reuters / Bloomberg wire. | 600-1100 words |

Read the matching `presets/<name>.md` for the structure. Don't free-write — the presets exist precisely to stop ad-hoc reproduction.

## Invocation

```
/article <preset> "<topic>" [--voices a,b,c] [--lang en|hu] [--length short|standard|long]
```

Examples:
- `/article qa-interview "China rare-earth halt → Europe EV/defense exposure" --voices eu-policy-analyst,jp-trade-neg,cee-auto-ops`
- `/article op-ed "Why the 6× rare-earth premium does not buy a refinery" --voices none --length short`
- `/article sector-analysis "Non-Chinese rare-earth refining capacity, 2026-2030" --voices macro-strategist,defense-procurement`
- `/article breaking-news "DeepSeek announces permanent inference price cuts" --lang en`

`--voices none` skips composite quotes and writes in single author voice.

## Pipeline (5 phases — all mandatory)

### Phase 1 — confirm topic + preset + voices, run cooldown gate

If the user invokes without args, ask three questions:
1. Topic (one sentence)
2. Preset (offer the 5 choices)
3. Voice mix (offer recommended set or `none`)

If args present, restate the chosen combination in one sentence before starting. Surface ambiguity, do NOT silently pick.

**Topic-cooldown gate (MANDATORY, runs as soon as the primary keyword is known):**

```bash
python3 ~/Documents/cue/scripts/topic-cooldown.py --primary "<proposed primary keyword>" --cooldown-days 14
```

If exit 1: surface the recent overlapping drafts, ask the user to confirm with one of three paths:
1. Pick a different angle (recommended) — re-run topic-cooldown with the new primary
2. Increase `--cooldown-days` for this run only (if there's a strong reason to revisit)
3. Pass `--warn-only` (escape hatch, used sparingly — audiences notice repetition)

Do NOT proceed to Phase 2 until cooldown returns exit 0 or the user explicitly overrides.

### Phase 2 — source-discipline frontmatter

The article frontmatter MUST include a `sources:` list when any non-obvious factual claim is made. Each source gets a stable key referenced inline as `{#key}`.

```yaml
---
title: "..."
date: 2026-MM-DD
preset: qa-interview
voices: [hk-allocator, eu-policy-analyst]
sources:
  eu-parl-2025-nov: "EU Parliament think-tank report on critical raw materials, November 2025"
  japan-times: "Japan Times reporting on rare-earth export halts, December 2025"
  csis: "CSIS dual-use end-use review analysis, May 2026"
---
```

In the body, every non-obvious claim attributes inline:

> Refined heavy rare earths now trade at a 6× premium outside China {#eu-parl-2025-nov}. Mitsubishi Heavy has been named explicitly in dual-use end-use reviews {#csis}.

The cross-check runs in Phase 5.

### Phase 3 — load the preset + voices

```bash
# from inside the article generation, the skill reads:
PRESET=$(cat $SKILL_DIR/presets/<preset>.md)
VOICES=$(cat $SKILL_DIR/voices.md)
# then writes the article per the preset's structure, pulling persona lines from VOICES
```

The preset file dictates the section headings, sequence, and rhythm. The voices file provides reusable composite personas with established tone, geography, and specialty.

### Phase 4 — write to drafts/

```
~/Documents/cue/drafts/YYYY-MM-DD-<slug>.md
```

Slug rules: lowercase, ASCII (strip diacritics), kebab-case, ≤60 chars. Strip Hungarian accents (`á→a`, `é→e`, `ő→o`, etc.) — match the convention in `medusa/marva-blog-author`'s slug algorithm.

### Phase 5 — mandatory pre-publish gates

Run BOTH in sequence. Article cannot move to /trend-to-thread or any publish path until both exit 0.

**5a. Sources gate:**
```bash
python3 ~/Documents/cue/scripts/article-sources-lint.py <draft.md>
```
Verifies every `{#key}` in body has a matching entry in frontmatter `sources:`, and warns on unused sources.

**5b. Slop gate:**
```
Invoke the ai-slop-detector skill against <draft.md>.
```
Returns AI-Slop score + Comprehension score. **Must score AI-Slop ≤ 30 and Comprehension ≥ 70 before publish.** If either fails, surface specific findings, rewrite, re-lint.

If both pass: article is ready. Hand off to the next step (publish, /trend-to-thread for X, repurpose, etc.).

### Phase 6 — SEO post-pass (after gates pass)

Once Phase 5a + 5b are clean, automatically derive SEO metadata. Write to a sister file at `~/Documents/cue/drafts/YYYY-MM-DD-<slug>.seo.md`:

```yaml
---
canonical: "<intended public URL or empty>"
titles:
  - "<title variant 1 — most direct>"
  - "<title variant 2 — number/data-led>"
  - "<title variant 3 — question or contrarian>"
meta_description: "<≤155 chars, complete sentences, includes primary keyword early>"
og:
  title: "<≤60 chars>"
  description: "<≤160 chars>"
  image: "<hero image path>"
twitter:
  title: "<≤70 chars>"
  description: "<≤160 chars>"
  image: "<hero image path>"
keywords:
  primary: "<the one keyword the title targets>"
  secondary: ["<5-7 related>"]
ai_search_optimized: true | false  # flagged when geo-content-optimizer recommendations applied
---
```

Invoke the existing skills already in this profile:
- **`meta-tags-optimizer`** for the title/meta/OG/Twitter variants.
- **`ai-seo`** + **`geo-content-optimizer`** for the AI-search-optimized version (helps ChatGPT/Perplexity/AI Overviews surface the piece).

Surface the 3 title variants to the user — they pick before publishing. Don't auto-decide; title is the highest-leverage CTR variable.

After Phase 6, set frontmatter `status: linted`. The article is now ready for either:
- direct publish (blog / Ghost / Medium with the canonical URL)
- `/trend-to-thread` (X thread)
- `/article-to-everywhere` (X + LinkedIn + Substack + Reddit fan-out)

## Output convention

Every article frontmatter must have:

```yaml
---
title: "<headline, ≤70 chars>"
date: YYYY-MM-DD
preset: <one of the 5>
voices: [<list of voice slugs, or empty if --voices none>]
length_target: "<from preset, e.g. 1800-2500>"
lang: en | hu
status: draft   # draft | linted | published
sources:
  <key>: "<full citation: publisher, date>"
disclaimer: "<if composite voices used, the standard disclaimer (see below)>"
---
```

**Composite-voices disclaimer** (copy verbatim when any voice from `voices.md` is used):

> Voices below are composite personas synthesized from on-record briefings and off-record conversations. They do not represent any single named individual. All numerical claims are sourced to the public reporting noted in the front matter.

## Why this skill exists (don't drift)

The Karpathy + Volaria voice rules apply:
- **No speculative framing.** If a number isn't sourceable, don't write it.
- **No persona drift.** The voices in `voices.md` have fixed geography, tone, and specialty. Don't have an "Asian family-office allocator" suddenly opine on Bay Area AI infra — use `ai-infra-founder` instead.
- **No filler.** "It is important to note that..." dies on the first read. Lead sentences with the verb or the answer.
- **No real-named quotes.** Composites only. Real names appear ONLY when sourced quotes are cited inline `{#key}`.

## Sister tooling

- `~/Documents/cue/scripts/article-sources-lint.py` — Phase 5a gate.
- `ai-slop-detector` skill — Phase 5b gate.
- `~/Documents/cue/resources/skills/skills/content/trend-to-thread/SKILL.md` — downstream pipeline; consumes article drafts produced here.
- `~/Documents/cue/resources/prompts/hero/volaria-news-card.md` — visual identity for Volaria-branded publishes.
