# GitHub Actions Secrets Setup Guide

This document explains all the secrets and credentials you need to configure in your GitHub repository for the CI/CD pipeline to work correctly.

## Required GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

### 1. Docker Hub Credentials

These are required to push Docker images to Docker Hub.

#### DOCKER_USERNAME
- **Description**: Your Docker Hub username
- **How to get it**: 
  1. Go to https://hub.docker.com
  2. Sign up or log in
  3. Your username is displayed in your profile
- **Example**: `myusername`

#### DOCKER_PASSWORD
- **Description**: Your Docker Hub password or access token
- **How to get it**:
  1. Go to https://hub.docker.com/settings/security
  2. Click "New Access Token"
  3. Give it a name (e.g., "GitHub Actions")
  4. Set permissions to "Read, Write, Delete"
  5. Copy the generated token (you won't see it again!)
- **Note**: Using an access token is more secure than using your password
- **Example**: `dckr_pat_xxxxxxxxxxxxxxxxxxxx`

### 2. AWS Credentials

These are required to deploy to AWS EC2.

#### AWS_ACCESS_KEY_ID
- **Description**: AWS access key ID for programmatic access
- **How to get it**:
  1. Log in to AWS Console
  2. Go to IAM → Users → Your User → Security credentials
  3. Click "Create access key"
  4. Select "Command Line Interface (CLI)" or "Application running outside AWS"
  5. Copy the Access Key ID
- **Example**: `AKIAIOSFODNN7EXAMPLE`

#### AWS_SECRET_ACCESS_KEY
- **Description**: AWS secret access key (paired with the access key ID)
- **How to get it**:
  1. When creating the access key (step above), copy the Secret Access Key
  2. **Important**: Save this immediately - you won't see it again!
- **Example**: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`

#### AWS_REGION
- **Description**: AWS region where your EC2 instance is located
- **Common values**: `us-east-1`, `us-west-2`, `eu-west-1`, `ap-southeast-1`
- **How to find it**: Check your EC2 instance details in AWS Console
- **Default**: `us-east-1` (if not set)

### 3. EC2 Instance Details

These are required to connect to and deploy on your EC2 instance.

#### EC2_HOST
- **Description**: Public IP address or DNS name of your EC2 instance
- **How to get it**:
  1. Go to AWS Console → EC2 → Instances
  2. Select your instance
  3. Copy the "Public IPv4 address" or "Public IPv4 DNS"
- **Example**: `54.123.45.67` or `ec2-54-123-45-67.compute-1.amazonaws.com`

#### EC2_USER
- **Description**: SSH username for your EC2 instance
- **Common values**:
  - Amazon Linux 2 / Amazon Linux 2023: `ec2-user`
  - Ubuntu: `ubuntu`
  - Debian: `admin`
  - RHEL/CentOS: `ec2-user` or `centos`
- **How to find it**: Check AWS documentation for your AMI type
- **Example**: `ec2-user`

#### EC2_SSH_PRIVATE_KEY
- **Description**: Private SSH key (PEM file content) to access your EC2 instance
- **How to get it**:
  1. When launching your EC2 instance, you should have downloaded a `.pem` file
  2. Open the `.pem` file in a text editor
  3. Copy the entire content (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`)
  4. Paste it as the secret value
- **Important**: 
  - Never commit this key to your repository!
  - Keep it secure
  - The key should be in OpenSSH format
- **Example**:
  ```
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEA...
  (entire key content)
  ...
  -----END RSA PRIVATE KEY-----
  ```

## Setting Up Your EC2 Instance

Before deploying, make sure your EC2 instance is properly configured:

### 1. Security Group Configuration

Your EC2 security group must allow inbound traffic on:
- **Port 22 (SSH)**: From your IP or GitHub Actions IPs (for deployment)
- **Port 8080 (API Gateway)**: From 0.0.0.0/0 (or your specific IPs)
- **Port 15672 (RabbitMQ Management)**: From 0.0.0.0/0 (or your specific IPs)
- **Port 8500 (Consul)**: From 0.0.0.0/0 (or your specific IPs)
- **Port 8025 (MailHog)**: From 0.0.0.0/0 (or your specific IPs)
- **Port 1433 (SQL Server)**: From EC2 security group only (internal)
- **Port 5672 (RabbitMQ)**: From EC2 security group only (internal)
- **Service ports (5003, 5005, 5020, 5078, 7280, 8085, 8888)**: From EC2 security group only (internal)

### 2. Install Docker on EC2

SSH into your EC2 instance and run:

**For Amazon Linux 2:**
```bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
```

**For Ubuntu:**
```bash
sudo apt-get update
sudo apt-get install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu
```

**Install Docker Compose:**
```bash
# For Docker Compose v2 (recommended)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Or install via pip
sudo pip3 install docker-compose
```

**Log out and log back in** for group changes to take effect.

### 3. Test Docker Installation

```bash
docker --version
docker-compose --version
docker ps
```

### 4. Create Deployment Directory

```bash
sudo mkdir -p /opt/konecta-erp
sudo chown $USER:$USER /opt/konecta-erp
```

## Verifying Secrets

After setting up all secrets, you can verify the pipeline by:

1. **Pushing to main branch**: This will trigger the full CI/CD pipeline
2. **Check GitHub Actions**: Go to your repository → Actions tab
3. **Monitor the workflow**: Watch each job complete
4. **Check EC2**: SSH into your EC2 and verify containers are running:
   ```bash
   cd /opt/konecta-erp
   docker-compose ps
   ```

## Troubleshooting

### Docker Hub Authentication Failed
- Verify `DOCKER_USERNAME` and `DOCKER_PASSWORD` are correct
- Make sure the access token has "Read, Write, Delete" permissions
- Check if your Docker Hub account is active

### AWS Authentication Failed
- Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are correct
- Check if the IAM user has necessary permissions (EC2, SSM)
- Verify `AWS_REGION` matches your EC2 instance region

### EC2 Connection Failed
- Verify `EC2_HOST` is correct (use public IP or DNS)
- Check `EC2_USER` matches your AMI type
- Verify `EC2_SSH_PRIVATE_KEY` is complete and correctly formatted
- Check security group allows SSH (port 22) from GitHub Actions IPs
- Test SSH connection manually: `ssh -i key.pem ec2-user@your-ec2-ip`

### Deployment Script Fails
- SSH into EC2 and check Docker is running: `sudo systemctl status docker`
- Check Docker Compose is installed: `docker-compose --version`
- Verify deployment directory exists: `ls -la /opt/konecta-erp`
- Check Docker Hub login: `docker login -u your-username`

## Security Best Practices

1. **Never commit secrets to your repository**
2. **Use access tokens instead of passwords** when possible
3. **Rotate credentials regularly**
4. **Use IAM roles** instead of access keys when possible (for AWS)
5. **Limit permissions** - only grant necessary permissions
6. **Monitor access logs** regularly
7. **Use separate credentials** for different environments (dev, staging, prod)

## Quick Checklist

- [ ] Docker Hub account created
- [ ] Docker Hub access token created
- [ ] AWS account with EC2 instance running
- [ ] AWS access keys created
- [ ] EC2 security group configured
- [ ] Docker installed on EC2
- [ ] Docker Compose installed on EC2
- [ ] All GitHub secrets configured
- [ ] Tested SSH connection to EC2
- [ ] Deployment directory created on EC2

