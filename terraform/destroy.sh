#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
APP_NAME="otel-demo"
REPO_NAME="${APP_NAME}-app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TF_DIR="$SCRIPT_DIR/aws"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --region "$REGION")
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
IMAGE_URI="${ECR_URI}/${REPO_NAME}:latest"

echo "==> Destroying Terraform infrastructure"
cd "$TF_DIR"
terraform destroy -input=false -auto-approve \
  -var="app_image=${IMAGE_URI}" \
  -var="region=${REGION}"

echo "==> Deleting ECR repository: $REPO_NAME"
aws ecr delete-repository --repository-name "$REPO_NAME" --region "$REGION" --force 2>/dev/null || true

echo "==> Destroy complete!"
