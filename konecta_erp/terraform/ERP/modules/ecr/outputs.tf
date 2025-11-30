output "authentication_service_repository_url" {
  description = "ECR repository URL for authentication service"
  value       = aws_ecr_repository.authentication_service.repository_url
}

output "user_management_service_repository_url" {
  description = "ECR repository URL for user management service"
  value       = aws_ecr_repository.user_management_service.repository_url
}

output "finance_service_repository_url" {
  description = "ECR repository URL for finance service"
  value       = aws_ecr_repository.finance_service.repository_url
}

output "hr_service_repository_url" {
  description = "ECR repository URL for HR service"
  value       = aws_ecr_repository.hr_service.repository_url
}

output "inventory_service_repository_url" {
  description = "ECR repository URL for inventory service"
  value       = aws_ecr_repository.inventory_service.repository_url
}

output "api_gateway_repository_url" {
  description = "ECR repository URL for API Gateway"
  value       = aws_ecr_repository.api_gateway.repository_url
}

output "reporting_service_repository_url" {
  description = "ECR repository URL for reporting service"
  value       = aws_ecr_repository.reporting_service.repository_url
}

output "config_server_repository_url" {
  description = "ECR repository URL for config server"
  value       = aws_ecr_repository.config_server.repository_url
}

output "hr_model_repository_url" {
  description = "ECR repository URL for HR model"
  value       = aws_ecr_repository.hr_model.repository_url
}

output "prophet_model_repository_url" {
  description = "ECR repository URL for Prophet model"
  value       = aws_ecr_repository.prophet_model.repository_url
}

