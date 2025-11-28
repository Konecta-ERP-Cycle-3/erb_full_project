output "cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "api_gateway_service_name" {
  description = "API Gateway ECS Service Name"
  value       = aws_ecs_service.api_gateway.name
}

output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = try(aws_lb.main.dns_name, null)
}

output "backend_service_name" {
  description = "Backend ECS Service Name (deprecated - use api_gateway_service_name)"
  value       = null
}

output "frontend_service_name" {
  description = "Frontend ECS Service Name (deprecated)"
  value       = null
}