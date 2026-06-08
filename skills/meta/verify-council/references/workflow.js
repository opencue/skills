export const meta = {
  name: 'verify-council',
  description: 'Token-scaled council of independent verifier lanes plus a real-screen visual lane; returns raw verdicts for the author to adjudicate.',
  phases: [
    { title: 'Council', detail: 'parallel verifier lanes over the diff + claims' },
  ],
}

// ---------------------------------------------------------------------------
// args (all passed by the orchestrating agent — scripts have no FS access):
//   diff          string   capped unified diff of the change (inline)
//   diffCmd       string   OR a scoped command the lane runs to get the diff,
//                          e.g. "git diff -- src/lib/picker.ts". Use this
//                          instead of `diff` for large diffs — same token cost,
//                          no giant string through args. One of diff/diffCmd.
//   claims        array    [{ id, text, kind: 'logic'|'visual', file }]
//   surface       string   'code' | 'tui' | 'web'   (default 'code')
//   hardToReverse boolean  add the skeptic lane when true
//   appCmd        string   how the visual lane launches a TUI surface (optional)
//   url           string   dev-server URL for a web surface (optional)
//
// The MECHANICAL gate (tests / typecheck / lint) runs in the orchestrator
// BEFORE this script — a failing gate means no council is spawned at all. This
// engine is only the agent fan-out; adjudication happens back in the orchestrator
// on the strong model, so the strong model never enters the parallel barrier.
// ---------------------------------------------------------------------------

// The harness may hand `args` to the script as a JSON STRING rather than a parsed
// object (verified: typeof args === 'string'). Parse it so a.claims / a.diff /
// a.hardToReverse resolve — otherwise every field reads undefined and the lanes
// run with no diff and no claims, which makes them roam the whole repo.
let a = args ?? {}
if (typeof a === 'string') {
  try { a = JSON.parse(a) } catch { a = {} }
}
const diff = String(a.diff ?? '').slice(0, 60000)
const diffCmd = a.diffCmd ? String(a.diffCmd) : ''
const claims = Array.isArray(a.claims) ? a.claims : []
const surface = a.surface ?? 'code'
const isVisual = surface === 'tui' || surface === 'web'

// Each lane either gets the diff inline, or is told to run one scoped command to
// obtain it (kept scoped so the lane never roams the repo — the token discipline
// is the same either way).
const diffSection = diff
  ? `The change under review is EXACTLY the diff below. Do not read or report on any
file outside it; discard any issue you cannot tie to a line shown here.
--- DIFF ---\n${diff}\n--- END DIFF ---`
  : diffCmd
    ? `The change under review is EXACTLY the output of this one command. Run it
verbatim and treat its output as the complete and only changeset:
  ${diffCmd}
Hard scope: do NOT run \`git diff\` without these exact paths, do NOT open, read,
or report on any file outside this output, and discard any finding you cannot
tie to a line inside it. Reviewing the wider repo is a scope violation that wastes
the token budget.`
    : '(no diff provided — audit the claims against the named files only)'

// When the caller lists claims, the lane must answer THOSE claims, not invent its
// own. Without this the lane drifts into a free-form repo review (more tokens, and
// the caller's actual claims go unverified).
const claimsDirective = claims.length
  ? `Return exactly one verdict per claim id below, using these ids verbatim. Do not
add, rename, merge, or invent claim ids. If a claim cannot be judged from the
changeset, mark it NA with that reason.`
  : `No claims were listed: derive the key correctness claims from the changeset itself.`

const claimsBlock = claims.length
  ? claims.map((c, i) => `${c.id ?? i + 1}. [${c.kind ?? 'logic'}] ${c.text}${c.file ? `  (${c.file})` : ''}`).join('\n')
  : '(no explicit claims listed — audit the diff for correctness)'

// Structured verdict every lane returns, so the orchestrator never parses prose.
const VERDICT = {
  type: 'object',
  additionalProperties: false,
  required: ['lane', 'summary', 'claims', 'findings'],
  properties: {
    lane: { type: 'string' },
    summary: { type: 'string', description: 'one line' },
    claims: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['id', 'verdict', 'evidence'],
        properties: {
          id: { type: 'string' },
          verdict: { type: 'string', enum: ['PASS', 'FAIL', 'PARTIAL', 'NA'] },
          evidence: { type: 'string', description: 'quoted line or measured value — never a paraphrase' },
        },
      },
    },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: false,
        required: ['severity', 'text'],
        properties: {
          severity: { type: 'string', enum: ['CRITICAL', 'HIGH', 'MEDIUM', 'LOW'] },
          text: { type: 'string' },
        },
      },
    },
  },
}

const NEUTRAL = `You are an INDEPENDENT verifier with no shared context. Do not edit anything.
Several assertions below may be false — do not assume they are correct.
For each claim return verdict PASS/FAIL/PARTIAL/NA with evidence that QUOTES the
exact line or MEASURES the value. A remembered or paraphrased line is not evidence.`

function correctnessPrompt() {
  return `${NEUTRAL}

Lane: correctness. Re-derive each claim strictly from the change.
${claimsDirective}

CLAIMS:
${claimsBlock}

${diffSection}`
}

function redteamPrompt() {
  return `${NEUTRAL}

Lane: red-team. Review ONLY the change for blocking defects.
  CRITICAL: security holes, data loss, crashes, injection, broken auth.
  HIGH:     real bugs, broken contracts, race conditions, wrong logic.
List each as a finding with its severity. Do not list LOW/style nits as blocking.
If there are no CRITICAL or HIGH defects, return an empty findings array and
summary "REVIEW_CLEAN". Map each claim's verdict to NA unless the change disproves it.

${diffSection}`
}

function visualPrompt() {
  const visualClaims = claims.filter((c) => c.kind === 'visual')
  const vBlock = visualClaims.length
    ? visualClaims.map((c, i) => `${c.id ?? i + 1}. ${c.text}`).join('\n')
    : '(measure whatever the diff claims about the rendered surface)'
  const driver = surface === 'web'
    ? `Surface: WEB. Use the lightpanda MCP tools (search for them with ToolSearch:
   goto ${a.url ?? '<dev-server-url>'} , then eval getComputedStyle() /
   getBoundingClientRect() on the relevant selectors and return the MEASURED
   pixel values.`
    : `Surface: TUI. Use the cue-tty-watch MCP tools (search for them with ToolSearch):
   launch the app in a tmux pane${a.appCmd ? ` with \`${a.appCmd}\`` : ''}, send_keys_tmux to
   reach the target screen, screenshot it, then find_text / ask_about_image to
   assert each claim against what is ACTUALLY on screen.`

  return `${NEUTRAL}

Lane: visual proof. Drive the REAL rendered surface and report what you observe.
A code read is NOT acceptable evidence for a visual claim — only a measured or
screenshotted value counts.

${driver}

VISUAL CLAIMS:
${vBlock}`
}

function skepticPrompt() {
  return `${NEUTRAL}

Lane: skeptic. Your job is to REFUTE the riskiest claim, not confirm it. Default
each claim to FAIL ("refuted") unless the change makes it undeniable. Be adversarial.
${claimsDirective}

CLAIMS:
${claimsBlock}

${diffSection}`
}

// Adaptive lane set: 2 default, +visual when visual, +skeptic when hard to reverse.
const lanes = [
  { key: 'correctness', prompt: correctnessPrompt() },
  { key: 'redteam', prompt: redteamPrompt() },
]
if (isVisual) lanes.push({ key: 'visual', prompt: visualPrompt() })
if (a.hardToReverse) lanes.push({ key: 'skeptic', prompt: skepticPrompt() })

// Surface the parsed inputs so a misdelivery (e.g. empty claims, no diff) is
// obvious in the run log instead of silently degrading into a repo-wide roam.
log(
  `council: ${lanes.map((l) => l.key).join(' + ')} ` +
    `(surface=${surface}, claims=${claims.length}, diff=${diff ? 'inline' : diffCmd ? 'cmd' : 'NONE'})`,
)

phase('Council')
const verdicts = await parallel(
  lanes.map((l) => () =>
    agent(l.prompt, { label: `lane:${l.key}`, phase: 'Council', schema: VERDICT, model: 'sonnet' })
      .then((v) => ({ ...v, lane: l.key }))
  ),
)

const ok = verdicts.filter(Boolean)
const blocking = ok.flatMap((v) =>
  (v.findings ?? []).filter((f) => f.severity === 'CRITICAL' || f.severity === 'HIGH').map((f) => ({ lane: v.lane, ...f })),
)
const failed = ok.flatMap((v) =>
  (v.claims ?? []).filter((c) => c.verdict === 'FAIL' || c.verdict === 'PARTIAL').map((c) => ({ lane: v.lane, ...c })),
)

// Raw material for the orchestrator's Phase-2 adjudication. No strong-model
// spend happened inside this script.
return {
  lanes: lanes.map((l) => l.key),
  verdicts: ok,
  blocking,
  disputedClaims: failed,
  clean: blocking.length === 0 && failed.length === 0,
}
