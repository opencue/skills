# Preset: sector-analysis

**Reads like**: a16z research note / Sequoia memo / sell-side initiation report.
**Length**: 1400-2200 words.
**Voices**: 1-2 from `voices.md`, used as supporting commentary not dialog.

## Structure

```
1. Title (H1, ≤70 chars) — names the sector and the angle (e.g. "Non-Chinese rare-earth refining: capacity, capital, and the 5-year window").

2. Executive summary — 4-6 bullets at the top, each 35-60 words.
   - Bullet 1: the sector definition + size estimate {#source}.
   - Bullet 2: the dominant structural feature.
   - Bullet 3: the leading driver (demand-side or policy).
   - Bullet 4: the leading risk (supply, regulatory, technological).
   - Bullet 5: the investable thesis.
   - Bullet 6 (optional): the contrarian read.

3. Market sizing — H2 section, 200-300 words.
   - TAM / SAM if quantifiable {#source}.
   - Geographic / vertical breakdown.
   - Growth rate with named time horizon.

4. Players — H2 section, 250-400 words.
   - 4-7 named entities (companies, sovereigns, projects).
   - For each: one line of positioning, one piece of evidence.
   - Distinguish public / private / state-backed.
   - Note if any are pre-revenue / pre-product.

5. Drivers — H2 section, 250-350 words.
   - 3-5 numbered drivers, each 50-80 words.
   - Mix demand-side (end-customer pull) and policy-side (CRMA, subsidies, sanctions).
   - Cite specific dollar / capacity / volume numbers {#source}.

6. Risks — H2 section, 250-350 words.
   - 3-5 numbered risks symmetric to drivers.
   - Mix execution, regulatory, technological, geopolitical.
   - Distinguish near-term (12-24mo) from structural (5y+).

7. Outlook — H2 section, 200-300 words.
   - 3 scenarios: base case, upside, downside.
   - Each scenario gets one sentence on probability and one on what it would look like.
   - Time horizon named (e.g. "by 2028").

8. Recommendations — H2 section, 150-250 words.
   - For different reader types (allocator, operator, policymaker).
   - 2-3 concrete actions per type.

9. One supporting voice quote (optional)
   - Pull 60-120 words from one voice in voices.md (use the macro-strategist, ai-infra-founder, or matching specialty).
   - Place it after Drivers or Risks for color, not as primary evidence.
   - Cite the composite-voice disclaimer in frontmatter.

10. Sources block (in frontmatter) and disclaimer.
```

## What separates this from a Q&A

- **Sector analysis is single-narrator**, even when it quotes voices. The writer is in charge.
- **Numbers are required**, not optional. If you can't cite the size, you don't have a sector analysis — you have an op-ed.
- **Players section is structural**: anchor names, not generic categories.

## Anti-patterns

- ❌ "The market is huge." → cite the number.
- ❌ Listing 15 companies in a row → 4-7 with positioning, depth over breadth.
- ❌ Scenarios with no probability framing → "could go up or down" is not a scenario.
- ❌ Recommendations that say "evaluate the opportunity" → say what to do.
