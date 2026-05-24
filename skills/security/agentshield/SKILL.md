---
name: agentshield
description: Use when the user asks to scan or audit a Claude Code / agent configuration for security issues — hardcoded secrets, overly-permissive Bash allow rules, hook injection, risky MCP servers, agent prompt-injection vectors — or mentions "agentshield", "scan my .claude", "audit my settings.json", "ecc-agentshield", or "miniclaw".
---

# AgentShield — security auditor for AI agent configurations

`ecc-agentshield` is a CLI scanner from [affaan-m/agentshield](https://github.com/affaan-m/agentshield) that audits `.claude/` directories, `settings.json`, `mcp.json`, hook scripts, and agent definitions for secrets, permission misconfigs, hook injection, MCP supply-chain risks, and prompt-injection vectors. Output is a graded report (A–F, 0–100) with severity-tagged findings.

## When to use

- The user wants to **vet a Claude Code / Codex / agent config** before sharing, committing, or deploying it.
- After installing a community plugin / skill / MCP — to verify the new surface didn't introduce a vulnerability.
- In CI on a PR that touches `.claude/`, `.codex/`, `settings.json`, `mcp.json`, hook scripts, or an `agents/` directory.
- The user mentions the recent agent-marketplace incidents (12% malicious skills, 1.5M leaked tokens) and wants a baseline scan.

## Quick start

```bash
# Scan the active ~/.claude/ (auto-discovery)
npx ecc-agentshield scan

# Scan a specific path (a repo's .claude/, .codex/, or a settings.json)
npx ecc-agentshield scan --path /path/to/project/.claude

# Auto-fix safe findings (env-var references for hardcoded secrets)
npx ecc-agentshield scan --fix

# Machine-readable
npx ecc-agentshield scan --format json
npx ecc-agentshield scan --format html > report.html

# Portable audit bundle (evidence + findings for handoff)
npx ecc-agentshield scan --evidence-pack ./agentshield-evidence

# Deep three-agent adversarial analysis via Opus (needs ANTHROPIC_API_KEY)
npx ecc-agentshield scan --opus --stream
```

Discovery automatically skips `node_modules/`, build output, and `.dmux` worktree mirrors.

## What it catches (5 rule categories, ~102 rules)

| Category | Count | Examples |
|---|---|---|
| **secrets** | 10 | hardcoded API keys, tokens, passwords, exposed env values, leaked webhooks, base64-encoded creds, private keys, internal IPs |
| **permissions** | 10 | `Bash(*)`, dangerous git flags, mutable tools, sensitive path access, network access without deny list |
| **hooks** | 34 | command injection, exfiltration, persistence, container escape, clipboard reads, log tampering, reverse shells |
| **mcp** | 23 | risky servers, env override, `npx` supply-chain risk, auto-approve, missing timeouts, bind-all interfaces, CORS misconfig |
| **agents** | 25 | tool-restriction gaps, prompt-injection vectors, reflection attacks, output manipulation, social-engineering pretexts |

Severity → deductions: `critical` -25, `high` -15, `medium` -5, `low` -2, `info` 0. Grade thresholds: A ≥90, B ≥75, C ≥60, D ≥40, F <40.

## CI / GitHub Action

```yaml
# .github/workflows/agentshield.yml
on: [pull_request]
jobs:
  agentshield:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: affaan-m/agentshield@v1
        with:
          path: .claude
          fail-on: high   # fail PR if any high/critical findings
```

A GitHub App ([`ecc-tools`](https://github.com/apps/ecc-tools)) also exists for org-wide PR commenting.

## MiniClaw — sandboxed agent execution server

AgentShield ships a separate sub-tool (`miniclaw`) that runs Claude Code in a hardened HTTP sandbox with tool whitelisting, prompt sanitization, rate limiting, and CORS. Use when the user wants to expose Claude as an internal HTTP API without giving it full shell.

```bash
npx ecc-agentshield miniclaw start                       # localhost:3000
npx ecc-agentshield miniclaw start --port 4000 --rate-limit 20
```

API + dashboard docs: `src/miniclaw/README.md` in the upstream repo.

## How to interpret the report

1. **Critical / high findings** are the only ones that should block a merge. Medium/low surface during a baseline audit.
2. **Active-runtime** findings (`mcp.json`, `.claude/mcp.json`, `.claude.json`, active `settings.json`) are real exposure. **Template-example** findings (`mcp-configs/`, `config/mcp/`) are catalog risks, not active runtime.
3. For hardcoded secrets, prefer `--fix` to auto-replace with `${ENV_VAR}` references — then move the actual value to a real env vault (e.g. envoult for Coolify projects).
4. For `Bash(*)` rules, replace with narrow patterns: `Bash(git *)`, `Bash(npm *)`, `Bash(node *)`.
5. For risky MCPs (`npx`-launched servers without pinned versions, broad filesystem access), pin a tag or sha and tighten the allowed root path.

## Output reference

```text
AgentShield Security Report
Grade: F (0/100)
Score Breakdown
  Secrets        ░░░░░░░░░░░░░░░░░░░░ 0
  Permissions    ░░░░░░░░░░░░░░░░░░░░ 0
  Hooks          ░░░░░░░░░░░░░░░░░░░░ 0
  MCP Servers    ░░░░░░░░░░░░░░░░░░░░ 0
  Agents         ░░░░░░░░░░░░░░░░░░░░ 0

● CRITICAL  Hardcoded Anthropic API key
  CLAUDE.md:13
  Fix: Replace with environment variable reference [auto-fixable]
```

## When NOT to use

- General OWASP / web-app security review of application code → use the `security-review` skill instead.
- Secret-scanning of arbitrary repos that have nothing to do with agent configs → use `gitleaks` / `trufflehog`.
- Running it against `node_modules/` or generated dirs — AgentShield already skips these; don't override unless you have a reason.

## Upstream

- Repo: <https://github.com/affaan-m/agentshield>
- npm: `ecc-agentshield`
- Author: Affaan Mustafa (built at Claude Code Hackathon, Feb 2026)
- Part of the [Everything Claude Code](https://github.com/affaan-m/everything-claude-code) ecosystem
