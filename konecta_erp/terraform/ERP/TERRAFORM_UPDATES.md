# Terraform Infrastructure Updates

## Overview
The Terraform configuration has been fully updated to align with the Konecta ERP microservices architecture.

## ✅ Completed Updates

### 1. Database Configuration
- **Changed RDS from PostgreSQL to SQL Server Express**
  - Engine: `sqlserver-ex` (SQL Server Express)
  - Port: 1433 (SQL Server default)
  - Databases: Created via Entity Framework migrations (not in Terraform)
  - Database names: `Konecta_Auth`, `Konecta_HR`, `Konecta_Finance`, `Konecta_Inventory`, `Konecta_UserManagement`

### 2. Microservices Infrastructure
All 8 microservices are now configured in ECS:

#### Public Services (Behind ALB)
- **API Gateway** (Port 8080) - Entry point, 2 instances
  - Image: `mohamed710/api-gateway:latest`
  - Health check: `/actuator/health`

#### Private Services
- **Config Server** (Port 8888) - 1 instance
  - Image: `mohamed710/config-server:latest`
  
- **Authentication Service** (Port 7280) - 2 instances
  - Image: `mohamed710/authentication-service:latest`
  - Database: `Konecta_Auth`
  
- **User Management Service** (Port 5078) - 2 instances
  - Image: `mohamed710/user-management-service:latest`
  - Database: `Konecta_UserManagement`
  
- **Finance Service** (Port 5003) - 2 instances
  - Image: `mohamed710/finance-service:latest`
  - Database: `Konecta_Finance`
  
- **HR Service** (Port 5005) - 2 instances
  - Image: `mohamed710/hr-service:latest`
  - Database: `Konecta_Hr`
  
- **Inventory Service** (Port 5020) - 2 instances
  - Image: `mohamed710/inventory-service:latest`
  - Database: `Konecta_Inventory`
  
- **Reporting Service** (Port 8085) - 1 instance
  - Image: `mohamed710/reporting-service:latest`

### 3. Infrastructure Services
- **RabbitMQ** (Ports 5672, 15672) - Message broker
  - Image: `rabbitmq:3.13-management`
  - 1 instance in private subnet
  
- **Consul** (Port 8500) - Service discovery
  - Image: `hashicorp/consul:1.18`
  - 1 instance in private subnet

### 4. Service Discovery
- AWS Cloud Map namespace: `${project_name}.local`
- All services registered for internal DNS resolution
- Services can communicate using: `service-name.${namespace}`

### 5. Security Groups
- **ALB SG**: Port 80 from internet
- **API Gateway SG**: Port 8080 from ALB
- **Backend SG**: Allows inter-service communication on all service ports
  - Ports: 7280, 5078, 5003, 5005, 5020, 8085, 8888, 5672, 8500
- **RDS SG**: Port 1433 (SQL Server) from backend services

### 6. Connection Strings
All .NET services use SQL Server connection strings:
```
Server={rds_endpoint},1433;Database={DatabaseName};User Id={username};Password={password};TrustServerCertificate=True;
```

### 7. Environment Variables
All services configured with:
- Database connection strings
- RabbitMQ connection (for .NET services that use it)
- Consul connection (for service discovery)
- Service-to-service URIs (for Java services)

## 📋 Configuration Files Updated

1. `modules/rds/rds.tf` - Changed to SQL Server
2. `modules/ecs/ecs.tf` - Added all microservices + RabbitMQ + Consul
3. `modules/ecs/variables.tf` - Updated for all service images
4. `modules/sg/sg.tf` - Updated security groups
5. `main.tf` - Updated to pass all service images
6. `variables.tf` - Added all service image variables
7. `dev.tfvars` - Updated with actual Docker image names

## 🚀 Deployment

### Prerequisites
- AWS CLI configured
- Terraform >= 1.0
- Docker images pushed to Docker Hub (`mohamed710/*`)

### Steps
1. Navigate to `cloud/ERP/`
2. Initialize: `terraform init`
3. Plan: `terraform plan -var-file=dev.tfvars`
4. Apply: `terraform apply -var-file=dev.tfvars`

### Important Notes
- SQL Server databases will be created automatically via Entity Framework migrations when services start
- Service discovery uses AWS Cloud Map (not Consul for DNS, but Consul is still available for health checks)
- All services use the pushed Docker images from `mohamed710/` namespace
- RDS SQL Server Express is used for cost optimization (can be upgraded to Standard/Enterprise for production)

## 🔍 Verification

After deployment:
1. Check ECS cluster: Services should be running
2. Check ALB DNS: Should route to API Gateway
3. Check CloudWatch Logs: All services should be logging
4. Verify service discovery: Services should resolve via DNS

## 📝 Next Steps (Optional)
- Add auto-scaling policies
- Add CloudWatch alarms
- Set up SSL/TLS certificates for HTTPS
- Configure backup strategies for RDS
- Add monitoring and alerting

