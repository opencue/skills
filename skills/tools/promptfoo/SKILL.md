---
name: promptfoo
description: Use when the user says "eval this prompt", "compare prompts/models", "test my LLM output", "regression-test the prompt", "red team the assistant", or "promptfoo". Runs declarative LLM evals and red-team scans locally with the promptfoo CLI and reports a pass rate instead of a vibe.
allowed-tools: Bash(promptfoo:*)
category: tools
tags: [tools, evals, llm, prompts, testing, red-team]
metadata:
  version: 1.0.0
  homepage: https://github.com/promptfoo/promptfoo
---

# LLM evals with promptfoo

promptfoo runs a matrix of **prompts × providers × test cases**, checks every output with assertions,
and prints a pass rate. Use it when a prompt or model change needs a number behind it: "the new prompt
is better" is a hypothesis until an eval says so.

## Prerequisites

Install the CLI once, globally (Node >= 22.22):

```bash
npm install -g promptfoo
promptfoo --version
```

Always run with telemetry, the update check and sharing off:

```bash
export PROMPTFOO_DISABLE_TELEMETRY=1 PROMPTFOO_DISABLE_UPDATE=1 PROMPTFOO_DISABLE_SHARING=1
```

## Privacy and cost — read before running

- **Never run `promptfoo share`, `eval --share` or `promptfoo auth login` unless the user asks.** They
  upload prompts, test data and outputs to promptfoo's cloud. A machine that is already logged in can
  have sharing switched on in its cloud config, and then a plain `eval` shares too — which is why
  `PROMPTFOO_DISABLE_SHARING=1` is always set above, not only for "private" projects.
- **A real eval spends API money**: calls = prompts × providers × tests × `--repeat`, plus one grader
  call per `llm-rubric` assertion. State the call count and ask before the first paid run.
- Provider keys come from the environment (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, …) or `--env-file`.
  Never write a key into `promptfooconfig.yaml`.
- Test data is sent to the model provider: use synthetic or anonymised cases, not customer records.

## Example — offline smoke test (no key, no cost)

The `echo` provider returns the rendered prompt, so the pipeline can be checked for free:

```yaml
# promptfooconfig.yaml
description: ad title prompt
prompts:
  - 'Write a short ad title for: {{product}}'
providers:
  - echo
tests:
  - vars: { product: 'garden chair' }
    assert:
      - type: contains
        value: 'garden chair'
      - type: javascript
        value: output.length < 200
```

```bash
promptfoo validate -c promptfooconfig.yaml     # "Configuration is valid."
promptfoo eval -c promptfooconfig.yaml --no-progress-bar -o results.json
```

## Core pattern — compare prompts or models

```yaml
prompts:
  - file://prompts/v1.txt
  - file://prompts/v2.txt
providers:
  - anthropic:messages:claude-haiku-4-5        # provider id = <vendor>:<api>:<model>
defaultTest:
  options:
    provider: anthropic:messages:claude-haiku-4-5   # grader for llm-rubric
tests:
  - description: refuses to invent a warranty
    vars: { product: 'used drill', notes: 'no warranty' }
    assert:
      - type: not-icontains
        value: 'warranty included'
      - type: llm-rubric
        value: States clearly that there is no warranty. Does not add facts missing from the notes.
  - file://tests/*.yaml
```

```bash
promptfoo eval -c promptfooconfig.yaml --no-progress-bar -j 4 -o results.json
promptfoo eval ... --repeat 3            # pass RATE over N runs, for flaky outputs
promptfoo eval ... --filter-pattern 'warranty'
promptfoo eval ... --no-cache            # force fresh calls (the default cache is on disk)
promptfoo view                           # local browser UI for the last run — nothing is uploaded
```

Read the result from `results.json` (`results.stats.successes` / `failures` / `errors`) or the summary
lines `✓ N passed (X%)`. The exit code is non-zero when a test fails — usable as a CI gate.

## Assertions worth knowing

| Type | Checks |
|---|---|
| `contains` / `icontains` / `not-contains` / `not-icontains` | substring (case-sensitive / insensitive / absent) |
| `regex`, `starts-with` | pattern |
| `is-json`, `contains-json` | valid JSON, optionally against a JSON schema in `value` |
| `javascript` / `python` | any expression over `output`, `context.vars` → boolean or 0–1 score |
| `llm-rubric` | a grader model judges the output against a plain-language rule |
| `similar` | embedding similarity to a reference, with `threshold` |
| `cost`, `latency` | budget ceilings |

Prefer deterministic assertions; add one `llm-rubric` per behaviour that cannot be checked mechanically.

## Testing your own code instead of a raw prompt

Point a provider at a script, so the eval exercises the real prompt-building code:

```yaml
providers:
  - file://eval/provider.mjs      # export default class { id() {…}  async callApi(prompt, context) { return { output } } }
```

## Red teaming

`promptfoo redteam init` → edit `redteam` plugins/strategies → `promptfoo redteam run`. It generates
adversarial inputs (prompt injection, data leakage, jailbreaks) against the configured target and
grades the responses. The attack probes are generated by promptfoo's own remote models, so a
description of the target leaves the machine and the run needs network access beyond the target's API.
It is the most call-hungry mode — confirm scope, budget and that sending the target description out is
acceptable first, and only target systems the user owns.

## Checklist before reporting

- [ ] `promptfoo validate` passed.
- [ ] The same tests ran against the baseline and the candidate (one variable changed).
- [ ] Reported: pass rate per prompt/provider, the failing cases, the number of paid calls made.
- [ ] Nothing was shared or uploaded.
