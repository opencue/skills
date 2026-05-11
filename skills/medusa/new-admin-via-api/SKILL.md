---
name: new-admin-via-api
description: >-
  Use when user says "create Medusa admin", "new admin via API", or "add admin user". API-based admin creation: auth, request, envs.
allowed-tools: Bash(curl:*)
---

# Create Medusa Admin User via API

Medusa v2 does **not** expose `POST /admin/users`. Admin creation goes through
invites. Pick the flow based on whether the backend already has an admin.

Inputs from the user:
- `backend-url` — e.g. `https://admin.compastor.hu` (no trailing slash)
- `email` — new admin email (must be a valid email; Medusa rejects bare usernames)
- `password` — new admin password
- Optional: `existing-admin-email` + `existing-admin-password` — required for Flow A

Before doing anything, ask the user to confirm: *does an admin user already
exist on this backend?* If they don't know, try logging in with their best
guess (Flow A, step 1) — a 401 means no usable existing admin.

---

## Flow A — Invite-accept (additional admin, existing admin known)

1. **Login as the existing admin** to get a session JWT:
   ```bash
   curl -sS -X POST "$BACKEND/auth/user/emailpass" \
     -H 'Content-Type: application/json' \
     -d "{\"email\":\"$EXISTING_EMAIL\",\"password\":\"$EXISTING_PASS\"}"
   ```
   Response: `{"token":"<ADMIN_JWT>"}`. If 401, the existing admin creds are
   wrong — fall back to Flow B.

2. **Mint an invite** for the new email:
   ```bash
   curl -sS -X POST "$BACKEND/admin/invites" \
     -H "Authorization: Bearer $ADMIN_JWT" \
     -H 'Content-Type: application/json' \
     -d "{\"email\":\"$NEW_EMAIL\"}"
   ```
   Response includes `invite.token` — that's `$INVITE_TOKEN`.

3. **Register the auth identity** for the new email/password (this creates the
   identity but no user yet):
   ```bash
   curl -sS -X POST "$BACKEND/auth/user/emailpass/register" \
     -H 'Content-Type: application/json' \
     -d "{\"email\":\"$NEW_EMAIL\",\"password\":\"$NEW_PASS\"}"
   ```
   Response: `{"token":"<REG_JWT>"}`. The JWT has empty `actor_id` until the
   invite is accepted.

4. **Accept the invite** with the registration JWT to link identity → user:
   ```bash
   curl -sS -X POST "$BACKEND/admin/invites/accept?token=$INVITE_TOKEN" \
     -H "Authorization: Bearer $REG_JWT" \
     -H 'Content-Type: application/json' \
     -d "{\"email\":\"$NEW_EMAIL\",\"first_name\":\"...\",\"last_name\":\"...\"}"
   ```
   200 → user created. The new admin can now log in at `$BACKEND/app/login`.

5. **Verify** by logging in as the new admin (same call as step 1, with new creds).

If step 4 returns "user is already authenticated and cannot accept an invite",
the JWT has a non-empty `actor_id` — register a fresh identity with a different
email or use Flow B.

---

## Flow B — CLI bootstrap (first admin, no existing admin)

There is no API path for the first admin. You must run the Medusa CLI inside
the running backend, either locally (if `DATABASE_URL` reaches the live DB) or
via `docker exec` on the deployment host:

```bash
# Option 1: locally, after `pnpm install` in apps/backend, with apps/backend/.env
# pointing at the production DATABASE_URL
cd apps/backend && node_modules/.bin/medusa user -e "$NEW_EMAIL" -p "$NEW_PASS"

# Option 2: via SSH + docker exec on the Coolify/Hostinger host
ssh root@<vps-ip> 'docker exec <medusa-container-name> npx medusa user -e <email> -p <password>'
```

Find the container name in the Coolify app details (look for the `medusa-...`
container) or via `docker ps` on the host. After bootstrap, switch to Flow A
for any further admins.

---

## Reporting

Print: backend URL, new admin email, the flow used (A or B), step-by-step
results (exit codes / HTTP statuses), and the final login URL
(`$BACKEND/app/login`). Never echo the password back. Mask JWTs to first 12
chars when logging.

## Pitfalls

- The `email` MUST be RFC-valid; bare strings like `compastor-admin` are
  rejected.
- The auth identity created in Flow A step 3 cannot be retried with the same
  email — if step 4 fails after step 3, the identity is stuck. Pick a new email
  or have the user clean up via DB.
- `admin.compastor.hu` and similar Coolify deployments may have TWO
  `DATABASE_URL` env vars; the active one is what the running container sees.
  Verify with the diagnose tool before assuming a local CLI run hits the right
  DB.
- Medusa v2 stores admin sessions as cookies for the dashboard but accepts
  bearer JWTs for API calls — these are interchangeable for this skill.
