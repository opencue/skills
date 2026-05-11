---
name: provision-medusa-s3-bucket
description: >-
  Use when user says "Medusa S3", "provision bucket", or "file storage bucket" and needs S3
  bucket provisioning for Medusa. Covers envs, provider settings, access, and validation.argument-hint: <bucket-name> [<region=eu-central-1>] [<prefix=medusa/>]
allowed-tools: Bash(aws:*)
---

# Provision Medusa S3 Bucket

One-shot S3 bucket setup for a Medusa v2 backend running anywhere (Hostinger
VPS, EC2, anything). Pairs with `medusa-config.ts` configurations that use
`@medusajs/medusa/file-s3` with explicit access keys (the R2 provider config
path in this codebase, with AWS endpoint + region set).

## Bouncer migration: out of scope

This skill operates at AWS-account admin tier — `s3:CreateBucket`,
`s3:PutBucketPolicy`, `s3:PutBucketCORS`, `s3:PutBucketLifecycle`,
`s3:PutEncryptionConfiguration`, `s3:PutBucketVersioning`. The recodee
bouncer MCP (`tools/secret-mcp/`) intentionally does NOT wrap these
operations — see PR #1660's design.md §"What this design does NOT settle":

> AWS-account admin operations (CreateBucket, PutBucketPolicy, etc.).
> Bucket provisioning is rare, admin-tier, and currently scripted via the
> `provision-medusa-s3-bucket` skill running with operator AWS creds.
> Adding these to the bouncer would require a separate IAM principal and
> review; defer to a follow-up PR if/when an agent-driven provisioning
> flow exists.

In practice this means: **provisioning runs with operator credentials**,
not vault-injected ones. The operator's `aws` CLI session must have IAM
admin reach (or at least `AmazonS3FullAccess`) for the duration of the
provision. After the bucket is up, the **runtime** credentials that go
into Medusa's `medusa-config.ts` are the lower-privilege ones the bouncer
serves to the agent at object-tier (`PutObject`/`GetObject`/`HeadObject`/
`DeleteObject` on the specific bucket, scoped via
`AWS_S3_BUCKETS_ALLOWED`).

This skill therefore stays **shell-driven only** — Mode B in the
nomenclature of `higgsfield-to-medusa-products`. There is no Mode A
alternative for it.

## Inputs

- `bucket-name` (required): globally unique S3 bucket name (e.g.
  `compastor-medusa`). Lowercase, no underscores.
- `region` (optional, default `eu-central-1`): AWS region. Must match the
  region you actually want the bucket in.
- `prefix` (optional, default `medusa/`): top-level prefix for all Medusa
  objects. Bucket policy will allow public read on `<prefix>products/*`.

## What the script does

1. Creates the bucket via `aws s3api create-bucket` (with
   `LocationConstraint` for non-us-east-1 regions).
2. Sets `PublicAccessBlock` to allow bucket policies (block public ACLs only).
3. Applies bucket policy: anonymous `s3:GetObject` on
   `arn:aws:s3:::<bucket>/<prefix>products/*`.
4. Applies CORS for admin uploads: allows `GET, PUT, POST, DELETE, HEAD` from
   `https://admin.<shop-domain>` and localhost dev. Edit the script if you need
   different origins.
5. Enables versioning (so accidental admin deletes are recoverable).
6. Sets `AES256` server-side encryption as default.
7. Adds a lifecycle rule that aborts incomplete multipart uploads after 7 days.
8. Prints the env var block ready to paste into the importer env file and into
   Coolify backend env.

## Usage

```bash
bash <path-to-skill>/scripts/provision.sh <bucket-name> [<region>] [<prefix>]

# Example:
bash ~/Documents/soul/skills/skills/medusa/provision-medusa-s3-bucket/scripts/provision.sh \
  compastor-medusa eu-central-1 medusa/
```

## Output env vars

The script prints two blocks — for the importer env file and for Coolify
backend app — pre-filled with the bucket's `https://<bucket>.s3.<region>.amazonaws.com`
URL and the supplied prefix.

## CORS origins

Default origins in the CORS rule:
- `https://admin.<shop-domain>` — admin UI uploads (you'll need to edit the
  script's `--cors-allowed-origins` list per shop or pass `CORS_ORIGINS` env
  var).
- `http://localhost:9000`, `http://localhost:5173` — dev.

Override via env when running:

```bash
CORS_ORIGINS="https://admin.compastor.hu,http://localhost:9000,http://localhost:5173" \
  bash <path>/provision.sh compastor-medusa
```

## Idempotency

- If the bucket already exists in your account, the script skips creation and
  re-applies the configuration (policy, CORS, lifecycle, versioning).
- Re-running is safe.

## Pitfalls

- Bucket names are global. If `compastor-medusa` is taken in another AWS
  account, the script fails with `BucketAlreadyExists`. Pick a different name.
- Public read on product images means anyone with the URL can fetch them. This
  is exactly what storefronts need for `<img src="...">`. Don't put non-public
  product files (e.g. licensed assets) under the `<prefix>products/*` path.
- Versioning is on by default — every overwrite keeps the previous version,
  growing storage cost slowly. Add a noncurrent-version lifecycle rule if that
  becomes an issue.
- `AmazonS3FullAccess` covers all needed actions. Tighter least-privilege
  policy: `s3:CreateBucket, s3:PutBucketPolicy, s3:PutBucketCORS,
  s3:PutBucketVersioning, s3:PutBucketLifecycleConfiguration,
  s3:PutEncryptionConfiguration, s3:PutPublicAccessBlock, s3:GetBucketLocation`.

## Verification

After the script reports success:

```bash
aws s3api get-bucket-location --bucket <bucket>
aws s3api get-bucket-policy --bucket <bucket> --query 'Policy' --output text | jq
aws s3api get-bucket-cors --bucket <bucket>
```

Quick upload smoke-test (creates 1 byte, deletes it):

```bash
echo -n x | aws s3 cp - s3://<bucket>/<prefix>products/_smoke.txt --content-type text/plain
curl -I "https://<bucket>.s3.<region>.amazonaws.com/<prefix>products/_smoke.txt"
aws s3 rm s3://<bucket>/<prefix>products/_smoke.txt
```

Expect `HTTP/2 200` from curl on the public URL.
