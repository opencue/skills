# Preset: breaking-news

**Reads like**: Reuters / Bloomberg wire / FT Alphaville first-take.
**Length**: 600-1100 words.
**Voices**: none. Inverted-pyramid news structure.

## Structure (inverted pyramid — heaviest information first)

```
1. Headline (H1, ≤70 chars) — the news in one line. Active voice. Past tense for completed events, present for ongoing.

2. Dateline — one line: [Location] — [Date] —
   Example: "BRUSSELS — 25 May 2026 —"

3. Lede — one paragraph (50-80 words).
   - The 5 Ws in one sentence (Who did What, When, Where, Why).
   - The first 20 words must stand alone as a tweet-grade summary.

4. Nut graf — one paragraph (60-100 words).
   - Why this matters NOW. What changed from yesterday's status.
   - Names the stakes for the reader's domain (markets, policy, ops).

5. Key facts — bullet list or short numbered list (5-8 items).
   - Each item: one sentence, one number or named entity per item.
   - Each item cited {#source}.
   - Order: most market-moving / consequential first.

6. Context — H2 section, 100-200 words.
   - What was the situation before this happened.
   - What's the precedent (2010 rare-earth crisis, 2022 SWIFT cutoff, etc.).
   - Cite the precedent {#source} if you reference a specific year/event.

7. Reactions / implications — H2 section, 120-220 words.
   - Named entities' reactions (governments, companies, regulators).
   - If markets moved, name the move (FX, equity, commodity, rates).
   - Cite each reaction {#source}.

8. What's next — H2 section, 80-150 words.
   - The next dated event (meeting, deadline, earnings release).
   - The earliest credible resolution path.
   - The specific signal to watch.

9. Sources block in frontmatter.
```

## News voice rules

- **Past tense for the event.** Present tense for ongoing situations. Future tense ONLY for scheduled events with names ("the G20 summit on 12 June").
- **Attribute everything non-obvious.** "According to [source], [claim] {#source}." Don't editorialize.
- **No adjectives that imply judgment.** "Dramatic" / "shocking" / "unprecedented" → cut. If it's actually unprecedented, prove it with a date.
- **Numbers are exact or ranged.** Not "roughly hundreds" — say "between 200 and 400."

## Anti-patterns

- ❌ Lede that buries the news ("In a development that surprised analysts..." → just say what happened).
- ❌ Quote in the lede → no. Lede is fact. Quotes start in reactions.
- ❌ Speculative "could / may / might" in the first three paragraphs → save uncertainty for the "what's next" section.
- ❌ Calling the event "historic" / "landmark" in the headline → let the reader decide.
- ❌ Writing two news stories in one piece → split them.
