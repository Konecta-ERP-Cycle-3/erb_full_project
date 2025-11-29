# Konecta ERP - Quick Reference Guide

A quick reference guide for common tasks and commands.

## 🚀 Quick Start Commands

### Start Everything
```bash
docker compose up -d --build
```

### Stop Everything
```bash
docker compose down
```

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f authentication-service
```

### Check Status
```bash
docker compose ps
```

## 🔐 Default Credentials

### Admin Account
- **Email**: `admin@konecta.com`
- **Password**: `Admin@123456`

### RabbitMQ Management
- **URL**: http://localhost:15672
- **Username**: `guest`
- **Password**: `guest`

## 🌐 Service URLs

| Service | URL | Description |
|---------|-----|-------------|
| API Gateway | http://localhost:8080 | Main entry point |
| Consul UI | http://localhost:8500 | Service discovery |
| RabbitMQ UI | http://localhost:15672 | Message broker |
| MailHog UI | http://localhost:8025 | Email testing |
| Config Server | http://localhost:8888 | Configuration |

## 📖 Swagger Documentation

All Swagger UIs are accessible through the API Gateway:

| Service | Swagger URL |
|---------|-------------|
| Authentication | http://localhost:8080/swagger/auth/index.html |
| HR | http://localhost:8080/swagger/hr/index.html |
| Finance | http://localhost:8080/swagger/finance/index.html |
| Inventory | http://localhost:8080/swagger/inventory/index.html |
| User Management | http://localhost:8080/swagger/users/index.html |
| Reporting | http://localhost:8080/swagger/reporting |

## 🔧 Common Tasks

### Login and Get Token
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@konecta.com",
    "password": "Admin@123456"
  }'
```

### Use Token in API Calls
```bash
curl -X GET http://localhost:8080/api/employees \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Re-seed Database
```bash
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "pa55w0rd!" -C \
  -i /scripts/seed-admin.sql
```

### Restart a Service
```bash
docker compose restart authentication-service
```

### Rebuild a Service
```bash
docker compose up -d --build authentication-service
```

### Access Service Shell
```bash
docker compose exec authentication-service /bin/bash
```

### View Database
```bash
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "pa55w0rd!" -C \
  -Q "SELECT name FROM sys.databases"
```

## 📦 Service Ports

| Service | Port | Protocol |
|---------|------|----------|
| API Gateway | 8080 | HTTP |
| Authentication | 7280 | HTTP |
| HR Service | 5005 | HTTP |
| Finance Service | 5003 | HTTP |
| Inventory Service | 5020 | HTTP |
| User Management | 5078 | HTTP |
| Reporting Service | 8085 | HTTP |
| Config Server | 8888 | HTTP |
| SQL Server | 1433 | TCP |
| RabbitMQ | 5672 | AMQP |
| RabbitMQ Management | 15672 | HTTP |
| Consul | 8500 | HTTP |
| MailHog SMTP | 1025 | SMTP |
| MailHog UI | 8025 | HTTP |

## 🗄️ Databases

| Database | Purpose |
|----------|---------|
| Konecta_Auth | Authentication & Identity |
| Konecta_HR | Human Resources |
| Konecta_Finance | Financial Data |
| Konecta_Inventory | Inventory Data |
| Konecta_UserManagement | User Directory |

## 🐛 Troubleshooting

### Service Won't Start
```bash
# Check logs
docker compose logs <service-name>

# Check if port is in use
netstat -an | grep <port>

# Restart service
docker compose restart <service-name>
```

### Database Connection Issues
```bash
# Check SQL Server status
docker compose ps sqlserver

# Check SQL Server logs
docker compose logs sqlserver

# Verify connection
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "pa55w0rd!" -C -Q "SELECT 1"
```

### Clear Everything and Start Fresh
```bash
# WARNING: This deletes all data!
docker compose down -v
docker compose up -d --build
```

## 📝 Development Commands

### Run .NET Service Locally
```bash
cd backend/AuthenticationService
dotnet restore
dotnet run
```

### Run Java Service Locally
```bash
cd backend/ApiGateWay
mvn clean install
mvn spring-boot:run
```

### Run Frontend Locally
```bash
cd frontend
npm install
ng serve
```

### Run Tests
```bash
# .NET
dotnet test

# Java
mvn test

# Frontend
cd frontend && npm test
```

## 🔄 CI/CD

### Trigger Pipeline
```bash
git push origin main
```

### Check Pipeline Status
1. Go to GitHub → Actions tab
2. View workflow runs
3. Check job logs

## 📚 More Information

- **Full Documentation**: [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md)
- **CI/CD Setup**: [CI_CD_QUICK_START.md](../devops/CI_CD_QUICK_START.md)
- **Secrets Setup**: [SECRETS_SETUP.md](../devops/SECRETS_SETUP.md)

---

**Last Updated**: November 2025

