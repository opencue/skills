---
name: trend-to-thread
description: >-
  End-to-end pipeline that chains trendradar → article-writer → X thread →
  Higgsfield hero image → Postiz draft in a single shot, turning a current
  trend topic into a posted-ready social thread with a generated hero
  image. Use when user says "/trend-to-thread", "post a trend thread",
  "build a thread from trends", "új X thread mai trendből", or "Postiz X
  poszt mai trendekből".
allowed-tools:
  - mcp__trendradar__get_trending_topics
  - mcp__trendradar__get_latest_news
  - mcp__trendradar__search_news
  - mcp__trendradar__find_related_news
  - mcp__trendradar__analyze_topic_trend
  - mcp__trendradar__analyze_sentiment
  - mcp__higgsfield__balance
  - mcp__higgsfield__generate_image
  - mcp__higgsfield__job_status
  - mcp__higgsfield__models_explore
  - WebSearch
  - Bash
  - Read
  - Write
  - Edit
---

# trend-to-thread — end-to-end TrendRadar → X thread → Postiz draft pipeline

Single-command runbook for the workflow that turned "ezen a napon mit lehet posztolni" into a published-ready Postiz draft with a Higgsfield hero image. Optimized for the **trendradar+postizz** profile on this machine. Hungarian or English topic input both work.

## Inputs

```
/trend-to-thread <seed>?      <-- optional. one of:
  auto                          → pull top trends, suggest 3-5 angles, ask user to pick
  "<topic seed>"                → use this topic literally (e.g. "China rare-earth export halt")
  --resume <draft-id>           → reopen a Postiz draft by ID and rebuild the image
```

If no seed is given, default to `auto`.

## Pre-flight (skip the slow stuff when possible)

1. **Higgsfield auth check** — call `mcp__higgsfield__balance` first.
   - If it returns credits → already authed, skip the OAuth dance.
   - If 401 / disconnected → walk the user through `mcp__higgsfield__authenticate` → wait for callback URL.
2. **Postiz reachability** — `curl -fsS http://localhost:4007 >/dev/null` or `postiz auth:status`. Bail with a helpful message if Postiz is down ("start the stack with `cd ~/Documents/postiz-app && docker compose up -d`").
3. **Integration ID** — read `postiz integrations:list -o json | jq '.[] | select(.identifier=="x") | .id'`. Don't hardcode the ID; it varies per account/instance.

## Pipeline (7 phases — each must finish before the next)

### Phase 1 — ROI-ranked ideation

Produce 3–5 candidate angles **ranked by predicted ROI**, in the conclusion-first format the blog-writer profile mandates (summary table first, prose verdicts second, no field-name skeleton, one explicit "Pick this one" line at the bottom).

#### 1.1 Signal pull (parallel)

- `mcp__trendradar__get_trending_topics(mode="daily", extract_mode="auto_extract", top_n=25)`
- `mcp__trendradar__get_latest_news(limit=60)`
- Cross-correlate: topics in BOTH trending keywords AND multiple platform top-3 are the cross-platform signals worth a thread. Filter out celebrity / regional sports / Mainland-China-domestic noise unless the user's audience is that.

#### 1.2 Competitive scan (web search per candidate)

For each top topic (≤5), call `WebSearch` with two queries to size up coverage saturation and identify the undercovered angle:

- `<topic> site:finance.yahoo.com OR site:bloomberg.com OR site:reuters.com` → what mainstream finance covered already
- `<topic> analysis OR "hot take"` → what financial X / Substack already said

Note for each candidate:
- **Coverage count** — how many top-tier outlets ran it (saturation proxy)
- **Dominant angle** — what take is everybody already running
- **Open angle** — what nobody's said yet that we could own

The highest-ROI ideas have a **strong catalyst with an undercovered angle**. Don't write the 5th version of a Bloomberg take.

#### 1.3 ROI score each candidate (0–25)

| Axis | 1 | 3 | 5 |
|---|---|---|---|
| **Catalyst clarity** | vague trend | known event, no date | binary headline + dated window |
| **Asymmetry** | symmetric risk | tilted up | defined downside, big upside |
| **Saturation (inverted)** | covered everywhere | 1–2 outlets | undercovered / fresh angle |
| **Brand fit (volaria)** | non-finance | tangential | core markets / tape / macro |
| **Time-decay risk** | intraday only | days | multi-week thesis |

Total: **15+ = strong, 10–14 = solid, <10 = skip.**

#### 1.4 Emit the ideation block (conclusion-first, blog-writer rules)

**Summary table first** (scan layer):

| Rank | Topic | Verdict (1-line, plain language) | ROI |
|---|---|---|---|
| 1 | … | "Binary catalyst, 30-day window, nobody's writing the supply-chain angle." | 19/25 |
| 2 | … | "Multi-quarter trend, low variance, fits volaria macro voice." | 16/25 |

**Per-item prose** (depth layer): 2–3 sentences each, no "Setup / Vehicle / Risk / ROI" field-name skeleton. Lead each item with the **bolded verdict** in plain language, then catalyst + vehicle + asymmetry + what-mainstream-missed flow as natural prose. Include the cashtag(s) inline, suggest the volaria card template (`tri-band-cinematic` / `billboard` / `ticker-tape` / `magazine`), and note image direction.

**End the block with one `Pick this one →` sentence** naming the top angle to run with, in plain language ("This one — binary headline + 30-day window + nobody's posted the spread trade angle"). Don't leave the user weighing 5 options without a recommendation.

#### 1.5 Confirm with user

Show the ranked block, surface your recommendation, wait for their pick (they may override). Proceed to Phase 2 with the chosen angle.

#### Seed mode (`"<topic seed>"`)

Skip steps 1.1–1.4. Run a one-topic competitive scan (just step 1.2 against the supplied seed) for sanity, surface what's already been said + the open angle, then proceed to Phase 2.

### Phase 2 — draft the long-form article

**Delegate to the `article-writer` skill** — do NOT free-write the article here. The skill owns the preset templates, voice library, and source-discipline conventions.

```
/article <preset> "<topic>" [--voices a,b,c] [--lang en|hu]
```

Default preset: `qa-interview` (the BeInCrypto/Arcanum format that lands on this account). Other presets: `op-ed`, `sector-analysis`, `listicle`, `breaking-news`. See `~/Documents/cue/resources/skills/skills/content/article-writer/SKILL.md` for the full picker.

Voices come from `~/Documents/cue/resources/skills/skills/content/article-writer/voices.md`. Pick 2-3 for `qa-interview`, 1-2 for `sector-analysis`. Default voice picks per topic class:

| Topic class | Default voices |
|---|---|
| Institutional crypto / RWA | `hk-allocator`, `us-vc-partner`, `eu-prime-broker` |
| Geopolitics / supply chain | `eu-policy-analyst`, `jp-trade-neg`, `cee-auto-ops` |
| Macro / market positioning | `macro-strategist`, `us-vc-partner`, `quant-hedge` |
| AI compute / infra | `ai-infra-founder`, `us-vc-partner`, `macro-strategist` |
| Defense industrial | `defense-procurement`, `eu-policy-analyst`, `ir-head` |
| Shipping / logistics | `sg-logistics`, `macro-strategist`, `eu-policy-analyst` |

Article output lands at `~/Documents/cue/drafts/YYYY-MM-DD-<slug>.md` with frontmatter that includes `sources:` and `voices:` lists.

**Phase 2 cannot finish until both gates below pass.** Source-discipline + slop-detector are mandatory:

```bash
# 2a — sources gate
python3 ~/Documents/cue/scripts/article-sources-lint.py ~/Documents/cue/drafts/<draft>.md
# must exit 0

# 2b — slop gate
# invoke the ai-slop-detector skill against the draft
# must score AI-Slop ≤ 30 and Comprehension ≥ 70
```

If either gate fails, surface findings, rewrite, re-run. No exceptions — both gates protect the brand voice.

### Phase 3 — derive the X thread

Write to `~/Documents/cue/drafts/YYYY-MM-DD-<slug>-thread.md` with `## Tweet N (description)` headers, body below each.

**Hard rules** (the `x-thread-lint.py` enforces these — see Phase 5):
- Each tweet **≤ 280 chars**.
- Each tweet has **at most ONE `$TICKER` cashtag**. The rest of the tickers must drop their `$` or move to a different tweet. Counted per-tweet, not per-thread. Violation = `nonRetryable` Postiz failure with "maximum of one cashtag". Full rationale: `rules/postiz/x-cashtag-limit.md`.

Target 8-10 tweets. Tweet 1 is a hook with 🧵, last tweet is a closer / aphorism. Distribute cashtags across tweets to maximize discoverability without breaking the rule.

### Phase 4 — generate the hero image

**Branch on brand first.** Default to VOLARIA unless the user names another brand or explicitly asks for an unbranded editorial image.

#### Volaria-branded mode (default for this account)

Use the canonical template at `~/Documents/cue/resources/prompts/hero/volaria-news-card.md`:

- Vertical **4:5** layout, three bands (header with logo / cinematic middle / massive condensed-sans headline).
- Pass `medias: [{value: <logo_media_id from template frontmatter>, role: "image"}]` so the Volaria logo is the literal reference image — NOT redrawn.
- Generate **one card per tweet** in the thread (so the thread is a sequence of branded news-cards, not one hero + plain replies).
- Fill the 4 slots per card: `MIDDLE_IMAGE_DESCRIPTION`, `HEADLINE_LINE_1`, `HEADLINE_LINE_2`, `HEADLINE_LINE_3`, `SUB_LABEL`. The headline is what *the card* says (e.g. `LOCKHEED / MARTIN'S / F-35 EXPOSED.`); the ticker stays in the tweet text (one cashtag per tweet, no exceptions).

#### Unbranded editorial mode (legacy / one-offs)

- Pick prompt template from `~/Documents/cue/resources/prompts/hero/` if one matches the topic class (finance-editorial, geopolitics-news, tech-product, crypto-rwa). Fill the topic slot.
- Default model: `nano_banana_pro` at `resolution=2k`, `aspect_ratio=16:9`. Always preflight cost with `get_cost: true` before spending credits.

#### Common to both modes

- Generate, poll `job_status` with `sync=true` until `status=completed`, download the `rawUrl` PNG to `~/Documents/cue/drafts/hero-YYYY-MM-DD-<slug>-T<n>.png`.
- **Postiz 10 MB upload cap:** if any 2k PNG exceeds ~10 MB, re-encode to JPEG with `ffmpeg -i in.png -q:v 4 out.jpg` (typically lands at 600-800 KB) before `postiz upload`. JPEG path uploads fine and renders identically on X.

### Phase 5 — lint the thread

```bash
python3 /home/deadpool/Documents/cue/scripts/x-thread-lint.py \
  ~/Documents/cue/drafts/YYYY-MM-DD-<slug>-thread.md
```

**Must exit 0** before proceeding. If exit 1: surface the per-tweet failures, fix in the .md, re-lint. No exceptions — this is the gate that prevents the `nonRetryable` X failure mode.

### Phase 6 — assemble the Postiz JSON payload

Write to `~/Documents/cue/drafts/YYYY-MM-DD-<slug>-postiz.json`. Shape (validated against the Postiz CLI source on this machine):

```json
{
  "type": "draft",
  "creationMethod": "CLI",
  "date": "YYYY-MM-DDTHH:MM:SS+02:00",
  "shortLink": true,
  "tags": [],
  "posts": [{
    "integration": {"id": "<from integrations:list>"},
    "value": [
      {
        "content": "tweet 1 body",
        "image": [{"id": "<from postiz upload>", "path": "http://localhost:4007/uploads/.../*.png"}],
        "delay": 0
      },
      {"content": "tweet 2 body", "image": [], "delay": 0}
    ],
    "settings": {"who_can_reply_post": "everyone"}
  }]
}
```

Gotchas (learned the hard way):
- `tags` MUST be `[]` or array-of-objects. Plain string tags → 400 "must be either object or array".
- The `date` field is required even for `type: draft`. Use a placeholder ~2 days out; drafts don't auto-publish.
- Hero image goes ONLY on tweet 1's `image` array. Don't replicate across the thread.
- Lint the JSON: `python3 /home/deadpool/Documents/cue/scripts/x-thread-lint.py <payload>.json`.

### Phase 7 — upload media + create draft

```bash
postiz upload ~/Documents/cue/drafts/hero-YYYY-MM-DD.png
# capture {id, path} from response, paste into payload JSON tweet 1's image array

postiz posts:create --json ~/Documents/cue/drafts/YYYY-MM-DD-<slug>-postiz.json
# capture postId from the response
```

Output to user: Postiz draft ID + `http://localhost:4007` preview URL + reminder to flip `draft → schedule` in the UI when ready.

**Phase 7b — back-write postId into source article frontmatter (MANDATORY).**

The engagement-feedback skill needs to join Postiz analytics ↔ article-level choices. The only stable join key is the postId, written into the article that generated this post.

```yaml
# add to article frontmatter immediately after Postiz draft creation
postiz:
  x: <postId from postiz posts:create response>
```

If the article already has a `postiz:` block (e.g. fan-out from `/article-to-everywhere` already wrote `linkedin:`), merge — don't overwrite. Each platform gets its own key (`x`, `linkedin`, `substack`, `reddit`, etc.).

Without this back-write, `/engagement-report` will have nothing to correlate. Treat it as a hard step, not a nice-to-have.

## Failure modes — learned

| Symptom | Root cause | Fix |
|---|---|---|
| `400 tags.each value … must be either object or array` | passed string tags | set `"tags": []` |
| `nonRetryable: maximum of one cashtag` | tweet had `$X $Y` | drop $ from one, or split tweets |
| Image not showing in preview | uploaded fine but `image: []` in payload | re-edit JSON, redeploy |
| Postiz CLI lacks `posts:update` | by design | delete + recreate (or use the HTTP API PATCH — see follow-up wrapper) |
| Higgsfield generates wrong style | prompt too vague | reuse a `prompts/hero/*.md` template, don't free-write |

## Out of scope (do NOT extend this skill to cover)

- LinkedIn / Threads / Bluesky reformatting — different skill (`/multi-platform-fanout`, not built yet).
- Auto-publishing without user review — drafts only. The flip to `schedule` is a human decision.
- Article-to-blog publish (e.g. Ghost/Medium) — keep the .md in `drafts/` for now; a `/publish-article` skill can come later.

## Sister tooling

- `~/Documents/cue/scripts/x-thread-lint.py` — the gate enforced in Phase 5.
- `~/Documents/cue/resources/prompts/hero/` — Higgsfield prompt templates (extend as new topic classes are encountered).
- `rules/postiz/x-cashtag-limit.md` — the upstream constraint this skill defends against.
