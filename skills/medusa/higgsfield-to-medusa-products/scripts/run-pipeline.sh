#!/usr/bin/env bash
# run-pipeline.sh — generate product images via Higgsfield, host on S3, patch
# Medusa products. See ../SKILL.md for the full contract.
#
# Usage:
#   run-pipeline.sh <shop> [<manifest.json>]
#
# Env overrides:
#   DRY_RUN=1       — generate + upload only, skip Medusa patch
#   SKIP_OPTIMIZE=1 — keep PNGs, do not convert to JPEG
#   RUN_ID=<str>    — override per-run cache subdir (default: timestamp)

set -euo pipefail

SHOP="${1:-}"
MANIFEST="${2:-$HOME/.config/medusa-image-pipeline/$SHOP.manifest.json}"
[[ -z "$SHOP" || ! -f "$MANIFEST" ]] && {
  cat <<EOF >&2
usage: $0 <shop> [<manifest.json>]
  manifest defaults to ~/.config/medusa-image-pipeline/<shop>.manifest.json
  see assets/manifest.example.json for schema
EOF
  exit 2
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=load-env.sh
SHOP="$SHOP" source "$SCRIPT_DIR/load-env.sh"

RUN_ID="${RUN_ID:-$(date +%Y%m%d-%H%M%S)}"
CACHE_DIR="$HOME/.cache/medusa-image-pipeline/$SHOP/$RUN_ID"
mkdir -p "$CACHE_DIR"

AUTH_HEADER="Authorization: Basic $(printf '%s:' "$MEDUSA_SECRET_KEY" | base64 -w0)"

# --- Bootstrap checks ---
for cmd in jq curl aws higgsfield; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "missing: $cmd" >&2; exit 3; }
done

# --- Auth probe ---
echo "==> Auth probe $MEDUSA_BACKEND_URL"
code=$(curl -sL --max-time 10 -o /dev/null -w "%{http_code}" \
  -H "$AUTH_HEADER" "$MEDUSA_BACKEND_URL/admin/products?limit=1")
[[ "$code" != "200" ]] && { echo "    auth failed HTTP $code" >&2; exit 4; }
echo "    ok (200)"

# --- Per-product loop ---
ENTRY_COUNT=$(jq 'length' "$MANIFEST")
echo "==> Manifest has $ENTRY_COUNT product(s)"

for i in $(seq 0 $((ENTRY_COUNT - 1))); do
  ENTRY=$(jq -c ".[$i]" "$MANIFEST")
  SLUG=$(echo "$ENTRY" | jq -r '.slug')
  PID=$(echo "$ENTRY" | jq -r '.product_id // empty')
  SHOTS_LEN=$(echo "$ENTRY" | jq '.shots | length')

  echo ""
  echo "==> [$((i+1))/$ENTRY_COUNT] $SLUG"

  # Resolve product_id from slug if absent
  if [[ -z "$PID" ]]; then
    PID=$(curl -sL --max-time 10 -H "$AUTH_HEADER" \
      "$MEDUSA_BACKEND_URL/admin/products?handle=$SLUG&limit=1" \
      | jq -r '.products[0].id // empty')
    [[ -z "$PID" ]] && { echo "    err  no product with handle=$SLUG"; continue; }
    echo "    resolved id=$PID"
  fi

  # Generate + download + upload each shot
  PUBLIC_URLS=()
  FAILED=0
  for j in $(seq 0 $((SHOTS_LEN - 1))); do
    SHOT=$(echo "$ENTRY" | jq -c ".shots[$j]")
    VARIANT=$(echo "$SHOT" | jq -r '.variant')
    EXISTING_URL=$(echo "$SHOT" | jq -r '.url // empty')

    if [[ -n "$EXISTING_URL" ]]; then
      # Manifest provided a URL directly — keep it (no Higgsfield call).
      PUBLIC_URLS+=("$EXISTING_URL")
      echo "    keep $VARIANT $EXISTING_URL"
      continue
    fi

    MODE=$(echo "$SHOT" | jq -r '.mode')
    PROMPT=$(echo "$SHOT" | jq -r '.prompt')
    ASPECT=$(echo "$SHOT" | jq -r '.aspect_ratio // "1:1"')
    REF_IMAGE=$(echo "$SHOT" | jq -r '.image // empty')

    echo "    gen  $VARIANT mode=$MODE aspect=$ASPECT"
    HF_ARGS=(product-photoshoot create
      --mode "$MODE"
      --prompt "$PROMPT"
      --count 1
      --aspect_ratio "$ASPECT"
      --resolution 2k
      --output json)
    [[ -n "$REF_IMAGE" ]] && HF_ARGS+=(--image "$REF_IMAGE")

    HF_RES=$(higgsfield "${HF_ARGS[@]}" 2>&1) || {
      echo "    err  higgsfield failed: $(echo "$HF_RES" | tail -1)"; FAILED=1; break; }
    HF_URL=$(echo "$HF_RES" | jq -r '.[0].url // .images[0].url // empty')
    [[ -z "$HF_URL" ]] && { echo "    err  no url in higgsfield response"; FAILED=1; break; }

    PNG="$CACHE_DIR/$SLUG-$VARIANT.png"
    curl -fsSL --max-time 60 -o "$PNG" "$HF_URL" || { echo "    err  download failed"; FAILED=1; break; }

    # Optimize → jpg if magick available and not skipped
    EXT="png"
    UPLOAD_FILE="$PNG"
    if [[ -z "${SKIP_OPTIMIZE:-}" ]] && command -v magick >/dev/null 2>&1; then
      JPG="$CACHE_DIR/$SLUG-$VARIANT.jpg"
      magick "$PNG" -quality 86 -strip "$JPG" >/dev/null 2>&1 && { EXT="jpg"; UPLOAD_FILE="$JPG"; }
    fi

    KEY="${S3_PREFIX}${SLUG}-${VARIANT}.${EXT}"
    aws s3 cp "$UPLOAD_FILE" "s3://${S3_BUCKET}/${KEY}" \
      --region "$S3_REGION" \
      --content-type "image/${EXT/jpg/jpeg}" \
      --cache-control "public, max-age=31536000, immutable" \
      >/dev/null

    PUB_URL="${S3_PUBLIC_BASE}/$(basename "$KEY")"
    PUB_CODE=$(curl -sI -o /dev/null -w "%{http_code}" "$PUB_URL")
    [[ "$PUB_CODE" != "200" ]] && { echo "    err  s3 public check $PUB_CODE for $PUB_URL"; FAILED=1; break; }

    PUBLIC_URLS+=("$PUB_URL")
    echo "    up   $VARIANT $PUB_URL"
  done

  (( FAILED == 1 )) && { echo "    skip $SLUG (generation/upload failed)"; continue; }

  # Patch product
  if [[ -n "${DRY_RUN:-}" ]]; then
    echo "    dry  would PATCH $PID with ${#PUBLIC_URLS[@]} images"
    continue
  fi

  THUMB="${PUBLIC_URLS[0]}"
  IMAGES_JSON=$(printf '%s\n' "${PUBLIC_URLS[@]}" | jq -R . | jq -s 'map({url: .})')
  BODY=$(jq -n --arg t "$THUMB" --argjson imgs "$IMAGES_JSON" '{thumbnail:$t, images:$imgs}')
  STATUS=$(curl -sL --max-time 20 -o "$CACHE_DIR/$SLUG-patch.json" -w "%{http_code}" \
    -X POST "$MEDUSA_BACKEND_URL/admin/products/$PID" \
    -H "$AUTH_HEADER" -H "Content-Type: application/json" -d "$BODY")
  if [[ "$STATUS" == "200" ]]; then
    echo "    ok   $SLUG ($PID) — ${#PUBLIC_URLS[@]} images"
  else
    echo "    err  $SLUG ($PID) HTTP $STATUS"
    head -c 400 "$CACHE_DIR/$SLUG-patch.json" >&2; echo >&2
  fi
done

echo ""
echo "==> Done. Cache: $CACHE_DIR"
