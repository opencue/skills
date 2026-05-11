---
name: "png-alpha-cleaner"
description: >-
  Use when user says "clean PNG alpha", "remove transparent fringe", or "fix PNG edges" and
  needs alpha-channel cleanup. Covers image inspection, processing, validation, and output
  checks.
---

# PNG Alpha Cleaner

Use this for logo/image fixes like "make this actually a PNG", "transparent background", "remove checkerboard", or "PNG has no alpha".

## Fast Path

Run the bundled script instead of re-deriving masks by hand:

```bash
python3 ~/.codex/skills/png-alpha-cleaner/scripts/fix_png_alpha.py INPUT.png --in-place --preview-color '#202020' --preview-color '#ff00ff'
```

For non-destructive output:

```bash
python3 ~/.codex/skills/png-alpha-cleaner/scripts/fix_png_alpha.py INPUT.png --output OUTPUT.png --preview-color '#202020'
```

## Workflow

1. Confirm what is wrong:
   - `file INPUT`
   - `identify -format '%m %w %h %[channels]\n' INPUT`
2. If the file is RGB-only or has baked checkerboard/background pixels, run `fix_png_alpha.py`.
3. Inspect a preview on a dark or magenta background when edges matter.
4. Verify before claiming done:
   - `file OUTPUT` says `PNG image data`.
   - `identify -format '%[channels]\n' OUTPUT` includes alpha (`srgba` or `rgba`).
   - A background corner reads transparent, for example `srgba(0,0,0,0)`.

## Script Behavior

- Uses ImageMagick plus Python stdlib only; no Pillow, NumPy, or network.
- Backs up in-place edits under `/tmp/png-alpha-cleaner-backups/...`.
- Detects already-transparent PNGs and normalizes them without destroying alpha.
- Removes light/neutral edge-connected backgrounds and baked checkerboards.
- Applies a small morphology pass to remove thin checkerboard leftovers.

## Tuning

If logo highlights are being removed, lower cleanup:

```bash
python3 ~/.codex/skills/png-alpha-cleaner/scripts/fix_png_alpha.py INPUT.png --output OUTPUT.png --open-radius 2 --min-light 228
```

If checkerboard leftovers remain, increase cleanup:

```bash
python3 ~/.codex/skills/png-alpha-cleaner/scripts/fix_png_alpha.py INPUT.png --output OUTPUT.png --open-radius 5 --min-light 214
```
