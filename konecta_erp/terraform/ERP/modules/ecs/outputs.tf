output "cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.main.name
}

output "alb_dns_name" {
  description = "ALB DNS Name for API Gateway"
  value       = aws_lb.alb.dns_name
}

output "service_discovery_namespace" {
  description = "Service Discovery Namespace"
  value       = aws_service_discovery_private_dns_namespace.this.name
}

output "api_gateway_service_name" {
  description = "API Gateway ECS Service Name"
  value       = aws_ecs_service.api_gateway.name
}

output "authentication_service_name" {
  description = "Authentication Service ECS Service Name"
  value       = aws_ecs_service.authentication_service.name
}

output "hr_service_name" {
  description = "HR Service ECS Service Name"
  value       = aws_ecs_service.hr_service.name
}

output "finance_service_name" {
  description = "Finance Service ECS Service Name"
  value       = aws_ecs_service.finance_service.name
}

output "inventory_service_name" {
  description = "Inventory Service ECS Service Name"
  value       = aws_ecs_service.inventory_service.name
}

output "user_management_service_name" {
  description = "User Management Service ECS Service Name"
  value       = aws_ecs_service.user_management_service.name
}

output "reporting_service_name" {
  description = "Reporting Service ECS Service Name"
  value       = aws_ecs_service.reporting_service.name
}

output "config_server_service_name" {
  description = "Config Server ECS Service Name"
  value       = aws_ecs_service.config_server.name
}
