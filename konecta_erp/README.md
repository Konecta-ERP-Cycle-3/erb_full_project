# Konecta ERP – Enterprise Resource Planning System

<div align="center">

![Konecta ERP](https://img.shields.io/badge/Konecta-ERP-blue)
![.NET](https://img.shields.io/badge/.NET-9.0-purple)
![Angular](https://img.shields.io/badge/Angular-19-red)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)

**A comprehensive Enterprise Resource Planning system built with microservices architecture**

[Getting Started](#-quick-start) • [Documentation](#-documentation) • [Architecture](#-architecture) • [API Documentation](#-api-documentation)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Quick Start](#-quick-start)
- [Documentation](#-documentation)
- [API Documentation](#-api-documentation)
- [Technology Stack](#-technology-stack)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)

---

## 🎯 Overview

Konecta ERP is a modern, scalable Enterprise Resource Planning system that integrates core business functions including:

- **Human Resources Management** - Employee lifecycle, departments, recruitment
- **Financial Management** - Invoicing, expenses, budgets, payroll
- **Inventory Management** - Product catalog, stock tracking, operations
- **User Management** - Role-based access control, permissions
- **Reporting & Analytics** - Comprehensive reporting across all modules

Built using a **microservices architecture** with .NET and Spring Boot, ensuring scalability, maintainability, and independent deployment of services.

---

## ✨ Features

- 🔐 **JWT-based Authentication** with OIDC support
- 🏗️ **Microservices Architecture** - Independent, scalable services
- 🔄 **Event-Driven Communication** - RabbitMQ message broker
- 🌐 **API Gateway** - Single entry point with routing and load balancing
- 📊 **Service Discovery** - Consul-based service registration
- ⚙️ **Centralized Configuration** - Spring Cloud Config Server
- 🐳 **Dockerized** - Complete containerization with Docker Compose
- 📱 **Modern Frontend** - Angular 19 with PrimeNG
- 🤖 **AI/ML Integration**
  - HR predictive analytics  
  - Prophet forecasting models  
  - Chatbot using RAG  
  - Invoice OCR extraction module
- 🚀 **CI/CD Pipeline** - Automated testing, building, and deployment

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Frontend (Angular)                    │
│                  http://localhost:4200                   │
└───────────────────────┬─────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              API Gateway (Spring Cloud)                │
│                 http://localhost:8080                     │
└───────┬───────────────┬───────────────┬────────────────┘
        │               │               │
   ┌────▼────┐    ┌────▼────┐    ┌────▼────┐
   │  .NET   │    │  Java   │    │Infrastructure│
   │Services │    │Services │    │  Services   │
   ├─────────┤    ├─────────┤    ├────────────┤
   │ Auth    │    │ Gateway │    │ SQL Server │
   │ HR      │    │ Config  │    │ RabbitMQ   │
   │ Finance │    │Reporting│    │ Consul     │
   │Inventory│    │         │    │ MailHog    │
   │User Mgmt│    │         │    │            │
   └─────────┘    └─────────┘    └────────────┘
```

### Microservices

| Service | Technology | Port | Database |
|---------|-----------|------|----------|
| Authentication | .NET 9 | 7280 | Konecta_Auth |
| HR | .NET 9 | 5005 | Konecta_HR |
| Finance | .NET 9 | 5003 | Konecta_Finance |
| Inventory | .NET 9 | 5020 | Konecta_Inventory |
| User Management | .NET 9 | 5078 | Konecta_UserManagement |
| API Gateway | Spring Boot | 8080 | - |
| Config Server | Spring Boot | 8888 | - |
| Reporting | Spring Boot | 8085 | - |

For detailed architecture documentation, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** (Windows/macOS) or **Docker Engine** (Linux)
- **Git**
- **8 GB RAM** minimum (16 GB recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Konecta-ERP-Cycle-3/erb_full_project.git
   cd erb_full_project/konecta_erp
   ```

2. **Start all services**
   ```bash
   docker compose up -d --build
   ```

3. **Verify services are running**
   ```bash
   docker compose ps
   ```

4. **Access the application**
   - API Gateway: http://localhost:8080
   - Swagger UI: http://localhost:8080/swagger/auth/index.html
   - Consul UI: http://localhost:8500
   - RabbitMQ UI: http://localhost:15672 (guest/guest)

### Default Credentials

- **Admin Email**: `admin@konecta.com`
- **Admin Password**: `Admin@123456`

### First Steps

1. **Login via Swagger**
   - Navigate to http://localhost:8080/swagger/auth/index.html
   - Use `POST /api/auth/login` with admin credentials
   - Copy the `accessToken` from response
   - Click "Authorize" button and paste `Bearer <token>`

2. **Explore APIs**
   - HR Service: http://localhost:8080/swagger/hr/index.html
   - Finance Service: http://localhost:8080/swagger/finance/index.html
   - Inventory Service: http://localhost:8080/swagger/inventory/index.html

For detailed setup instructions, see [docs/GETTING_STARTED.md](docs/GETTING_STARTED.md).

---

## 📚 Documentation

### Essential Guides

- **[Getting Started](docs/GETTING_STARTED.md)** - Complete setup and onboarding guide
- **[Architecture](docs/ARCHITECTURE.md)** - System architecture and design decisions
- **[API Documentation](docs/API.md)** - Complete API reference
- **[Quick Reference](docs/QUICK_REFERENCE.md)** - Common commands and quick tasks

### Development

- **[Development Guide](docs/DEVELOPMENT.md)** - Local development setup and workflows
- **[Team Guide](docs/TEAM_GUIDE.md)** - Team collaboration and workflow
- **[Contributing](CONTRIBUTING.md)** - Contribution guidelines

### Operations

- **[Deployment Guide](docs/DEPLOYMENT.md)** - Production deployment instructions
- **[CI/CD Setup](devops/CI_CD_QUICK_START.md)** - CI/CD pipeline configuration
- **[Troubleshooting](devops/TROUBLESHOOTING.md)** - Common issues and solutions

### Complete Documentation Index

See [docs/README.md](docs/README.md) for the complete documentation index.

---

## 🔌 API Documentation

All APIs are accessible through the API Gateway at `http://localhost:8080` and documented via Swagger UI:

| Service | Swagger URL | Description |
|---------|------------|-------------|
| Authentication | `/swagger/auth/index.html` | User authentication and JWT |
| HR | `/swagger/hr/index.html` | Employee and department management |
| Finance | `/swagger/finance/index.html` | Invoices, expenses, budgets |
| Inventory | `/swagger/inventory/index.html` | Product catalog and stock |
| User Management | `/swagger/users/index.html` | User directory and roles |
| Reporting | `/swagger/reporting` | Analytics and reports |

### Authentication

All protected endpoints require a JWT token in the Authorization header:

```bash
Authorization: Bearer <your-token>
```

For complete API documentation, see [docs/API.md](docs/API.md).

---

## 🛠️ Technology Stack

### Backend
- **.NET 9.0** - Microservices (C#)
- **Spring Boot 3.2** - API Gateway, Config Server, Reporting
- **Entity Framework Core** - ORM for .NET services
- **ASP.NET Core Identity** - Authentication

### Frontend
- **Angular 19** - Frontend framework
- **PrimeNG 19** - UI component library
- **RxJS** - Reactive programming

### Infrastructure
- **SQL Server 2022** - Primary database
- **RabbitMQ 3.13** - Message broker
- **Consul 1.18** - Service discovery
- **Docker & Docker Compose** - Containerization

### DevOps
- **GitHub Actions** - CI/CD pipeline
- **Docker Hub** - Container registry

---

## 📁 Project Structure

```
konecta_erp/
├── backend/                    # Backend microservices
│   ├── AuthenticationService/   # Auth & JWT service
│   ├── HrService/              # HR management
│   ├── FinanceService/         # Financial operations
│   ├── InventoryService/       # Inventory management
│   ├── UserManagementService/  # User directory
│   ├── ReportingService/       # Reporting & analytics
│   ├── ApiGateWay/             # API Gateway
│   ├── config/                 # Config server
│   └── SharedContracts/       # Shared contracts
├── frontend/                   # Angular application
├── Ai/                         # AI/ML Models and Artifacts
│   └── artifacts/
│       ├── hr_model/           # HR Prediction Model (XGBoost)
│       │   ├── hr_xgb_model.pkl
│       │   ├── hr_scaler.pkl
│       │   ├── hr_feature_columns.csv
│       │   └── Dockerfile
│       └── prophet_model/      # Prophet Forecasting Model
│           ├── prophet_model.pkl
│           ├── prophet_forecast.csv
│           └── Dockerfile
├── devops/                     # CI/CD and deployment
│   ├── scripts/                # Deployment scripts
│   └── *.md                    # DevOps documentation
├── docker/                     # Docker configurations
│   └── sqlserver/              # SQL seed scripts
├── docs/                       # Documentation
│   ├── GETTING_STARTED.md      # Setup guide
│   ├── ARCHITECTURE.md         # Architecture docs
│   ├── API.md                  # API reference
│   └── ...                     # Other docs
├── docker-compose.yml          # Development environment
└── docker-compose.prod.yml     # Production environment
```

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Quick Contribution Steps

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📞 Support

- **Documentation**: [docs/README.md](docs/README.md)
- **Issues**: [GitHub Issues](https://github.com/Konecta-ERP-Cycle-3/erb_full_project/issues)
- **Troubleshooting**: [devops/TROUBLESHOOTING.md](devops/TROUBLESHOOTING.md)

---

## 📄 License

[Add your license here]

---

## 👥 Team

This project is developed by multiple specialized teams:

- **🚀 Fullstack Team** - Backend and frontend development
- **🔧 DevOps Team** - CI/CD and deployment automation
- **☁️ Cloud Team** - Infrastructure and cloud resources
- **🤖 AI/ML Team** - Machine learning models

See [TEAMS.md](TEAMS.md) for detailed team information.

---

<div align="center">

**Built with ❤️ by the Konecta ERP Team**

[⭐ Star us on GitHub](https://github.com/Konecta-ERP-Cycle-3/erb_full_project)

</div>
