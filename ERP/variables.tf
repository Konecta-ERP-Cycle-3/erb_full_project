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

variable "frontend_image" {
  description = "Docker image for frontend ECS task"
  type        = string
  default     = "nginx:latest"
}

variable "backend_image" {
  description = "Docker image for backend ECS task"
  type        = string
  default     = "postgres:13"
}
