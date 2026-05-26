---
name: amazon-product-listing
description: >-
  Generate product images and video for Amazon listings — hero shots,
  lifestyle images, infographics, and A+ content. Use when user says
  "Amazon listing", "product images for Amazon", "A+ content",
  "marketplace photos", or wants e-commerce product visuals.
tags: [video, ecommerce, amazon, product]
category: video
version: 1.0.0
requires_mcps: [Higgsfield]
allowed-tools: Bash
---

# Amazon Product Listing

Generate complete Amazon listing visuals — hero images, lifestyle shots, infographics, and video.

## When to activate

- User says "Amazon listing images", "product photos for marketplace"
- User says "A+ content", "EBC images"
- User wants e-commerce product visuals
- User mentions "hero image", "lifestyle shot", "infographic"

## Step 1 — Amazon image requirements

| Slot | Type | Requirements |
|------|------|-------------|
| Main | Hero (white BG) | Pure white (#FFFFFF), product fills 85%+ |
| 2-3 | Lifestyle | Product in use, real environment |
| 4-5 | Infographic | Features + callouts + dimensions |
| 6 | Comparison | vs competitors or before/after |
| 7 | Video | 15-30s product demo |

## Step 2 — Hero image generation

```
Product: [item] centered on pure white background.
Lighting: Soft studio, no harsh shadows.
Angle: 3/4 front view (most informative angle).
Fill: Product occupies 85% of frame.
Resolution: 2000×2000px minimum.
```

## Step 3 — Lifestyle shots

Generate product-in-context images:
- Person using the product (hands, face, environment)
- Product in its natural setting (kitchen, office, outdoors)
- Scale reference (next to common objects)

## Step 4 — Infographic overlays

Design info-rich images with:
- Feature callouts with arrows/lines
- Dimensions and specifications
- "What's in the box" layout
- Comparison charts

## Step 5 — Product video (15-30s)

```
Shot 1: Unboxing reveal (3s)
Shot 2: Product hero spin (5s)
Shot 3: Feature demonstration (10s)
Shot 4: Lifestyle usage (7s)
Shot 5: Brand lockup + CTA (5s)
```

## Rules

- Main image MUST be pure white background (Amazon requirement)
- All images minimum 2000×2000px (Amazon minimum for zoom)
- No text/logos on main image (Amazon policy)
- Lifestyle images should show the product being USED, not just placed
- Video must work without sound (add text overlays)
- Generate both square (1:1) and portrait (4:5) versions
