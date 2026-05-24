---
name: mirofish
description: Use when running multi-agent prediction or simulation — digital sandbox rehearsals, social-trend forecasting, swarm-intelligence experiments, "what if" scenarios. Pointer to upstream 666ghj/MiroFish.
allowed-tools: Bash(node:*), Bash(npm:*), Bash(uv:*), Bash(python:*), Bash(python3:*), Bash(docker:*), Bash(git:*)
---

# MiroFish — multi-agent prediction & simulation engine

[`666ghj/MiroFish`](https://github.com/666ghj/MiroFish) — extracts seed information (news, policy drafts, financial signals, narrative fragments), builds a high-fidelity parallel digital world, populates it with thousands of agents that have personalities + long-term memory + behavioral logic, lets them interact, and returns a prediction report. Powered by [OASIS](https://github.com/camel-ai/oasis) (CAMEL-AI's open-source agent social simulation framework).

## When to use
- "Simulate how public opinion would react to [policy / event / announcement]"
- "Predict the second-order effects of [decision] before we commit"
- "Generate a plausible ending to [story / scenario]"
- "Run N counterfactuals on [breaking news / financial signal]"
- Strategy rehearsal: test marketing campaigns, PR statements, product launches against a synthetic crowd before real release
- Creative writing: explore alternate endings, character interactions, world-building consequences

## What you get back
- A detailed **prediction report** (Markdown / structured)
- A **deeply interactive high-fidelity digital world** — you can chat with any simulated agent inside it
- Dual-platform parallel simulation (multiple environments running concurrently)
- Auto-parsed prediction requirements + dynamic temporal memory updates as the sim evolves

## Architecture (workflow stages)
1. **Graph building** — seed extraction, individual + collective memory injection, GraphRAG construction
2. **Environment setup** — entity relationship extraction, persona generation, agent config injection
3. **Simulation** — dual-platform parallel sim, prediction-requirement parser, dynamic temporal memory
4. **Report generation** — ReportAgent with toolset for post-sim interaction
5. **Deep interaction** — chat with any agent in the simulated world OR with ReportAgent

## Install (source — recommended)

```bash
git clone https://github.com/666ghj/MiroFish.git
cd MiroFish
cp .env.example .env
# Edit .env — set LLM_API_KEY, LLM_BASE_URL, LLM_MODEL_NAME, ZEP_API_KEY
npm run setup:all       # installs root + frontend (Node) + backend (Python via uv)
npm run dev             # starts frontend on :3000, backend on :5001
```

## Install (Docker)

```bash
git clone https://github.com/666ghj/MiroFish.git
cd MiroFish
cp .env.example .env       # fill in API keys
docker compose up -d
```

## Prerequisites
- **Node.js** 18+
- **Python** ≥3.11 and ≤3.12 (3.13 not yet supported)
- **uv** (Astral's package manager) — `cue cli install uv` or [docs](https://docs.astral.sh/uv/)
- **An LLM API key** with OpenAI-SDK-compatible endpoint:
  - Recommended: Alibaba Qwen-plus via [Bailian Platform](https://bailian.console.aliyun.com/) — best quality/cost for Chinese + English simulations
  - Any OpenAI-compatible endpoint works (OpenAI, Anthropic via proxy, Together, DeepSeek, etc.)
- **Zep Cloud API key** (free tier sufficient for simple usage) — [getzep.com](https://app.getzep.com/) — provides long-term memory for the simulated agents
- Optional: **Docker** + **docker compose** for the containerized path

## Cost & scale warning
- High LLM consumption — each simulation round = many agent turns × thousands of agents
- Start with **<40 rounds** to gauge cost before larger runs
- The QPS limits of free LLM tiers will throttle simulations; Qwen-plus paid tier or equivalent recommended for serious work

## Notes
- The simulation engine is **OASIS** by CAMEL-AI; MiroFish is the orchestrator + UI + GraphRAG layer on top
- Live demo: [mirofish-live-demo](https://github.com/666ghj/MiroFish#-live-demo)
- For pure agent-simulation research without the predict-report layer, install OASIS directly
- Supports both serious decision rehearsal (macro: policy / PR testing) and playful counterfactuals (micro: novel endings, "what if" exploration)
- The MiroFish team is recruiting (full-time + intern); see upstream README

## Use with cue
This profile (`predict-everything`) inherits `core` and adds this pointer skill plus the `uv` CLI recipe. Future prediction/simulation tools — additional OASIS-based forks, alternate engines like AgentSims or Generative Agents from Stanford — would land as siblings under `predict-everything/`.
