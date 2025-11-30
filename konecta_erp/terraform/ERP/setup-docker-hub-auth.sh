#!/bin/bash
# Script to set up Docker Hub authentication for ECS

set -e

echo "=== Setting up Docker Hub Authentication for ECS ==="
echo ""

# Check if variables are set
if [ -z "$DOCKER_HUB_USERNAME" ] || [ -z "$DOCKER_HUB_PASSWORD" ]; then
  echo "Please provide Docker Hub credentials:"
  read -p "Docker Hub Username: " DOCKER_HUB_USERNAME
  read -s -p "Docker Hub Password or Access Token: " DOCKER_HUB_PASSWORD
  echo ""
fi

PROJECT_NAME="konecta-ass1"
ENVIRONMENT="dev"
SECRET_NAME="${PROJECT_NAME}-${ENVIRONMENT}-docker-hub-credentials"
AWS_REGION="us-east-1"

echo "Creating AWS Secrets Manager secret: $SECRET_NAME"

# Create the secret JSON
SECRET_JSON=$(cat <<EOF
{
  "username": "$DOCKER_HUB_USERNAME",
  "password": "$DOCKER_HUB_PASSWORD"
}
EOF
)

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

echo "✅ Secret created/updated: $SECRET_ARN"
echo ""
echo "=== Next Steps ==="
echo "1. Add this to your dev.tfvars file:"
echo "   docker_hub_secret_arn = \"$SECRET_ARN\""
echo ""
echo "2. Or export as environment variable before running terraform:"
echo "   export TF_VAR_docker_hub_secret_arn=\"$SECRET_ARN\""
echo ""
echo "3. Run terraform apply to update your ECS task definitions"

