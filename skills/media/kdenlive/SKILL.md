---
name: kdenlive
version: 0.1.0
description: >-
  Use when user says "edit this video", "render the kdenlive project", "stitch
  clips together", "add a title card", "crossfade these", "cut a 9:16 version",
  "add background music", or "trim/concat". Headless non-linear video editing and
  rendering with melt (the MLT engine behind Kdenlive) plus ffmpeg. Deterministic
  and local. NOT for AI text-to-video generation (use media/core-media).
allowed-tools: Bash(melt:*), Bash(ffmpeg:*), Bash(ffprobe:*), Bash(mediainfo:*), Bash(bash:*)
category: media
---

# 🎬 Kdenlive / MLT headless video editing

Edit and render video from the terminal with **`melt`** (the MLT framework that
powers Kdenlive) and **`ffmpeg`**. No GUI, no display, no API key. Build a
timeline, crossfade clips, burn in titles, score with music, render a
`.kdenlive` project headlessly, and reframe for social.

Kdenlive the app is GUI-only (it needs a display); its render engine is `melt`,
which these scripts drive. A project you build here (`.kdenlive` / `.mlt` XML)
opens in the Kdenlive GUI and renders identically on a headless box.

## Prerequisites

```bash
sudo apt-get install -y kdenlive melt ffmpeg mediainfo fonts-montserrat
# verify: melt -version && ffmpeg -version | head -1
```

Titles default to the **Montserrat** font (override with `--font`).

## Scripts (run one command, not eight)

| Script | Does |
| :--- | :--- |
| `inspect.sh <file...>` | Duration, resolution, fps, codecs + the auto-matched melt profile |
| `title-card.sh --text "..."` | Standalone title/intro card (solid bg + centered text) |
| `assemble.sh -o out.mp4 ...clips` | Concat or crossfade clips, optional intro title + bg music, optional `.kdenlive` export |
| `render.sh <project.kdenlive>` | Render a Kdenlive/MLT project file headlessly to mp4 |
| `reframe.sh <in> --aspect 9:16` | Reframe to 9:16 / 1:1 / 16:9 with blurred fill (no stretch) |

The melt profile (resolution + fps) is auto-detected from the first input, so
mixed sources render onto one consistent canvas.

## Quick start

```bash
S=scripts   # from the skill dir

# Inspect inputs
bash $S/inspect.sh raw1.mp4 raw2.mp4

# Stitch a reel: intro title, 12-frame crossfades, background music,
# and also save an editable .kdenlive project.
bash $S/assemble.sh --title "LAUNCH 2026" --xfade 12 --music track.m4a \
     --project launch.kdenlive -o reel.mp4  raw1.mp4 raw2.mp4 raw3.mp4

# Render that project headlessly (e.g. on a server / in CI)
bash $S/render.sh launch.kdenlive -o reel.mp4

# Make the vertical social cut
bash $S/reframe.sh reel.mp4 --aspect 9:16 -o reel_vertical.mp4

# Just a title card
bash $S/title-card.sh --text "Q3 RESULTS" --subtitle "all-hands" --dur 3 -o card.mp4
```

## The .kdenlive project flow

`assemble.sh --project show.kdenlive` writes an MLT XML project alongside the
mp4. That file is the same format Kdenlive saves: open it in the GUI to keep
editing, hand it to a teammate, or re-render on any headless machine with
`render.sh`. This is how you separate "decide the edit" from "render the edit".

## Pairs with the generation skills

These are the **assembly** layer. Generate shots with `media/core-media`
(`generate-video.sh`, `image-to-video.sh`) or a recipe like
`media/cinema-director`, then stitch, title, score, and reframe them here.

Example: `cinema-director` → 3 shots → `assemble.sh --xfade 15 --title ...` →
`reframe.sh --aspect 9:16` → a finished vertical ad, fully local after the shots
exist.

## Rules

- **melt renders, Kdenlive edits.** Never try to run the `kdenlive` GUI binary
  headlessly. Drive `melt` for any non-interactive render.
- **Frames, not seconds, inside melt.** `in=`/`out=` and `-mix` are in frames.
  At 25 fps, 12 frames is ~0.5 s. The scripts handle the conversion for you.
- **Let the profile auto-match.** Pass `--profile` only to force a different
  canvas; otherwise the first clip's resolution and fps win.
- **Keep the project file.** When the edit matters, always pass `--project` so
  the decision is reproducible and re-renderable, not baked only into an mp4.
- **ffmpeg for reframe and audio mux, melt for the timeline.** Each tool does
  the half it is reliable at.

## Example

```bash
# Person photo + product shots already generated → finished 9:16 UGC cut, local.
bash scripts/assemble.sh --title "NEW DROP" --xfade 10 --music beat.m4a \
     --project drop.kdenlive -o drop.mp4  shot1.mp4 shot2.mp4 shot3.mp4
bash scripts/reframe.sh drop.mp4 --aspect 9:16 -o drop_reels.mp4
```
