---
name: preview
description: 'Inspect files or generate visual explanations, slides, diagrams, or HTML recaps. Use when user says "preview this", "make slides", "explain visually", or "generate an HTML recap".'
category: content
license: MIT
metadata:
  attribution: "Adapted from claudekit vc:preview (MIT), de-Flowsered for cue"
  version: "1.0.0"
---

# Preview

Universal viewer plus visual generator. View existing content, or generate new visual explanations, slides, diagrams, and self-contained HTML pages.

For durable publish-grade SVG/PNG diagrams, use the `tech-graph` skill instead. Reach for `preview` when the goal is explanation, review, slides, or an HTML page that opens straight in a browser.

## Prerequisites

- A browser for HTML output (`open` on macOS, `xdg-open` on Linux, `start` on Windows)
- `gh` only for `--diff <PR-number>` (GitHub PR diffs). Optional.

## Modes

Markdown generation:
- `--explain <topic>` visual explanation (ASCII + Mermaid + prose)
- `--slides <topic>` presentation slides, one concept per slide
- `--diagram <topic>` focused diagram (ASCII + Mermaid)
- `--ascii <topic>` terminal-friendly ASCII-only diagram

HTML generation (self-contained, opens in browser):
- `--html --explain <topic>`, `--html --slides <topic>`, `--html --diagram <topic>`
- `--html --diff [ref]` visual diff review of a branch, commit, range, or PR
- `--html --plan-review [plan-file]` plan vs codebase comparison
- `--html --recap [timeframe]` project context snapshot

View mode: pass a file or directory path to render it.

## Reference loading

Before generating HTML, read `references/html-design-guidelines.md`, then the mode-specific refs:

- `--explain` / `--diagram`: `html-css-patterns.md`, `html-libraries.md`, template `templates/architecture.html` or `templates/mermaid-flowchart.html`
- `--slides`: `html-slide-patterns.md`, `html-css-patterns.md`, `html-libraries.md`, template `templates/slide-deck.html`
- `--diff` / `--plan-review` / `--recap`: `html-css-patterns.md`, `html-libraries.md`, templates `data-table.html` + `architecture.html`

Multi-section pages also read `html-responsive-nav.md`. For Markdown generation modes read `references/generation-modes.md`; for view mode read `references/view-mode.md`.

## Rules

- Every HTML page must include a light/dark theme toggle (see `html-css-patterns.md`). Pages without it are incomplete.
- Vary aesthetics between consecutive HTML outputs (different font pair and palette) to avoid generic-looking results.
- If no output path is given, write next to the source the page describes, not `/tmp` or the Desktop.
- `--ascii` is terminal-only; `--html --ascii` is unsupported, suggest `--html --diagram`.

## Example

```
User: generate an HTML recap of the last two weeks
Agent:
  1. Reads html-design-guidelines.md + html-css-patterns.md
  2. Pulls git log/status for the 2w window
  3. Writes a self-contained recap.html with a theme toggle
  4. Opens it with xdg-open and reports the path
```

Good trigger phrases: "preview this file", "make slides for X", "explain this visually", "generate an HTML diff review", "recap the last 2 weeks", "plan-review this against the codebase".
