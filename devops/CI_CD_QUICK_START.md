# CI/CD Pipeline Quick Start Guide

## What Was Created

### 1. GitHub Actions Workflow
**File**: `.github/workflows/ci-cd-pipeline.yml`

This workflow automates:
- ✅ **Security Scanning**: Semgrep security and code quality scanning
- ✅ **Testing**: Runs tests for all .NET services, Java services, and frontend
- ✅ **Building**: Builds Docker images for all services (8 microservices + 2 AI models)
- ✅ **Pushing**: Pushes images to Docker Hub
- ⚠️ **Deploying**: Cloud deployment to AWS EC2 (not fully completed - see note below)

> **⚠️ Deployment Status**: The cloud deployment process was not fully completed due to lack of AWS account access. The intended deployment strategy was:
> - **Image Registry**: AWS ECR (Elastic Container Registry) - currently using Docker Hub as fallback
> - **Testing Phase**: Deploy to AWS EC2 instances for testing and validation
> - **Production Phase**: Deploy to AWS ECS (Elastic Container Service) for production
> 
> The deployment job in the pipeline is configured with `continue-on-error: true` to allow the workflow to complete even if deployment fails. All Docker images are successfully built and pushed (currently to Docker Hub, but ECR was intended).

### 2. Deployment Script
**File**: `devops/scripts/deploy.sh`

A bash script that:
- Sets up the deployment environment on EC2
- Pulls latest Docker images from Docker Hub
- Manages container lifecycle (stop, pull, start)
- Performs health checks
- Creates backups before deployment

> **Note**: This script is included but deployment was not fully completed due to cloud infrastructure challenges.

### 3. Production Docker Compose
**File**: `docker-compose.prod.yml`

Production-ready docker-compose file that uses Docker Hub images instead of building locally.

### 4. Documentation
**File**: `devops/SECRETS_SETUP.md`

Complete guide on setting up all required secrets and credentials.

## Quick Setup Steps

### Step 1: Set Up Docker Hub

1. Create account at https://hub.docker.com
2. Go to Account Settings → Security → New Access Token
3. Create token with "Read, Write, Delete" permissions
4. Copy the token (you won't see it again!)

### Step 2: Set Up AWS EC2

1. Launch an EC2 instance (Ubuntu or Amazon Linux)
2. Configure security group to allow:
   - Port 22 (SSH) - from your IP or GitHub Actions
   - Port 8080 (API Gateway) - from 0.0.0.0/0
   - Port 15672 (RabbitMQ) - from 0.0.0.0/0
   - Port 8500 (Consul) - from 0.0.0.0/0
   - Port 8025 (MailHog) - from 0.0.0.0/0
3. Install Docker and Docker Compose on EC2:
   ```bash
   # For Ubuntu
   sudo apt-get update
   sudo apt-get install docker.io -y
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -aG docker ubuntu
   
   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```
4. Download your EC2 key pair (.pem file)

### Step 3: Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets:

| Secret Name | Description | Example |
|------------|-------------|---------|
| `DOCKER_USERNAME` | Your Docker Hub username | `myusername` |
| `DOCKER_PASSWORD` | Docker Hub access token | `dckr_pat_xxxxx` |
| `AWS_ACCESS_KEY_ID` | AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `wJalrXUtnFEMI/K7MDENG...` |
| `AWS_REGION` | AWS region | `us-east-1` |
| `EC2_HOST` | EC2 public IP or DNS | `54.123.45.67` |
| `EC2_USER` | SSH username | `ubuntu` or `ec2-user` |
| `EC2_SSH_PRIVATE_KEY` | Content of your .pem file | `-----BEGIN RSA PRIVATE KEY-----...` |

### Step 4: Test the Pipeline

1. Push to `main` branch:
   ```bash
   git add .
   git commit -m "Add CI/CD pipeline"
   git push origin main
   ```

2. Check GitHub Actions:
   - Go to your repository → **Actions** tab
   - Watch the workflow run
   - Check each job for success/failure

3. Verify deployment on EC2:
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-ip
   cd /opt/konecta-erp
   docker-compose ps
   ```

## Pipeline Workflow

```
Push to main branch
    ↓
[Test .NET Services] → [Test Java Services] → [Test Frontend]
    ↓
[Build & Push Docker Images]
    ↓
[Deploy to AWS EC2]
    ↓
✅ Application Live!
```

## Services Being Deployed

1. **config-server** (Java/Spring Boot)
2. **api-gateway** (Java/Spring Boot)
3. **reporting-service** (Java/Spring Boot)
4. **authentication-service** (.NET)
5. **hr-service** (.NET)
6. **inventory-service** (.NET)
7. **finance-service** (.NET)
8. **user-management-service** (.NET)

Plus infrastructure:
- SQL Server
- RabbitMQ
- Consul
- MailHog

## Troubleshooting

### Pipeline fails at "Test" step
- Check if tests exist for all services
- Some services might not have tests yet (that's OK, they'll show warnings)

### Pipeline fails at "Build & Push"
- Verify `DOCKER_USERNAME` and `DOCKER_PASSWORD` are correct
- Check Docker Hub account is active
- Ensure access token has correct permissions

### Pipeline fails at "Deploy to EC2"
- Verify all EC2 secrets are correct
- Check EC2 security group allows SSH (port 22)
- Test SSH connection manually: `ssh -i key.pem user@ec2-ip`
- Ensure Docker is installed on EC2
- Check EC2 has enough resources (RAM, disk space)

### Deployment script fails
- SSH into EC2 and check Docker: `docker ps`
- Check deployment directory: `ls -la /opt/konecta-erp`
- View logs: `cd /opt/konecta-erp && docker-compose logs`

## Manual Deployment (if needed)

If you need to deploy manually:

```bash
# On EC2
cd /opt/konecta-erp
docker login -u YOUR_DOCKER_USERNAME
docker-compose pull
docker-compose up -d
docker-compose ps
```

## Next Steps

1. ✅ Set up all GitHub secrets
2. ✅ Configure EC2 instance
3. ✅ Push code to trigger pipeline
4. ✅ Monitor deployment
5. ✅ Access your application at `http://your-ec2-ip:8080`

## Support

For detailed information, see:
- `devops/SECRETS_SETUP.md` - Complete secrets setup guide
- `.github/workflows/ci-cd-pipeline.yml` - Pipeline configuration
- `devops/scripts/deploy.sh` - Deployment script

