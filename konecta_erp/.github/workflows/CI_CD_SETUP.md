# CI/CD Pipeline Setup Guide

## Overview

The CI/CD pipeline automates the complete software delivery process:
1. **Security Scanning** - Semgrep security audit
2. **Testing** - Unit tests for .NET, Java, and Frontend
3. **Building** - Docker images for all 8 microservices
4. **Pushing** - Images to Docker Hub (`mohamed710/*`)
5. **Deploying** - Infrastructure and services to AWS ECS using Terraform

## Pipeline Workflow

```
┌─────────────────┐
│  Code Push/PR   │
└────────┬────────┘
         │
         ├─► Security Scan (Semgrep)
         ├─► Test .NET Services
         ├─► Test Java Services
         └─► Test Frontend
              │
              ▼
    ┌─────────────────┐
    │ Build & Push    │
    │ Docker Images   │
    └────────┬────────┘
             │
             ├─► Terraform Plan
             │
             └─► Deploy to AWS ECS (main branch only)
```

## Required GitHub Secrets

Configure these secrets in your GitHub repository settings (`Settings > Secrets and variables > Actions`):

### Docker Hub
- `DOCKER_USERNAME` - Your Docker Hub username (e.g., `mohamed710`)
- `DOCKER_PASSWORD` - Your Docker Hub access token or password

### AWS Credentials
- `AWS_ACCESS_KEY_ID` - AWS access key with deployment permissions
- `AWS_SECRET_ACCESS_KEY` - AWS secret access key
- `AWS_REGION` - AWS region (default: `us-east-1`)

### Optional (for advanced features)
- `EC2_HOST` - EC2 instance hostname (if using EC2 for testing)
- `EC2_USER` - EC2 SSH user
- `EC2_SSH_PRIVATE_KEY` - EC2 SSH private key

## Pipeline Jobs

### 1. Security Scan
- **Tool**: Semgrep
- **Scans**: Security vulnerabilities, OWASP Top 10, code quality
- **Runs on**: All pushes and PRs
- **Duration**: ~2-3 minutes

### 2. Test Jobs
- **.NET Services**: Authentication, Finance, HR, Inventory, UserManagement
- **Java Services**: API Gateway, Reporting Service, Config Server
- **Frontend**: Angular application tests
- **Runs on**: All pushes and PRs
- **Duration**: ~5-10 minutes

### 3. Build and Push
- **Builds**: 8 microservice Docker images
- **Registry**: Docker Hub (`mohamed710/*`)
- **Tags**: 
  - `latest` (on main branch)
  - `{branch}-{commit-sha}` (all branches)
- **Runs on**: All pushes (not PRs)
- **Duration**: ~15-20 minutes

### 4. Terraform Plan
- **Validates**: Terraform configuration
- **Plans**: Infrastructure changes
- **Runs on**: All pushes (not PRs)
- **Duration**: ~3-5 minutes

### 5. Deploy to AWS ECS
- **Deploys**: Complete infrastructure to AWS
- **Includes**:
  - VPC, Subnets, Security Groups
  - RDS SQL Server
  - ECS Cluster with all services
  - Application Load Balancer
  - Service Discovery
- **Runs on**: Main branch only
- **Duration**: ~10-15 minutes

## Deployment Process

### Automatic Deployment
When code is pushed to `main` branch:
1. All tests pass
2. Docker images are built and pushed
3. Terraform plan is generated
4. Infrastructure is deployed to AWS ECS
5. Services are started and health-checked

### Manual Deployment
You can trigger deployment manually:
1. Go to **Actions** tab in GitHub
2. Select **CI/CD Pipeline** workflow
3. Click **Run workflow**
4. Select branch and click **Run workflow**

## What Gets Deployed

### Infrastructure
- **VPC**: Custom VPC with public and private subnets
- **RDS**: SQL Server Express database
- **ECS Cluster**: Fargate cluster for containerized services
- **ALB**: Application Load Balancer for external access
- **Cloud Map**: Service discovery namespace

### Microservices (8 Services)
1. **API Gateway** - Port 8080 (public, behind ALB)
2. **Config Server** - Port 8888 (private)
3. **Authentication Service** - Port 7280 (private)
4. **User Management Service** - Port 5078 (private)
5. **Finance Service** - Port 5003 (private)
6. **HR Service** - Port 5005 (private)
7. **Inventory Service** - Port 5020 (private)
8. **Reporting Service** - Port 8085 (private)

### Infrastructure Services
- **RabbitMQ** - Ports 5672, 15672 (private)
- **Consul** - Port 8500 (private)

## Monitoring Deployment

### GitHub Actions
- View workflow runs in **Actions** tab
- Check logs for each job
- See deployment summary in workflow output

### AWS Console
- **ECS**: Check service status in ECS console
- **CloudWatch**: View logs for all services
- **ALB**: Check target health and access logs
- **RDS**: Monitor database performance

### Post-Deployment
After successful deployment:
1. Get ALB URL from Terraform outputs or GitHub Actions summary
2. Access API Gateway: `http://{alb-dns-name}`
3. Check service health: `http://{alb-dns-name}/actuator/health`
4. View CloudWatch logs for service debugging

## Troubleshooting

### Build Failures
- Check Dockerfile syntax
- Verify build context paths
- Review build logs for specific errors

### Test Failures
- Review test output in job logs
- Check for missing dependencies
- Verify test configuration

### Deployment Failures
- Check AWS credentials and permissions
- Verify Terraform state
- Review Terraform plan output
- Check ECS service logs in CloudWatch

### Service Not Starting
- Check ECS task logs in CloudWatch
- Verify security group rules
- Check service discovery configuration
- Verify database connectivity

## Environment Variables

The pipeline uses these environment variables:
- `DOCKER_USERNAME`: `mohamed710` (hardcoded)
- `AWS_REGION`: `us-east-1` (default)
- `TERRAFORM_VERSION`: `1.6.0`

## Image Tags

Images are tagged as:
- **Latest**: `mohamed710/{service-name}:latest` (main branch only)
- **Branch**: `mohamed710/{service-name}:{branch}-{commit-sha}` (all branches)

## Notes

- **AI Models**: `hr-image` and `prophet-image` are not built in CI/CD (already pushed manually)
- **Database**: SQL Server databases are created via EF migrations when services start
- **Service Discovery**: Services communicate using AWS Cloud Map DNS names
- **Security**: All services run as non-root users in containers

## Next Steps

1. Set up GitHub secrets
2. Push code to trigger pipeline
3. Monitor deployment in GitHub Actions
4. Access deployed application via ALB URL
5. Set up monitoring and alerting (optional)

