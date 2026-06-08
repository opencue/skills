# Internals

Read this before changing the resolver or materializer; they are the hot path
every `claude` / `codex` launch runs through.

## Launch hot path

```
claude (shim) -> cue launch claude
  -> resolveProfileForCwd()    # find which profile applies to cwd
  -> loadProfile()             # YAML parse + inheritance chain
  -> materializeRuntime()      # hash check, then symlink skills + write settings
  -> exec(real claude binary)  # hand off to the real agent
```

The materializer is content-addressed: if the profile has not changed, launch
is a stat plus a sha256 compare (under ~5ms overhead). Keep this path
allocation-light and avoid adding synchronous network or heavy parsing to it.

## Profile resolution order

1. `--cue-profile X` flag (explicit).
2. `.cue.profile` file in cwd, walking up to `$HOME`.
3. Repo-level default (`.cue.profile` at the git root).
4. Global default (`~/.config/cue/default-profile`).
5. TUI picker (interactive fallback).

## Key modules

| Module | Purpose |
|---|---|
| `cwd-resolver.ts` | Find which profile applies to the current directory |
| `profile-loader.ts` | Parse YAML, resolve inheritance chains |
| `runtime-materializer.ts` | Build isolated config dirs with symlinked skills |
| `resolver-local.ts` | Find skills on disk by slug |
| `resolver-npx.ts` | Fetch and cache skills from GitHub repos |
| `skill-linter.ts` | Validate SKILL.md against R001-R008 |
| `manifest-cache.ts` | Cache resolved profiles for fast repeat launches |

## Runtime layout

Materialized runtimes live under `~/.config/cue/runtime/<profile>/`. They are
generated, never hand-edited. To inspect what a launch would produce without
running it:

```bash
cue launch claude --dry-run
```

## Where things live

- CLI source: `src/` (commands in `src/commands/`, shared libs in `src/lib/`).
- Profiles: `profiles/<name>/profile.yaml`.
- Skill library: `resources/skills/skills/<category>/<slug>/`.
- MCP configs: `resources/mcps/`.
- Claude Code plugin (slash commands): `plugins/cue/`.
- cue studio dashboard: `web/` (React + Vite, own tsconfig).

## CI gate reality

CI on `main` can show red on validate or e2e jobs that depend on private or
local-only MCP references. Those are a known baseline condition, not your
break. The real gates for a change are `lint` and `test`. Before merging, prove
your change adds no new failing checks relative to the base branch rather than
chasing a pre-existing red job.
