# Preset: qa-interview

**Reads like**: BeInCrypto / Bloomberg interview, Arcanum-style Q&A.
**Length**: 1800-2500 words.
**Voices**: 2-3 from `voices.md`.

## Structure

```
1. Title (H1, ≤70 chars)

2. TL;DR lead — 3 bullets
   - Each bullet 35-60 words.
   - Bullet 1: the headline development (with {#source}).
   - Bullet 2: the broader implication / data point (with {#source}).
   - Bullet 3: the local / downstream angle (with {#source} where applicable).

3. Framing paragraphs — 2-3 paragraphs (150-250 words total)
   - Names the concrete news hooks (today's actual data, not generic claims).
   - Establishes the "why this story right now" angle.
   - Sets up the conversation that follows.

4. Voices declaration
   - "The conversation below is a composite synthesis..."
   - List voices with display lines from voices.md.

5. Q&A sections — 8-12 sections, each:
   - H2 section header (5-9 words, no question mark in the header itself)
   - First Q&A: opens the section's topic
   - 2-3 Q&A exchanges per section
   - Each Q is 1-2 sentences (italicized or bolded)
   - Each A is 60-160 words from one voice
   - Mix voices — don't have one voice dominate
   - Use {#source} citations inline for any non-obvious factual claim

6. The Hardest Question — final H2
   - One question that's harder than the rest.
   - 3 answers, one per voice if 3 voices present.
   - Each answer 80-120 words.

7. Closer disclaimer — italics, 2-3 sentences confirming composite nature.
```

## Q&A section topic patterns

For a topic that's a market / industry / policy story, the 8-12 sections typically follow this rhythm:

1. **What actually changed** — establish the substantive news, not the headline
2. **Why X matters specifically** — focus on one named data point (a company, a number, a date)
3. **The big number and what it hides** — surface a counter-intuitive layer beneath the headline
4. **Operational impact** — what it means for someone running an actual business / position
5. **Reactions / political angle** — how stakeholders are responding (negotiations, regulators, etc.)
6. **Local exposure** — concentrated impact (Hungarian corridor, US defense base, etc.)
7. **Realistic mitigation** — what can actually be done in 6-12 months
8. **Where the next-order effects land** — defense, capital, energy, downstream sectors
9. **Capital implications** — investable thesis
10. **The hardest question** — closer

Not every story uses all 10. Cut to 8 if the topic is narrow; expand to 12 if there's genuine depth.

## Question phrasing

Use one of these patterns; mix them, don't repeat the same pattern in adjacent sections:

- **For substance**: *"What actually changed in [timeframe]?"* / *"For readers who only see this in headlines — what is the substantive change?"*
- **For specificity**: *"[Source] specifically named [entity]. Why is that the data point that matters?"*
- **For scale**: *"A [number] sounds like [intuitive reading]. Why isn't it?"*
- **For operations**: *"For a [role] today — what actually [mitigates / changes / matters]?"*
- **For interpretation**: *"Is [event] a [conventional read] or [alternative read]?"*
- **For forecast**: *"Is there a credible scenario where this de-escalates inside [timeframe]?"*

Avoid: "Can you explain X?", "What are your thoughts on...", "How do you feel about...". These read as filler.

## Worked examples in this account

- `~/Documents/cue/drafts/2026-05-25-serious-capital-2026.md` — institutional crypto (Arcanum-style)
- `~/Documents/cue/drafts/2026-05-25-rare-earth-japan-halt.md` — geopolitical industrial supply chain

Read either one to see the exact rhythm in action. Do not free-write a new piece — match the cadence.

## Anti-patterns (do not do)

- ❌ "It is important to note that..." → cut, name the thing directly.
- ❌ "In conclusion / To summarize / In summary..." → the closer doesn't announce itself.
- ❌ A single voice answering 7+ questions → break it up, use the others.
- ❌ Q that contains the A inside it ("Given that X is obviously bad, why is X bad?") → ask, don't lead.
- ❌ Vague attributions ("some say", "many believe") → name the voice (composite) or cite the source.
- ❌ Adding new persona attributes on the fly ("Mira, who is also a former central banker, ...") → only what's in voices.md.
