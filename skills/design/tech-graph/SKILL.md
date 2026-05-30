---
name: tech-graph
description: 'Publish-grade SVG/PNG technical diagrams (architecture, flow, sequence, UML, state, ER) from templates. Use when user says "draw the architecture" or "make a sequence diagram".'
category: design
license: MIT
metadata:
  attribution: "Adapted from fireworks-tech-graph (MIT), de-Flowsered for cue"
  version: "1.0.0"
---

# Tech Graph

Generate publish-grade technical diagrams as SVG first, then PNG when raster export is needed. Ships 10 templates, 7 visual styles, regression fixtures, and a template-driven generator.

Use this when the diagram should become a durable artifact in docs, a README, or a slide. For explanation-first or review visuals (Mermaid, ASCII, HTML recaps), use the `preview` skill instead.

## Prerequisites

- `python3` and standard Unix tools (required for generation + SVG validation)
- `rsvg-convert` (optional, for PNG export). Without it the scripts run in SVG-only mode and warn, they do not fail.

```bash
rsvg-convert --version || echo "PNG export unavailable; SVG-only mode"
```

## Diagram types

architecture, data-flow, flowchart, sequence, comparison, timeline, mind-map, agent, memory, use-case, class, state-machine, er-diagram, network-topology.

Classify the diagram type before drawing. If the request is really explanation-first, switch to `preview`.

## References (load the smallest that fits)

- `references/style-diagram-matrix.md` to pick a style and diagram family
- `references/style-1-flat-icon.md` through `references/style-7-openai.md` for exact visual language
- `references/icons.md` for semantic shapes and product icons
- `references/svg-layout-best-practices.md` for spacing, routing, labels, and export discipline

## Workflow

1. Decide: publish-grade SVG/PNG (this skill) or explanation visual (`preview`).
2. Classify the diagram type and pick the output path.
3. Load the matching style reference. Default to style 1 unless the request implies another visual language.
4. Use a `templates/` SVG or a `fixtures/` JSON structure to speed up clean generation.
5. Generate the SVG directly, or render from a template:

```bash
python3 ~/.claude/skills/tech-graph/scripts/generate-from-template.py <type> <output.svg> '<json-data>'
```

6. Validate:

```bash
bash ~/.claude/skills/tech-graph/scripts/validate-svg.sh <file.svg>
```

7. Export PNG when sharing or proofing:

```bash
bash ~/.claude/skills/tech-graph/scripts/generate-diagram.sh -o <file.svg>
```

8. Review the render and iterate.

## Bundled scripts

- `scripts/generate-from-template.py` renders starter diagrams from templates + JSON, with the 7-style system and semantic shapes.
- `scripts/validate-svg.sh` checks XML structure and closing tags; uses `rsvg-convert` as an extra validator when present.
- `scripts/generate-diagram.sh` validates an SVG and exports a sibling PNG when `rsvg-convert` is available.
- `scripts/test-all-styles.sh` renders the regression fixtures, validates every SVG, and writes to `scripts/.test-output` (override with `TECH_GRAPH_TEST_OUTPUT_DIR`).

## Output policy

Prefer `.svg` as the source artifact. Generate `.png` alongside it when the user wants a shareable image or a visual proof. If no output path is given, write next to the doc the diagram supports, not `/tmp` or the Desktop.

## Example

```
User: draw the architecture for our ingest pipeline as a publishable SVG
Agent:
  1. Classifies as "architecture", picks style 6 from style-diagram-matrix.md
  2. Renders: python3 ~/.claude/skills/tech-graph/scripts/generate-from-template.py architecture docs/ingest-arch.svg '{...}'
  3. Validates: bash ~/.claude/skills/tech-graph/scripts/validate-svg.sh docs/ingest-arch.svg
  4. Exports PNG for the README, reports both paths
```

Good trigger phrases: "generate architecture diagram", "draw the system flow", "make this sequence diagram publishable", "create a clean SVG for this process", "turn this architecture into PNG", "build a comparison matrix".
