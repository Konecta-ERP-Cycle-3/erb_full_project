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

# Service Images
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
  description = "Docker image for API Gateway"
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
  description = "Docker image for HR model service"
  type        = string
  default     = "mohamed710/hr-model:latest"
}

variable "prophet_model_image" {
  description = "Docker image for Prophet model service"
  type        = string
  default     = "mohamed710/prophet-model:latest"
}

variable "num_clusters" {
  description = "Number of ECS clusters to create (for high availability)"
  type        = number
  default     = 1
}

# Service Desired Counts
variable "authentication_service_desired_count" {
  description = "Number of desired authentication service tasks"
  type        = number
  default     = 2
}

variable "user_management_service_desired_count" {
  description = "Number of desired user management service tasks"
  type        = number
  default     = 2
}

variable "finance_service_desired_count" {
  description = "Number of desired finance service tasks"
  type        = number
  default     = 2
}

variable "hr_service_desired_count" {
  description = "Number of desired HR service tasks"
  type        = number
  default     = 2
}

variable "inventory_service_desired_count" {
  description = "Number of desired inventory service tasks"
  type        = number
  default     = 2
}

variable "api_gateway_desired_count" {
  description = "Number of desired API Gateway tasks"
  type        = number
  default     = 2
}

variable "reporting_service_desired_count" {
  description = "Number of desired reporting service tasks"
  type        = number
  default     = 2
}

variable "config_server_desired_count" {
  description = "Number of desired config server tasks"
  type        = number
  default     = 1
}

variable "hr_model_desired_count" {
  description = "Number of desired HR model service tasks"
  type        = number
  default     = 1
}

variable "prophet_model_desired_count" {
  description = "Number of desired Prophet model service tasks"
  type        = number
  default     = 1
}

# Docker Hub Authentication (to avoid rate limits)
variable "docker_hub_username" {
  description = "Docker Hub username for authentication"
  type        = string
  default     = ""
}

variable "docker_hub_password" {
  description = "Docker Hub password or access token"
  type        = string
  sensitive   = true
  default     = ""
}
