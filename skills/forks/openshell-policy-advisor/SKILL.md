---
name: openshell-policy-advisor
description: >-
  Use only while working in the claude-quickstarts project. Use when an OpenShell sandbox returns policy_denied,
  mentions policy.local, or needs a narrow network policy proposal.
category: forks
---

> Upstream: [NagyVikt/claude-quickstarts](https://github.com/NagyVikt/claude-quickstarts/blob/4a4224bdf0e9cfb3332167b69c90457403813625/managed-agents/self-hosted-sandboxes/openshell-policy/sandbox/openshell-skills/policy-advisor/SKILL.md). Run project-specific commands only in a checkout of that upstream project.

# OpenShell Policy Advisor

When a request fails with `policy_denied`, do not treat the denial as final if the user task still needs the request. Read `/etc/openshell/skills/policy_advisor.md`, inspect `http://policy.local/v1/policy/current`, submit the narrowest proposal to `http://policy.local/v1/proposals`, wait on `/v1/proposals/{chunk_id}/wait?timeout=300`, and retry only after approval with `policy_reloaded: true`.
