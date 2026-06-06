#!/usr/bin/env bash
# Ensure the Trivy CLI is installed; install via the first method that works.
# Used by the security/trivy-scan skill as the pre-merge gate's prerequisite.
set -euo pipefail

if command -v trivy >/dev/null 2>&1; then
  trivy --version
  exit 0
fi

echo "trivy not found, installing..." >&2
brew install trivy 2>/dev/null \
  || sudo pacman -S --noconfirm trivy 2>/dev/null \
  || curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/v0.71.0/contrib/install.sh \
       | sh -s -- -b "$HOME/.local/bin"

command -v trivy >/dev/null 2>&1 || {
  echo "FATAL: trivy install failed. Install manually: https://trivy.dev/latest/getting-started/installation/" >&2
  exit 1
}
trivy --version
