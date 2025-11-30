#!/bin/bash
# Script to create Docker Hub credentials in AWS Secrets Manager

set -e

PROJECT_NAME="konecta-ass1"
ENVIRONMENT="dev"
SECRET_NAME="${PROJECT_NAME}-${ENVIRONMENT}-docker-hub-credentials"
AWS_REGION="us-east-1"

echo "=== Setting up Docker Hub Authentication ==="
echo ""

# Get credentials
if [ -z "$DOCKER_HUB_USERNAME" ] || [ -z "$DOCKER_HUB_PASSWORD" ]; then
  echo "Please provide your Docker Hub credentials:"
  read -p "Docker Hub Username: " DOCKER_HUB_USERNAME
  read -s -p "Docker Hub Password or Access Token: " DOCKER_HUB_PASSWORD
  echo ""
fi

# Create the secret JSON (ECS expects this format)
SECRET_JSON=$(cat <<EOF
{
  "username": "$DOCKER_HUB_USERNAME",
  "password": "$DOCKER_HUB_PASSWORD"
}
EOF
)

echo "Creating/updating AWS Secrets Manager secret: $SECRET_NAME"

# Create or update the secret
SECRET_ARN=$(aws secretsmanager create-secret \
  --name "$SECRET_NAME" \
  --description "Docker Hub credentials for ${PROJECT_NAME} ECS tasks" \
  --secret-string "$SECRET_JSON" \
  --region "$AWS_REGION" \
  --query 'ARN' \
  --output text 2>/dev/null || \
  aws secretsmanager update-secret \
    --secret-id "$SECRET_NAME" \
    --secret-string "$SECRET_JSON" \
    --region "$AWS_REGION" \
    --query 'ARN' \
    --output text)

echo ""
echo "✅ Secret created/updated successfully!"
echo ""
echo "Secret ARN: $SECRET_ARN"
echo ""
echo "=== Next Steps ==="
echo "1. Add this line to your dev.tfvars file:"
echo "   docker_hub_secret_arn = \"$SECRET_ARN\""
echo ""
echo "2. The task definitions will need to be updated to use repositoryCredentials"
echo "   (This requires updating the ECS module to add repositoryCredentials to each task definition)"

