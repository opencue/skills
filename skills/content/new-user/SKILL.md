---
name: new-user
description: >-
  Create a new Medusa admin user via `npx medusa user -e <email> -p <password>`.
  Use when user says create admin, new admin user, /medusa-dev:user, or supplies
  an email + password pair for a Medusa backend. Medusa-only — NOT for general
  user creation.
argument-hint: <email> <password>
allowed-tools: Bash(npx medusa user:*)
---

# Create Admin User

Create a new admin user in Medusa with the specified email and password.

The user will provide two arguments:
- First argument: email address
- Second argument: password

For example: `/medusa-dev:user admin@test.com supersecret`

Use the Bash tool to execute the command `npx medusa user -e <email> -p <password>`, replacing `<email>` with the first argument and `<password>` with the second argument.

Report the results to the user, including:

- Confirmation that the admin user was created successfully
- The email address of the created user
- Any errors that occurred
- Next steps (e.g., logging in to the admin dashboard)
