variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

# ECS container ports
variable "frontend_port" {
  description = "Port for frontend ECS container"
  type        = number
  default     = 80
}

variable "backend_port" {
  description = "Port for backend ECS container"
  type        = number
  default     = 3000
}
