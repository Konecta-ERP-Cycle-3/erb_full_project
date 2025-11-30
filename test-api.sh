#!/bin/bash
# Quick test script for API Gateway endpoints

ALB_URL="http://konecta-ass1-dev-alb-2094459706.us-east-1.elb.amazonaws.com"

echo "=== Testing API Gateway Endpoints ==="
echo ""
echo "ALB URL: $ALB_URL"
echo ""

echo "1. Testing root path (expects 401 - requires auth):"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "$ALB_URL/" || echo "Connection failed"
echo ""

echo "2. Testing health endpoint:"
curl -s -w "\nHTTP Status: %{http_code}\n" "$ALB_URL/actuator/health" || echo "Connection failed"
echo ""

echo "3. Testing login endpoint (POST):"
curl -s -X POST "$ALB_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@konecta.com","password":"Admin@123456"}' \
  -w "\nHTTP Status: %{http_code}\n" || echo "Connection failed"
echo ""

echo "=== Test Complete ==="
echo ""
echo "Note: If you get 401 on root path, that's NORMAL - the API is secured!"
echo "Use /api/auth/login to get a token, then use that token for other endpoints."

