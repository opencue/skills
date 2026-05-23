---
name: profile-suggest
description: >-
  FIRST MESSAGE ONLY. When no .cue-profile exists in the current directory,
  analyze the repo and suggest the best profile. Runs once then self-removes
  from the project CLAUDE.md.
tags: [meta, cue, profiles, onboarding]
category: meta
version: 1.0.0
requires_mcps: []
allowed-tools: Bash
---

# Profile Suggestion (First-Time Repo Setup)

**This skill activates ONLY on the first message in a repo without a `.cue-profile`.**

## Trigger

You see `<!-- cue:first-time-suggest -->` in your CLAUDE.md. This means no profile
is pinned to this directory yet. Your FIRST action before answering the user's
question is to quickly analyze the repo and suggest a profile.

## What to do

### 1. Scan the repo (fast, <2 seconds)

```bash
# Detect project type
ls package.json Cargo.toml pyproject.toml go.mod Makefile Dockerfile docker-compose.yml \
   .github/workflows tsconfig.json next.config.* nuxt.config.* vite.config.* \
   tailwind.config.* prisma/ supabase/ stripe/ 2>/dev/null

# Check package.json for framework hints
cat package.json 2>/dev/null | grep -E '"(next|react|vue|angular|express|fastify|stripe|medusa)"' | head -5

# Check for security/infra patterns
ls .env* terraform/ ansible/ k8s/ helm/ 2>/dev/null
```

### 2. List available profiles

```bash
cue list 2>/dev/null
```

### 3. Present your suggestion (CONCISE — max 6 lines)

Format exactly like this:

```
💡 **Profile suggestion for this repo:**

I detected: [Next.js + Stripe + Supabase project]

→ Recommended: **🦋 frontend** — has ui-ux-pro-max, playwright, image-to-code
  Also relevant: stripe-webhooks, supabase (from backend profile)

Pin it? I'll run: `echo frontend > .cue-profile` — or pick another with `cue list`
```

### 4. If user agrees (or says nothing against it)

```bash
echo "<profile-name>" > .cue-profile
```

Then tell them: "Done! Next time you run `claude` here, it'll boot with the **<name>** profile. Restart to activate, or continue — current session still works."

### 5. Remove the first-time marker

After suggesting (whether accepted or not), the marker is gone next session
because `.cue-profile` now exists (or user explicitly skipped).

## Rules

- **Be fast.** Don't spend more than 1-2 tool calls scanning. The user asked a question — answer it after the suggestion.
- **Don't block.** Show the suggestion, then immediately proceed with the user's actual request.
- **One suggestion only.** Don't nag if they ignore it.
- **If the repo is ambiguous** (could be frontend or backend), suggest the broader one and mention the alternative.
- **If a profile already exists** (`.cue-profile` is present), do nothing — this skill shouldn't have fired.

## Matching heuristics

| Detected | Suggest |
|----------|---------|
| next.config / react / vue / tailwind / vite | frontend |
| express / fastify / prisma / supabase / API routes only | backend |
| Both frontend + backend in monorepo | full or backend (broader) |
| Dockerfile + k8s + terraform | backend or fleet-control |
| .md files + obsidian / docs/ | docs-writer |
| Marketing copy, SEO configs, analytics | marketing |
| Medusa / e-commerce | medusa-dev |
| Security tools, pentest, CTF | cybersecurity |
| NVIDIA / CUDA / ML models | nvidia |
| No clear signal | caveman-quick (lightweight default) |
