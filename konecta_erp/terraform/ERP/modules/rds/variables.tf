variable "project_name" { type = string }
variable "environment"  { type = string }

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_sg_id" {
  type = string
}

variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
# Note: db_name not used for SQL Server - databases are created via EF migrations
# variable "db_name"     { type = string }
