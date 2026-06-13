#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------
# Create Terraform S3 backend + DynamoDB lock table
# -----------------------------------------------

REGION="us-east-1"
PROJECT="k8s-platform"

# Get AWS account ID from caller identity
echo "Verifying AWS credentials..."
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text 2>/dev/null) || {
  echo "ERROR: Failed to get AWS identity. Check your credentials/profile."
  exit 1
}
echo "AWS Account: ${ACCOUNT_ID}"

BUCKET_NAME="${PROJECT}-tf-state-${ACCOUNT_ID}"
TABLE_NAME="${PROJECT}-tf-locks"

# -----------------------------------------------
# S3 Bucket
# -----------------------------------------------
if aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
  echo "S3 bucket already exists: ${BUCKET_NAME}"
else
  echo "Creating S3 bucket: ${BUCKET_NAME}"
  aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${REGION}"

  aws s3api put-bucket-versioning \
    --bucket "${BUCKET_NAME}" \
    --versioning-configuration Status=Enabled

  aws s3api put-public-access-block \
    --bucket "${BUCKET_NAME}" \
    --public-access-block-configuration \
      BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

  echo "S3 bucket created with versioning and public access blocked."
fi

# -----------------------------------------------
# DynamoDB Table
# -----------------------------------------------
if aws dynamodb describe-table --table-name "${TABLE_NAME}" --region "${REGION}" >/dev/null 2>&1; then
  echo "DynamoDB table already exists: ${TABLE_NAME}"
else
  echo "Creating DynamoDB table: ${TABLE_NAME}"
  aws dynamodb create-table \
    --table-name "${TABLE_NAME}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${REGION}"

  aws dynamodb wait table-exists --table-name "${TABLE_NAME}" --region "${REGION}"
  echo "DynamoDB table created."
fi

# -----------------------------------------------
# Summary
# -----------------------------------------------
echo ""
echo "=== Backend Ready ==="
echo "Bucket: ${BUCKET_NAME}"
echo "Table:  ${TABLE_NAME}"
echo "Region: ${REGION}"
echo ""
echo "Use in backend.tf:"
echo "  bucket         = \"${BUCKET_NAME}\""
echo "  dynamodb_table = \"${TABLE_NAME}\""
echo "  region         = \"${REGION}\""
