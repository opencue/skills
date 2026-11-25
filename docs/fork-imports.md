# November 2026 NagyVikt fork sources

The scan covers the 21 public forks created from November 1 through November
25, 2026. It found 226 standard `SKILL.md` entrypoints and one nonstandard
Base44 skill template. After deduplicating variants and excluding workflows
not mirrored here, 129 skills from 13 forks are available under
[`skills/forks/`](../skills/forks/). The import does not enable any profiles,
hooks, or permissions.

## Find the source and its resources

The [machine-readable source index](../catalog/fork-sources.json) maps each
`forks/<name>` ID to its exact entrypoint, fork commit, parent repository, and
local license notices. To resolve a skill's source without using a moving branch:

```sh
jq -r --arg id 'forks/solidcraft-modeling' '
  .skills[$id] as $s
  | "https://github.com/\($s.fork)/blob/\(.repositories[$s.fork].commit)/\($s.entrypoint)"
' catalog/fork-sources.json
```

- **Bundled:** check the skill directory first for its references and helpers.
  Product dependencies such as an MCP server or CLI are not installed by the
  catalog.
- **Upstream project:** run project-specific steps in the pinned upstream
  checkout, not in the skills library.
- **Upstream assets:** for Taste Skill and Video Shotcraft, use the pinned
  checkout for scripts, project files, and media not mirrored here.
- **Adapted template:** the local Base44 skill is adapted for read-only task
  reporting from the linked Base44 template.

## Scan results

Every pin is from the NagyVikt fork. The first column identifies its parent.

| Parent repository | Fork pin | Imported | Notes |
| --- | --- | ---: | --- |
| Claude-BugHunter | `5d91c812` | 0 | Offensive workflows not mirrored |
| [wonderwhy-er/DesktopCommanderMCP](https://github.com/wonderwhy-er/DesktopCommanderMCP) | [9a101b17](https://github.com/NagyVikt/DesktopCommanderMCP/tree/9a101b17e44577f0baefa4c7120f087881c5cc56) | 6 | Canonical skills; Claude and Cursor variants deduplicated |
| ESP32Marauder | `511bb369` | 0 | No standalone skill |
| [a2ui-project/a2ui](https://github.com/a2ui-project/a2ui) | [b4f91c26](https://github.com/NagyVikt/a2ui/tree/b4f91c26fcf62abc0720c21a65840220941d0a3f) | 23 | Imported |
| [ag-ui-protocol/ag-ui](https://github.com/ag-ui-protocol/ag-ui) | [2330368a](https://github.com/NagyVikt/ag-ui/tree/2330368a2a74573902858867072406638ba3073d) | 23 | Imported |
| [vercel-labs/agent-desktop](https://github.com/vercel-labs/agent-desktop) | [b43ac4f6](https://github.com/NagyVikt/agent-desktop/tree/b43ac4f6e892ef608f8851428613c4009f0e84c7) | 8 | Imported |
| [mjmirza/app-store-compliance](https://github.com/mjmirza/app-store-compliance) | [d2156bab](https://github.com/NagyVikt/app-store-compliance/blob/d2156bab9d7189835631c0a99adcc2479d32138d/agent-os/skill/SKILL.md) | 0 | Skill source only; redistribution terms not cleared |
| [ranxianglei/billion-context](https://github.com/ranxianglei/billion-context) | [04ecbb42](https://github.com/NagyVikt/billion-context/blob/04ecbb42dd38543e9c407bd40eb773ae5ec8b60b/PLUGIN.md) | 0 | Plugin documentation only; no standalone skill |
| [anthropics/claude-quickstarts](https://github.com/anthropics/claude-quickstarts) | [4a4224bd](https://github.com/NagyVikt/claude-quickstarts/tree/4a4224bdf0e9cfb3332167b69c90457403813625) | 4 | Imported |
| [base44/cli](https://github.com/base44/cli) | [10a8d28e](https://github.com/NagyVikt/cli/tree/10a8d28ec6d7e3b3d20de1fb67c51e44d4bf672c) | 1 | Base44 weekly-report template; project commands and test fixtures are not skills |
| [google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model) | [e4747323](https://github.com/NagyVikt/elephant-goldfish-model/tree/e4747323aab66157812cd3a71755f6447b2803a2) | 7 | Imported |
| [kajisho5/ffmpeg-skill](https://github.com/kajisho5/ffmpeg-skill) | [c7dad34c](https://github.com/NagyVikt/ffmpeg-skill/tree/c7dad34c846099e7cf606ef943abe5e12d1ab0f9) | 18 | Canonical skill and project tools; generated duplicate omitted |
| [croffasia/itsaplan](https://github.com/croffasia/itsaplan) | [3c0875ea](https://github.com/NagyVikt/itsaplan/tree/3c0875ea1130ef0b269e6568b36fdd356833d714) | 2 | Project skills; exploit-reproduction audit not mirrored |
| [nginx/nginx](https://github.com/nginx/nginx) | [2e8440bc](https://github.com/NagyVikt/nginx/tree/2e8440bcdc438f0f1cd03da778a3843ddb3c86d9) | 0 | No standalone skill |
| [tangency-labs/solidcraft](https://github.com/tangency-labs/solidcraft) | [18dfe20b](https://github.com/NagyVikt/solidcraft/tree/18dfe20b005bd2e8846ed6ba8ca145c2678ed5b3) | 19 | Imported |
| [google-labs-code/stitch-skills](https://github.com/google-labs-code/stitch-skills) | [0337446d](https://github.com/NagyVikt/stitch-skills/tree/0337446dadde6f8c94210444e2aa9d546126480f) | 16 | Imported |
| [we-promise/sure](https://github.com/we-promise/sure) | [270ee4b6](https://github.com/NagyVikt/sure/tree/270ee4b6e4d6bef3d67c70a36a1f5a21a5211204) | 0 | No standalone skill |
| [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) | [f6b76575](https://github.com/NagyVikt/taste-skill/tree/f6b76575f949707b4e3c37cd86cb44b0b98643e8) | 1 | Companion scripts and assets come from the pinned checkout |
| [dream-num/univer](https://github.com/dream-num/univer) | [0d7923dd](https://github.com/NagyVikt/univer/tree/0d7923dd7a26e6bea56f1bc791a03618235a4618) | 0 | No standalone skill |
| [louislam/uptime-kuma](https://github.com/louislam/uptime-kuma) | [7e5075d1](https://github.com/NagyVikt/uptime-kuma/tree/7e5075d12c85f7282f9c7b7d6821d56aa3acc688) | 0 | No standalone skill |
| [Vincentwei1021/video-shotcraft](https://github.com/Vincentwei1021/video-shotcraft) | [da5ffcfc](https://github.com/NagyVikt/video-shotcraft/tree/da5ffcfc7195b3840d90ff352a7c52f527886688) | 1 | Build projects and media come from the pinned checkout |
