# Lane prompts (Agent-tool fallback)

Use these when the Workflow tool is unavailable (e.g. Codex). Spawn one Agent
per lane, in parallel, each on a cheap model (sonnet). They are the same prompts
the Workflow engine builds inline; this file is the human-readable canonical
copy. Fill in `<DIFF>`, `<CLAIMS>`, `<URL>`, `<APP_CMD>` before spawning.

Every lane shares this preamble:

```text
You are an INDEPENDENT verifier with no shared context. Do not edit anything.
Several assertions below may be false — do not assume they are correct.
For each claim return PASS / FAIL / PARTIAL / NA with evidence that QUOTES the
exact line or MEASURES the value. A remembered or paraphrased line is not evidence.
Return a terse list: one claim id + verdict + one evidence line each.

SCOPE: the change under review is EXACTLY <DIFF> (or the verbatim output of the one
command you are given). Do not open or report on any file outside it; discard any
finding you cannot tie to a line shown there. Reviewing the wider repo wastes the
token budget.
CLAIMS: answer exactly the claim ids listed, verbatim. Do not invent, rename, or add
ids. If a claim cannot be judged from the change, mark it NA.
```

The scope + claim-binding lines matter: without them a lane drifts into a free-form
repo review, which both blows the token budget and leaves the caller's actual claims
unverified.

## Lane A — correctness (always)

```text
Lane: correctness. Re-derive each claim strictly from the diff.

CLAIMS:
<CLAIMS>

--- DIFF ---
<DIFF>
--- END DIFF ---
```

## Lane B — red-team (always for code)

```text
Lane: red-team. Review ONLY the diff for blocking defects.
  CRITICAL: security holes, data loss, crashes, injection, broken auth.
  HIGH:     real bugs, broken contracts, race conditions, wrong logic.
List each as a finding with severity. Skip LOW/style nits.
If there are no CRITICAL or HIGH defects, reply exactly: REVIEW_CLEAN.

--- DIFF ---
<DIFF>
--- END DIFF ---
```

## Lane C — visual proof (only when the surface is rendered)

A code read is not acceptable here. Only a screenshot or a measured value counts.

TUI surface:

```text
Lane: visual proof. Surface: TUI.
Use the cue-tty-watch MCP tools (find them with ToolSearch): launch the app in a
tmux pane with `<APP_CMD>`, send_keys_tmux to reach the target screen, screenshot
it, then find_text / ask_about_image to assert each claim against what is on screen.

VISUAL CLAIMS:
<CLAIMS>
```

Web surface:

```text
Lane: visual proof. Surface: WEB.
Use the lightpanda MCP tools (find them with ToolSearch): goto <URL>, then eval
getComputedStyle() / getBoundingClientRect() on the relevant selectors and return
the MEASURED pixel values for each claim.

VISUAL CLAIMS:
<CLAIMS>
```

## Lane D — skeptic (only when the change is hard to reverse)

```text
Lane: skeptic. Your job is to REFUTE the riskiest claim, not confirm it. Default
each claim to FAIL ("refuted") unless the diff makes it undeniable. Be adversarial.

CLAIMS:
<CLAIMS>

--- DIFF ---
<DIFF>
--- END DIFF ---
```

## Adjudication (back on the strong model)

The lanes surface disagreement; the source settles it. For every FAIL / PARTIAL /
finding: re-read the source at its absolute path, quote the exact line (`grep -H`,
never `-h`), and let the source win. Tag a claim `[VERIFIED]` only when its lane
PASSed with quoted or measured evidence; a visual claim needs Lane C's measurement.
