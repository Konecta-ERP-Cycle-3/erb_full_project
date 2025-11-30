variable "ecs_execution_role_arn" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "ecs_service_sg" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

# Service Images
variable "authentication_service_image" {
  type = string
}

variable "user_management_service_image" {
  type = string
}

variable "finance_service_image" {
  type = string
}

variable "hr_service_image" {
  type = string
}

variable "inventory_service_image" {
  type = string
}

variable "api_gateway_image" {
  type = string
}

variable "reporting_service_image" {
  type = string
}

variable "config_server_image" {
  type = string
}

variable "hr_model_image" {
  type = string
}

variable "prophet_model_image" {
  type = string
}

# Service Desired Counts
variable "authentication_service_desired_count" {
  type    = number
  default = 2
}

variable "user_management_service_desired_count" {
  type    = number
  default = 2
}

variable "finance_service_desired_count" {
  type    = number
  default = 2
}

variable "hr_service_desired_count" {
  type    = number
  default = 2
}

variable "inventory_service_desired_count" {
  type    = number
  default = 2
}

variable "api_gateway_desired_count" {
  type    = number
  default = 2
}

variable "reporting_service_desired_count" {
  type    = number
  default = 2
}

variable "config_server_desired_count" {
  type    = number
  default = 1
}

variable "hr_model_desired_count" {
  type    = number
  default = 1
}

variable "prophet_model_desired_count" {
  type    = number
  default = 1
}

# Infrastructure Configuration
variable "rds_endpoint" {
  type        = string
  description = "RDS database endpoint"
}

variable "db_username" {
  type        = string
  description = "Database username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password"
}

variable "consul_host" {
  type        = string
  description = "Consul host URL (if using Consul for service discovery)"
  default     = ""
}
