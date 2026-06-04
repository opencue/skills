#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# Faithful to upstream, plus linux/arm64 for ARM servers (Graviton, Hetzner ARM,
# Raspberry Pi). Each target is a static, CGO-free binary.
platforms=(
  "linux/amd64"
  "linux/arm64"
  "darwin/amd64"
  "darwin/arm64"
)

for platform in "${platforms[@]}"; do
  os="${platform%/*}"
  arch="${platform#*/}"
  suffix="${os}-${arch}"

  echo "Building for ${os}/${arch}..."

  echo "  ccimgd-${suffix}"
  (cd daemon && CGO_ENABLED=0 GOOS="$os" GOARCH="$arch" go build -o "ccimgd-${suffix}" .)

  echo "  ccimg-${suffix}"
  (cd client && CGO_ENABLED=0 GOOS="$os" GOARCH="$arch" go build -o "ccimg-${suffix}" .)
done

echo "Done."
