# Troubleshooting

## Build and run

| Symptom | Likely cause | Action |
|---|---|---|
| `bun: command not found` | Bun not installed or not on PATH | Install from [bun.sh](https://bun.sh), open a fresh shell |
| Commands fail right after `git pull` | Stale `node_modules` | Re-run `bun install`; there is no compiled artifact to clear |
| `cue` (shim) runs old behavior | Shim points at a different checkout | Run `bun src/index.ts <cmd>` directly to confirm, then re-check the shim path |
| TypeScript errors only in `web/` | Wrong tsconfig scope | `cd web && bunx tsc --noEmit` |

## Tests

| Symptom | Likely cause | Action |
|---|---|---|
| One test passes alone but fails in the suite | Env-var or state leak across tests | Isolate setup/teardown; do not let one test mutate global env for another |
| A profile test fails after editing `profiles/` | Profile no longer validates | `cue validate --all` and fix the reported field |
| Flaky failure | Order dependence or a real race | Re-run the single file; if it still flakes, treat it as a real bug, not noise |

## Lint gate

| Symptom | Likely cause | Action |
|---|---|---|
| `cue lint-skill` reports an error | R001/R002/R005 (missing name, missing description, malformed `allowed-tools`) | Fix the frontmatter; `--fix` handles the auto-fixable warnings |
| Stop-time gate blocks the session | A changed SKILL.md has a lint error | `cue lint-skill <path>` to see it, fix, re-run |
| Broken-anchor warning (R008) | A `#anchor` link points at a heading that does not exist | Fix or remove the anchor; relative file links to real files are fine |
| Em-dash warning (R009) | An em dash in prose | Replace with commas or periods, or wrap a legitimate use in backticks |

## Dependencies

| Symptom | Likely cause | Action |
|---|---|---|
| CI flags a dependency mismatch | `package.json` and lockfile drifted | `bun install` to regenerate the lockfile, commit it |
| Tempted to add a package | A utility feels missing | Confirm the need, propose the `package.json` edit, let the maintainer `bun add` it; never global-install |

## When stuck

- `cue doctor` for an environment health check.
- `cue launch claude --dry-run` to see what a launch would materialize.
- Read the neighboring source and its test before changing behavior.
- After three failed attempts at the same fix, stop and re-state the problem
  rather than flailing; the approach is probably wrong.
