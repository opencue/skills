---
name: motion-design-flow
description: >-
  Motion design for product videos, reference images, logos, and infographics.
  Use when user says "motion design", "animate this logo", "product animation",
  "animated infographic", "motion graphics", or wants dynamic visual content
  that isn't live-action footage.
tags: [video, motion-design, animation, graphics]
category: video
version: 1.0.0
requires_mcps: [Higgsfield]
allowed-tools: Bash
---

# Motion Design Flow

Create motion design content — product animations, logo reveals, infographics, and reference image animations.

## When to activate

- User says "motion design", "animate this", "motion graphics"
- User says "logo animation", "product spin", "animated infographic"
- User has a static image and wants it animated
- User wants dynamic visual content (not live-action)

## Step 1 — Identify motion type

| Type | Input | Output |
|------|-------|--------|
| **Product animation** | Product photo | 360° spin, floating, exploded view |
| **Logo reveal** | Logo file | Animated entrance, particles, morph |
| **Infographic** | Data/text | Animated charts, counters, transitions |
| **Reference animate** | Static image | Subtle motion (parallax, cinemagraph) |

## Step 2 — Define motion language

```
Easing: ease-in-out (default), spring (playful), linear (mechanical)
Duration: 2-5s per element
Stagger: 100-200ms between elements
Direction: Left-to-right (reading flow), center-out (impact), top-down (gravity)
```

## Step 3 — Generate prompts

**Product animation:**
```
A [product] floating in center frame against [background]. Slow rotation
revealing all angles. Soft studio lighting with rim light. Subtle particle
effects. Camera: locked, product rotates 360°. Duration: 5s loop.
```

**Logo reveal:**
```
[Logo] assembles from scattered particles/liquid/geometric shapes.
Background: [solid/gradient]. Style: [minimal/energetic/elegant].
Camera: static. Duration: 3s with 1s hold at end.
```

## Step 4 — Output specifications

```
📐 Motion Design Specs:

  Format: MP4 (H.264) + transparent MOV (ProRes 4444) if needed
  Resolution: 1920×1080 (landscape) or 1080×1920 (portrait)
  FPS: 30 (social) or 60 (premium)
  Loop: Yes/No
  Audio: SFX whoosh/click/ambient (optional)
```

## Rules

- Motion design is NOT live-action — no characters walking/talking
- Keep animations under 10s for social, under 30s for presentations
- Always provide loop-friendly versions for social media
- Match motion energy to brand (luxury = slow/elegant, tech = fast/sharp)
- Include transparent background option for logos and product shots
