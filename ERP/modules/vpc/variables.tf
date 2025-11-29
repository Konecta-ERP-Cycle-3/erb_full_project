# modules/vpc/variables.tf
variable "vpc_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}