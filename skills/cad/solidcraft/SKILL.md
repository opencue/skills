---
name: solidcraft
description: Use when the user says "model a part", "SolidCraft", "CAD this", "export STEP/STL", or opens a .sc design. Drives SolidCraft CAD over its MCP server and checks each stage with measure.
allowed-tools: Bash(solidcraft-cli:*)
category: cad
tags: [cad, 3d, modeling, solidcraft, mcp, step, stl]
metadata:
  version: 1.0.0
  homepage: https://github.com/tangency-labs/solidcraft
---

# SolidCraft CAD over MCP

SolidCraft is a parametric 3D CAD app (sketches, feature timeline, B-rep solids). Its MCP server
(`mcp__solidcraft__*`, launched as `solidcraft-cli mcp`) runs the same engine commands as the
toolbar and never opens a dialog. This skill gets you to a working session. The detailed modeling
rules ship inside the server; read them there rather than guessing command shapes.

## Prerequisites

- SolidCraft installed, with `solidcraft-cli` on `PATH`. The Linux AppImage writes
  `~/.local/bin/solidcraft-cli` on its first run; deb/rpm install it in `/usr/bin`; the macOS app
  links it into `/opt/homebrew/bin` or `/usr/local/bin`.
- The `solidcraft` MCP server enabled in the agent (cue registry id `solidcraft`).

## 1. Check the session

1. If the `mcp__solidcraft__*` tools are missing, run `solidcraft-cli --version`. Not found means
   SolidCraft is not installed or its launcher is not on `PATH`. Report that and stop.
2. Find out which backend you have. The server's instructions end with
   `Backend: connected to the SolidCraft app` (you are editing the user's open window) or
   `Backend: headless ...` (an in-process design nobody sees).
3. If the user wants to watch, they open the app and turn on Preferences > Assistant > Agents
   through MCP > "Let AI agents connect". If that happens before any design work in a headless
   session, the next call is bridged to the app; after design work, restart the MCP server.

## 2. Load the built-in guide before modeling

Call `skill_reference` once, for the job at hand:

| Job | Call |
|---|---|
| New part | `skill_reference {"skill":"solidcraft-modeling"}` |
| Change an existing design | `skill_reference {"skill":"solidcraft-editing","file":"SKILL.md"}`, then the modeling reference |
| Assembly, joints, motion | `skill_reference {"skill":"solidcraft-mechanisms"}` |
| Checks SolidCraft does not report, porting | `skill_reference {"skill":"solidcraft-checking","file":"SKILL.md"}` |

`file` defaults to `reference.md`, which only modeling and mechanisms have; an unknown skill or file
is refused with the available choices. The references hold the command shapes, plane axes, sketch id
rules and known traps, so you do not need the command catalog. Never call `list_commands` without a
`filter`: the full list is over 100 KB.

## 3. Build

1. `inspect_design {"measure":false,"sketches":false}` first, even when you expect an empty session.
2. Work the part out as numbers before any call: parameters, placement centred on the origin, every
   feature with the world point you will pick, and the expected volume and bounding box.
3. Build in a few `batch` calls, one per stage (sketch and first feature; fillets and shell; holes,
   cuts and patterns). A batch is all-or-nothing: on failure read `failed.index` and
   `failed.error`, fix that one step and resend.
4. After each stage run `measure {"summary":true}` and compare volume, bbox and face count with
   your numbers. A cut that leaves the volume unchanged missed, even if it reported success.
5. Finish with one `screenshot {"source":"model","view":"iso","width":480,"height":320}`.

## 4. Save and export

- `save {"path":"part.sc"}` keeps the editable design.
- `export {"path":"part.step"}` for CAD exchange, `.stl` or `.3mf` for printing, `.urdf` for an
  assembly with joints.
- Tools only reach the design's folder, the recovery folder, the scratch folder and any
  `--allow-path` folder. If a path is refused, ask the user where to write instead of widening access.

## Example

User: "Make a 60 × 40 × 5 mm mounting plate with four M4 holes 6 mm in from each corner, as STEP."

1. `inspect_design {"measure":false,"sketches":false}`, then
   `skill_reference {"skill":"solidcraft-modeling"}`.
2. Plan: parameters `w=60`, `d=40`, `t=5`, hole radius 2.2; plate centred on the origin; holes at
   `(±24, ±14)`. Expected volume `60·40·5 − 4·π·2.2²·5 ≈ 11 696 mm³`, bbox `60 × 40 × 5`.
3. One `batch` for parameters, the plate sketch and extrude; `measure {"summary":true}` → 12 000 mm³.
4. One `batch` for the hole sketch and cut; `measure` → about 11 696 mm³ (unchanged 12 000 means the cut missed).
5. `screenshot` iso, then `export {"path":"plate.step"}` and tell the user where it is.

## Guardrails

- Bridged to the user's app: ask before `new_design` or `open`, both discard unsaved work. Pass
  `"source":"model"` to `screenshot` and leave out `view` unless the user wants their camera moved.
- Only a `measure` that matches your computed values counts as done; "ok" from a tool does not.
- Without MCP, use the CLI: `solidcraft-cli run script.json --out part.step`,
  `solidcraft-cli eval design.sc`, `solidcraft-cli snapshot script.json --out shot.png`.
- Changing SolidCraft's own source code is a different job: read that checkout's `AGENTS.md`
  first, which has its own hard rules (clean-room, no GPL code, no panics).
