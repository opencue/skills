# API And Auth

- Keep route handlers focused: parse input, validate, delegate, format output.
- Reuse project auth middleware and permission checks.
- Fail closed for protected actions.
- Avoid leaking internal errors or stack traces in API responses.
