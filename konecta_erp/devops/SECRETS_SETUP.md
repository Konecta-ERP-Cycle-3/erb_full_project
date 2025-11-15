# GitHub Actions Secrets Setup Guide

This document explains all the secrets and credentials needed for the CI/CD pipeline.

> **⚠️ Important Note**: Due to lack of AWS account access, the cloud deployment was not completed. This document describes the **intended secrets** that would be needed for the full deployment strategy:
> - **Image Registry**: AWS ECR (Elastic Container Registry) - intended
> - **Testing**: AWS EC2 instances
> - **Production**: AWS ECS (Elastic Container Service)
> 
> Currently, Docker Hub is used as a fallback for image registry.

---

## Required GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

---

## 1. Image Registry Credentials

### Option A: AWS ECR (Intended - Not Configured)

These would be used for AWS ECR (Elastic Container Registry):

#### AWS_ACCOUNT_ID
- **Description**: Your AWS account ID (12-digit number)
- **Status**: ⚠️ Not configured (AWS account not available)
- **How to get it** (if AWS access available):
  1. Log in to AWS Console
  2. Click on your account name (top right)
  3. Account ID is displayed
- **Example**: `123456789012`

#### ECR_REPOSITORY_URI
- **Description**: Base URI for ECR repositories
- **Status**: ⚠️ Not configured
- **Format**: `<AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com`
- **Example**: `123456789012.dkr.ecr.us-east-1.amazonaws.com`

#### AWS_ACCESS_KEY_ID (for ECR)
- **Description**: AWS access key for ECR access
- **Status**: ⚠️ Not configured
- **Required Permissions**: `ecr:GetAuthorizationToken`, `ecr:BatchCheckLayerAvailability`, `ecr:GetDownloadUrlForLayer`, `ecr:BatchGetImage`, `ecr:PutImage`, `ecr:InitiateLayerUpload`, `ecr:UploadLayerPart`, `ecr:CompleteLayerUpload`
- **Example**: `AKIAIOSFODNN7EXAMPLE`

#### AWS_SECRET_ACCESS_KEY (for ECR)
- **Description**: AWS secret access key
- **Status**: ⚠️ Not configured
- **Example**: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`

### Option B: Docker Hub (Current Fallback)

Currently using Docker Hub as fallback:

#### DOCKER_USERNAME
- **Description**: Your Docker Hub username
- **Status**: ✅ Configured (if available)
- **How to get it**: 
  1. Go to https://hub.docker.com
  2. Sign up or log in
  3. Your username is displayed in your profile
- **Example**: `myusername`

#### DOCKER_PASSWORD
- **Description**: Your Docker Hub password or access token
- **Status**: ✅ Configured (if available)
- **How to get it**:
  1. Go to https://hub.docker.com/settings/security
  2. Click "New Access Token"
  3. Give it a name (e.g., "GitHub Actions")
  4. Set permissions to "Read, Write, Delete"
  5. Copy the generated token
- **Example**: `dckr_pat_xxxxxxxxxxxxxxxxxxxx`

---

## 2. AWS Deployment Credentials (Not Configured)

### AWS_ACCESS_KEY_ID
- **Description**: AWS access key ID for programmatic access
- **Status**: ⚠️ Not configured (AWS account not available)
- **Required Permissions**:
  - EC2: `ec2:DescribeInstances`, `ec2:RunInstances`, `ec2:TerminateInstances`
  - ECS: `ecs:CreateCluster`, `ecs:CreateService`, `ecs:UpdateService`, `ecs:DescribeServices`
  - ECR: Full ECR permissions (see above)
  - IAM: `iam:PassRole` (for ECS task roles)
  - VPC: `ec2:DescribeVpcs`, `ec2:DescribeSubnets`, `ec2:DescribeSecurityGroups`
- **How to get it** (if AWS access available):
  1. Log in to AWS Console
  2. Go to IAM → Users → Your User → Security credentials
  3. Click "Create access key"
  4. Select "Command Line Interface (CLI)" or "Application running outside AWS"
  5. Copy the Access Key ID
- **Example**: `AKIAIOSFODNN7EXAMPLE`

### AWS_SECRET_ACCESS_KEY
- **Description**: AWS secret access key (paired with the access key ID)
- **Status**: ⚠️ Not configured
- **How to get it** (if AWS access available):
  1. When creating the access key, copy the Secret Access Key
  2. **Important**: Save this immediately - you won't see it again!
- **Example**: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`

### AWS_REGION
- **Description**: AWS region for deployment
- **Status**: ⚠️ Not configured (default: `us-east-1`)
- **Common values**: `us-east-1`, `us-west-2`, `eu-west-1`, `ap-southeast-1`
- **Example**: `us-east-1`

---

## 3. EC2 Testing Phase Credentials (Not Configured)

### EC2_HOST
- **Description**: Public IP address or DNS name of EC2 instance(s) for testing
- **Status**: ⚠️ Not configured
- **How to get it** (if AWS access available):
  1. Go to AWS Console → EC2 → Instances
  2. Select your instance
  3. Copy the "Public IPv4 address" or "Public IPv4 DNS"
- **Example**: `54.123.45.67` or `ec2-54-123-45-67.compute-1.amazonaws.com`

### EC2_USER
- **Description**: SSH username for EC2 instance
- **Status**: ⚠️ Not configured
- **Common values**:
  - Amazon Linux 2 / Amazon Linux 2023: `ec2-user`
  - Ubuntu: `ubuntu`
  - Debian: `admin`
  - RHEL/CentOS: `ec2-user` or `centos`
- **Example**: `ec2-user`

### EC2_SSH_PRIVATE_KEY
- **Description**: Private SSH key (PEM file content) to access EC2 instance
- **Status**: ⚠️ Not configured
- **How to get it** (if AWS access available):
  1. When launching EC2 instance, download the `.pem` file
  2. Open the `.pem` file in a text editor
  3. Copy the entire content (including headers)
  4. Paste it as the secret value
- **Format**:
  ```
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEA...
  (entire key content)
  ...
  -----END RSA PRIVATE KEY-----
  ```

### EC2_INSTANCE_IDS
- **Description**: Comma-separated list of EC2 instance IDs for testing
- **Status**: ⚠️ Not configured
- **Example**: `i-0123456789abcdef0,i-0123456789abcdef1`

---

## 4. ECS Production Phase Credentials (Not Configured)

### ECS_CLUSTER_NAME
- **Description**: Name of the ECS cluster for production
- **Status**: ⚠️ Not configured
- **Example**: `konecta-erp-production`

### ECS_SERVICE_NAME
- **Description**: Name of the ECS service (or comma-separated for multiple services)
- **Status**: ⚠️ Not configured
- **Example**: `authentication-service` or `authentication-service,hr-service,finance-service`

### VPC_ID
- **Description**: VPC ID where ECS services will run
- **Status**: ⚠️ Not configured
- **How to get it** (if AWS access available):
  1. Go to AWS Console → VPC → Your VPCs
  2. Copy the VPC ID
- **Example**: `vpc-0123456789abcdef0`

### SUBNET_IDS
- **Description**: Comma-separated list of subnet IDs for ECS tasks
- **Status**: ⚠️ Not configured
- **How to get it** (if AWS access available):
  1. Go to AWS Console → VPC → Subnets
  2. Select subnets in different availability zones
  3. Copy subnet IDs
- **Example**: `subnet-0123456789abcdef0,subnet-0123456789abcdef1`

### SECURITY_GROUP_IDS
- **Description**: Comma-separated list of security group IDs for ECS tasks
- **Status**: ⚠️ Not configured
- **How to get it** (if AWS access available):
  1. Go to AWS Console → EC2 → Security Groups
  2. Select appropriate security groups
  3. Copy security group IDs
- **Example**: `sg-0123456789abcdef0`

### ECS_TASK_EXECUTION_ROLE_ARN
- **Description**: ARN of IAM role for ECS task execution
- **Status**: ⚠️ Not configured
- **Example**: `arn:aws:iam::123456789012:role/ecsTaskExecutionRole`

### ECS_TASK_ROLE_ARN
- **Description**: ARN of IAM role for ECS tasks
- **Status**: ⚠️ Not configured
- **Example**: `arn:aws:iam::123456789012:role/ecsTaskRole`

---

## 5. Additional AWS Resources (Not Configured)

### RDS_ENDPOINT
- **Description**: RDS SQL Server endpoint (if using managed database)
- **Status**: ⚠️ Not configured
- **Example**: `konecta-db.xxxxx.us-east-1.rds.amazonaws.com:1433`

### ALB_DNS_NAME
- **Description**: Application Load Balancer DNS name
- **Status**: ⚠️ Not configured
- **Example**: `konecta-alb-123456789.us-east-1.elb.amazonaws.com`

### CLOUDWATCH_LOG_GROUP
- **Description**: CloudWatch log group name
- **Status**: ⚠️ Not configured
- **Example**: `/ecs/konecta-erp`

---

## Intended Deployment Strategy

### Phase 1: Testing on EC2
Would require:
- ✅ AWS_ACCOUNT_ID
- ✅ AWS_ACCESS_KEY_ID
- ✅ AWS_SECRET_ACCESS_KEY
- ✅ AWS_REGION
- ✅ ECR_REPOSITORY_URI
- ✅ EC2_HOST
- ✅ EC2_USER
- ✅ EC2_SSH_PRIVATE_KEY

### Phase 2: Production on ECS
Would require (in addition to Phase 1):
- ✅ ECS_CLUSTER_NAME
- ✅ ECS_SERVICE_NAME
- ✅ VPC_ID
- ✅ SUBNET_IDS
- ✅ SECURITY_GROUP_IDS
- ✅ ECS_TASK_EXECUTION_ROLE_ARN
- ✅ ECS_TASK_ROLE_ARN

---

## Current Status

### Configured Secrets
- ✅ `DOCKER_USERNAME` - Docker Hub (fallback)
- ✅ `DOCKER_PASSWORD` - Docker Hub (fallback)

### Not Configured (Placeholders)
- ⚠️ All AWS credentials
- ⚠️ All ECR credentials
- ⚠️ All EC2 credentials
- ⚠️ All ECS credentials

---

## Security Best Practices

1. **Never commit secrets to your repository**
2. **Use IAM roles** instead of access keys when possible (for AWS)
3. **Rotate credentials regularly**
4. **Limit permissions** - only grant necessary permissions
5. **Use separate credentials** for different environments
6. **Monitor access logs** regularly
7. **Use AWS Secrets Manager** for sensitive data in production

---

## Quick Checklist

### For Docker Hub (Current)
- [x] Docker Hub account (if using fallback)
- [x] Docker Hub access token (if using fallback)

### For AWS ECR (Intended - Not Available)
- [ ] AWS account created
- [ ] AWS_ACCOUNT_ID obtained
- [ ] ECR repositories created
- [ ] ECR_REPOSITORY_URI configured
- [ ] AWS access keys with ECR permissions

### For EC2 Testing (Intended - Not Available)
- [ ] EC2 instances launched
- [ ] EC2_HOST configured
- [ ] EC2_USER configured
- [ ] EC2_SSH_PRIVATE_KEY configured
- [ ] Security groups configured

### For ECS Production (Intended - Not Available)
- [ ] ECS cluster created
- [ ] ECS_CLUSTER_NAME configured
- [ ] VPC and subnets configured
- [ ] Security groups configured
- [ ] IAM roles created
- [ ] Task definitions created

---

**Last Updated**: November 2025  
**Status**: Intended secrets documented, not configured due to lack of AWS access
