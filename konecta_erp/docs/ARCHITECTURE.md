# Konecta ERP Architecture

This document provides a comprehensive overview of the Konecta ERP system architecture, design decisions, and technical implementation.

---

## 🏗️ Architecture Overview

Konecta ERP follows a **microservices architecture** pattern, enabling independent development, deployment, and scaling of services.

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Frontend (Angular 19)                     │
│                  http://localhost:4200                      │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│              API Gateway (Spring Cloud Gateway)             │
│                 http://localhost:8080                       │
│  • Request Routing                                          │
│  • Load Balancing                                           │
│  • JWT Validation                                           │
│  • CORS Handling                                            │
└──────────────┬───────────────────────────────┬──────────────┘
               │                               │
    ┌──────────┴──────────┐      ┌────────────┴────────────┐
    │                     │      │                         │
┌───▼──────────┐  ┌───────▼──────┐  ┌──────────▼──────────┐
│ .NET Services│  │ Java Services │  │ Infrastructure      │
├──────────────┤  ├───────────────┤  ├─────────────────────┤
│ Auth (7280)  │  │ Gateway (8080)│  │ SQL Server (1433)   │
│ HR (5005)    │  │ Config (8888) │  │ RabbitMQ (5672)     │
│ Finance(5003)│  │ Reporting(8085)│ │ Consul (8500)       │
│ Inventory(5020)│               │  │ MailHog (8025)      │
│ User Mgmt(5078)│               │  │                     │
└──────────────┘  └───────────────┘  └─────────────────────┘
```

---

## 🔧 Microservices

### .NET Services

#### Authentication Service
- **Port**: 7280
- **Database**: `Konecta_Auth`
- **Technology**: .NET 9, ASP.NET Core Identity
- **Responsibilities**:
  - User authentication and authorization
  - JWT token generation and validation
  - Password management
  - JWKS endpoint for token validation
  - Integration with User Management Service

#### HR Service
- **Port**: 5005
- **Database**: `Konecta_HR`
- **Technology**: .NET 9, Entity Framework Core
- **Responsibilities**:
  - Employee lifecycle management
  - Department management
  - Job openings and recruitment
  - Publishes employee events to RabbitMQ

#### Finance Service
- **Port**: 5003
- **Database**: `Konecta_Finance`
- **Technology**: .NET 9, Entity Framework Core
- **Responsibilities**:
  - Invoice management
  - Expense tracking
  - Budget management
  - Payroll processing
  - Employee compensation

#### Inventory Service
- **Port**: 5020
- **Database**: `Konecta_Inventory`
- **Technology**: .NET 9, Entity Framework Core
- **Responsibilities**:
  - Product catalog management
  - Stock tracking and operations
  - Inventory movements
  - Low stock alerts

#### User Management Service
- **Port**: 5078
- **Database**: `Konecta_UserManagement`
- **Technology**: .NET 9, Entity Framework Core
- **Responsibilities**:
  - User directory management
  - Role and permission management
  - Authorization profile generation
  - RBAC implementation

### Java Services

#### API Gateway
- **Port**: 8080
- **Technology**: Spring Cloud Gateway, Spring Boot 3.2
- **Responsibilities**:
  - Single entry point for all requests
  - Request routing to microservices
  - JWT token validation
  - Load balancing
  - Swagger UI aggregation
  - CORS configuration

#### Config Server
- **Port**: 8888
- **Technology**: Spring Cloud Config, Spring Boot 3.2
- **Responsibilities**:
  - Centralized configuration management
  - Environment-specific settings
  - Dynamic configuration updates

#### Reporting Service
- **Port**: 8085
- **Technology**: Spring Boot 3.2, Spring Data JPA
- **Responsibilities**:
  - Cross-service reporting
  - Analytics and dashboards
  - PDF/Excel export
  - Data aggregation

---

## 🗄️ Database Architecture

### Database per Service Pattern

Each microservice has its own database, ensuring data isolation and independent scaling:

| Service | Database | Purpose |
|---------|----------|---------|
| Authentication | `Konecta_Auth` | User accounts, roles, claims |
| HR | `Konecta_HR` | Employees, departments, job openings |
| Finance | `Konecta_Finance` | Invoices, expenses, budgets, payroll |
| Inventory | `Konecta_Inventory` | Products, stock, movements |
| User Management | `Konecta_UserManagement` | User profiles, roles, permissions |

### Database Technology

- **Primary Database**: SQL Server 2022
- **ORM**: Entity Framework Core (for .NET services)
- **ORM**: Spring Data JPA (for Java services)

---

## 🔄 Communication Patterns

### Synchronous Communication

- **HTTP/REST**: Primary communication method
- **API Gateway**: Routes requests to appropriate services
- **Service-to-Service**: Direct HTTP calls when needed

### Asynchronous Communication

- **Message Broker**: RabbitMQ 3.13
- **Event-Driven**: Services publish/consume events
- **Event Types**:
  - Employee Created
  - Employee Updated
  - Compensation Created
  - User Role Changed

### Service Discovery

- **Tool**: Consul 1.18
- **Purpose**: Service registration and discovery
- **Health Checks**: Automatic service health monitoring

---

## 🔐 Security Architecture

### Authentication

- **Method**: JWT (JSON Web Tokens)
- **Algorithm**: RS256 (RSA with SHA-256)
- **Token Type**: Bearer tokens
- **Validation**: Via JWKS endpoint

### Authorization

- **Model**: Role-Based Access Control (RBAC)
- **Implementation**: Fine-grained permissions
- **Token Claims**: Roles and permissions in JWT

### Security Layers

1. **API Gateway**: First line of defense, JWT validation
2. **Service Level**: Additional authorization checks
3. **Database**: Row-level security where applicable

---

## 📦 Infrastructure Components

### SQL Server
- **Version**: 2022
- **Port**: 1433
- **Purpose**: Primary database for all services
- **Features**: Multiple databases, automatic seeding

### RabbitMQ
- **Version**: 3.13
- **Ports**: 5672 (AMQP), 15672 (Management UI)
- **Purpose**: Message broker for event-driven communication
- **Features**: Queues, exchanges, routing

### Consul
- **Version**: 1.18
- **Port**: 8500
- **Purpose**: Service discovery and health checking
- **Features**: Service registration, health monitoring, KV store

### MailHog
- **Ports**: 1025 (SMTP), 8025 (Web UI)
- **Purpose**: Email testing in development
- **Features**: Email capture, web UI for viewing

---

## 🎨 Frontend Architecture

### Technology Stack

- **Framework**: Angular 19
- **UI Library**: PrimeNG 19
- **State Management**: RxJS
- **HTTP Client**: Angular HttpClient

### Architecture Pattern

- **Component-Based**: Modular components
- **Service Layer**: Business logic in services
- **Routing**: Angular Router for navigation
- **State**: RxJS Observables for reactive state

---

## 🚀 Deployment Architecture

### Development

- **Orchestration**: Docker Compose
- **All Services**: Run in containers
- **Networking**: Docker bridge network
- **Volumes**: Persistent data storage

### Production

- **Orchestration**: Docker Compose (or Kubernetes)
- **Image Registry**: Docker Hub
- **Deployment**: Automated via CI/CD
- **Environment**: AWS EC2 (or similar)

---

## 📊 Data Flow

### User Request Flow

```
1. User → Frontend (Angular)
2. Frontend → API Gateway (HTTP)
3. API Gateway → Validates JWT
4. API Gateway → Routes to Microservice
5. Microservice → Processes Request
6. Microservice → Database (if needed)
7. Microservice → Response
8. API Gateway → Response to Frontend
9. Frontend → Display to User
```

### Event Flow

```
1. Service A → Publishes Event to RabbitMQ
2. RabbitMQ → Routes to Queue
3. Service B → Consumes Event
4. Service B → Processes Event
5. Service B → Updates Database
```

---

## 🤖 AI/ML Components

### HR Prediction Model (XGBoost)

**Location**: `Ai/artifacts/hr_model/`

**Components**:
- `hr_xgb_model.pkl` - Trained XGBoost model
- `hr_scaler.pkl` - Feature scaler
- `hr_feature_columns.csv` - Feature columns
- `Dockerfile` - Container configuration

**Purpose**: Predicts HR-related metrics and outcomes

**Deployment**:
```bash
docker pull mohamed710/hr-image:latest
docker run mohamed710/hr-image:latest
```

### Prophet Forecasting Model

**Location**: `Ai/artifacts/prophet_model/`

**Components**:
- `prophet_model.pkl` - Trained Prophet model
- `prophet_forecast.csv` - Forecast results
- `Dockerfile` - Container configuration

**Purpose**: Time series forecasting for business metrics

**Deployment**:
```bash
docker pull mohamed710/prophet-image:latest
docker run mohamed710/prophet-image:latest
```

### AI/ML Integration

- Models are containerized for easy deployment
- Can be integrated with Reporting Service
- Used for predictive analytics and forecasting
- Supports HR predictions and business forecasting

---

## 🔍 Design Patterns

### Patterns Used

1. **Microservices Pattern**: Independent, deployable services
2. **API Gateway Pattern**: Single entry point
3. **Database per Service**: Data isolation
4. **Event-Driven Architecture**: Asynchronous communication
5. **Service Discovery**: Dynamic service location
6. **Circuit Breaker**: Fault tolerance (via API Gateway)
7. **Repository Pattern**: Data access abstraction

---

## 📈 Scalability

### Horizontal Scaling

- Each service can be scaled independently
- Load balancing via API Gateway
- Stateless services for easy scaling

### Vertical Scaling

- Database scaling per service
- Resource allocation per service
- Independent performance tuning

---

## 🔄 Monitoring & Observability

### Health Checks

- **Consul**: Service health monitoring
- **Docker**: Container health checks
- **Services**: Health endpoints

### Logging

- **Format**: Structured logging
- **Aggregation**: Docker logs
- **Levels**: Debug, Info, Warning, Error

---

## 🎯 Design Decisions

### Why Microservices?

- **Scalability**: Independent scaling of services
- **Technology Diversity**: .NET and Java services
- **Team Autonomy**: Independent development
- **Fault Isolation**: Failure in one service doesn't affect others

### Why API Gateway?

- **Single Entry Point**: Simplified client interaction
- **Centralized Security**: JWT validation in one place
- **Request Routing**: Intelligent routing
- **Aggregation**: Swagger UI aggregation

### Why Event-Driven?

- **Decoupling**: Services don't need direct dependencies
- **Scalability**: Asynchronous processing
- **Resilience**: Event replay capabilities
- **Flexibility**: Easy to add new consumers

---

## 📚 Related Documentation

- [Getting Started](GETTING_STARTED.md) - Setup guide
- [Development Guide](DEVELOPMENT.md) - Development workflows
- [API Documentation](API.md) - API reference
- [Deployment Guide](DEPLOYMENT.md) - Deployment instructions

---

**Last Updated**: November 2024  
**Architecture Version**: 1.0

