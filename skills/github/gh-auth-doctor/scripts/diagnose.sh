#!/usr/bin/env bash
# gh-auth-doctor: detect stale env tokens masking a working credential store.
# Read-only. Never modifies env, ~/.git-credentials, or gh config.
#
# Exit codes:
#   0 HEALTHY               — gh ok (and store ok if probed)
#   1 ENV_STALE_STORE_FRESH — gh broken AND store has a credential AND env tokens are set
#                             (the silent-finish-hang bug — env masks the working store cred for gh)
#   2 BOTH_BROKEN           — gh broken AND store has no credential
#   3 UNUSUAL               — gh ok but store missing or probe fails
#   4 NO_GH_CLI             — gh binary not in PATH

set -u

gh_bin="${GH_BIN:-gh}"
probe_remote="${GH_AUTH_DOCTOR_PROBE_REMOTE:-}"

check_gh() {
  command -v "$gh_bin" >/dev/null 2>&1 || return 99
  "$gh_bin" auth status >/dev/null 2>&1
}

# Returns 0 if git's credential helper has a stored credential for github.com.
# Uses `git credential fill` non-interactively (no network call). The credential
# store is the canonical place authenticated git pushes read from; if there's
# nothing here, refresh is required regardless of env state.
check_store() {
  local out
  out="$(printf 'protocol=https\nhost=github.com\n\n' \
    | env -u GH_TOKEN -u GITHUB_TOKEN GIT_TERMINAL_PROMPT=0 git credential fill 2>/dev/null)" || return 1
  [[ -n "$out" ]] && printf '%s\n' "$out" | grep -q '^password='
}

# Optional: actually probe a remote URL to verify the stored credential works.
# Skipped by default — set GH_AUTH_DOCTOR_PROBE_REMOTE=<url> to enable.
check_probe_remote() {
  [[ -z "$probe_remote" ]] && return 0
  env -u GH_TOKEN -u GITHUB_TOKEN GIT_TERMINAL_PROMPT=0 git ls-remote "$probe_remote" HEAD >/dev/null 2>&1
}

env_token_state() {
  local gh_set="" gh_user_set="" credstore_helper=""
  [[ -n "${GH_TOKEN:-}" ]] && gh_set="GH_TOKEN"
  [[ -n "${GITHUB_TOKEN:-}" ]] && gh_user_set="GITHUB_TOKEN"
  credstore_helper="$(git config --get-all credential.helper 2>/dev/null | tr '\n' ',' | sed 's/,$//')"
  printf 'env_GH_TOKEN=%s\n' "${gh_set:-unset}"
  printf 'env_GITHUB_TOKEN=%s\n' "${gh_user_set:-unset}"
  printf 'credential.helper=%s\n' "${credstore_helper:-none}"
}

main() {
  local gh_rc store_rc probe_rc env_set verdict exit_code
  check_gh
  gh_rc=$?
  if [[ $gh_rc -eq 99 ]]; then
    printf 'verdict=NO_GH_CLI\n'
    printf 'gh_bin=%s (not found in PATH)\n' "$gh_bin"
    env_token_state
    return 4
  fi
  check_store
  store_rc=$?
  check_probe_remote
  probe_rc=$?

  env_set=0
  [[ -n "${GH_TOKEN:-}" || -n "${GITHUB_TOKEN:-}" ]] && env_set=1

  printf 'gh_auth_status_exit=%s\n' "$gh_rc"
  printf 'credential_store_has_github_password=%s\n' "$([[ $store_rc -eq 0 ]] && echo yes || echo no)"
  if [[ -n "$probe_remote" ]]; then
    printf 'probe_remote=%s\n' "$probe_remote"
    printf 'probe_remote_ls_remote_exit=%s\n' "$probe_rc"
  fi
  env_token_state

  if [[ $gh_rc -eq 0 && ( -z "$probe_remote" || $probe_rc -eq 0 ) ]]; then
    verdict=HEALTHY
    exit_code=0
  elif [[ $gh_rc -ne 0 && $store_rc -eq 0 && $env_set -eq 1 ]]; then
    verdict=ENV_STALE_STORE_FRESH
    exit_code=1
  elif [[ $gh_rc -ne 0 && $store_rc -ne 0 ]]; then
    verdict=BOTH_BROKEN
    exit_code=2
  elif [[ $gh_rc -ne 0 && $store_rc -eq 0 && $env_set -eq 0 && -n "$probe_remote" && $probe_rc -eq 0 ]]; then
    # gh broken, store has cred, no env masking, probe confirmed cred works → only gh needs refresh.
    verdict=GH_BROKEN_GIT_OK
    exit_code=1
  elif [[ $gh_rc -ne 0 && $store_rc -eq 0 && $env_set -eq 0 ]]; then
    # gh broken, store has cred, no env masking, no probe → cannot confirm cred validity; conservative.
    verdict=BOTH_BROKEN
    exit_code=2
  else
    verdict=UNUSUAL
    exit_code=3
  fi
  printf 'verdict=%s\n' "$verdict"

  case "$verdict" in
    HEALTHY)
      printf 'next=proceed\n'
      ;;
    ENV_STALE_STORE_FRESH)
      printf 'next=refresh_gh (interactive: gh auth login -h github.com --web)\n'
      printf 'workaround=prefix automation with: env -u GH_TOKEN -u GITHUB_TOKEN\n'
      printf 'risk=gx branch finish --via-pr will silently hang on this state\n'
      ;;
    BOTH_BROKEN)
      printf 'next=refresh_gh (interactive: gh auth login -h github.com --web)\n'
      printf 'risk=neither gh nor authenticated git push will work until refreshed\n'
      ;;
    GH_BROKEN_GIT_OK)
      printf 'next=refresh_gh (interactive: gh auth login -h github.com --web)\n'
      printf 'workaround=git operations work; only gh-based steps will fail\n'
      printf 'risk=gx branch finish --via-pr will silently hang (gh-based PR creation)\n'
      ;;
    UNUSUAL)
      printf 'next=inspect git config --get-all credential.helper and ~/.git-credentials\n'
      ;;
  esac

  return "$exit_code"
}

main "$@"
