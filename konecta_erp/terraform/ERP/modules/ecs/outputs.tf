output "cluster_ids" {
  description = "IDs of all ECS clusters"
  value       = [for c in aws_ecs_cluster.main : c.id]
}

output "frontend_service_names" {
  description = "Names of all frontend ECS services"
  value       = [for s in aws_ecs_service.frontend : s.name]
}

output "backend_service_names" {
  description = "Names of all backend ECS services"
  value       = [for s in aws_ecs_service.backend : s.name]
}

output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = aws_lb.alb.dns_name
}
