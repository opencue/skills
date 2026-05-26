---
name: cinematic-flow
description: >-
  Generate cinematic video — short (15s) and long format films using
  Higgsfield Cinema Studio 3.5 and MCSLA formula. Use when user says
  "cinematic video", "film this", "short film", "commercial", "movie
  quality", "cinema studio", or wants professional film-grade output.
tags: [video, cinematic, film, production]
category: video
version: 1.0.0
requires_mcps: [Higgsfield]
allowed-tools: Bash
---

# Cinematic Flow

Generate professional cinematic video using Higgsfield Cinema Studio 3.5.

## When to activate

- User says "cinematic video", "short film", "commercial"
- User says "film quality", "movie-grade", "cinema studio"
- User wants professional production-quality video
- User mentions specific camera movements or film techniques

## Step 1 — Scene breakdown

Decompose the concept into shots:

| Element | Options |
|---------|---------|
| **Genre** | Action, Drama, Horror, Sci-Fi, Romance, Documentary |
| **Duration** | 15s (social), 30s (ad), 60s (short), 3-5min (film) |
| **Aspect** | 16:9 (cinema), 2.39:1 (anamorphic), 9:16 (vertical) |

## Step 2 — Apply MCSLA formula per shot

For each shot, define:

```
M — Mood: emotional tone (tense, euphoric, melancholic, mysterious)
C — Camera: movement + lens (dolly in 35mm, crane up 24mm, handheld 50mm)
S — Subject: who/what is in frame + action
L — Lighting: style (golden hour, neon noir, overcast soft, studio Rembrandt)
A — Action: what happens in this shot (verb-first)
```

**Example prompt:**
```
Mood: Tense anticipation. Camera: Slow dolly forward, 35mm anamorphic lens,
shallow depth of field. Subject: A woman in a red coat standing at the edge
of a rooftop, wind catching her hair. Lighting: Blue hour, city lights
bokeh behind. Action: She turns to face camera, expression shifts from
worry to determination.
```

## Step 3 — Character consistency via Soul ID

- Create character sheet (front, side, back views)
- Lock Soul ID before generating any shots
- Reference Soul ID in every prompt for the same character

## Step 4 — Production settings

```
Cinema Studio 3.5 settings:
  Quality: Maximum
  Physics: Enabled (fabric, hair, particles)
  Audio: Native generation (ambient + SFX)
  Motion: Cinematic (24fps feel, natural motion blur)
```

## Step 5 — Sequence assembly

Output a shot list with timing:

```
🎬 Cinematic Sequence:

  Shot 1 [0:00-0:04]: Establishing wide — city skyline at blue hour
  Shot 2 [0:04-0:07]: Medium — character walks into frame
  Shot 3 [0:07-0:10]: Close-up — eyes, determination
  Shot 4 [0:10-0:13]: Action — character leaps
  Shot 5 [0:13-0:15]: Wide — landing, dust settles

  Transitions: Cut (1→2), Match cut (2→3), Smash cut (3→4), Slow-mo (4→5)
```

## Rules

- Always use MCSLA formula for every shot prompt
- Lock Soul ID before generating multi-shot sequences
- Use Cinema Studio 3.5 physics for realistic motion
- Match camera language to genre (action = handheld, drama = dolly, horror = static)
- Include audio direction (ambient, score mood, SFX cues)
- For 15s social: max 4-5 shots. For 60s: max 12-15 shots.
