# CI/CD Pipeline - Complete Setup ✅

## What's Configured

### ✅ Complete CI/CD Pipeline
- **File**: `.github/workflows/ci-cd-pipeline.yml`
- **Status**: Fully configured and ready

### Pipeline Stages

1. **Security Scanning** ✅
   - Semgrep security audit
   - OWASP Top 10 scanning
   - Code quality checks

2. **Testing** ✅
   - .NET services (5 services)
   - Java services (3 services)
   - Frontend (Angular)

3. **Build & Push** ✅
   - 8 microservice Docker images
   - Pushed to `mohamed710/*` on Docker Hub
   - Tagged with `latest` and commit SHA

4. **Terraform Plan** ✅
   - Validates infrastructure code
   - Generates deployment plan
   - Checks for configuration errors

5. **Deploy to AWS ECS** ✅
   - Deploys complete infrastructure
   - All 8 microservices
   - RabbitMQ and Consul
   - RDS SQL Server
   - Application Load Balancer

## Quick Start

### 1. Set Up GitHub Secrets

Go to: `Settings > Secrets and variables > Actions`

Add these secrets:
```
DOCKER_USERNAME=mohamed710
DOCKER_PASSWORD=<your-docker-hub-token>
AWS_ACCESS_KEY_ID=<your-aws-access-key>
AWS_SECRET_ACCESS_KEY=<your-aws-secret-key>
AWS_REGION=us-east-1
```

### 2. Push to Main Branch

```bash
git add .
git commit -m "Setup CI/CD pipeline"
git push origin main
```

### 3. Monitor Deployment

1. Go to **Actions** tab in GitHub
2. Watch the pipeline run
3. Check deployment summary
4. Get ALB URL from workflow output

## What Gets Deployed

### Infrastructure
- VPC with public/private subnets
- RDS SQL Server Express
- ECS Fargate Cluster
- Application Load Balancer
- AWS Cloud Map (Service Discovery)

### Services
- API Gateway (public)
- Config Server
- Authentication Service
- User Management Service
- Finance Service
- HR Service
- Inventory Service
- Reporting Service
- RabbitMQ
- Consul

## Image Registry

All images are pushed to:
- **Registry**: Docker Hub
- **Namespace**: `mohamed710`
- **Tags**: 
  - `latest` (main branch)
  - `{branch}-{sha}` (feature branches)

## Deployment Flow

```
Code Push
    ↓
Security Scan + Tests
    ↓
Build Docker Images
    ↓
Push to Docker Hub
    ↓
Terraform Plan
    ↓
Deploy to AWS ECS (main only)
    ↓
Services Running ✅
```

## Accessing Deployed Application

After deployment:
1. Get ALB DNS name from Terraform outputs
2. Access: `http://{alb-dns-name}`
3. Health check: `http://{alb-dns-name}/actuator/health`

## Documentation

- **Setup Guide**: `CI_CD_SETUP.md` - Complete setup instructions
- **Terraform**: `cloud/ERP/TERRAFORM_UPDATES.md` - Infrastructure details

## Notes

- AI models (`hr-image`, `prophet-image`) are not built in CI/CD (already pushed)
- Database migrations run automatically when services start
- All services use service discovery for inter-service communication
- Pipeline runs on push to `main` or `develop` branches

## Troubleshooting

See `CI_CD_SETUP.md` for detailed troubleshooting guide.

