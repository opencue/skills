#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: provision.sh <bucket-name> [<region=eu-central-1>] [<prefix=medusa/>]

Provisions an S3 bucket for a Medusa v2 backend in one shot.

Required env (or AWS_PROFILE):
  AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY

Optional env:
  CORS_ORIGINS  comma-separated. Default:
                "http://localhost:9000,http://localhost:5173"
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" || $# -lt 1 ]]; then
  usage; exit 2
fi

BUCKET="$1"
REGION="${2:-eu-central-1}"
PREFIX="${3:-medusa/}"
PREFIX="${PREFIX%/}/"  # ensure trailing slash, no double-slash

if ! [[ "$BUCKET" =~ ^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$ ]]; then
  echo "Error: invalid bucket name '$BUCKET'. Lowercase, 3-63 chars, no underscores." >&2
  exit 2
fi

if [[ -z "${AWS_ACCESS_KEY_ID:-}" || -z "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
  if [[ -z "${AWS_PROFILE:-}" ]]; then
    echo "Error: set AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY (or AWS_PROFILE) before running." >&2
    exit 2
  fi
fi

CORS_ORIGINS="${CORS_ORIGINS:-http://localhost:9000,http://localhost:5173}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

ok()   { printf "\033[32m  ok\033[0m %s\n" "$*"; }
warn() { printf "\033[33m  !!\033[0m %s\n" "$*"; }
step() { printf "\033[36m==>\033[0m %s\n" "$*"; }

bucket_exists() {
  aws s3api head-bucket --bucket "$BUCKET" --region "$REGION" >/dev/null 2>&1
}

step "Provisioning bucket '$BUCKET' in $REGION (prefix: $PREFIX)"

# 1. Create bucket (skip if exists)
if bucket_exists; then
  ok "bucket already exists — re-applying configuration"
else
  if [[ "$REGION" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" >/dev/null
  else
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
      --create-bucket-configuration "LocationConstraint=$REGION" >/dev/null
  fi
  ok "bucket created"
fi

# 2. Block public ACLs but allow public bucket policies
aws s3api put-public-access-block --bucket "$BUCKET" --region "$REGION" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=false,RestrictPublicBuckets=false" >/dev/null
ok "public-access-block: ACLs blocked, policies allowed"

# 3. Bucket policy: public read on <prefix>products/*
cat > "$TMP/policy.json" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadProductImages",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${BUCKET}/${PREFIX}products/*"
    }
  ]
}
EOF
aws s3api put-bucket-policy --bucket "$BUCKET" --region "$REGION" --policy "file://$TMP/policy.json" >/dev/null
ok "bucket policy: public read on s3://${BUCKET}/${PREFIX}products/*"

# 4. CORS for admin uploads
ORIGINS_JSON=$(printf '%s' "$CORS_ORIGINS" | awk -F, '{
  printf "[";
  for (i=1; i<=NF; i++) {
    gsub(/^ +| +$/, "", $i);
    printf "%s\"%s\"", (i>1?",":""), $i;
  }
  printf "]";
}')
cat > "$TMP/cors.json" <<EOF
{
  "CORSRules": [
    {
      "AllowedOrigins": ${ORIGINS_JSON},
      "AllowedMethods": ["GET","PUT","POST","DELETE","HEAD"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": ["ETag","x-amz-version-id"],
      "MaxAgeSeconds": 3000
    }
  ]
}
EOF
aws s3api put-bucket-cors --bucket "$BUCKET" --region "$REGION" \
  --cors-configuration "file://$TMP/cors.json" >/dev/null
ok "CORS: ${CORS_ORIGINS}"

# 5. Versioning
aws s3api put-bucket-versioning --bucket "$BUCKET" --region "$REGION" \
  --versioning-configuration "Status=Enabled" >/dev/null
ok "versioning enabled"

# 6. Default SSE-S3 encryption
cat > "$TMP/sse.json" <<'EOF'
{ "Rules": [ { "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm": "AES256" } } ] }
EOF
aws s3api put-bucket-encryption --bucket "$BUCKET" --region "$REGION" \
  --server-side-encryption-configuration "file://$TMP/sse.json" >/dev/null
ok "default encryption: AES256"

# 7. Lifecycle: abort incomplete multipart uploads after 7 days
cat > "$TMP/lifecycle.json" <<EOF
{
  "Rules": [
    {
      "ID": "abort-incomplete-multipart-7d",
      "Status": "Enabled",
      "Filter": { "Prefix": "" },
      "AbortIncompleteMultipartUpload": { "DaysAfterInitiation": 7 }
    }
  ]
}
EOF
aws s3api put-bucket-lifecycle-configuration --bucket "$BUCKET" --region "$REGION" \
  --lifecycle-configuration "file://$TMP/lifecycle.json" >/dev/null
ok "lifecycle: abort incomplete multipart uploads after 7d"

# 8. Print the ready-to-paste env block
FILE_URL="https://${BUCKET}.s3.${REGION}.amazonaws.com"
ENDPOINT="https://s3.${REGION}.amazonaws.com"
cat <<EOF

==============================================================================
Bucket '$BUCKET' ready.

Public URL pattern (product images):
  ${FILE_URL}/${PREFIX}products/<...>

Append to ~/.config/woocommerce-medusa-import/env (importer):
------------------------------------------------------------------------------
S3_BUCKET="${BUCKET}"
S3_REGION="${REGION}"
S3_ENDPOINT="${ENDPOINT}"
S3_FILE_URL="${FILE_URL}"
S3_PREFIX="${PREFIX}"
------------------------------------------------------------------------------

Add to Coolify backend app env (so Medusa file provider switches to S3) — use
R2_* keys because medusa-config's R2 path uses access keys (works with AWS S3):
------------------------------------------------------------------------------
R2_FILE_URL=${FILE_URL}
R2_BUCKET=${BUCKET}
R2_ENDPOINT=${ENDPOINT}
R2_PREFIX=${PREFIX}
R2_ACCESS_KEY_ID=<your AWS access key>
R2_SECRET_ACCESS_KEY=<your AWS secret>
------------------------------------------------------------------------------

Smoke test:
  echo -n x | aws s3 cp - s3://${BUCKET}/${PREFIX}products/_smoke.txt --content-type text/plain
  curl -I "${FILE_URL}/${PREFIX}products/_smoke.txt"   # expect 200
  aws s3 rm s3://${BUCKET}/${PREFIX}products/_smoke.txt
==============================================================================
EOF
