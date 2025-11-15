# Deployment Guide

Complete guide for deploying Konecta ERP to production environments.

> **⚠️ Deployment Status Note**: The cloud deployment process was not fully completed due to the lack of AWS account access. Without AWS credentials, we were unable to proceed with cloud infrastructure setup. This documentation describes the **intended deployment strategy** that would have been implemented:
> - **Testing Phase**: Deploy to AWS EC2 instances for testing and validation
> - **Production Phase**: Deploy to AWS ECS (Elastic Container Service) for production
> - **Image Registry**: Use AWS ECR (Elastic Container Registry) instead of Docker Hub
> 
> For local development and testing, all services can be run successfully using Docker Compose.

---

## 🎯 Intended Deployment Strategy

### Two-Phase Deployment Approach

#### Phase 1: Testing on EC2
- Deploy to EC2 instances for testing and validation
- Validate all services work correctly in cloud environment
- Test integration between services
- Performance testing and optimization

#### Phase 2: Production on ECS
- Deploy to AWS ECS for production
- Auto-scaling and load balancing
- High availability and fault tolerance
- Production-grade monitoring and logging

### Image Registry Strategy

**Intended**: AWS ECR (Elastic Container Registry)
- Private container registry within AWS
- Integrated with ECS for seamless deployment
- Better security and access control
- Cost-effective for AWS-native deployments

**Current**: Docker Hub (fallback for local development)

---

## 📋 Prerequisites

### Required AWS Resources (Not Configured)

- **AWS Account** - Required for cloud deployment
- **AWS ECR Repository** - For container image storage
- **AWS EC2 Instances** - For testing phase
- **AWS ECS Cluster** - For production deployment
- **AWS VPC** - Virtual Private Cloud for networking
- **AWS Security Groups** - For network security
- **AWS IAM Roles** - For service permissions

### Required Credentials (Placeholders)

The following AWS credentials would be needed but are not configured:

| Credential | Purpose | Status |
|------------|---------|--------|
| `AWS_ACCOUNT_ID` | AWS account identifier | ⚠️ Not configured |
| `AWS_ACCESS_KEY_ID` | Programmatic access | ⚠️ Not configured |
| `AWS_SECRET_ACCESS_KEY` | Secret access key | ⚠️ Not configured |
| `AWS_REGION` | Deployment region | ⚠️ Not configured |
| `ECR_REPOSITORY_URI` | ECR repository URL | ⚠️ Not configured |
| `ECS_CLUSTER_NAME` | ECS cluster name | ⚠️ Not configured |
| `ECS_SERVICE_NAME` | ECS service name | ⚠️ Not configured |
| `EC2_INSTANCE_IDS` | EC2 instance IDs for testing | ⚠️ Not configured |
| `VPC_ID` | Virtual Private Cloud ID | ⚠️ Not configured |
| `SUBNET_IDS` | Subnet IDs for ECS | ⚠️ Not configured |
| `SECURITY_GROUP_IDS` | Security group IDs | ⚠️ Not configured |

---

## 🚀 Intended Deployment Process

### Phase 1: Testing on EC2

#### Step 1: Setup AWS ECR

1. **Create ECR Repository**:
   ```bash
   aws ecr create-repository --repository-name konecta-erp/authentication-service --region us-east-1
   aws ecr create-repository --repository-name konecta-erp/hr-service --region us-east-1
   aws ecr create-repository --repository-name konecta-erp/finance-service --region us-east-1
   aws ecr create-repository --repository-name konecta-erp/inventory-service --region us-east-1
   aws ecr create-repository --repository-name konecta-erp/user-management-service --region us-east-1
   aws ecr create-repository --repository-name konecta-erp/api-gateway --region us-east-1
   aws ecr create-repository --repository-name konecta-erp/reporting-service --region us-east-1
   aws ecr create-repository --repository-name konecta-erp/config-server --region us-east-1
   aws ecr create-repository --repository-name konecta-erp/hr-model --region us-east-1
   aws ecr create-repository --repository-name konecta-erp/prophet-model --region us-east-1
   ```

2. **Get ECR Login Token**:
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
   ```

#### Step 2: Build and Push to ECR

Images would be built and pushed to ECR instead of Docker Hub:

```bash
# Example for authentication service
docker build -t konecta-erp/authentication-service:latest ./backend/AuthenticationService
docker tag konecta-erp/authentication-service:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/konecta-erp/authentication-service:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/konecta-erp/authentication-service:latest
```

#### Step 3: Deploy to EC2 for Testing

1. **Launch EC2 Instances**:
   - Multiple instances for different services
   - Configure security groups
   - Set up networking

2. **Deploy Services**:
   ```bash
   # Pull images from ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
   docker pull <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/konecta-erp/authentication-service:latest
   
   # Run services
   docker-compose -f docker-compose.ec2-test.yml up -d
   ```

3. **Validate and Test**:
   - Test all API endpoints
   - Verify service communication
   - Performance testing
   - Load testing

### Phase 2: Production on ECS

#### Step 1: Create ECS Cluster

```bash
aws ecs create-cluster --cluster-name konecta-erp-production --region us-east-1
```

#### Step 2: Create ECS Task Definitions

Each service would have a task definition:

```json
{
  "family": "konecta-erp-authentication-service",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "containerDefinitions": [{
    "name": "authentication-service",
    "image": "<AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/konecta-erp/authentication-service:latest",
    "portMappings": [{
      "containerPort": 7280,
      "protocol": "tcp"
    }],
    "environment": [
      {"name": "ASPNETCORE_ENVIRONMENT", "value": "Production"}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/konecta-erp",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }]
}
```

#### Step 3: Create ECS Services

```bash
aws ecs create-service \
  --cluster konecta-erp-production \
  --service-name authentication-service \
  --task-definition konecta-erp-authentication-service \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"
```

#### Step 4: Setup Application Load Balancer

- Create ALB for API Gateway
- Configure target groups
- Set up health checks
- Configure SSL/TLS certificates

---

## 🔧 Production Configuration

### ECS Task Definition Environment Variables

```json
{
  "environment": [
    {"name": "ASPNETCORE_ENVIRONMENT", "value": "Production"},
    {"name": "ConnectionStrings__DefaultConnection", "value": "Server=rds-endpoint;Database=Konecta_Auth;..."},
    {"name": "RabbitMq__HostName", "value": "rabbitmq-service"},
    {"name": "JwtOptions__SecretKey", "value": "from-secrets-manager"}
  ],
  "secrets": [
    {
      "name": "JwtOptions__SecretKey",
      "valueFrom": "arn:aws:secretsmanager:us-east-1:ACCOUNT_ID:secret:konecta/jwt-secret"
    }
  ]
}
```

### Infrastructure Components

- **RDS** - Managed SQL Server database
- **ElastiCache** - Redis for caching
- **S3** - Object storage for artifacts
- **CloudWatch** - Logging and monitoring
- **Secrets Manager** - Secure credential storage

---

## 🔄 CI/CD Pipeline (Intended)

### GitHub Actions Workflow

The intended workflow would:

1. **Security Scan** - Semgrep security and code quality scanning ✅ (Currently working)
2. **Test** - Run all tests ✅ (Currently working)
3. **Build** - Build Docker images ✅ (Currently working)
4. **Push to ECR** - Push to AWS ECR ⚠️ (Would use ECR instead of Docker Hub)
5. **Deploy to EC2** - Deploy to EC2 for testing ⚠️ (Not configured)
6. **Deploy to ECS** - Deploy to ECS for production ⚠️ (Not configured)

#### Security Scanning with Semgrep

The pipeline includes automated security scanning using Semgrep:
- **Scans for**: Security vulnerabilities, OWASP Top 10 issues, code quality
- **Languages**: C#, Java, JavaScript, TypeScript
- **Reports**: SARIF format uploaded to GitHub Security tab
- **Status**: ✅ Working - Runs on every push and PR

### Required GitHub Secrets (Placeholders)

| Secret | Description | Status |
|--------|-------------|--------|
| `AWS_ACCOUNT_ID` | AWS account ID | ⚠️ Not configured |
| `AWS_ACCESS_KEY_ID` | AWS access key | ⚠️ Not configured |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | ⚠️ Not configured |
| `AWS_REGION` | AWS region (e.g., us-east-1) | ⚠️ Not configured |
| `ECR_REPOSITORY_URI` | ECR repository base URI | ⚠️ Not configured |
| `ECS_CLUSTER_NAME` | ECS cluster name | ⚠️ Not configured |
| `ECS_SERVICE_NAME` | ECS service name | ⚠️ Not configured |
| `VPC_ID` | VPC ID for ECS | ⚠️ Not configured |
| `SUBNET_IDS` | Comma-separated subnet IDs | ⚠️ Not configured |
| `SECURITY_GROUP_IDS` | Comma-separated security group IDs | ⚠️ Not configured |
| `EC2_HOST` | EC2 instance IP/DNS (for testing) | ⚠️ Not configured |
| `EC2_USER` | SSH username | ⚠️ Not configured |
| `EC2_SSH_PRIVATE_KEY` | SSH private key | ⚠️ Not configured |

---

## 📊 Monitoring & Logging (Intended)

### CloudWatch Integration

- **Logs**: All container logs to CloudWatch Logs
- **Metrics**: Service metrics and custom metrics
- **Alarms**: Automated alerts for issues
- **Dashboards**: Visual monitoring dashboards

### Application Load Balancer

- Health checks for all services
- SSL/TLS termination
- Request routing
- Access logs

---

## 🔐 Security (Intended)

### IAM Roles

- ECS Task Execution Role
- ECS Task Role
- EC2 Instance Role

### Secrets Management

- AWS Secrets Manager for sensitive data
- Encrypted environment variables
- Secure credential rotation

### Network Security

- VPC with private subnets
- Security groups
- Network ACLs
- WAF for API protection

---

## 🐛 Troubleshooting

### Common Issues (If Deployment Was Completed)

1. **ECR Authentication Failed**
   - Verify AWS credentials
   - Check IAM permissions
   - Verify ECR repository exists

2. **ECS Service Not Starting**
   - Check task definition
   - Verify image exists in ECR
   - Check security group rules
   - Review CloudWatch logs

3. **EC2 Connection Issues**
   - Verify security group allows SSH
   - Check key pair configuration
   - Verify instance is running

---

## 📚 Related Documentation

- [CI/CD Quick Start](../devops/CI_CD_QUICK_START.md) - CI/CD setup
- [Secrets Setup](../devops/SECRETS_SETUP.md) - Secrets configuration
- [Architecture](ARCHITECTURE.md) - System architecture
- [Troubleshooting](../devops/TROUBLESHOOTING.md) - Common issues

---

## 📝 Summary

### What Was Intended

- ✅ **Image Registry**: AWS ECR (Elastic Container Registry)
- ✅ **Testing**: AWS EC2 instances
- ✅ **Production**: AWS ECS (Elastic Container Service)
- ✅ **Two-Phase Deployment**: Test on EC2, then deploy to ECS

### Current Status

- ⚠️ **AWS Account**: Not available
- ⚠️ **ECR Setup**: Not configured
- ⚠️ **EC2 Deployment**: Not completed
- ⚠️ **ECS Deployment**: Not completed
- ✅ **Local Development**: Fully functional with Docker Compose
- ✅ **CI/CD Pipeline**: Builds and tests work, deployment steps are placeholders

### Next Steps (If AWS Access Becomes Available)

1. Create AWS account and set up IAM
2. Create ECR repositories for all services
3. Update CI/CD pipeline to use ECR
4. Set up EC2 instances for testing
5. Deploy and test on EC2
6. Create ECS cluster and services
7. Deploy to ECS for production
8. Configure monitoring and logging

---

**Last Updated**: November 2025  
**Deployment Status**: Intended strategy documented, not implemented due to lack of AWS access
