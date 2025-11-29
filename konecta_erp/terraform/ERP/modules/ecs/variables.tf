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

variable "frontend_image" { 
  type = string 
}

variable "backend_image"  { 
  type = string 
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
