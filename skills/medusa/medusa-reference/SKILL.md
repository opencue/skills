---
name: medusa-reference
description: Medusa implementation guidance for backend and storefront work. Use when building or modifying Medusa workflows, subscribers, API routes, auth, data models, query logic, jobs, or storefront integrations.
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
