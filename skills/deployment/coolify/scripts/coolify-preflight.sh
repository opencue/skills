#!/usr/bin/env bash
set -euo pipefail

echo "[coolify] binary: $(command -v coolify)"
echo "[coolify] version: $(coolify version)"
echo "[coolify] config: $(coolify config)"

echo "[coolify] contexts:"
coolify context list --format=table

echo "[coolify] context verify:"
if coolify context verify --format=table; then
  echo "[coolify] verification: ok"
else
  echo "[coolify] verification: failed (check token/context)"
fi
