---
name: hostinger-webmail-login
description: >-
  Use when user says "open hostinger mail", "log into hostinger webmail", "hostinger webmail login", or "/hostinger-webmail-login". Opens https://mail.hostinger.com/ in a headed Chromium window and signs in with a stored credential. Stays open for the user.
last_updated: "2026-05-13"
---

# Hostinger Webmail Login

Launches a visible Chromium window, navigates to `https://mail.hostinger.com/`, and signs in using the email the user specifies. The password is **never** stored in this skill — it lives in a chmod-600 file outside any git repo.

## Credentials file

Location:

```
~/.config/hostinger-webmail/accounts.json
```

Shape:

```json
{
  "_default": "<fallback password>",
  "accounts": {
    "info@example.com": "<password-for-this-account>",
    "support@another.hu": "<another-password>"
  }
}
```

Lookup order: explicit `accounts.<email>` → `_default` → fail.

The file must be `0600`. If a user reports "no password", check with:

```bash
ls -la ~/.config/hostinger-webmail/accounts.json
```

Never write the password to anywhere inside `~/Documents/soul/`, the project repo, the conversation transcript echo, or a screenshot. If the user pastes a password in chat, treat it as sensitive — add it to `accounts.json` via a single `Write`/`Edit` of that file, do not re-print it.

## Invocation

The skill ships with `login.py`. Run it via `uv` so the `playwright` package is auto-installed into an ephemeral env:

```bash
uv run --with playwright \
  python ~/Documents/soul/skills/skills/hostinger/hostinger-webmail-login/login.py \
  <email>
```

Optional flags:

- `--password '<override>'` — bypass the stored password (use sparingly; prefer updating `accounts.json`)
- `--headless` — run without a visible window (debug / automation only)

The script blocks until the user closes the Chromium window, so launch it in the background or in its own terminal if Claude needs to keep working:

```bash
uv run --with playwright \
  python ~/Documents/soul/skills/skills/hostinger/hostinger-webmail-login/login.py \
  <email> &
```

(In Claude Code, prefer `run_in_background: true` on the Bash call.)

## Browser profile

Persistent profile lives at `~/.cache/hostinger-webmail-profile/`. Cookies, sessions, and "remember me" state survive across launches — second logins to the same account often skip the password prompt entirely. Delete the folder to force a fresh session:

```bash
rm -rf ~/.cache/hostinger-webmail-profile
```

## Login-page quirks

Hostinger's webmail entrypoint sometimes redirects through their h-panel SSO and sometimes goes straight to a Roundcube-style form. The script handles both:

1. fills the first `input[type=email]` it sees,
2. if a password field is not yet visible, clicks a "Next" / "Continue" / "Tovább" button,
3. fills the password field,
4. clicks the submit button (falls back to pressing Enter).

If selectors stop working, open the window with `--headless=false` (default) and watch the flow; update the locator chain in `login.py`.

## Adding a new account

If the user gives an email + password:

1. Read `~/.config/hostinger-webmail/accounts.json`.
2. Add `"<email>": "<password>"` under `accounts`.
3. Write the file back with `Edit` (don't echo the password in chat).
4. Confirm with `ls -la` only — never `cat` the file.

## Quick checks

```bash
# is the script reachable?
test -x ~/Documents/soul/skills/skills/hostinger/hostinger-webmail-login/login.py && echo ok

# is the creds file present and locked down?
stat -c '%a %n' ~/.config/hostinger-webmail/accounts.json   # expect: 600

# does Chromium launch headed? (requires a display / Wayland session)
echo "${DISPLAY:-${WAYLAND_DISPLAY:-no-display}}"
```
