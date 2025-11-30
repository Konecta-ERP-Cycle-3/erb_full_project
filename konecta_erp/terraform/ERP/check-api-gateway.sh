#!/bin/bash
# Script to check API Gateway ALB status

echo "=== Checking ALB Status ==="
ALB_DNS=$(terraform output -json alb_dns_name 2>/dev/null | jq -r '.' || echo "")
if [ -z "$ALB_DNS" ]; then
  echo "❌ Could not get ALB DNS from Terraform outputs"
  exit 1
fi

echo "ALB DNS: $ALB_DNS"
echo ""

echo "=== Checking ALB Health ==="
ALB_ARN=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?DNSName=='$ALB_DNS'].LoadBalancerArn" --output text)
if [ -z "$ALB_ARN" ]; then
  echo "❌ ALB not found!"
  exit 1
fi

echo "ALB ARN: $ALB_ARN"
ALB_STATE=$(aws elbv2 describe-load-balancers --load-balancer-arns "$ALB_ARN" --query 'LoadBalancers[0].State.Code' --output text)
echo "ALB State: $ALB_STATE"
echo ""

echo "=== Checking Target Groups ==="
TG_ARN=$(aws elbv2 describe-target-groups --load-balancer-arn "$ALB_ARN" --query 'TargetGroups[0].TargetGroupArn' --output text)
if [ -z "$TG_ARN" ]; then
  echo "❌ No target groups found for ALB!"
  exit 1
fi

echo "Target Group ARN: $TG_ARN"
echo ""

echo "=== Checking Target Health ==="
aws elbv2 describe-target-health --target-group-arn "$TG_ARN" --output table
echo ""

echo "=== Checking ECS API Gateway Service ==="
CLUSTER_NAME=$(terraform output -json cluster_name 2>/dev/null | jq -r '.' || echo "konecta-ass1-dev-cluster")
SERVICE_NAME=$(aws ecs list-services --cluster "$CLUSTER_NAME" --query "serviceArns[?contains(@, 'api-gateway')]" --output text | awk -F'/' '{print $NF}')
if [ -z "$SERVICE_NAME" ]; then
  echo "❌ API Gateway service not found!"
  exit 1
fi

echo "Service Name: $SERVICE_NAME"
SERVICE_STATUS=$(aws ecs describe-services --cluster "$CLUSTER_NAME" --services "$SERVICE_NAME" --query 'services[0].{Status:status,RunningCount:runningCount,DesiredCount:desiredCount}' --output table)
echo "$SERVICE_STATUS"
echo ""

echo "=== Testing ALB Connection ==="
echo "Trying to connect to http://$ALB_DNS..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://$ALB_DNS/actuator/health" || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ ALB is responding! HTTP Code: $HTTP_CODE"
elif [ "$HTTP_CODE" = "000" ]; then
  echo "❌ Cannot connect to ALB (connection timeout or DNS issue)"
elif [ "$HTTP_CODE" = "503" ]; then
  echo "⚠️  ALB is responding but service is unavailable (503)"
  echo "   This means ALB is working but no healthy targets"
else
  echo "⚠️  ALB responded with HTTP Code: $HTTP_CODE"
fi

