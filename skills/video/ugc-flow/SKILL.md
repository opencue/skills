---
name: ugc-flow
description: >-
  Generate UGC talking-head videos — script, avatar, and delivery.
  Use when user says "make a UGC video", "talking head ad", "create
  testimonial video", "UGC creator content", or wants authentic-looking
  user-generated content for ads or social media.
tags: [video, ugc, marketing, ads]
category: video
version: 1.0.0
requires_mcps: [Higgsfield]
allowed-tools: Bash
---

# UGC Flow

Generate authentic UGC talking-head videos — from script to final delivery.

## When to activate

- User says "UGC video", "talking head", "testimonial video"
- User says "create a UGC ad", "make creator content"
- User wants authentic-looking video for social ads
- User mentions "hook + body + CTA" video structure

## Step 1 — Script generation

Structure the UGC script:

```
Hook (0-3s): Attention-grabbing opener
  → "I was skeptical too, but..."
  → "Nobody talks about this..."
  → "POV: you just discovered..."

Body (3-20s): Value delivery
  → Problem → Solution → Proof
  → Feature walkthrough
  → Before/after demonstration

CTA (20-30s): Call to action
  → "Link in bio"
  → "Try it free"
  → "Comment [word] for the link"
```

## Step 2 — Avatar/character setup

- Select or create avatar via Soul ID for consistency
- Match avatar to target demographic (age, style, energy)
- Set environment (bedroom, kitchen, office, outdoor — authentic settings)

## Step 3 — Shot direction

UGC-specific camera rules:
- **Handheld feel** — slight movement, not locked tripod
- **Eye-level or slightly above** — phone selfie angle
- **Natural lighting** — window light, ring light visible is OK
- **Portrait orientation** (9:16) for TikTok/Reels/Shorts

## Step 4 — Generate with Higgsfield

Construct prompt using UGC-specific parameters:
- Camera: Handheld, slight shake
- Lighting: Natural/soft
- Style: Authentic, not polished
- Audio: Direct-to-camera speech

## Step 5 — Variations

Generate 3-5 hook variations for A/B testing:
- Different opening lines
- Different energy levels (calm vs excited)
- Different backgrounds

## Rules

- UGC should look authentic, NOT polished/cinematic
- Always generate in 9:16 portrait for social platforms
- Include captions/subtitles in the output plan
- Hook must grab attention in first 1-2 seconds
- Keep total length under 60s for best engagement
