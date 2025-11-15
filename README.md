# Konecta ERP - Final Project Submission

<div align="center">

![Konecta ERP](https://img.shields.io/badge/Konecta-ERP-blue)
![.NET](https://img.shields.io/badge/.NET-9.0-purple)
![Angular](https://img.shields.io/badge/Angular-19-red)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2-green)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
![Microservices](https://img.shields.io/badge/Architecture-Microservices-orange)

**Enterprise Resource Planning System - Cycle 3 Final Submission**

[📖 Project Documentation](konecta_erp/README.md) • [🚀 Quick Start](konecta_erp/docs/GETTING_STARTED.md) • [🏗️ Architecture](konecta_erp/docs/ARCHITECTURE.md)

</div>

---

## 🎯 Welcome to Konecta ERP

This repository contains the **final consolidated submission** of the Konecta ERP project, developed collaboratively by multiple specialized teams as part of Cycle 3.

### What is Konecta ERP?

Konecta ERP is a comprehensive **Enterprise Resource Planning system** built with modern microservices architecture, integrating:

- 👥 **Human Resources Management** - Complete employee lifecycle management
- 💰 **Financial Management** - Invoicing, expenses, budgets, and payroll
- 📦 **Inventory Management** - Product catalog and stock tracking
- 👤 **User Management** - Role-based access control and permissions
- 📊 **Reporting & Analytics** - Cross-service reporting and insights
- 🤖 **AI/ML Integration** - Predictive models for HR and forecasting

---

## 🚀 Quick Navigation

### 📁 Project Structure

```
erb_full_project/
├── konecta_erp/          # Main project directory
│   ├── backend/          # Microservices (.NET & Spring Boot)
│   ├── frontend/         # Angular application
│   ├── Ai/               # AI/ML models and artifacts
│   ├── devops/           # CI/CD and deployment scripts
│   ├── docker/           # Docker configurations
│   └── docs/             # Comprehensive documentation
├── .github/              # GitHub Actions workflows
└── README.md             # This file
```

### 📚 Documentation

All documentation is located in the `konecta_erp/` directory:

- **[Main README](konecta_erp/README.md)** - Complete project overview and quick start
- **[Getting Started](konecta_erp/docs/GETTING_STARTED.md)** - Setup guide from zero to running
- **[Architecture](konecta_erp/docs/ARCHITECTURE.md)** - System architecture and design
- **[API Documentation](konecta_erp/docs/API.md)** - Complete API reference
- **[Deployment Guide](konecta_erp/docs/DEPLOYMENT.md)** - Deployment instructions
- **[Team Information](konecta_erp/TEAMS.md)** - Team structure and contributions

---

## ⚡ Quick Start

### Prerequisites

- Docker Desktop (Windows/macOS) or Docker Engine (Linux)
- Git
- 8 GB RAM minimum

### Get Started in 3 Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Konecta-ERP-Cycle-3/erb_full_project.git
   cd erb_full_project/konecta_erp
   ```

2. **Start all services**
   ```bash
   docker compose up -d --build
   ```

3. **Access the application**
   - API Gateway: http://localhost:8080
   - Swagger UI: http://localhost:8080/swagger/auth/index.html
   - Admin Login: `admin@konecta.com` / `Admin@123456`

For detailed setup instructions, see [Getting Started Guide](konecta_erp/docs/GETTING_STARTED.md).

---

## 🏗️ Architecture Highlights

### Microservices Architecture

- **8 Microservices**: 5 .NET services + 3 Spring Boot services
- **Event-Driven**: RabbitMQ for asynchronous communication
- **Service Discovery**: Consul for service registration
- **API Gateway**: Spring Cloud Gateway as single entry point
- **Containerized**: All services run in Docker containers

### Technology Stack

- **Backend**: .NET 9, Spring Boot 3.2
- **Frontend**: Angular 19 with PrimeNG
- **Database**: SQL Server 2022
- **Message Broker**: RabbitMQ 3.13
- **Service Discovery**: Consul 1.18
- **AI/ML**: XGBoost, Prophet models

---

## 👥 Team Collaboration

This project was developed by **26 team members** across **9 specialized teams**:

- 🚀 **Fullstack Team** - Backend and frontend development
- 🔧 **DevOps Team** - CI/CD and deployment automation
- ☁️ **Cloud Team** - Infrastructure and cloud resources
- 🤖 **AI/ML Team** - Machine learning models
- 🔒 **Cyber Security Team** - Security implementation
- 📊 **Data Analytics Team** - Analytics and visualization
- 💰 **Finance Team** - Finance module development
- 👥 **HR Team** - HR module development
- 📋 **Project Management Team** - Project coordination

See [TEAMS.md](konecta_erp/TEAMS.md) for complete team information and contributions.

---

## 📊 Project Statistics

- **Total Team Members**: 26
- **Total Teams**: 9 specialized teams
- **Microservices**: 8 services
- **AI/ML Models**: 2 models (HR Prediction, Prophet Forecasting)
- **Frontend**: Angular 19 application
- **Documentation**: Comprehensive guides and references
- **CI/CD**: Fully automated pipeline

---

## 🎯 Key Features

- ✅ **Microservices Architecture** - Scalable and maintainable
- ✅ **JWT Authentication** - Secure authentication with RBAC
- ✅ **Event-Driven Communication** - Asynchronous service communication
- ✅ **API Gateway** - Single entry point with routing
- ✅ **Service Discovery** - Automatic service registration
- ✅ **Docker Containerization** - Complete containerization
- ✅ **CI/CD Pipeline** - Automated testing and building
- ✅ **AI/ML Integration** - Predictive models
- ✅ **Comprehensive Documentation** - Complete guides and references

---

## 📖 Documentation Index

### Essential Guides

| Document | Description |
|---------|------------|
| [Main README](konecta_erp/README.md) | Project overview and quick start |
| [Getting Started](konecta_erp/docs/GETTING_STARTED.md) | Complete setup guide |
| [Architecture](konecta_erp/docs/ARCHITECTURE.md) | System architecture |
| [API Documentation](konecta_erp/docs/API.md) | API reference |
| [Development Guide](konecta_erp/docs/DEVELOPMENT.md) | Development workflows |
| [Deployment Guide](konecta_erp/docs/DEPLOYMENT.md) | Deployment instructions |

### Additional Resources

- [Quick Reference](konecta_erp/docs/QUICK_REFERENCE.md) - Common commands
- [Team Guide](konecta_erp/docs/TEAM_GUIDE.md) - Team collaboration
- [CI/CD Setup](konecta_erp/devops/CI_CD_QUICK_START.md) - Pipeline configuration
- [Secrets Setup](konecta_erp/devops/SECRETS_SETUP.md) - Credentials configuration
- [Troubleshooting](konecta_erp/devops/TROUBLESHOOTING.md) - Common issues

---

## 🔄 CI/CD Pipeline

The project includes a comprehensive CI/CD pipeline:

- ✅ **Testing** - Automated tests for all services
- ✅ **Building** - Docker image builds (10 images: 8 services + 2 AI models)
- ✅ **Pushing** - Images pushed to registry
- ⚠️ **Deployment** - Cloud deployment (not completed - see [Deployment Guide](konecta_erp/docs/DEPLOYMENT.md))

**Intended Strategy**:
- Image Registry: AWS ECR (currently Docker Hub as fallback)
- Testing: AWS EC2 instances
- Production: AWS ECS (Elastic Container Service)

---

## 🛠️ Technology Stack

### Backend
- .NET 9.0 - Microservices (C#)
- Spring Boot 3.2 - API Gateway, Config Server, Reporting
- Entity Framework Core - ORM
- ASP.NET Core Identity - Authentication

### Frontend
- Angular 19 - Frontend framework
- PrimeNG 19 - UI component library
- RxJS - Reactive programming

### Infrastructure
- SQL Server 2022 - Database
- RabbitMQ 3.13 - Message broker
- Consul 1.18 - Service discovery
- Docker & Docker Compose - Containerization

### AI/ML
- XGBoost - HR prediction model
- Prophet - Time series forecasting

---

## 📁 Repository Structure

```
erb_full_project/
│
├── konecta_erp/              # Main project
│   ├── backend/              # Backend microservices
│   │   ├── AuthenticationService/
│   │   ├── HrService/
│   │   ├── FinanceService/
│   │   ├── InventoryService/
│   │   ├── UserManagementService/
│   │   ├── ReportingService/
│   │   ├── ApiGateWay/
│   │   └── config/
│   ├── frontend/             # Angular application
│   ├── Ai/                   # AI/ML models
│   │   └── artifacts/
│   │       ├── hr_model/
│   │       └── prophet_model/
│   ├── devops/               # CI/CD and deployment
│   ├── docker/               # Docker configurations
│   ├── docs/                 # Documentation
│   ├── docker-compose.yml    # Development environment
│   └── README.md             # Main project README
│
├── .github/                  # GitHub Actions workflows
│   └── workflows/
│       └── ci-cd-pipeline.yml
│
└── README.md                 # This file
```

---

## 🎓 Project Highlights

### What Makes This Project Special

1. **Collaborative Development** - 26 team members across 9 specialized teams
2. **Modern Architecture** - Microservices with event-driven communication
3. **Technology Diversity** - Integration of .NET and Spring Boot
4. **AI/ML Integration** - Predictive models for business intelligence
5. **Comprehensive Documentation** - Complete guides and references
6. **Production-Ready** - Docker containerization and CI/CD pipeline
7. **Scalable Design** - Microservices architecture for independent scaling

---

## 🚀 Getting Started

### For Developers

1. Read the [Main README](konecta_erp/README.md)
2. Follow the [Getting Started Guide](konecta_erp/docs/GETTING_STARTED.md)
3. Review the [Architecture Documentation](konecta_erp/docs/ARCHITECTURE.md)
4. Check the [Development Guide](konecta_erp/docs/DEVELOPMENT.md)

### For Evaluators

1. Review the [Project Overview](konecta_erp/README.md)
2. Check [Team Contributions](konecta_erp/TEAMS.md)
3. Review [Architecture](konecta_erp/docs/ARCHITECTURE.md)
4. Test the system using [Quick Start](konecta_erp/docs/GETTING_STARTED.md)

---

## 📞 Support & Resources

- **Documentation**: [Complete Documentation Index](konecta_erp/docs/README.md)
- **Issues**: [GitHub Issues](https://github.com/Konecta-ERP-Cycle-3/erb_full_project/issues)
- **Troubleshooting**: [Troubleshooting Guide](konecta_erp/devops/TROUBLESHOOTING.md)

---

## 📄 License

[Add your license information here]

---

## 🙏 Acknowledgments

This project represents the collaborative effort of **26 dedicated team members** working across **9 specialized teams** to deliver a comprehensive Enterprise Resource Planning system. Special thanks to all contributors for their hard work and dedication.

---

<div align="center">

**Built with ❤️ by the Konecta ERP Team - Cycle 3**

[⭐ Star us on GitHub](https://github.com/Konecta-ERP-Cycle-3/erb_full_project)

**November 2025**

</div>

