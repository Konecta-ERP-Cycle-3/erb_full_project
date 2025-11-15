# Development Guide

This guide covers local development setup, workflows, and best practices for contributing to Konecta ERP.

---

## 🛠️ Local Development Setup

### Prerequisites

- **.NET 9 SDK** - For .NET services
- **Java 17 JDK** - For Java services
- **Node.js 20+** - For frontend
- **Angular CLI** - For frontend development
- **Docker** - For infrastructure services (SQL Server, RabbitMQ, etc.)

### Option 1: Full Docker Setup (Recommended)

Run all services in Docker:

```bash
docker compose up -d
```

### Option 2: Hybrid Setup

Run infrastructure in Docker, services locally:

```bash
# Start only infrastructure
docker compose up -d sqlserver rabbitmq consul mailhog

# Run services locally (see below)
```

---

## 💻 Running Services Locally

### .NET Services

#### Setup

1. **Navigate to service directory**
   ```bash
   cd backend/AuthenticationService
   ```

2. **Restore dependencies**
   ```bash
   dotnet restore
   ```

3. **Update connection strings** in `appsettings.Development.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=localhost,1433;Database=Konecta_Auth;User Id=sa;Password=pa55w0rd!;TrustServerCertificate=True;"
     },
     "RabbitMq": {
       "HostName": "localhost",
       "Port": 5672,
       "UserName": "guest",
       "Password": "guest"
     }
   }
   ```

4. **Run the service**
   ```bash
   dotnet run
   ```

#### Available Services

- `backend/AuthenticationService/` - Port 7280
- `backend/HrService/` - Port 5005
- `backend/FinanceService/` - Port 5003
- `backend/InventoryService/` - Port 5020
- `backend/UserManagementService/` - Port 5078

### Java Services

#### Setup

1. **Navigate to service directory**
   ```bash
   cd backend/ApiGateWay
   ```

2. **Build with Maven**
   ```bash
   mvn clean install
   ```

3. **Run the service**
   ```bash
   mvn spring-boot:run
   ```

#### Available Services

- `backend/ApiGateWay/` - Port 8080
- `backend/config/` - Port 8888
- `backend/ReportingService/` - Port 8085

### Frontend

#### Setup

1. **Navigate to frontend directory**
   ```bash
   cd frontend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Run development server**
   ```bash
   ng serve
   ```

4. **Access**: http://localhost:4200

---

## 🔄 Development Workflow

### 1. Create Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Changes

- Write code following coding standards
- Add/update tests
- Update documentation if needed

### 3. Test Locally

```bash
# Run tests
dotnet test  # For .NET services
mvn test     # For Java services
npm test     # For frontend
```

### 4. Commit Changes

```bash
git add .
git commit -m "feat: Add your feature description"
```

**Commit Message Format**:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `test:` - Tests
- `chore:` - Maintenance

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

---

## 🧪 Testing

### .NET Services

```bash
# Run all tests
dotnet test

# Run tests for specific service
cd backend/AuthenticationService
dotnet test

# Run with coverage
dotnet test /p:CollectCoverage=true
```

### Java Services

```bash
# Run all tests
mvn test

# Run tests for specific service
cd backend/ApiGateWay
mvn test
```

### Frontend

```bash
cd frontend
npm test
```

---

## 📝 Code Style

### .NET (C#)

- Follow C# coding conventions
- Use `dotnet format` to format code:
  ```bash
  dotnet format
  ```

### Java

- Follow Java coding conventions
- Use Maven formatter plugin

### TypeScript/Angular

- Follow Angular style guide
- Use ESLint and Prettier:
  ```bash
  npm run lint
  npm run format
  ```

---

## 🗄️ Database Migrations

### .NET Services (Entity Framework Core)

#### Create Migration

```bash
cd backend/AuthenticationService
dotnet ef migrations add MigrationName
```

#### Apply Migrations

```bash
# Local development
dotnet ef database update

# Via Docker
docker compose exec authentication-service dotnet ef database update
```

#### Rollback Migration

```bash
dotnet ef database update PreviousMigrationName
```

---

## 🔍 Debugging

### .NET Services

1. **Set breakpoints** in Visual Studio or VS Code
2. **Attach debugger** to running process
3. **Use logging** for production debugging

### Java Services

1. **Set breakpoints** in IntelliJ IDEA or VS Code
2. **Run in debug mode**:
   ```bash
   mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
   ```

### Frontend

1. **Use browser DevTools**
2. **Angular DevTools** extension
3. **Console logging**

---

## 🐛 Common Development Issues

### Port Already in Use

**Solution**: Change port in `appsettings.Development.json` or `application.yml`

### Database Connection Failed

**Solution**: 
- Ensure SQL Server is running: `docker compose ps sqlserver`
- Check connection string
- Verify SQL Server is healthy

### RabbitMQ Connection Failed

**Solution**:
- Ensure RabbitMQ is running: `docker compose ps rabbitmq`
- Check connection settings
- Verify RabbitMQ is accessible

### Service Not Starting

**Solution**:
- Check logs: `docker compose logs <service-name>`
- Verify dependencies are running
- Check configuration files

---

## 📚 Project Structure

```
backend/
├── AuthenticationService/
│   ├── Controllers/        # API controllers
│   ├── Services/          # Business logic
│   ├── Repositories/      # Data access
│   ├── Models/            # Domain models
│   ├── Dtos/              # Data transfer objects
│   ├── Data/              # DbContext
│   └── Migrations/        # Database migrations
├── [Other Services]/      # Similar structure
└── SharedContracts/       # Shared contracts

frontend/
├── src/
│   ├── app/
│   │   ├── components/    # Angular components
│   │   ├── services/       # Services
│   │   ├── models/         # TypeScript models
│   │   └── guards/         # Route guards
│   └── assets/            # Static assets
└── package.json
```

---

## 🔗 Useful Commands

### Docker

```bash
# View logs
docker compose logs -f <service-name>

# Restart service
docker compose restart <service-name>

# Rebuild service
docker compose up -d --build <service-name>

# Access service shell
docker compose exec <service-name> /bin/bash
```

### .NET

```bash
# Restore packages
dotnet restore

# Build
dotnet build

# Run
dotnet run

# Test
dotnet test

# Format code
dotnet format
```

### Java

```bash
# Build
mvn clean install

# Run
mvn spring-boot:run

# Test
mvn test
```

### Frontend

```bash
# Install dependencies
npm install

# Run dev server
ng serve

# Build
ng build

# Test
npm test

# Lint
npm run lint
```

---

## 📖 Related Documentation

- [Getting Started](GETTING_STARTED.md) - Initial setup
- [Architecture](ARCHITECTURE.md) - System architecture
- [API Documentation](API.md) - API reference
- [Team Guide](TEAM_GUIDE.md) - Team collaboration

---

**Last Updated**: January 2025

