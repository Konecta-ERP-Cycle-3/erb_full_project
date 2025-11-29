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
  default     = "dbuser"
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

# Docker Images for All Services
variable "authentication_service_image" {
  description = "Docker image for authentication service"
  type        = string
  default     = "mohamed710/authentication-service:latest"
}

variable "user_management_service_image" {
  description = "Docker image for user management service"
  type        = string
  default     = "mohamed710/user-management-service:latest"
}

variable "finance_service_image" {
  description = "Docker image for finance service"
  type        = string
  default     = "mohamed710/finance-service:latest"
}

variable "hr_service_image" {
  description = "Docker image for HR service"
  type        = string
  default     = "mohamed710/hr-service:latest"
}

variable "inventory_service_image" {
  description = "Docker image for inventory service"
  type        = string
  default     = "mohamed710/inventory-service:latest"
}

variable "api_gateway_image" {
  description = "Docker image for API gateway"
  type        = string
  default     = "mohamed710/api-gateway:latest"
}

variable "reporting_service_image" {
  description = "Docker image for reporting service"
  type        = string
  default     = "mohamed710/reporting-service:latest"
}

variable "config_server_image" {
  description = "Docker image for config server"
  type        = string
  default     = "mohamed710/config-server:latest"
}

variable "hr_model_image" {
  description = "Docker image for HR model (AI)"
  type        = string
  default     = "mohamed710/hr-model:latest"
}

variable "prophet_model_image" {
  description = "Docker image for Prophet model (AI)"
  type        = string
  default     = "mohamed710/prophet-model:latest"
}
