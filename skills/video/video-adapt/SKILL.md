---
name: video-adapt
description: >-
  Adapt a video from a link — swap product, swap character, or copy 1:1.
  Use when user says "adapt this video", "swap the product in this video",
  "recreate this ad with my product", "copy this video style", or provides
  a video URL and wants a variation.
tags: [video, creative, adaptation, ugc]
category: video
version: 1.0.0
requires_mcps: [Higgsfield]
allowed-tools: Bash
---

# Video Adapt

Adapt an existing video by swapping products, characters, or recreating the style 1:1.

## When to activate

- User provides a video URL and says "adapt", "recreate", "swap product"
- User says "make this ad but with my product"
- User says "copy this video style"
- User wants a variation of an existing video

## Step 1 — Analyze the source video

Extract key elements from the source:
- Shot composition (angles, movement, duration)
- Subject (person, product, or both)
- Style (cinematic, UGC, motion graphics)
- Audio (voiceover, music, SFX)

```bash
# If video URL provided, download for analysis
yt-dlp -f best "<url>" -o /tmp/source-video.mp4 2>/dev/null
ffmpeg -i /tmp/source-video.mp4 -vf "fps=1" /tmp/frames/frame_%04d.jpg 2>/dev/null
```

## Step 2 — Determine adaptation type

| Type | What changes | What stays |
|------|-------------|-----------|
| **Product swap** | The product shown | Character, setting, camera, style |
| **Character swap** | The person/avatar | Product, setting, camera, style |
| **1:1 copy** | Nothing (recreate exactly) | Everything — match frame-by-frame |
| **Style transfer** | Visual treatment | Content, structure, timing |

## Step 3 — Generate prompts for Higgsfield/Seedance

Based on the analysis, construct prompts using:
- **MCSLA formula** for cinematic shots (Mood, Camera, Subject, Lighting, Action)
- **Soul ID** for character consistency across shots
- **Cinema Studio 3.5** settings for production quality

## Step 4 — Output the adaptation plan

```
🎬 Video Adaptation Plan:

  Source: <url>
  Type: Product swap
  Shots: 5 (matching source timing)

  Shot 1: [0:00-0:03] Close-up product reveal
    → Prompt: "<MCSLA prompt with new product>"
    → Camera: Dolly in, shallow DOF
  
  Shot 2: [0:03-0:07] Character interaction
    → Prompt: "<prompt>"
    → Soul ID: <character-ref>
```

## Rules

- Always analyze the source video before generating prompts
- Maintain timing and pacing from the original
- Use Soul ID for character consistency across all shots
- For product swaps, match the original lighting and angle exactly
- Output prompts ready to paste into Higgsfield Cinema Studio
