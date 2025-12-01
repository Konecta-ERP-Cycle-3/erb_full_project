#!/bin/bash

# API Testing Script
# This script helps you test your API endpoints and see the output

ALB_URL="http://konecta-ass1-dev-alb-602225348.us-east-1.elb.amazonaws.com"

echo "==============================================="
echo "  API Testing Script"
echo "==============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to make API calls
api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    local token=$4
    
    echo -e "${BLUE}${method} ${endpoint}${NC}"
    
    if [ -n "$token" ]; then
        response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X "$method" "${ALB_URL}${endpoint}" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token" \
            -d "$data")
    else
        response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X "$method" "${ALB_URL}${endpoint}" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    http_code=$(echo "$response" | grep "HTTP_STATUS" | cut -d: -f2)
    body=$(echo "$response" | sed '/HTTP_STATUS/d')
    
    echo "HTTP Status: $http_code"
    echo "Response:"
    echo "$body" | python3 -m json.tool 2>/dev/null || echo "$body"
    echo ""
}

# 1. Health Check
echo -e "${GREEN}1. Health Check (Public Endpoint)${NC}"
api_call "GET" "/actuator/health/ping" "" ""

# 2. Login
echo -e "${GREEN}2. Login (Get JWT Token)${NC}"
login_response=$(curl -s -X POST "${ALB_URL}/auth/login" \
    -H "Content-Type: application/json" \
    -d '{
        "email": "admin@konecta.com",
        "password": "Admin@123"
    }')

echo "$login_response" | python3 -m json.tool 2>/dev/null || echo "$login_response"
echo ""

# Extract token
TOKEN=$(echo "$login_response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('result', {}).get('accessToken', ''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    echo -e "${YELLOW}Warning: Could not extract token. Trying alternative method...${NC}"
    TOKEN=$(echo "$login_response" | grep -o '"accessToken":"[^"]*' | cut -d'"' -f4)
fi

if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
    echo -e "${GREEN}✓ Token extracted successfully!${NC}"
    echo "Token (first 50 chars): ${TOKEN:0:50}..."
    echo ""
    
    # 3. Test Protected Endpoint
    echo -e "${GREEN}3. Test Protected Endpoint (HR Service - Employees)${NC}"
    api_call "GET" "/hr/employees" "" "$TOKEN"
    
    # 4. Test User Management
    echo -e "${GREEN}4. Test User Management (Users List)${NC}"
    api_call "GET" "/users" "" "$TOKEN"
    
    # 5. Test Finance Service
    echo -e "${GREEN}5. Test Finance Service (Budgets)${NC}"
    api_call "GET" "/finance/budgets" "" "$TOKEN"
    
    # 6. Test Inventory Service
    echo -e "${GREEN}6. Test Inventory Service (Items)${NC}"
    api_call "GET" "/inventory/items" "" "$TOKEN"
    
else
    echo -e "${YELLOW}⚠ Could not extract token from login response.${NC}"
    echo "Login response was:"
    echo "$login_response"
    echo ""
    echo "Please check your credentials or service status."
fi

echo "==============================================="
echo "  Testing Complete"
echo "==============================================="
echo ""
echo "Your ALB URL: $ALB_URL"
echo ""
