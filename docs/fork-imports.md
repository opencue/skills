# NagyVikt fork imports

This snapshot covers public forks created from 2026-11-01 through 2026-11-25.
The 128 imported skills live under [`skills/forks/`](../skills/forks/) and are
available to Cue profiles by `forks/<name>`. Runtime profiles are not enabled
or changed by the import.

| Source snapshot | Skills |
| --- | ---: |
| [ffmpeg-skill](https://github.com/NagyVikt/ffmpeg-skill/tree/c7dad34c846099e7cf606ef943abe5e12d1ab0f9) | 18 |
| [DesktopCommanderMCP](https://github.com/NagyVikt/DesktopCommanderMCP/tree/9a101b17e44577f0baefa4c7120f087881c5cc56) | 6 |
| [itsaplan](https://github.com/NagyVikt/itsaplan/tree/3c0875ea1130ef0b269e6568b36fdd356833d714) | 2 |
| [a2ui](https://github.com/NagyVikt/a2ui/tree/b4f91c26fcf62abc0720c21a65840220941d0a3f) | 23 |
| [taste-skill](https://github.com/NagyVikt/taste-skill/tree/f6b76575f949707b4e3c37cd86cb44b0b98643e8) | 1 |
| [video-shotcraft](https://github.com/NagyVikt/video-shotcraft/tree/da5ffcfc7195b3840d90ff352a7c52f527886688) | 1 |
| [stitch-skills](https://github.com/NagyVikt/stitch-skills/tree/0337446dadde6f8c94210444e2aa9d546126480f) | 16 |
| [solidcraft](https://github.com/NagyVikt/solidcraft/tree/18dfe20b005bd2e8846ed6ba8ca145c2678ed5b3) | 19 |
| [claude-quickstarts](https://github.com/NagyVikt/claude-quickstarts/tree/4a4224bdf0e9cfb3332167b69c90457403813625) | 4 |
| [elephant-goldfish-model](https://github.com/NagyVikt/elephant-goldfish-model/tree/e4747323aab66157812cd3a71755f6447b2803a2) | 7 |
| [ag-ui](https://github.com/NagyVikt/ag-ui/tree/2330368a2a74573902858867072406638ba3073d) | 23 |
| [agent-desktop](https://github.com/NagyVikt/agent-desktop/tree/b43ac4f6e892ef608f8851428613c4009f0e84c7) | 8 |

Each skill links to its exact source and includes upstream license notices.
Repo-specific workflows require the upstream checkout. Taste Skill and Video
Shotcraft also use their pinned checkout for scripts and assets. The library
does not register upstream hooks or pre-approve upstream tool permissions.

The scan found 226 entrypoints in 21 forks. Thirteen generated or tool-specific
FFmpeg and Desktop Commander variants were collapsed into their canonical
skills. Seven forks had no `SKILL.md`. The Claude-BugHunter collection and the
itsaplan security-audit skill are not mirrored; they include offensive or
exploit-reproduction workflows. The
[App Store Compliance skill](https://github.com/NagyVikt/app-store-compliance/blob/d2156bab9d7189835631c0a99adcc2479d32138d/agent-os/skill/SKILL.md)
is source-linked only: its nonstandard redistribution terms were not cleared
for this catalog.
