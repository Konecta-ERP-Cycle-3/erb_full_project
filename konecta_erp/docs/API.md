# API Documentation

Complete API reference for Konecta ERP microservices.

---

## 🔐 Authentication

All protected endpoints require a JWT token in the Authorization header:

```
Authorization: Bearer <your-token>
```

### Getting a Token

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

### Using Token in Swagger

1. Click the **Authorize** button (🔓)
2. Enter: `Bearer <your-token>`
3. Click **Authorize**
4. All subsequent requests will include the token

---

## 📖 Swagger Documentation

All APIs are documented via Swagger UI, accessible through the API Gateway:

| Service | Swagger URL |
|---------|-------------|
| Authentication | http://localhost:8080/swagger/auth/index.html |
| HR | http://localhost:8080/swagger/hr/index.html |
| Finance | http://localhost:8080/swagger/finance/index.html |
| Inventory | http://localhost:8080/swagger/inventory/index.html |
| User Management | http://localhost:8080/swagger/users/index.html |
| Reporting | http://localhost:8080/swagger/reporting |

---

## 🔑 Authentication Service

**Base URL**: `http://localhost:8080/api/auth`

### Login

**POST** `/api/auth/login`

Authenticate user and receive JWT token.

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "Password123!"
}
```

**Response**: JWT token and user information

### Register

**POST** `/api/auth/register`

Register a new user account.

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "fullName": "John Doe"
}
```

### Update Password

**PUT** `/api/auth/update-password`

Update user password (requires authentication).

**Request Body**:
```json
{
  "oldPassword": "OldPassword123!",
  "newPassword": "NewPassword123!",
  "confirmPassword": "NewPassword123!"
}
```

### JWKS Endpoint

**GET** `/.well-known/jwks.json`

Get public keys for JWT validation.

---

## 👥 HR Service

**Base URL**: `http://localhost:8080/api`

### Employees

#### Get All Employees

**GET** `/api/employees`

**Query Parameters**:
- `page` (optional): Page number
- `pageSize` (optional): Items per page
- `search` (optional): Search term

**Response**:
```json
{
  "result": [
    {
      "id": "guid",
      "firstName": "John",
      "lastName": "Doe",
      "workEmail": "john.doe@konecta.com",
      "position": "Software Engineer",
      "departmentId": "guid",
      "hireDate": "2025-01-15T00:00:00Z",
      "salary": 75000.00
    }
  ]
}
```

#### Get Employee by ID

**GET** `/api/employees/{id}`

#### Create Employee

**POST** `/api/employees`

**Request Body**:
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "workEmail": "john.doe@konecta.com",
  "personalEmail": "john.personal@email.com",
  "phoneNumber": "+1234567890",
  "position": "Software Engineer",
  "departmentId": "guid",
  "hireDate": "2025-01-15T00:00:00Z",
  "salary": 75000.00
}
```

#### Update Employee

**PUT** `/api/employees/{id}`

#### Delete Employee

**DELETE** `/api/employees/{id}`

### Departments

#### Get All Departments

**GET** `/api/departments`

#### Get Department by ID

**GET** `/api/departments/{id}`

#### Create Department

**POST** `/api/departments`

**Request Body**:
```json
{
  "name": "Engineering",
  "description": "Software development department"
}
```

#### Update Department

**PUT** `/api/departments/{id}`

#### Delete Department

**DELETE** `/api/departments/{id}`

### Job Openings

#### Get All Job Openings

**GET** `/api/job-openings`

#### Create Job Opening

**POST** `/api/job-openings`

**Request Body**:
```json
{
  "title": "Senior Software Engineer",
  "departmentId": "guid",
  "description": "Job description here",
  "requirements": "Requirements here",
  "status": "Open"
}
```

---

## 💰 Finance Service

**Base URL**: `http://localhost:8080/api`

### Invoices

#### Get All Invoices

**GET** `/api/invoices`

#### Get Invoice by ID

**GET** `/api/invoices/{id}`

#### Create Invoice

**POST** `/api/invoices`

**Request Body**:
```json
{
  "invoiceNumber": "INV-001",
  "customerId": "guid",
  "amount": 1000.00,
  "dueDate": "2025-02-15T00:00:00Z",
  "status": "Pending"
}
```

#### Update Invoice

**PUT** `/api/invoices/{id}`

#### Delete Invoice

**DELETE** `/api/invoices/{id}`

### Expenses

#### Get All Expenses

**GET** `/api/expenses`

#### Create Expense

**POST** `/api/expenses`

**Request Body**:
```json
{
  "description": "Office supplies",
  "amount": 500.00,
  "category": "Office",
  "date": "2025-01-15T00:00:00Z"
}
```

### Budgets

#### Get All Budgets

**GET** `/api/budgets`

#### Create Budget

**POST** `/api/budgets`

**Request Body**:
```json
{
  "departmentId": "guid",
  "amount": 100000.00,
  "period": "2025-Q1",
  "category": "Operations"
}
```

---

## 📦 Inventory Service

**Base URL**: `http://localhost:8080/api`

### Inventory Items

#### Get All Items

**GET** `/api/inventory-items`

#### Get Item by ID

**GET** `/api/inventory-items/{id}`

#### Create Item

**POST** `/api/inventory-items`

**Request Body**:
```json
{
  "name": "Laptop",
  "sku": "LAP-001",
  "description": "Dell Laptop",
  "quantity": 10,
  "unitPrice": 1200.00,
  "category": "Electronics"
}
```

#### Update Item

**PUT** `/api/inventory-items/{id}`

#### Delete Item

**DELETE** `/api/inventory-items/{id}`

### Stock Movements

#### Get All Movements

**GET** `/api/stock-movements`

#### Create Movement

**POST** `/api/stock-movements`

**Request Body**:
```json
{
  "itemId": "guid",
  "quantity": 5,
  "movementType": "In",
  "reason": "Restock"
}
```

---

## 👤 User Management Service

**Base URL**: `http://localhost:8080/api`

### Users

#### Get All Users

**GET** `/api/users`

#### Get User by ID

**GET** `/api/users/{id}`

#### Update User

**PUT** `/api/users/{id}`

### Roles

#### Get All Roles

**GET** `/api/roles`

#### Create Role

**POST** `/api/roles`

**Request Body**:
```json
{
  "name": "Manager",
  "description": "Department manager role"
}
```

### Permissions

#### Get All Permissions

**GET** `/api/permissions`

#### Assign Permission to Role

**POST** `/api/roles/{roleId}/permissions`

---

## 📊 Reporting Service

**Base URL**: `http://localhost:8080/api`

### Reports

#### Get Financial Summary

**GET** `/api/reports/financial-summary`

#### Get HR Analytics

**GET** `/api/reports/hr-analytics`

#### Get Inventory Report

**GET** `/api/reports/inventory`

---

## 🔧 Using APIs with cURL

### Login Example

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@konecta.com",
    "password": "Admin@123456"
  }'
```

### Authenticated Request Example

```bash
curl -X GET http://localhost:8080/api/employees \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📝 Response Format

All APIs follow a consistent response format:

### Success Response

```json
{
  "result": { /* Data */ },
  "code": "200",
  "c_Message": "Success message",
  "s_Message": "Detailed success message"
}
```

### Error Response

```json
{
  "result": null,
  "code": "400",
  "c_Message": "Error message",
  "s_Message": "Detailed error message"
}
```

---

## 🔒 Authorization

### Roles

- **System Admin**: Full access to all services
- **HR Manager**: Access to HR and related services
- **Finance Manager**: Access to Finance services
- **Inventory Manager**: Access to Inventory services
- **Employee**: Limited access

### Permissions

Permissions are fine-grained and can be assigned per role. Common permissions:

- `employees.read`, `employees.write`, `employees.delete`
- `invoices.read`, `invoices.write`, `invoices.delete`
- `inventory.read`, `inventory.write`, `inventory.delete`

---

## 📚 Related Documentation

- [Getting Started](GETTING_STARTED.md) - Setup guide
- [Architecture](ARCHITECTURE.md) - System architecture
- [Development Guide](DEVELOPMENT.md) - Development workflows
- [Quick Reference](QUICK_REFERENCE.md) - Quick commands

---

**Last Updated**: January 2025

