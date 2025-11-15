# Konecta ERP - Complete Project Documentation

**Version:** 1.0  
**Last Updated:** November 2025  
**Project Type:** Enterprise Resource Planning (ERP) System  
**Architecture:** Microservices with API Gateway

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [System Architecture](#2-system-architecture)
3. [Technology Stack](#3-technology-stack)
4. [Prerequisites & System Requirements](#4-prerequisites--system-requirements)
5. [Installation & Setup](#5-installation--setup)
6. [Development Guide](#6-development-guide)
7. [API Documentation](#7-api-documentation)
8. [Database Schema](#8-database-schema)
9. [Deployment Guide](#9-deployment-guide)
10. [CI/CD Pipeline](#10-cicd-pipeline)
11. [Security](#11-security)
12. [Troubleshooting](#12-troubleshooting)
13. [Contributing](#13-contributing)
14. [FAQ](#14-faq)

---

## 1. Project Overview

### 1.1 Introduction

Konecta ERP is a comprehensive Enterprise Resource Planning system designed to integrate and manage core business functions including Human Resources, Finance, Inventory, and Reporting. The system is built using a microservices architecture, ensuring scalability, maintainability, and independent deployment of services.

### 1.2 Key Features

- **Human Resources Management**: Employee lifecycle, departments, job openings, attendance, performance management
- **Financial Management**: Invoicing, expense tracking, budget management, payroll, employee compensation
- **Inventory Management**: Product catalog, stock tracking, inventory operations
- **User Management**: Role-based access control (RBAC), user directory, permissions management
- **Authentication & Authorization**: JWT-based authentication with OIDC support
- **Reporting & Analytics**: Comprehensive reporting across all modules
- **Event-Driven Architecture**: Asynchronous communication via RabbitMQ
- **Service Discovery**: Consul-based service registration and discovery
- **Centralized Configuration**: Spring Cloud Config Server

### 1.3 Project Goals

- Provide a unified platform for managing enterprise resources
- Enable cross-functional collaboration through integrated workflows
- Ensure scalability and high availability
- Maintain security and compliance standards
- Support real-time data synchronization across services

---

## 2. System Architecture

### 2.1 Architecture Overview

The system follows a **microservices architecture** with the following components:

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend (Angular)                    │
│                    http://localhost:4200                     │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway (Spring Cloud)              │
│                    http://localhost:8080                     │
│  - Routing & Load Balancing                                 │
│  - Authentication & Authorization                            │
│  - Request/Response Transformation                          │
└──────────────┬───────────────────────────────┬──────────────┘
               │                               │
    ┌──────────┴──────────┐      ┌────────────┴────────────┐
    │                     │      │                         │
┌───▼──────────┐  ┌───────▼──────┐  ┌──────────▼──────────┐
│ .NET Services│  │ Java Services │  │ Infrastructure      │
├──────────────┤  ├───────────────┤  ├─────────────────────┤
│ Auth Service │  │ API Gateway   │  │ SQL Server          │
│ HR Service   │  │ Config Server │  │ RabbitMQ            │
│ Finance Svc  │  │ Reporting Svc │  │ Consul              │
│ Inventory    │  │               │  │ MailHog             │
│ User Mgmt    │  │               │  │                     │
└──────────────┘  └───────────────┘  └─────────────────────┘
```

### 2.2 Microservices

#### 2.2.1 Authentication Service (.NET)
- **Port**: 7280
- **Purpose**: User authentication, JWT token generation, password management
- **Database**: `Konecta_Auth`
- **Key Features**:
  - User registration and login
  - JWT token generation and validation
  - Password reset and update
  - JWKS endpoint for token validation
  - Integration with User Management Service

#### 2.2.2 HR Service (.NET)
- **Port**: 5005
- **Purpose**: Human resources management
- **Database**: `Konecta_HR`
- **Key Features**:
  - Employee management (CRUD operations)
  - Department management
  - Job openings and recruitment
  - Employee lifecycle events
  - Publishes events to RabbitMQ for account provisioning

#### 2.2.3 Finance Service (.NET)
- **Port**: 5003
- **Purpose**: Financial operations and accounting
- **Database**: `Konecta_Finance`
- **Key Features**:
  - Invoice management
  - Expense tracking
  - Budget management
  - Payroll processing
  - Employee compensation tracking
  - Financial reporting

#### 2.2.4 Inventory Service (.NET)
- **Port**: 5020
- **Purpose**: Inventory and stock management
- **Database**: `Konecta_Inventory`
- **Key Features**:
  - Product catalog management
  - Stock tracking
  - Inventory operations (add, remove, transfer)
  - Low stock alerts

#### 2.2.5 User Management Service (.NET)
- **Port**: 5078
- **Purpose**: User directory and role management
- **Database**: `Konecta_UserManagement`
- **Key Features**:
  - User profile management
  - Role assignment
  - Permission management
  - Authorization profile generation
  - Synchronization with Authentication Service

#### 2.2.6 API Gateway (Java/Spring Boot)
- **Port**: 8080
- **Purpose**: Single entry point for all client requests
- **Key Features**:
  - Request routing to microservices
  - JWT validation
  - Load balancing
  - Swagger UI aggregation
  - CORS handling

#### 2.2.7 Config Server (Java/Spring Boot)
- **Port**: 8888
- **Purpose**: Centralized configuration management
- **Key Features**:
  - Configuration files for all services
  - Environment-specific settings
  - Dynamic configuration updates

#### 2.2.8 Reporting Service (Java/Spring Boot)
- **Port**: 8085
- **Purpose**: Cross-service reporting and analytics
- **Key Features**:
  - Financial summaries
  - HR analytics
  - Inventory reports
  - PDF/Excel export
  - Dashboard data aggregation

### 2.3 Infrastructure Services

#### 2.3.1 SQL Server
- **Port**: 1433
- **Purpose**: Primary database for all .NET services
- **Databases**:
  - `Konecta_Auth`
  - `Konecta_HR`
  - `Konecta_Finance`
  - `Konecta_Inventory`
  - `Konecta_UserManagement`

#### 2.3.2 RabbitMQ
- **Ports**: 5672 (AMQP), 15672 (Management UI)
- **Purpose**: Message broker for event-driven communication
- **Key Features**:
  - Asynchronous event publishing
  - Service decoupling
  - Event replay capabilities

#### 2.3.3 Consul
- **Port**: 8500
- **Purpose**: Service discovery and health checking
- **Key Features**:
  - Service registration
  - Health monitoring
  - Configuration storage
  - Service mesh capabilities

#### 2.3.4 MailHog
- **Ports**: 1025 (SMTP), 8025 (Web UI)
- **Purpose**: Email testing and development
- **Key Features**:
  - Captures all outgoing emails
  - Web UI for viewing emails
  - No actual email delivery

---

## 3. Technology Stack

### 3.1 Backend Technologies

| Component | Technology | Version |
|-----------|-----------|---------|
| .NET Services | .NET 9.0 | Latest |
| Java Services | Java 17 | 17+ |
| API Gateway | Spring Cloud Gateway | 3.2.x |
| Config Server | Spring Cloud Config | 3.2.x |
| ORM (.NET) | Entity Framework Core | 9.0 |
| ORM (Java) | Spring Data JPA | 3.2.x |
| Authentication | ASP.NET Core Identity | 9.0 |
| JWT | System.IdentityModel.Tokens.Jwt | Latest |

### 3.2 Frontend Technologies

| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Angular | 19.x |
| UI Library | PrimeNG | 19.x |
| Icons | PrimeIcons | 7.x |
| HTTP Client | Angular HttpClient | Built-in |
| State Management | RxJS | 7.8.x |

### 3.3 Infrastructure

| Component | Technology | Version |
|-----------|-----------|---------|
| Database | SQL Server | 2022 |
| Message Broker | RabbitMQ | 3.13 |
| Service Discovery | Consul | 1.18 |
| Containerization | Docker | Latest |
| Orchestration | Docker Compose | Latest |
| CI/CD | GitHub Actions | Latest |

### 3.4 Development Tools

| Tool | Purpose |
|------|---------|
| Visual Studio / VS Code | IDE |
| Postman / Swagger | API Testing |
| Git | Version Control |
| Docker Desktop | Container Management |

---

## 4. Prerequisites & System Requirements

### 4.1 System Requirements

#### Minimum Requirements
- **CPU**: 4 cores
- **RAM**: 8 GB
- **Disk Space**: 20 GB free
- **OS**: Windows 10/11, macOS 10.15+, or Linux (Ubuntu 20.04+)

#### Recommended Requirements
- **CPU**: 8 cores
- **RAM**: 16 GB
- **Disk Space**: 50 GB free (SSD recommended)
- **OS**: Windows 11, macOS 12+, or Linux (Ubuntu 22.04+)

### 4.2 Required Software

1. **Docker Desktop** (Windows/macOS) or **Docker Engine** (Linux)
   - Version: 20.10 or later
   - Docker Compose: 2.0 or later
   - Download: https://www.docker.com/products/docker-desktop

2. **Git**
   - Version: 2.30 or later
   - Download: https://git-scm.com/downloads

3. **.NET 9 SDK** (Optional, for local development)
   - Download: https://dotnet.microsoft.com/download

4. **Java 17 JDK** (Optional, for local development)
   - Download: https://adoptium.net/

5. **Node.js 20+** (For frontend development)
   - Download: https://nodejs.org/

6. **Angular CLI** (For frontend development)
   ```bash
   npm install -g @angular/cli
   ```

### 4.3 Network Requirements

- **Ports to be available**:
  - 1433 (SQL Server)
  - 5672, 15672 (RabbitMQ)
  - 8500 (Consul)
  - 8025, 1025 (MailHog)
  - 8080 (API Gateway)
  - 8888 (Config Server)
  - 5003, 5005, 5020, 5078, 7280, 8085 (Microservices)
  - 4200 (Frontend - development only)

---

## 5. Installation & Setup

### 5.1 Clone the Repository

```bash
git clone https://github.com/<your-org>/Konecta_ERP.git
cd Konecta_ERP/konecta_erp
```

### 5.2 Docker Setup

1. **Start Docker Desktop** (Windows/macOS) or ensure Docker daemon is running (Linux)

2. **Verify Docker installation**:
   ```bash
   docker --version
   docker-compose --version
   ```

3. **Allocate resources** (Docker Desktop):
   - Go to Settings → Resources
   - Allocate at least 4 CPUs and 6 GB RAM
   - Apply & Restart

### 5.3 Start the Application

#### Option 1: Full Stack (Recommended)

```bash
# From the konecta_erp directory
docker compose up -d --build
```

This command will:
- Build all Docker images
- Start all infrastructure services (SQL Server, RabbitMQ, Consul, MailHog)
- Start all microservices
- Run database migrations
- Seed initial data (admin user, roles, permissions)

#### Option 2: Start Specific Services

```bash
# Start only infrastructure
docker compose up -d sqlserver rabbitmq consul mailhog

# Start specific microservice
docker compose up -d authentication-service
```

### 5.4 Verify Installation

1. **Check running containers**:
   ```bash
   docker compose ps
   ```

   All services should show "Up" status.

2. **Check service health**:
   - Consul UI: http://localhost:8500
   - RabbitMQ Management: http://localhost:15672 (guest/guest)
   - MailHog UI: http://localhost:8025
   - API Gateway: http://localhost:8080

3. **View logs**:
   ```bash
   # All services
   docker compose logs -f

   # Specific service
   docker compose logs -f authentication-service
   ```

### 5.5 Initial Configuration

#### 5.5.1 Default Admin Account

After first startup, the system seeds a default admin account:

- **Email**: `admin@konecta.com`
- **Password**: `Admin@123456`
- **Role**: `System Admin` (full permissions)

#### 5.5.2 Database Seeding

Database seeding happens automatically via the `sqlserver-seed` container. If you need to re-seed:

```bash
# Re-seed admin user
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "pa55w0rd!" -C \
  -i /scripts/seed-admin.sql

# Re-seed permissions
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "pa55w0rd!" -C \
  -i /scripts/assign-admin-permissions.sql
```

---

## 6. Development Guide

### 6.1 Project Structure

```
konecta_erp/
├── backend/
│   ├── ApiGateWay/              # Spring Cloud Gateway
│   ├── AuthenticationService/   # .NET Auth Service
│   ├── FinanceService/          # .NET Finance Service
│   ├── HrService/               # .NET HR Service
│   ├── InventoryService/        # .NET Inventory Service
│   ├── UserManagementService/   # .NET User Management
│   ├── ReportingService/        # Spring Boot Reporting
│   ├── config/                  # Spring Cloud Config
│   └── SharedContracts/         # Shared .NET contracts
├── frontend/                    # Angular application
├── docker/                      # SQL seed scripts
├── devops/                      # CI/CD scripts
│   ├── scripts/
│   └── SECRETS_SETUP.md
├── docs/                        # Documentation
├── docker-compose.yml           # Development compose
├── docker-compose.prod.yml      # Production compose
└── README.md
```

### 6.2 Running Services Locally (Without Docker)

#### 6.2.1 .NET Services

1. **Prerequisites**:
   - .NET 9 SDK installed
   - SQL Server running (or use Docker SQL Server)
   - RabbitMQ running (or use Docker RabbitMQ)

2. **Run a service**:
   ```bash
   cd backend/AuthenticationService
   dotnet restore
   dotnet run
   ```

3. **Update connection strings** in `appsettings.Development.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=localhost,1433;Database=Konecta_Auth;User Id=sa;Password=pa55w0rd!;TrustServerCertificate=True;"
     }
   }
   ```

#### 6.2.2 Java Services

1. **Prerequisites**:
   - Java 17 JDK installed
   - Maven 3.9+ installed
   - Consul running (or use Docker Consul)

2. **Run a service**:
   ```bash
   cd backend/ApiGateWay
   mvn clean install
   mvn spring-boot:run
   ```

#### 6.2.3 Frontend

1. **Install dependencies**:
   ```bash
   cd frontend
   npm install
   ```

2. **Run development server**:
   ```bash
   ng serve
   ```

3. **Access**: http://localhost:4200

### 6.3 Development Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make changes** and test locally

3. **Commit changes**:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

4. **Push and create Pull Request**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **After PR approval**, merge to `develop` or `main`

### 6.4 Testing

#### 6.4.1 .NET Services

```bash
# Run all tests
dotnet test

# Run tests for specific service
cd backend/AuthenticationService
dotnet test
```

#### 6.4.2 Java Services

```bash
# Run all tests
mvn test

# Run tests for specific service
cd backend/ApiGateWay
mvn test
```

#### 6.4.3 Frontend

```bash
cd frontend
npm test
```

### 6.5 Code Style & Linting

#### .NET
- Follow C# coding conventions
- Use `dotnet format` to format code:
  ```bash
  dotnet format
  ```

#### Java
- Follow Java coding conventions
- Use Maven formatter plugin

#### TypeScript/Angular
- Follow Angular style guide
- Use ESLint and Prettier

---

## 7. API Documentation

### 7.1 Accessing Swagger UI

All APIs are documented via Swagger UI, accessible through the API Gateway:

| Service | Swagger URL |
|---------|-------------|
| Authentication | http://localhost:8080/swagger/auth/index.html |
| HR | http://localhost:8080/swagger/hr/index.html |
| Finance | http://localhost:8080/swagger/finance/index.html |
| Inventory | http://localhost:8080/swagger/inventory/index.html |
| User Management | http://localhost:8080/swagger/users/index.html |
| Reporting | http://localhost:8080/swagger/reporting |

### 7.2 Authentication

#### 7.2.1 Login

**Endpoint**: `POST /api/auth/login`

**Request**:
```json
{
  "email": "admin@konecta.com",
  "password": "Admin@123456"
}
```

**Response**:
```json
{
  "result": {
    "accessToken": "eyJhbGciOiJSUzI1NiIs...",
    "expiresAtUtc": "2025-01-15T10:30:00Z",
    "keyId": "key-id",
    "userId": "guid",
    "email": "admin@konecta.com",
    "roles": ["System Admin"],
    "permissions": ["*"]
  },
  "code": "200",
  "c_Message": "Login successful.",
  "s_Message": "JWT token generated successfully."
}
```

#### 7.2.2 Register

**Endpoint**: `POST /api/auth/register`

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "fullName": "John Doe"
}
```

#### 7.2.3 Update Password

**Endpoint**: `PUT /api/auth/update-password`

**Headers**: `Authorization: Bearer <token>`

**Request**:
```json
{
  "oldPassword": "OldPassword123!",
  "newPassword": "NewPassword123!",
  "confirmPassword": "NewPassword123!"
}
```

### 7.3 HR Service APIs

#### 7.3.1 Employees

- `GET /api/employees` - Get all employees
- `GET /api/employees/{id}` - Get employee by ID
- `POST /api/employees` - Create employee
- `PUT /api/employees/{id}` - Update employee
- `DELETE /api/employees/{id}` - Delete employee

#### 7.3.2 Departments

- `GET /api/departments` - Get all departments
- `GET /api/departments/{id}` - Get department by ID
- `POST /api/departments` - Create department
- `PUT /api/departments/{id}` - Update department
- `DELETE /api/departments/{id}` - Delete department

#### 7.3.3 Job Openings

- `GET /api/job-openings` - Get all job openings
- `POST /api/job-openings` - Create job opening
- `PUT /api/job-openings/{id}` - Update job opening
- `DELETE /api/job-openings/{id}` - Delete job opening

### 7.4 Finance Service APIs

#### 7.4.1 Invoices

- `GET /api/invoices` - Get all invoices
- `GET /api/invoices/{id}` - Get invoice by ID
- `POST /api/invoices` - Create invoice
- `PUT /api/invoices/{id}` - Update invoice
- `DELETE /api/invoices/{id}` - Delete invoice

#### 7.4.2 Expenses

- `GET /api/expenses` - Get all expenses
- `POST /api/expenses` - Create expense
- `PUT /api/expenses/{id}` - Update expense
- `DELETE /api/expenses/{id}` - Delete expense

#### 7.4.3 Budgets

- `GET /api/budgets` - Get all budgets
- `POST /api/budgets` - Create budget
- `PUT /api/budgets/{id}` - Update budget

### 7.5 Inventory Service APIs

#### 7.5.1 Inventory Items

- `GET /api/inventory-items` - Get all items
- `GET /api/inventory-items/{id}` - Get item by ID
- `POST /api/inventory-items` - Create item
- `PUT /api/inventory-items/{id}` - Update item
- `DELETE /api/inventory-items/{id}` - Delete item

### 7.6 Using APIs with Authentication

All protected endpoints require a JWT token in the Authorization header:

```bash
curl -X GET http://localhost:8080/api/employees \
  -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIs..."
```

In Swagger UI:
1. Click the "Authorize" button (🔓)
2. Enter: `Bearer <your-token>`
3. Click "Authorize"
4. All subsequent requests will include the token

---

## 8. Database Schema

### 8.1 Database Overview

The system uses SQL Server with separate databases for each service:

- **Konecta_Auth**: Authentication and identity
- **Konecta_HR**: Human resources data
- **Konecta_Finance**: Financial data
- **Konecta_Inventory**: Inventory data
- **Konecta_UserManagement**: User directory and roles

### 8.2 Key Tables

#### Authentication Database
- `AspNetUsers` - User accounts
- `AspNetRoles` - Roles
- `AspNetUserRoles` - User-role assignments
- `AspNetUserClaims` - User claims

#### HR Database
- `Employees` - Employee records
- `Departments` - Department information
- `JobOpenings` - Job postings
- `Attendances` - Attendance records

#### Finance Database
- `Invoices` - Invoice records
- `Expenses` - Expense records
- `Budgets` - Budget information
- `Payrolls` - Payroll records
- `EmployeeCompensations` - Compensation data

#### Inventory Database
- `InventoryItems` - Product catalog
- `StockMovements` - Stock transactions
- `Warehouses` - Warehouse information

### 8.3 Database Migrations

#### .NET Services (Entity Framework Core)

```bash
# Create migration
cd backend/AuthenticationService
dotnet ef migrations add MigrationName

# Apply migrations
dotnet ef database update

# Or via Docker
docker compose exec authentication-service dotnet ef database update
```

---

## 9. Deployment Guide

### 9.1 Production Deployment

See detailed deployment guide in:
- `devops/CI_CD_QUICK_START.md` - Quick start guide
- `devops/SECRETS_SETUP.md` - Secrets configuration

### 9.2 Manual Deployment

#### 9.2.1 Prepare EC2 Instance

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

3. **Configure security group**:
   - Allow SSH (22)
   - Allow HTTP (80)
   - Allow HTTPS (443)
   - Allow API Gateway (8080)
   - Allow management UIs (15672, 8500, 8025) - restrict to your IP

#### 9.2.2 Deploy Application

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

### 9.3 Environment Variables

For production, set environment variables in `docker-compose.prod.yml`:

```yaml
environment:
  ASPNETCORE_ENVIRONMENT: Production
  ConnectionStrings__DefaultConnection: "Server=sqlserver;Database=Konecta_Auth;..."
  JwtOptions__SecretKey: "your-production-secret-key"
```

---

## 10. CI/CD Pipeline

### 10.1 Pipeline Overview

The CI/CD pipeline is configured in `.github/workflows/ci-cd-pipeline.yml` and includes:

1. **Test Phase**: Runs tests for all services
2. **Build Phase**: Builds Docker images
3. **Push Phase**: Pushes images to Docker Hub
4. **Deploy Phase**: Deploys to AWS EC2

### 10.2 Pipeline Triggers

- **Push to `main`**: Full pipeline (test, build, push, deploy)
- **Push to `develop`**: Test and build only
- **Pull Request**: Test only

### 10.3 Required Secrets

Configure in GitHub → Settings → Secrets:

- `DOCKER_USERNAME` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub access token
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `AWS_REGION` - AWS region
- `EC2_HOST` - EC2 instance IP/DNS
- `EC2_USER` - SSH username (ubuntu/ec2-user)
- `EC2_SSH_PRIVATE_KEY` - SSH private key content

See `devops/SECRETS_SETUP.md` for detailed setup instructions.

### 10.4 Monitoring Pipeline

1. Go to GitHub repository → **Actions** tab
2. Click on the workflow run
3. Monitor each job's progress
4. Check logs for any failures

---

## 11. Security

### 11.1 Authentication & Authorization

- **JWT-based authentication** with RS256 algorithm
- **Role-based access control (RBAC)** with fine-grained permissions
- **Token expiration** and refresh mechanisms
- **Password hashing** using ASP.NET Core Identity

### 11.2 Security Best Practices

1. **Never commit secrets** to the repository
2. **Use environment variables** for sensitive configuration
3. **Enable HTTPS** in production
4. **Regular security updates** for dependencies
5. **Input validation** on all endpoints
6. **SQL injection prevention** via parameterized queries (EF Core)
7. **CORS configuration** to restrict origins
8. **Rate limiting** on authentication endpoints

### 11.3 Security Headers

The API Gateway should be configured with security headers:
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security: max-age=31536000`

---

## 12. Troubleshooting

### 12.1 Common Issues

#### Services Not Starting

**Problem**: Containers fail to start or crash immediately

**Solutions**:
1. Check Docker resources (CPU/RAM)
2. View logs: `docker compose logs <service-name>`
3. Verify ports are not in use: `netstat -an | grep <port>`
4. Check database connectivity

#### Database Connection Errors

**Problem**: Services cannot connect to SQL Server

**Solutions**:
1. Verify SQL Server is running: `docker compose ps sqlserver`
2. Check connection string in configuration
3. Verify SQL Server is healthy: `docker compose logs sqlserver`
4. Wait for SQL Server to be ready (takes ~30 seconds)

#### Authentication Failures

**Problem**: Login returns 401 Unauthorized

**Solutions**:
1. Verify credentials (admin@konecta.com / Admin@123456)
2. Check JWT configuration
3. Verify Authentication Service is running
4. Check token expiration

#### RabbitMQ Connection Issues

**Problem**: Events not being published/consumed

**Solutions**:
1. Verify RabbitMQ is running: `docker compose ps rabbitmq`
2. Check RabbitMQ Management UI: http://localhost:15672
3. Verify connection strings in configuration
4. Check queue/exchange names

### 12.2 Useful Commands

```bash
# View all logs
docker compose logs -f

# View specific service logs
docker compose logs -f authentication-service

# Restart a service
docker compose restart authentication-service

# Rebuild and restart
docker compose up -d --build authentication-service

# Check service health
docker compose ps

# Access service shell
docker compose exec authentication-service /bin/bash

# View database
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "pa55w0rd!" -C \
  -Q "SELECT name FROM sys.databases"

# Clean up everything (WARNING: deletes all data)
docker compose down -v
```

### 12.3 Getting Help

1. Check logs first: `docker compose logs -f`
2. Review this documentation
3. Check GitHub Issues
4. Contact the development team

---

## 13. Contributing

### 13.1 Contribution Guidelines

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes** following coding standards
4. **Write/update tests** for your changes
5. **Commit with clear messages**: `git commit -m "Add amazing feature"`
6. **Push to your fork**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### 13.2 Code Review Process

1. All PRs require at least one approval
2. All tests must pass
3. Code must follow style guidelines
4. Documentation must be updated if needed

### 13.3 Branch Naming Convention

- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Critical production fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates

---

## 14. FAQ

### Q: How do I reset the admin password?

A: Re-run the seed script:
```bash
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "pa55w0rd!" -C \
  -i /scripts/seed-admin.sql
```

### Q: Can I run services individually?

A: Yes, you can run services outside Docker. See section 6.2 for details.

### Q: How do I add a new microservice?

A: 
1. Create the service project
2. Add Dockerfile
3. Add service to docker-compose.yml
4. Configure API Gateway routes
5. Update Config Server configuration

### Q: How do I change the database password?

A: Update the `SA_PASSWORD` in docker-compose.yml and connection strings in all services.

### Q: Can I use a different database?

A: Yes, but you'll need to:
1. Update connection strings
2. Modify Entity Framework configurations
3. Update migration scripts

### Q: How do I scale services?

A: Use Docker Compose scaling:
```bash
docker compose up -d --scale hr-service=3
```

Or use Kubernetes for production scaling.

---

## Appendix

### A. Useful Links

- [Docker Documentation](https://docs.docker.com/)
- [.NET Documentation](https://docs.microsoft.com/dotnet/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Angular Documentation](https://angular.io/docs)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)
- [Consul Documentation](https://www.consul.io/docs)

### B. Contact Information

- **Project Repository**: https://github.com/<your-org>/Konecta_ERP
- **Issues**: https://github.com/<your-org>/Konecta_ERP/issues
- **Documentation**: See `docs/` folder

### C. License

[Specify your license here]

---

**Document Version**: 1.0  
**Last Updated**: November 2025  
**Maintained By**: Konecta Development Team

