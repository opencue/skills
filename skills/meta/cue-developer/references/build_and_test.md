# Build & Test

cue runs its TypeScript directly under Bun, so local development has no compile
step. A build only happens when packaging for npm distribution.

## Running cue locally

```bash
bun src/index.ts <command> [args...]

# Examples
bun src/index.ts status
bun src/index.ts list
bun src/index.ts validate --all
bun src/index.ts doctor
bun src/index.ts launch claude --dry-run
```

## Tests

```bash
bun test                              # whole suite
bun test src/lib/skill-router.test.ts # one file
bun test --filter "loadProfile"       # tests matching a pattern
```

Tests live next to their source (`foo.ts` and `foo.test.ts`) and use Bun's
built-in runner. New commands and library functions require tests.

## Typecheck and lint

```bash
bunx tsc --noEmit       # typecheck the root project
bunx biome lint src     # lint the source tree
```

The web studio (under `web/`) has its own `tsconfig.json`; typecheck it from
inside that directory:

```bash
cd web && bunx tsc --noEmit
```

## Skill linting

Any SKILL.md you touch must pass the linter with zero errors:

```bash
cue lint-skill resources/skills/skills/<category>/<slug>/SKILL.md
cue lint-skill <path> --fix     # auto-fix the fixable warnings
```

`cue lint-skill` exits 0 when there are no errors (warnings and info are
allowed but lower the score). The Stop-time quality gate
(`resources/quality-gates/lint-skill-pass.sh`) blocks if any changed SKILL.md
has a lint error.

## Packaging build (rare)

```bash
bun run build:bundle     # node-targeted dist/cue.js for npm publish
```

You do not need this for normal development. If the local CLI behaves oddly
after pulling, the cause is almost never a stale build (there is none); re-run
`bun install` and `bun test`.

## RAM-constrained machines

cue's test suite is light compared to a CUDA build, so there is no
`PARALLEL_LEVEL` knob to tune. If `bun test` is slow, run a single file or a
`--filter` pattern while iterating, then the full suite once before committing.
