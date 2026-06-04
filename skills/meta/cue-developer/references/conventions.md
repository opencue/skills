# Coding Conventions

Match the file you are editing. When a local pattern conflicts with this list,
the local pattern wins; raise the conflict instead of silently diverging.

## Language and modules

- TypeScript, ESM (`import` / `export`), no CommonJS `require`.
- Lazy-import heavy modules inside command handlers so cold start stays fast
  (see existing files in `src/commands/`).
- Prefer `node:fs/promises` for async work; use `node:fs` sync only in hot
  paths like the launch resolver.

## Naming

- Variables and functions: `camelCase`, descriptive.
- Booleans: `is`, `has`, `should`, or `can` prefix.
- Types, interfaces, classes: `PascalCase`.
- Constants: `UPPER_SNAKE_CASE`.

## File organization

- Many small files over few large ones. High cohesion, low coupling.
- One command per file in `src/commands/`, registered in `_index.ts`.
- Tests sit next to source: `foo.ts` and `foo.test.ts`.
- Aim for under 400 lines per file; 800 is the hard ceiling.

## Error handling

- Use typed error classes for failures the caller should branch on (see
  `resolver-npx.ts` for the pattern).
- Handle errors explicitly. Do not swallow them silently.
- User-facing CLI messages should be short and actionable; log detail to stderr.

## Immutability

- Build new objects instead of mutating inputs. Return a changed copy rather
  than editing in place. This keeps the resolver and materializer predictable.

## Input validation

- Validate at the boundary: CLI args, parsed YAML, file contents, network
  responses. Fail fast with a clear message.

## Tests

- New commands and library functions need tests.
- Arrange, Act, Assert structure. Name the test for the behavior under test, for
  example `returns empty array when no profile matches`.
- Keep tests isolated; do not let one test's environment variables leak into
  another (a past suite failure came from exactly this).

## Voice for docs and skills

No em dashes. Avoid filler and AI-vocabulary words (delve, crucial, robust,
comprehensive, nuanced, leverage, furthermore, moreover, pivotal, landscape).
Lead a sentence with the verb or the answer.
