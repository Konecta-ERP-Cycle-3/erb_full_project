# Terraform Resource Import Guide

## Overview

This directory contains a helper script to safely import existing AWS resources into Terraform state, preventing "already exists" errors.

## Resources That Can Be Imported

The script automatically detects and imports:
- `aws_service_discovery_private_dns_namespace` - Service Discovery namespace
- `aws_lb` - Application Load Balancer
- `aws_lb_target_group` - Target Group for API Gateway

## Usage

### Basic Usage

```bash
cd konecta_erp/terraform/ERP
./import-resources.sh
```

### With Custom Variables

```bash
export PROJECT_NAME="konecta-ass1"
export AWS_REGION="us-east-1"
export DB_PASSWORD="your-password"  # Optional, for terraform import
./import-resources.sh
```

### With Terraform Variables File

If you have a `dev.tfvars` file, the script will use it automatically. For imports that require `db_password`, set it as an environment variable:

```bash
export DB_PASSWORD="your-password"
./import-resources.sh
```

## What the Script Does

1. **Checks Terraform State**: Verifies if resources are already in state
2. **Discovers AWS Resources**: Uses AWS CLI to find existing resources
3. **Imports Resources**: Safely imports resources that exist in AWS but not in state
4. **Reports Results**: Shows which resources were imported and which already existed

## Lifecycle Protection

All critical resources have `lifecycle { prevent_destroy = true }` blocks to prevent accidental deletion:

- `aws_service_discovery_private_dns_namespace.main`
- `aws_lb.main`
- `aws_lb_target_group.api_gateway_tg`
- `aws_ecs_cluster.main`

## Manual Import Commands

If you need to import resources manually:

```bash
# Import namespace
terraform import -var-file=dev.tfvars -var="db_password=$DB_PASSWORD" \
  module.ecs.aws_service_discovery_private_dns_namespace.main <namespace-id>

# Import load balancer
terraform import -var-file=dev.tfvars -var="db_password=$DB_PASSWORD" \
  module.ecs.aws_lb.main <alb-arn>

# Import target group
terraform import -var-file=dev.tfvars -var="db_password=$DB_PASSWORD" \
  module.ecs.aws_lb_target_group.api_gateway_tg <target-group-arn>
```

## Verification

After importing, verify with:

```bash
terraform plan -var-file=dev.tfvars -var="db_password=$DB_PASSWORD"
```

You should see **0 changes** if all resources are correctly imported.

## Troubleshooting

### Resource Already in State

If a resource is already in state, the script will skip it and report:
```
✓ Resource already in state
```

### Resource Not Found in AWS

If a resource doesn't exist in AWS, the script will report:
```
⚠ Resource not found in AWS
```

### Import Fails

If import fails, check:
1. AWS credentials are configured
2. Resource ARN/ID is correct
3. Terraform is initialized (`terraform init`)
4. Required variables are provided

## Next Steps

1. Run the import script
2. Verify with `terraform plan`
3. Apply changes if needed: `terraform apply`

