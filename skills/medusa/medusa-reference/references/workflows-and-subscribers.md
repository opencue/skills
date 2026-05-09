# Workflows And Subscribers

- Use deterministic step naming and narrow responsibility per step.
- Keep event subscriber side effects idempotent when possible.
- Prefer explicit guards over broad try/catch suppression.
- Reuse existing event names and payload conventions from nearby modules.
