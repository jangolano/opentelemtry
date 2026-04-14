#!/usr/bin/env bash
set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
APP_NAME="otel-demo"
REPO_NAME="${APP_NAME}-app"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$SCRIPT_DIR/aws"

# Get AWS account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --region "$REGION")
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
IMAGE_URI="${ECR_URI}/${REPO_NAME}:latest"

echo "==> Account: $ACCOUNT_ID | Region: $REGION"

# Create ECR repo if it doesn't exist
if ! aws ecr describe-repositories --repository-names "$REPO_NAME" --region "$REGION" &>/dev/null; then
  echo "==> Creating ECR repository: $REPO_NAME"
  aws ecr create-repository --repository-name "$REPO_NAME" --region "$REGION" --output text
fi

# Docker login to ECR
echo "==> Logging into ECR"
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ECR_URI"

# Build and push
echo "==> Building Docker image"
docker build --platform linux/amd64 -t "$IMAGE_URI" "$PROJECT_ROOT"

echo "==> Pushing image to ECR"
docker push "$IMAGE_URI"

# Terraform
echo "==> Running Terraform"
cd "$TF_DIR"
terraform init -input=false
terraform apply -input=false -auto-approve \
  -var="app_image=${IMAGE_URI}" \
  -var="region=${REGION}"

echo ""
echo "==> Deploy complete!"
terraform output
