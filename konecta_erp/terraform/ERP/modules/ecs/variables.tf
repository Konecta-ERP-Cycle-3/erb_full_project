variable "vpc_id" { type = string }

variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

variable "alb_sg_id" { type = string }
variable "api_gateway_sg_id" { type = string }
variable "backend_sg_id" { type = string }

variable "ecs_execution_role_arn" { type = string }

variable "project_name" { type = string }
variable "environment" { type = string }

variable "aws_region" { type = string }

variable "api_gateway_image" { type = string }
variable "config_server_image" { type = string }
variable "authentication_service_image" { type = string }
variable "user_management_service_image" { type = string }
variable "finance_service_image" { type = string }
variable "hr_service_image" { type = string }
variable "inventory_service_image" { type = string }
variable "reporting_service_image" { type = string }

variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}


variable "rds_endpoint" {
  type = string
}