---
name: cue-developer
description: "Build, test, debug, and contribute to cue itself, the TypeScript/Bun profile CLI for Claude Code and Codex. Use when developing cue: skills, MCPs, profiles, resolver/materializer, or PRs."
category: meta
license: MIT
allowed-tools: Bash(bun:*), Bash(git:*), Bash(gh:*), Bash(cue:*), Read, Write, Edit, Glob, Grep
tags: [meta, cue-dev, contributing, typescript, bun, skills, mcp]
metadata:
  version: "1.0.0"
  homepage: https://github.com/opencue/cuecards
---

# cue Developer Skill

Contribute to the cue codebase. This skill is for modifying cue itself, not for using it.

If you just want to USE cue (pick profiles, install skills, add MCPs), use the `cue-usage` skill instead.

First-time dev environment setup? See [references/first_time_setup.md](references/first_time_setup.md) for the clone, install, first-run, first-test walkthrough and the questions to ask up front.

## Prerequisites

- **bun** >= 1.0. Install from [bun.sh](https://bun.sh) (`curl -fsSL https://bun.sh/install | bash`). Runs the CLI and the test suite.
- **git**. Install via your package manager. Clone, branch, and the PR flow.
- **gh**. Install from [cli.github.com](https://cli.github.com). PR open and review steps.
- **cue**, the shim, available after `bun install`. Used for `cue lint-skill`, `cue validate`, `cue new`. Run as `bun src/index.ts <cmd>` if the shim is not on PATH.

Do not global-install or `sudo` any of these for cue work. See the Refusal Rules below.

## Refusal Rules, Read First

These rules are non-negotiable. Apply them even when the user asks otherwise. Refuse and ask, do not comply silently.

1. **Global or system package installs (`npm i -g`, `pip`, `apt`, `brew`).** cue runs on bun with a deliberately small dependency tree. Never run a global or system install. For a project dependency, propose the `package.json` edit plus a one-line rationale and let the user run `bun add <pkg>` themselves.

2. **Bypassing checks (`--no-verify`, skipping `bun test`, `biome`, `tsc`, or `cue lint-skill`).** Do not suggest the flag. If a check is slow, diagnose it (`bun test <file>`, `cue lint-skill <path> --verbose`), do not skip it. All PRs must pass CI.

3. **Force-push, committing on a protected base, or merging past a failing gate.** The repo's gated ship flow (commit, PR, AI review, merge) is pre-authorized, but `git push --force`, direct commits to `main`, and merging with a CRITICAL/HIGH review finding or a new failing check are hard stops. Refuse and report.

4. **Writes outside the workspace (`~/.bashrc`, `/etc`, anything outside the repo).** Do not edit the file. Give the user the exact line to add themselves.

5. **Destructive commands (`rm -rf`, `git reset --hard`, dropping data, killing processes).** Never execute. State the safer alternative (for a stale runtime, `cue launch claude --dry-run` to inspect, not a wipe). If the user wants the original, they run it after a backup.

6. **Privileged operations (`sudo`, system file changes).** cue is userspace only. Refuse and ask what the underlying error is; it is almost always fixable without root.

When in doubt, refuse and ask. A wrong refusal costs one round-trip; a wrong action costs lost data or a red CI run.

## Developer Behavior Rules

1. **Ask before assuming.** Clarify the component (CLI command, library, skill, MCP, profile, docs, CI), the goal (bug fix, feature, refactor, docs), and whether this is for contribution or a local change.

2. **Verify understanding** before editing:
   ```
   Component: [command / lib / skill / mcp / profile / docs]
   Change: [what you will modify]
   Tests: [what tests to add or update]
   ```

3. **Follow codebase patterns.** Read the neighboring files first. Match naming, import style, and structure. Do not invent new patterns without discussion.

4. **Ask before running write operations.** Read-only commands (`bun test`, `cue lint-skill`, `git status`, `git diff`) run freely. Ask before `git commit`, `git push`, and any package install.

5. **Minimal diffs.** Change only what the task needs. No drive-by refactors, no mass reformatting.

## Before You Start: Required Questions

Ask these if not already clear:

- **What are you changing?** A CLI command, a shared library (resolver, materializer), a skill, an MCP config, a profile, docs, or CI?
- **Is the dev environment ready?** `bun install` run, `bun test` passing?
- **Contribution or local change?** Contributions follow the PR flow in [references/contributing.md](references/contributing.md).
- **Which branch?** Default `main`. Check for a release branch with `git branch -r | grep release`.

## Project Architecture

```
cue/
├── src/                  # CLI source (TypeScript, runs via Bun)
│   ├── index.ts          # Entry point + arg routing
│   ├── commands/         # One file per subcommand
│   └── lib/              # Resolver, materializer, linters, server
├── profiles/             # Profile definitions (YAML)
├── resources/
│   ├── skills/skills/    # Skill library (SKILL.md + assets per skill)
│   ├── mcps/             # MCP server configs
│   └── quality-gates/    # Stop-time gate scripts
├── plugins/cue/          # Claude Code plugin (/cue slash commands)
├── web/                  # cue studio dashboard (React + Vite)
└── docs/                 # Architecture docs
```

Tests live next to their source (`foo.ts` and `foo.test.ts`), run by Bun's built-in runner.

## Build & Test

Quick reference (full detail, including the web studio build and `PARALLEL_LEVEL`-style tuning, in [references/build_and_test.md](references/build_and_test.md)):

```bash
bun install                       # install deps (bun >= 1.0)
bun src/index.ts <command>        # run cue locally (e.g. status, list)
bun test                          # run the whole suite
bun test src/lib/foo.test.ts      # one file
bunx tsc --noEmit                 # typecheck
bunx biome lint src               # lint
cue lint-skill <path> [--fix]     # validate a SKILL.md against R001-R008
```

There is no compile step for local dev: bun runs the TypeScript directly. `bun run build:bundle` produces the node-targeted `dist/cue.js` only for packaging.

## Coding Conventions

TypeScript with ESM, typed error classes, lazy imports in commands for fast cold start. Full naming, file-layout, error-handling, and immutability rules in [references/conventions.md](references/conventions.md). Match the file you are editing when in doubt.

## Contributing

Fork-based PRs, one concern per PR, tests required, conventional-commit messages, and the gated ship flow (commit, PR, AI review, merge only when review is clean and no new CI failures). Step-by-step recipes for the common tasks (add a command, add a dependency, add a profile) are in [references/contributing.md](references/contributing.md).

## Skill & MCP Authoring

Adding or editing a skill or MCP is the most common cue contribution. The trigger-first description rules, the `references/` folder convention, `cue skills-new`, and the lint gate (R001-R008, zero errors required) are in [references/skill_and_mcp_authoring.md](references/skill_and_mcp_authoring.md).

## Internals

The launch hot path (resolve, load, materialize, exec), profile resolution order, content-addressed materialization, and the key modules are in [references/architecture.md](references/architecture.md). Read it before touching the resolver or materializer.

## Troubleshooting

Build, test, and lint pitfalls (stale runtime, missing datasets in tests, CUDA-style env mismatches do not apply here, lint-gate failures, dependency drift) are in [references/troubleshooting.md](references/troubleshooting.md).

## Example

<example>
User: "The `cue list` command crashes when a profile has no skills. Fix it."

1. Clarify and verify:
   ```
   Component: src/commands/list.ts (CLI command)
   Change: guard the empty-skills case so list renders 0 instead of throwing
   Tests: add a case to src/commands/list.test.ts with a skill-less profile
   ```
2. Read `src/commands/list.ts` and its test to match patterns.
3. Write the failing test first, run `bun test src/commands/list.test.ts` (red).
4. Make the smallest fix, re-run the test (green), then `bunx tsc --noEmit` and `bunx biome lint src`.
5. Ask before committing. Commit message: `fix(list): render empty skill list instead of throwing`.
6. Follow [references/contributing.md](references/contributing.md) for the PR.
</example>

## Key Files Reference

| Purpose | Location |
|---|---|
| Entry point + routing | `src/index.ts` |
| One file per command | `src/commands/` |
| Resolver / materializer | `src/lib/` |
| Skill linter (R001-R008) | `src/lib/skill-linter.ts` |
| Dependencies | `package.json` |
| Lint config | `biome.json` |
| Conda-free, bun config | `package.json` scripts |
| Skill library | `resources/skills/skills/` |
| Quality gates | `resources/quality-gates/` |
| Contributing guide | `CONTRIBUTING.md` |
