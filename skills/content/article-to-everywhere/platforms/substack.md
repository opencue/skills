# Platform converter: Substack

**Output**: markdown file ready to paste into Substack composer.
**Lint**: subject + preheader length, body word count, markdown link formatting.
**No Postiz integration** — Substack is paste-and-publish manually.

## Output file structure

```
~/Documents/cue/drafts/<slug>-everywhere/substack.md
```

With YAML frontmatter at top:

```yaml
---
subject: "<subject line, ≤55 chars>"
preheader: "<preheader, ≤90 chars — shows next to subject in inbox>"
audience: "all subscribers"   # or "paid only" etc.
estimated_read_time: "<X min>"
---
```

Then the body in plain markdown (Substack composer converts cleanly).

## Subject line rules

- ≤55 chars (Gmail truncates at ~70 on mobile, but mobile clients trim sooner).
- No emoji in subject (spam-flag risk + ASCII-only is safer for inbox preview).
- Lead with the news/claim, not the topic. Compare:
  - ✗ "On rare earths and supply chains"
  - ✓ "China just stopped shipping rare earths to Japan"
- Numbers help: "The 6× premium that doesn't buy a refinery"
- Questions sparingly: max 1 in 5 emails — too many trains readers to skip

## Preheader rules

- ≤90 chars. Complements the subject — does NOT repeat it.
- This is the second line of inbox preview. Use it to add the hook the subject couldn't.
  - Subject: "China just stopped shipping rare earths to Japan"
  - Preheader: "And 80% of EU industrial firms sit within three supply-chain hops."

## Body structure

```
1. Lede (1 paragraph, 60-100 words)
   Same as the article's TL;DR bullet 1, expanded to email-conversational voice.

2. "Here's what's happening" (2-3 paragraphs)
   The core facts, with at least 2 inline links to sources.

3. "Why it matters" (1-2 paragraphs)
   The implication — for the reader's professional life, not the abstract market.

4. "Watching next" (1 paragraph)
   The named next event/date/signal.

5. Closing line + (optional) "Reply if X" — invites a one-way reader response.

Total: 600-1000 words.
```

## Voice shift from X / LinkedIn

Substack is **conversational long-form**. You're writing to readers who chose to receive this email — assume they're interested but time-poor.

- Use "I" sparingly but not avoided entirely. Some "I noticed X" / "I've been thinking about Y" personalizes it.
- Direct second-person works: "If you're an EU industrial allocator, what changes today is..."
- Avoid filler like "I hope this finds you well" — readers paid for substance, not pleasantries.

## Linking

- Inline markdown links: `[Lockheed Martin's filing](https://...)` — Substack converts these cleanly.
- No raw URLs in body. They look amateur and break on mobile.
- Footnotes are okay for 3+ sources cited tightly: `^[1]` notation, listed at the bottom.

## Lint rules

```bash
# subject ≤55 chars
# preheader ≤90 chars
# body word count 600-1000
# no raw URLs in body (use markdown links)
# no $TICKER cashtags (they read odd in email — write "Lockheed Martin (LMT)" instead)
```

## When to paid-gate

- Free email: any general-interest piece, breaking news, sector overviews.
- Paid email: deep-dive analysis, specific actionable recommendations, longer pieces (>1000 words).

If `lang: hu`, target Hungarian Substack audience — keep brand voice consistent but match Hungarian newsletter conventions (more formal greeting, less direct CTA).

## Anti-patterns

- ❌ "Click here to read more" with a link to the same article — the email IS the read
- ❌ Auto-paste of the long-form article — too long for email, readers churn
- ❌ "If you enjoyed this, subscribe" at the end — they already subscribed
- ❌ Multiple footnoted callouts — distracts from the narrative; keep 1 callout max per email
