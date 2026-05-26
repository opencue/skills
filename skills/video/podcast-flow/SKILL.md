---
name: podcast-flow
description: >-
  Generate long-form podcast video content — talking heads, split screen,
  dynamic cuts. Use when user says "podcast video", "interview format",
  "long-form video", "conversation video", or wants multi-speaker
  dialogue content.
tags: [video, podcast, long-form, interview]
category: video
version: 1.0.0
requires_mcps: [Higgsfield]
allowed-tools: Bash
---

# Podcast Flow

Generate podcast-style long-form video content with multiple speakers.

## When to activate

- User says "podcast video", "interview format", "conversation video"
- User says "long-form content", "talking heads discussion"
- User wants multi-speaker dialogue video

## Step 1 — Format selection

| Format | Layout | Best for |
|--------|--------|----------|
| **Solo** | Single speaker, direct to camera | Monologue, essay |
| **Interview** | 2 speakers, shot/reverse-shot | Q&A, guest episodes |
| **Panel** | 3+ speakers, wide + singles | Discussion, debate |
| **Split screen** | Side-by-side | Remote interviews |

## Step 2 — Speaker setup

For each speaker:
- Create Soul ID (consistent appearance across all shots)
- Define position (left/right/center)
- Set energy level and speaking style
- Background/environment per speaker

## Step 3 — Shot pattern

Standard podcast edit pattern:
```
Wide (both speakers): 3-5s — establishing
Single A (speaker talking): 5-15s — main content
Reaction B (listener): 2-3s — nods, reactions
Single B (response): 5-15s — reply
Wide: 3-5s — transition/laugh moment
```

## Step 4 — Generate segments

Break long-form into 30-60s segments:
- Each segment = one topic/question
- Vary shot sizes within each segment
- Include B-roll cutaways for visual variety

## Step 5 — Audio direction

```
Audio specs:
  Voice: Clear, close-mic sound (-16 LUFS)
  Music: Subtle bed underneath (20% volume)
  Transitions: Whoosh/stinger between segments
  Silence: Allow natural pauses (authenticity)
```

## Rules

- Podcast content is LONG — plan for 5-30 minute total runtime
- Generate in segments (30-60s each) for manageability
- Maintain Soul ID consistency across ALL segments
- Vary shot sizes to avoid visual monotony
- Include reaction shots — they make conversations feel real
- Audio clarity is #1 priority (over visual polish)
