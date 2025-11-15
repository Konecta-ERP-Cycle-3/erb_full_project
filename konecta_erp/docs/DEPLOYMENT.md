# Deployment Guide

Complete guide for deploying Konecta ERP to production environments.

---

## 📋 Prerequisites

- **Docker** and **Docker Compose** installed
- **AWS EC2** instance (or similar cloud provider)
- **Docker Hub** account for image registry
- **GitHub Actions** configured (for CI/CD)
- **SSH access** to deployment server

---

## 🚀 Quick Deployment

### Step 1: Prepare EC2 Instance

1. **Launch EC2 instance** (Ubuntu 22.04 or Amazon Linux 2023)
2. **Install Docker**:
   ```bash
   # Ubuntu
   sudo apt-get update
   sudo apt-get install docker.io -y
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo usermod -aG docker ubuntu
   
   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. **Configure Security Group**:
   - Allow SSH (22) - from your IP
   - Allow HTTP (80) - from 0.0.0.0/0
   - Allow HTTPS (443) - from 0.0.0.0/0
   - Allow API Gateway (8080) - from 0.0.0.0/0
   - Allow Management UIs (15672, 8500) - restrict to your IP

### Step 2: Deploy Application

1. **Copy files to EC2**:
   ```bash
   scp -i key.pem docker-compose.prod.yml ubuntu@ec2-ip:/opt/konecta-erp/
   scp -i key.pem -r docker/ ubuntu@ec2-ip:/opt/konecta-erp/
   ```

2. **SSH into EC2**:
   ```bash
   ssh -i key.pem ubuntu@ec2-ip
   ```

3. **Login to Docker Hub**:
   ```bash
   docker login -u your-username
   ```

4. **Update docker-compose.prod.yml** with your Docker Hub username

5. **Start services**:
   ```bash
   cd /opt/konecta-erp
   docker-compose -f docker-compose.prod.yml up -d
   ```

6. **Verify deployment**:
   ```bash
   docker-compose ps
   curl http://localhost:8080/actuator/health
   ```

---

## 🔧 Production Configuration

### Environment Variables

Set environment variables in `docker-compose.prod.yml`:

```yaml
environment:
  ASPNETCORE_ENVIRONMENT: Production
  ConnectionStrings__DefaultConnection: "Server=sqlserver;Database=Konecta_Auth;..."
  JwtOptions__SecretKey: "your-production-secret-key"
  RabbitMq__HostName: "rabbitmq"
  RabbitMq__Port: "5672"
```

### Docker Compose Production

Use `docker-compose.prod.yml` which:
- Uses Docker Hub images instead of building locally
- Includes production configurations
- Sets up proper networking
- Configures health checks

---

## 🔄 CI/CD Deployment

### GitHub Actions Setup

The CI/CD pipeline automatically:
1. **Tests** - Runs all tests
2. **Builds** - Builds Docker images
3. **Pushes** - Pushes to Docker Hub
4. **Deploys** - Deploys to EC2

### Required Secrets

Configure in GitHub → Settings → Secrets:

| Secret | Description |
|--------|------------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub access token |
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `AWS_REGION` | AWS region |
| `EC2_HOST` | EC2 instance IP/DNS |
| `EC2_USER` | SSH username (ubuntu/ec2-user) |
| `EC2_SSH_PRIVATE_KEY` | SSH private key content |

See [Secrets Setup Guide](../devops/SECRETS_SETUP.md) for detailed instructions.

### Pipeline Triggers

- **Push to `main`**: Full pipeline (test, build, push, deploy)
- **Push to `develop`**: Test and build only
- **Pull Request**: Test only

---

## 📊 Monitoring

### Health Checks

All services include health check endpoints:

```bash
# API Gateway
curl http://localhost:8080/actuator/health

# Individual services
curl http://localhost:7280/health  # Authentication
curl http://localhost:5005/health   # HR
```

### Logs

View logs for monitoring:

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f authentication-service

# Last 100 lines
docker-compose logs --tail=100 authentication-service
```

### Service Discovery

Check service health via Consul:
- **Consul UI**: http://your-server:8500
- View registered services and health status

---

## 🔐 Security Best Practices

### 1. Secrets Management

- Never commit secrets to repository
- Use environment variables or secrets manager
- Rotate secrets regularly

### 2. Network Security

- Use private networks for services
- Expose only necessary ports
- Use firewall rules

### 3. SSL/TLS

- Enable HTTPS in production
- Use reverse proxy (Nginx/Traefik)
- Configure SSL certificates

### 4. Database Security

- Use strong passwords
- Restrict database access
- Enable encryption at rest

### 5. Container Security

- Use official base images
- Keep images updated
- Scan for vulnerabilities

---

## 🔄 Updates and Rollbacks

### Updating Services

1. **Pull latest images**:
   ```bash
   docker-compose pull
   ```

2. **Restart services**:
   ```bash
   docker-compose up -d
   ```

3. **Verify health**:
   ```bash
   docker-compose ps
   curl http://localhost:8080/actuator/health
   ```

### Rolling Back

1. **Check previous image tags**:
   ```bash
   docker images
   ```

2. **Update docker-compose.prod.yml** with previous tag

3. **Restart services**:
   ```bash
   docker-compose up -d
   ```

---

## 📈 Scaling

### Horizontal Scaling

Scale services independently:

```bash
# Scale HR service to 3 instances
docker-compose up -d --scale hr-service=3
```

### Load Balancing

API Gateway automatically load balances requests across service instances.

### Database Scaling

- Use read replicas for read-heavy workloads
- Consider database sharding for large datasets
- Implement connection pooling

---

## 🗄️ Database Management

### Backups

```bash
# Backup SQL Server databases
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "password" \
  -Q "BACKUP DATABASE Konecta_Auth TO DISK = '/backup/auth.bak'"
```

### Restore

```bash
# Restore from backup
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "password" \
  -Q "RESTORE DATABASE Konecta_Auth FROM DISK = '/backup/auth.bak'"
```

---

## 🐛 Troubleshooting

### Services Not Starting

1. Check logs: `docker-compose logs <service-name>`
2. Verify resources (CPU/RAM)
3. Check dependencies are running
4. Verify configuration

### Database Connection Issues

1. Verify SQL Server is running
2. Check connection strings
3. Verify network connectivity
4. Check firewall rules

### High Memory Usage

1. Monitor container resources
2. Scale services horizontally
3. Optimize application code
4. Increase server resources

For more troubleshooting, see [Troubleshooting Guide](../devops/TROUBLESHOOTING.md).

---

## 📚 Related Documentation

- [CI/CD Quick Start](../devops/CI_CD_QUICK_START.md) - CI/CD setup
- [Secrets Setup](../devops/SECRETS_SETUP.md) - Secrets configuration
- [Architecture](ARCHITECTURE.md) - System architecture
- [Troubleshooting](../devops/TROUBLESHOOTING.md) - Common issues

---

**Last Updated**: November 2025

