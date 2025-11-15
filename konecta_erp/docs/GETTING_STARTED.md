# Getting Started with Konecta ERP

This guide will help you get Konecta ERP up and running on your local machine from scratch.

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

| Software | Version | Purpose | Download |
|----------|---------|---------|----------|
| **Docker Desktop** (Windows/macOS) or **Docker Engine** (Linux) | 20.10+ | Containerization | [Docker](https://www.docker.com/products/docker-desktop) |
| **Docker Compose** | 2.0+ | Container orchestration | Included with Docker |
| **Git** | 2.30+ | Version control | [Git](https://git-scm.com/downloads) |

### System Requirements

- **CPU**: 4 cores minimum (8 cores recommended)
- **RAM**: 8 GB minimum (16 GB recommended)
- **Disk Space**: 20 GB free (50 GB recommended)
- **OS**: Windows 10/11, macOS 10.15+, or Linux (Ubuntu 20.04+)

### Optional (for local development)

- **.NET 9 SDK** - For running .NET services locally
- **Java 17 JDK** - For running Java services locally
- **Node.js 20+** - For frontend development
- **Angular CLI** - For frontend development

---

## 🚀 Quick Start (5 minutes)

### Step 1: Clone the Repository

```bash
git clone https://github.com/Konecta-ERP-Cycle-3/erb_full_project.git
cd erb_full_project/konecta_erp
```

### Step 2: Start All Services

```bash
docker compose up -d --build
```

This command will:
- Build all Docker images
- Start all infrastructure services (SQL Server, RabbitMQ, Consul, MailHog)
- Start all microservices
- Run database migrations
- Seed initial data (admin user, roles, permissions)

**Note**: First startup may take 5-10 minutes as it builds all images.

### Step 3: Verify Services

Check that all services are running:

```bash
docker compose ps
```

All services should show "Up" status.

### Step 4: Access the Application

- **API Gateway**: http://localhost:8080
- **Swagger UI**: http://localhost:8080/swagger/auth/index.html
- **Consul UI**: http://localhost:8500
- **RabbitMQ UI**: http://localhost:15672 (guest/guest)
- **MailHog UI**: http://localhost:8025

### Step 5: Login

1. Open Swagger UI: http://localhost:8080/swagger/auth/index.html
2. Use `POST /api/auth/login` with:
   ```json
   {
     "email": "admin@konecta.com",
     "password": "Admin@123456"
   }
   ```
3. Copy the `accessToken` from the response
4. Click the "Authorize" button and paste `Bearer <token>`

**Congratulations!** You now have Konecta ERP running locally! 🎉

---

## 📖 Detailed Setup

### Docker Configuration

#### Allocate Resources (Docker Desktop)

1. Open Docker Desktop
2. Go to Settings → Resources
3. Allocate:
   - **CPUs**: 4+ (8 recommended)
   - **Memory**: 6 GB+ (12 GB recommended)
4. Click "Apply & Restart"

#### Verify Docker Installation

```bash
docker --version
docker-compose --version
```

### Starting Services

#### Start All Services

```bash
docker compose up -d --build
```

#### Start Specific Services

```bash
# Start only infrastructure
docker compose up -d sqlserver rabbitmq consul mailhog

# Start specific microservice
docker compose up -d authentication-service
```

#### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f authentication-service
```

#### Stop Services

```bash
# Stop without removing data
docker compose down

# Stop and remove volumes (WARNING: deletes all data)
docker compose down -v
```

---

## 🔐 Default Credentials

### Admin Account

- **Email**: `admin@konecta.com`
- **Password**: `Admin@123456`
- **Role**: `System Admin` (full permissions)

### Service Credentials

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| RabbitMQ Management | http://localhost:15672 | `guest` | `guest` |
| SQL Server | localhost:1433 | `sa` | `pa55w0rd!` |

---

## 🌐 Service URLs

### Infrastructure Services

| Service | URL | Description |
|---------|-----|-------------|
| API Gateway | http://localhost:8080 | Main entry point |
| Consul UI | http://localhost:8500 | Service discovery |
| RabbitMQ UI | http://localhost:15672 | Message broker |
| MailHog UI | http://localhost:8025 | Email testing |
| Config Server | http://localhost:8888 | Configuration |

### Swagger Documentation

All Swagger UIs are accessible through the API Gateway:

| Service | Swagger URL |
|---------|-------------|
| Authentication | http://localhost:8080/swagger/auth/index.html |
| HR | http://localhost:8080/swagger/hr/index.html |
| Finance | http://localhost:8080/swagger/finance/index.html |
| Inventory | http://localhost:8080/swagger/inventory/index.html |
| User Management | http://localhost:8080/swagger/users/index.html |
| Reporting | http://localhost:8080/swagger/reporting |

---

## 🧪 First Steps After Setup

### 1. Create an Employee

1. Go to HR Swagger: http://localhost:8080/swagger/hr/index.html
2. Authorize with admin token
3. Call `POST /api/employees`:
   ```json
   {
     "firstName": "John",
     "lastName": "Doe",
     "workEmail": "john.doe@konecta.com",
     "personalEmail": "john.personal@email.com",
     "phoneNumber": "+1234567890",
     "position": "Software Engineer",
     "departmentId": "your-department-id",
     "hireDate": "2025-01-15T00:00:00Z",
     "salary": 75000.00
   }
   ```

### 2. Check Email (MailHog)

1. Open MailHog: http://localhost:8025
2. You should see a welcome email with temporary password
3. Use this password for the employee's first login

### 3. Employee Login

1. Go to Authentication Swagger
2. Use `POST /api/auth/login` with employee email and temporary password
3. Change password using `PUT /api/auth/update-password`

---

## 🔧 Common Tasks

### Re-seed Database

If you need to reset the database:

```bash
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "pa55w0rd!" -C \
  -i /scripts/seed-admin.sql

docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "pa55w0rd!" -C \
  -i /scripts/assign-admin-permissions.sql
```

### Restart a Service

```bash
docker compose restart authentication-service
```

### Rebuild a Service

```bash
docker compose up -d --build authentication-service
```

### View Service Health

```bash
# Check all services
docker compose ps

# Check specific service logs
docker compose logs authentication-service
```

---

## ⚠️ Troubleshooting

### Services Not Starting

**Problem**: Containers fail to start

**Solutions**:
1. Check Docker resources (CPU/RAM)
2. View logs: `docker compose logs <service-name>`
3. Verify ports are not in use
4. Wait for SQL Server to be ready (takes ~30 seconds)

### Database Connection Errors

**Problem**: Services cannot connect to SQL Server

**Solutions**:
1. Verify SQL Server is running: `docker compose ps sqlserver`
2. Check SQL Server logs: `docker compose logs sqlserver`
3. Wait for SQL Server to be healthy (check health status)

### Port Already in Use

**Problem**: Port conflict error

**Solutions**:
1. Check what's using the port: `netstat -an | grep <port>`
2. Stop conflicting service
3. Change port in `docker-compose.yml` if needed

### Out of Memory

**Problem**: Docker runs out of memory

**Solutions**:
1. Increase Docker Desktop memory allocation
2. Stop unnecessary containers
3. Reduce number of running services

For more troubleshooting help, see [Troubleshooting Guide](../devops/TROUBLESHOOTING.md).

---

## 📚 Next Steps

Now that you have Konecta ERP running:

1. **Explore the APIs** - Use Swagger UI to test endpoints
2. **Read the Architecture** - Understand system design ([ARCHITECTURE.md](ARCHITECTURE.md))
3. **Start Developing** - Set up local development ([DEVELOPMENT.md](DEVELOPMENT.md))
4. **Learn the APIs** - Review API documentation ([API.md](API.md))

---

## 🆘 Need Help?

- **Quick Reference**: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- **Troubleshooting**: [Troubleshooting Guide](../devops/TROUBLESHOOTING.md)
- **Documentation**: [Documentation Index](README.md)
- **GitHub Issues**: [Create an issue](https://github.com/Konecta-ERP-Cycle-3/erb_full_project/issues)

---

**Last Updated**: November 2024

