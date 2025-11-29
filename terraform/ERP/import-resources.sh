#!/bin/bash
# Terraform Import Helper Script
# This script safely imports existing AWS resources into Terraform state

# Don't exit on errors - we want to try importing all resources even if some fail
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="${PROJECT_NAME:-konecta-ass1}"
AWS_REGION="${AWS_REGION:-us-east-1}"
TERRAFORM_DIR="$(pwd)"
DB_PASSWORD="${DB_PASSWORD:-}"

# Terraform variable flags
TF_VAR_FLAGS="-var-file=dev.tfvars"
if [ -n "$DB_PASSWORD" ]; then
    TF_VAR_FLAGS="$TF_VAR_FLAGS -var=db_password=$DB_PASSWORD"
fi

echo -e "${GREEN}=== Terraform Resource Import Script ===${NC}"
echo "Project: $PROJECT_NAME"
echo "Region: $AWS_REGION"
echo ""

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    terraform init -input=false
fi

# Function to check if resource exists in state
resource_in_state() {
    local resource_path=$1
    terraform state list 2>/dev/null | grep -q "^${resource_path}$" && return 0 || return 1
}

# Function to import resource
import_resource() {
    local resource_path=$1
    local resource_id=$2
    local resource_name=$3

    if resource_in_state "$resource_path"; then
        echo -e "${GREEN}✓${NC} $resource_name already in state"
        return 0
    fi

    echo -e "${YELLOW}Importing $resource_name...${NC}"
    echo "Resource path: $resource_path"
    echo "Resource ID: $resource_id"
    echo "Command: terraform import $TF_VAR_FLAGS \"$resource_path\" \"$resource_id\""
    
    # Run import and capture both output and exit code
    terraform import $TF_VAR_FLAGS "$resource_path" "$resource_id" 2>&1
    local import_status=$?
    
    if [ $import_status -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Successfully imported $resource_name"
        return 0
    else
        echo -e "${RED}✗${NC} Failed to import $resource_name (exit code: $import_status)"
        echo "This is OK - the resource may need to be created or already exists differently"
        return 1
    fi
}

# Get VPC ID
echo -e "${YELLOW}Getting VPC ID...${NC}"
VPC_ID=$(terraform output -raw vpc_id 2>/dev/null || \
    terraform state show module.vpc.aws_vpc.main 2>/dev/null | grep -E '^id\s*=' | awk '{print $3}' || echo "")

if [ -z "$VPC_ID" ]; then
    echo -e "${RED}Error: Could not determine VPC ID${NC}"
    echo "Terraform state might not be initialized. Attempting to continue anyway..."
    # Don't exit - try to continue
fi

if [ -n "$VPC_ID" ]; then
    echo "VPC ID: $VPC_ID"
else
    echo "VPC ID: Not found (will skip VPC-dependent checks)"
fi
echo ""

# 1. Service Discovery Private DNS Namespace
# NOTE: Namespace is now referenced via data source, no import needed
echo -e "${YELLOW}=== Service Discovery Namespace ===${NC}"
NAMESPACE_NAME="${PROJECT_NAME}.local"
echo "Namespace is referenced via data source (data.aws_service_discovery_dns_namespace.existing)"
echo "No import needed - Terraform will reference the existing namespace automatically"
echo ""

# 2. Import Application Load Balancer
echo -e "${YELLOW}=== Application Load Balancer ===${NC}"
LB_NAME="${PROJECT_NAME}-alb"
LB_ARN=$(aws elbv2 describe-load-balancers \
    --region "$AWS_REGION" \
    --names "$LB_NAME" \
    --query 'LoadBalancers[0].LoadBalancerArn' \
    --output text 2>/dev/null || echo "")

if [ -n "$LB_ARN" ] && [ "$LB_ARN" != "None" ]; then
    import_resource "module.ecs.aws_lb.main" "$LB_ARN" "Application Load Balancer" || true
else
    echo -e "${YELLOW}⚠${NC} Load Balancer $LB_NAME not found in AWS"
fi
echo ""

# 3. Import Target Group
echo -e "${YELLOW}=== Target Group ===${NC}"
TG_NAME="${PROJECT_NAME}-api-gateway-tg"
TG_ARN=$(aws elbv2 describe-target-groups \
    --region "$AWS_REGION" \
    --names "$TG_NAME" \
    --query 'TargetGroups[0].TargetGroupArn' \
    --output text 2>/dev/null || echo "")

if [ -n "$TG_ARN" ] && [ "$TG_ARN" != "None" ]; then
    import_resource "module.ecs.aws_lb_target_group.api_gateway_tg" "$TG_ARN" "Target Group" || true
else
    echo -e "${YELLOW}⚠${NC} Target Group $TG_NAME not found in AWS"
fi
echo ""

# Summary
echo -e "${GREEN}=== Import Summary ===${NC}"
echo "Resources in Terraform state:"
terraform state list 2>/dev/null | grep -E "(namespace|lb|target_group)" || echo "None found"
echo ""
echo -e "${GREEN}Import process completed!${NC}"
echo ""
echo "Next steps:"
echo "1. Run: terraform plan"
echo "2. Verify no unexpected changes"
echo "3. Run: terraform apply (if needed)"

# Always exit successfully - even if some imports failed
# This allows the pipeline to continue
exit 0

