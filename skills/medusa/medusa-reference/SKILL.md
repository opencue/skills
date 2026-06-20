---
name: medusa-reference
description: 'Use when user says "Medusa workflow", "Medusa subscriber", "Medusa auth", or "Medusa query", or modifies API routes, models, or backend logic. Reference for Medusa v2 backend/storefront patterns.'
category: medusa
---

# Medusa Reference

Use this skill before editing Medusa-specific code.

1. Identify the change scope first:
- backend workflow / subscriber / API / auth / model / query
- storefront integration / request flow / data mapping

2. Prefer existing project patterns:
- locate nearest similar implementation
- reuse naming, folder placement, and error handling style

3. For backend changes:
- keep handlers/workflows narrow and explicit
- validate payloads and avoid silent fallback behavior
- return actionable errors that help debugging

4. For storefront changes:
- keep data fetching and transformation predictable
- avoid hidden coupling between UI and backend response shape
- preserve existing loading/error states

5. Read references when relevant:
- references/workflows-and-subscribers.md
- references/api-and-auth.md
- references/storefront-integration.md
