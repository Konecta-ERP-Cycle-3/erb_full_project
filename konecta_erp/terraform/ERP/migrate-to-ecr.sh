#!/bin/bash
# Script to migrate Docker images from Docker Hub to AWS ECR

set -e

AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="585768179815"
PROJECT_NAME="konecta-ass1"
ENVIRONMENT="dev"

echo "=== Migrating Docker Images from Docker Hub to AWS ECR ==="
echo ""

# Get AWS login token
echo "Logging into ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

SERVICES=(
  "authentication-service"
  "user-management-service"
  "finance-service"
  "hr-service"
  "inventory-service"
  "api-gateway"
  "reporting-service"
  "config-server"
  "hr-model"
  "prophet-model"
)

for SERVICE in "${SERVICES[@]}"; do
  DOCKER_HUB_IMAGE="mohamed710/${SERVICE}:latest"
  ECR_REPO="${PROJECT_NAME}-${ENVIRONMENT}-${SERVICE}"
  ECR_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:latest"
  
  echo ""
  echo "=== Migrating ${SERVICE} ==="
  echo "Source: ${DOCKER_HUB_IMAGE}"
  echo "Destination: ${ECR_IMAGE}"
  
  # Pull from Docker Hub
  echo "Pulling from Docker Hub..."
  docker pull "${DOCKER_HUB_IMAGE}" || echo "⚠️  Could not pull ${DOCKER_HUB_IMAGE} - might already be rate limited"
  
  # Tag for ECR
  echo "Tagging for ECR..."
  docker tag "${DOCKER_HUB_IMAGE}" "${ECR_IMAGE}"
  
  # Push to ECR
  echo "Pushing to ECR..."
  docker push "${ECR_IMAGE}" || echo "⚠️  Could not push - ECR repo might not exist yet. Run terraform apply first."
  
  echo "✅ ${SERVICE} migration complete"
done

echo ""
echo "=== Migration Complete ==="
echo ""
echo "All images should now be in ECR. Next steps:"
echo "1. Run terraform apply to update task definitions to use ECR images"
echo "2. Restart ECS services"

