variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnets CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "Private subnets CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "project_name" {
  description = "Project name for resources"
  type        = string
  default     = "konecta-ass1"
}

variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
  default     = "dev"
}

variable "db_username" {
  description = "RDS database username"
  type        = string
  default     = "dbuser"  # CHANGED: From "admin" to avoid reserved word
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "api_gateway_image" {
  description = "Docker image for API Gateway"
  type        = string
  default     = "mohamed710/api-gateway:latest"
}

variable "config_server_image" {
  description = "Docker image for Config Server"
  type        = string
  default     = "mohamed710/config-server:latest"
}

variable "authentication_service_image" {
  description = "Docker image for Authentication Service"
  type        = string
  default     = "mohamed710/authentication-service:latest"
}

variable "user_management_service_image" {
  description = "Docker image for User Management Service"
  type        = string
  default     = "mohamed710/user-management-service:latest"
}

variable "finance_service_image" {
  description = "Docker image for Finance Service"
  type        = string
  default     = "mohamed710/finance-service:latest"
}

variable "hr_service_image" {
  description = "Docker image for HR Service"
  type        = string
  default     = "mohamed710/hr-service:latest"
}

variable "inventory_service_image" {
  description = "Docker image for Inventory Service"
  type        = string
  default     = "mohamed710/inventory-service:latest"
}

variable "reporting_service_image" {
  description = "Docker image for Reporting Service"
  type        = string
  default     = "mohamed710/reporting-service:latest"
}


