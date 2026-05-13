#!/usr/bin/env python3
"""Open https://mail.hostinger.com/ in a headed Chromium window and sign in.

Reads credentials from ~/.config/hostinger-webmail/accounts.json:
  {
    "_default": "<fallback password>",
    "accounts": { "user@example.com": "<password>" }
  }

Usage:
  uv run --with playwright python login.py <email>
  uv run --with playwright python login.py <email> --password '<override>'

The browser window stays open until the user closes it.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

CREDS_PATH = Path.home() / ".config" / "hostinger-webmail" / "accounts.json"
PROFILE_DIR = Path.home() / ".cache" / "hostinger-webmail-profile"
LOGIN_URL = "https://mail.hostinger.com/"


def load_password(email: str, override: str | None) -> str:
    if override:
        return override
    if not CREDS_PATH.exists():
        sys.exit(f"creds file missing: {CREDS_PATH}")
    data = json.loads(CREDS_PATH.read_text())
    accounts = data.get("accounts") or {}
    if email in accounts:
        return accounts[email]
    default = data.get("_default")
    if default:
        return default
    sys.exit(f"no password for {email} and no _default in {CREDS_PATH}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("email", help="webmail address to sign in as")
    parser.add_argument("--password", help="override stored password", default=None)
    parser.add_argument("--headless", action="store_true", help="run headless (default: visible)")
    args = parser.parse_args()

    password = load_password(args.email, args.password)
    PROFILE_DIR.mkdir(parents=True, exist_ok=True)

    from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout

    with sync_playwright() as p:
        context = p.chromium.launch_persistent_context(
            user_data_dir=str(PROFILE_DIR),
            headless=args.headless,
            viewport={"width": 1280, "height": 860},
            args=["--disable-blink-features=AutomationControlled"],
        )
        page = context.pages[0] if context.pages else context.new_page()
        page.goto(LOGIN_URL, wait_until="domcontentloaded")

        try:
            email_field = page.locator(
                "input[type='email'], input[name='email'], input[name='_user'], input[id*='email' i]"
            ).first
            email_field.wait_for(state="visible", timeout=15_000)
            email_field.fill(args.email)
        except PWTimeout:
            print("could not locate email field — leaving window open for manual entry", file=sys.stderr)
        else:
            # Some flows are two-step: click Next, then password appears.
            pwd_field = page.locator(
                "input[type='password'], input[name='password'], input[name='_pass']"
            ).first
            try:
                pwd_field.wait_for(state="visible", timeout=2_500)
            except PWTimeout:
                next_btn = page.get_by_role("button", name=lambda n: bool(n) and n.strip().lower() in {"next", "continue", "tovább"})
                if next_btn.count():
                    next_btn.first.click()
                    pwd_field.wait_for(state="visible", timeout=10_000)

            pwd_field.fill(password)

            submit = page.locator(
                "button[type='submit'], input[type='submit'], button:has-text('Sign in'), button:has-text('Log in'), button:has-text('Login')"
            ).first
            try:
                submit.click(timeout=5_000)
            except PWTimeout:
                page.keyboard.press("Enter")

        print(f"signed in attempt complete for {args.email}; close the window to exit", flush=True)

        # Block until the user closes the window.
        try:
            context.wait_for_event("close", timeout=0)
        except Exception:
            pass


if __name__ == "__main__":
    main()
