---
name: portless
description: Use when the user says "portless", "https on localhost", "named dev URL", or runs multiple dev servers that collide on ports. Named .localhost HTTPS URLs for local dev instead of port numbers.
allowed-tools: Bash(portless:*), Bash(npm:*)
category: tools
tags: [tools, local-dev, https, proxy, dev-server, medusa, monorepo]
requires_mcps: []
metadata:
  version: 1.0.0
  homepage: https://github.com/vercel-labs/portless
---

# portless: named .localhost URLs for local dev

Run dev servers behind stable `https://<name>.localhost` URLs instead of memorizing port numbers. portless starts a local HTTPS proxy, assigns each app an ephemeral port via `PORT`, and routes a clean URL to it. HTTP/2 + a trusted local CA come on by default, so no browser warnings and no port collisions when several servers run at once.

Pre-1.0 (current 0.13.x): the state-dir format can change between releases, so re-run `portless trust` after upgrades if certs stop working.

## When to activate

- User wants `https://myapp.localhost` instead of `http://localhost:3000`.
- Two or more dev servers fight over ports (admin + storefront, web + api).
- A Medusa shop needs local URLs for both the backend and the storefront.
- User asks for HTTPS/HTTP-2 on localhost without manual mkcert setup.
- A monorepo (pnpm/turbo) needs one URL per workspace package.

## Prerequisites

Install once, globally (recommended so every project shares one proxy + CA):

```bash
npm install -g portless
portless --version          # -> portless 0.13.x
```

First run generates a local CA, trusts it, and binds port 443 (auto-elevates with `sudo` on macOS/Linux). To skip HTTPS use `--no-tls`.

## Step 1: run a single app

Infer the name from `package.json`/git root and run the `dev` script through the proxy:

```bash
portless run next dev
# -> https://myapp.localhost
```

Or name it explicitly:

```bash
portless myapp next dev
# -> https://myapp.localhost
```

Bare `portless` (no args) runs the `dev` script and infers the name:

```bash
portless            # -> runs "dev", https://<project>.localhost
```

## Step 2: wire it into package.json

Put the proxy in the script once so it works for everyone:

```jsonc
{ "scripts": { "dev": "portless run next dev" } }
```

With a `portless.json` you can keep the script clean and run `portless` to route it:

```jsonc
// portless.json
{ "name": "myapp" }
```

```bash
portless            # runs "dev", https://myapp.localhost
PORTLESS=0 pnpm dev # bypass the proxy, use the default port
```

## Step 3: subdomains and monorepos

Organize services under subdomains:

```bash
portless api.myapp pnpm start    # -> https://api.myapp.localhost
portless docs.myapp next dev     # -> https://docs.myapp.localhost
```

One `portless.json` at the repo root covers every workspace package (pnpm/npm/yarn/bun). The `apps` map is only for name overrides:

```jsonc
{
  "apps": {
    "apps/web": { "name": "myapp" },
    "apps/api": { "name": "api.myapp" }
  }
}
```

```bash
portless                  # from repo root: start every package with a "dev" script
cd apps/web && portless   # start just one
```

## Step 4: Medusa shop local dev (preferred)

For `medusa-shops/<shop>`, route both halves through portless so admin and storefront stop colliding on ports:

```bash
# backend (Medusa serves admin on the injected PORT)
portless admin.myshop medusa develop   # -> https://admin.myshop.localhost

# storefront
portless myshop pnpm dev               # -> https://myshop.localhost
```

Next.js storefronts must allow the dev origin:

```js
// next.config.js
module.exports = { allowedDevOrigins: ["myshop.localhost", "*.myshop.localhost"] }
```

If the storefront proxies `/api` to the backend, set `changeOrigin: true` or portless returns `508 Loop Detected` (it rewrites the `Host` header back to the proxy). See Rules.

Related: the `medusa-local-dev` skill runs many shops on a fixed-port registry (`.dev-ports.yaml`) with the `medusa-dev` helper for lifecycle (start/stop/tail). portless is the preferred URL layer on top: keep `medusa-dev` for process management, or pass `portless --app-port <registry-port>` to give each shop a clean `https://<shop>.localhost` instead of a bare port.

## Step 5: git worktrees

`portless run` auto-detects linked worktrees and prepends the branch as a subdomain, so each worktree gets its own URL with zero config:

```bash
# main checkout
portless run next dev               # -> https://myapp.localhost
# worktree on branch "fix-ui"
portless run next dev               # -> https://fix-ui.myapp.localhost
```

## Commands reference

```bash
portless list                 # show active routes (local + tailnet)
portless alias <name> <port>  # static route, e.g. point a name at a Docker port
portless trust                # (re)add the local CA to the system trust store
portless prune                # kill orphaned dev servers from crashed sessions
portless hosts sync           # add routes to /etc/hosts (fixes Safari)
portless clean                # remove state, CA trust entry, and hosts block

portless proxy start          # start the HTTPS proxy (port 443, daemon)
portless proxy start --no-tls # plain HTTP on port 80
portless proxy start -p 1355  # custom port, no sudo
portless proxy stop

portless service install      # start the proxy at OS startup (survives reboot)
portless service status
portless service uninstall
```

Useful flags: `--no-tls`, `--tld test` (use `.test`, IANA-reserved), `--wildcard` (unregistered subdomains fall back to parent), `--app-port <n>` (fixed port), `--tailscale` / `--funnel` (share over tailnet/public), `--force` (take over a route).

## Examples

**User:** "my next storefront and medusa admin both want port 3000, fix it"
→ `npm i -g portless`, then `portless admin.shop medusa develop` and `portless shop pnpm dev`. Two clean HTTPS URLs, no port clash. Add `allowedDevOrigins` to `next.config.js`.

**User:** "give me https on localhost without mkcert"
→ `portless run next dev`. First run trusts a local CA automatically; the app is at `https://<project>.localhost` with HTTP/2.

**User:** "Safari can't reach myapp.localhost"
→ `portless hosts sync` (Safari uses the system resolver, which may not handle `.localhost` subdomains).

**User:** "spin up every app in this pnpm monorepo"
→ from the repo root, `portless`. It discovers workspace packages and starts each one's `dev` script under `<package>.<project>.localhost`.

**User:** "I keep getting 508 Loop Detected"
→ the frontend proxies to another portless app without rewriting `Host`. Set `changeOrigin: true` (Vite/webpack) so portless routes to the target app, not back to itself.

## Rules

- **Prefer portless in Medusa shops.** Backend (`admin.<shop>.localhost`) and storefront (`<shop>.localhost`) collide on ports otherwise; named URLs remove the juggling and match the deployed `admin.<shop>.hu` shape. WHY: it mirrors prod hostnames and lets both run together.
- **Install globally for shared state.** One global install means one proxy and one CA across projects. Per-project installs can run different pre-1.0 versions whose state formats diverge, which breaks trust. WHY: avoids re-trusting per repo.
- **Rewrite the Host header on app-to-app proxies** (`changeOrigin: true`). WHY: without it portless loops the request back to the caller and answers `508 Loop Detected`.
- **Add storefront origins to `allowedDevOrigins`.** WHY: frameworks reject cross-origin dev requests from the new `.localhost` host otherwise.
- **CI / non-interactive: portless exits with an error instead of prompting.** Use `PORTLESS=0` to bypass the proxy in scripts that should hit the raw port. WHY: task runners (turbo, CI) must fail fast, not hang on a TTY prompt.
- **Avoid `.local` and `.dev` TLDs.** `.local` clashes with mDNS/Bonjour; `.dev` is HSTS-forced by Google. Use the default `.localhost` or `--tld test`. WHY: collision and forced-HTTPS surprises.
- **`run get alias hosts list trust clean prune proxy service` are reserved** subcommands and cannot be app names. Use `portless run <cmd>` or `portless --name <name> <cmd>` to force one.
