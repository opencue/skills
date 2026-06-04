# First-Time Dev Environment Setup

The clone, install, first-run, first-test walkthrough for a fresh cue checkout.

## Questions to ask up front

- Is `bun` installed and at least version 1.0? (`bun --version`)
- Is this a fork (for contribution) or the upstream clone (for local change)?
- Which branch? Default `main`. A release branch may exist: `git branch -r | grep release`.

## Steps

```bash
# 1. Clone
git clone https://github.com/opencue/cuecards.git ~/Documents/cue
cd ~/Documents/cue

# 2. Install deps (requires bun >= 1.0)
bun install

# 3. Run cue locally (no build step, bun runs the TypeScript)
bun src/index.ts status
bun src/index.ts list

# 4. Run the test suite
bun test
```

A green `bun test` means the environment is ready. If install fails, confirm `bun --version` is >= 1.0; cue does not use npm, conda, or a virtualenv.

## Prerequisites

- **Bun** >= 1.0 from [bun.sh](https://bun.sh)
- **Git** for cloning and version control
- **Node.js** >= 20 (optional, only for npm-based MCPs)

## What NOT to do

- Do not `npm install` or `pip install` anything. cue is bun-only.
- Do not run a global install. If a dependency is genuinely missing, it belongs in `package.json` via `bun add`, after discussion.
- Do not edit files outside the repo to make the build work.

## Verifying the install

```bash
bun src/index.ts --version     # prints the cue version
bun src/index.ts doctor        # environment health check
bun test                       # full suite, must be green before you start
```

If `cue` (the installed shim) is also on PATH, `cue lint-skill` and other subcommands work without the `bun src/index.ts` prefix.
