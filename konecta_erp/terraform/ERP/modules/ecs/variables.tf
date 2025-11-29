variable "vpc_id" { 
  type = string 
}

variable "public_subnet_ids" { 
  type = list(string) 
}

variable "private_subnet_ids" { 
  type = list(string) 
}

variable "alb_sg_id" { 
  type = string 
}

variable "frontend_sg_id" { 
  type = string 
}

variable "backend_sg_id" { 
  type = string 
}

variable "ecs_execution_role_arn" { 
  type = string 
}

variable "project_name" { 
  type = string 
}

variable "environment"  { 
  type = string 
}

variable "aws_region" { 
  type = string 
}

# Docker Images for All Services
variable "authentication_service_image" {
  type = string
  description = "Docker image for authentication service"
}

variable "user_management_service_image" {
  type = string
  description = "Docker image for user management service"
}

variable "finance_service_image" {
  type = string
  description = "Docker image for finance service"
}

variable "hr_service_image" {
  type = string
  description = "Docker image for hr service"
}

variable "inventory_service_image" {
  type = string
  description = "Docker image for inventory service"
}

variable "api_gateway_image" {
  type = string
  description = "Docker image for API gateway"
}

variable "reporting_service_image" {
  type = string
  description = "Docker image for reporting service"
}

variable "config_server_image" {
  type = string
  description = "Docker image for config server"
}

variable "hr_model_image" {
  type = string
  description = "Docker image for HR model (AI)"
}

variable "prophet_model_image" {
  type = string
  description = "Docker image for Prophet model (AI)"
}

variable "db_username" { 
  type = string 
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "rds_endpoint" { 
  type = string 
}

# NEW OPTIONAL VARIABLES (Counts)
variable "frontend_desired_count" {
  type    = number
  default = 2
}

variable "backend_desired_count" {
  type    = number
  default = 8
}
