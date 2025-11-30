#!/bin/bash
# Quick script to check ECS service status

CLUSTER="konecta-ass1-dev-cluster"
REGION="us-east-1"
ALB_URL="http://konecta-ass1-dev-alb-2094459706.us-east-1.elb.amazonaws.com"

echo "=== 🏥 ECS Service Health Check ==="
echo ""

echo "Services Status:"
aws ecs describe-services --cluster "$CLUSTER" --region "$REGION" \
  --services konecta-ass1-dev-authentication-service \
             konecta-ass1-dev-api-gateway \
             konecta-ass1-dev-config-server \
  --query 'services[*].{Service:serviceName,Running:runningCount,Desired:desiredCount}' \
  --output table

echo ""
echo "=== 🌐 API Endpoint Tests ==="
echo ""

echo "1. Root path (expects 401 - requires auth):"
curl -s -o /dev/null -w "   Status: %{http_code} ✅\n" "$ALB_URL/"

echo ""
echo "2. Login endpoint (expects 405 - service not ready):"
curl -s -o /dev/null -w "   Status: %{http_code}\n" -X POST "$ALB_URL/auth/login" \
  -H "Content-Type: application/json" -d '{}'

echo ""
echo "=== 📊 Summary ==="
echo ""
echo "• 401 = Normal (API is secured)"
echo "• 404/405 = Backend services need to be running"
echo ""
echo "To fix: Check why authentication-service tasks are crashing"

