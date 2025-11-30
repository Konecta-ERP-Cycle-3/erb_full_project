variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "docker_hub_secret_arn" {
  description = "ARN of the Secrets Manager secret containing Docker Hub credentials"
  type        = string
  default     = ""
}
