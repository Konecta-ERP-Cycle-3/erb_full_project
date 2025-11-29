output "cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "frontend_service_name" {
  value = aws_ecs_service.frontend.name
}

output "backend_service_name" {
  value = aws_ecs_service.backend.name
}

output "alb_dns_name" {
  value = aws_lb.frontend.dns_name
}

# NEW OUTPUTS (if needed)
output "frontend_desired_count" {
  value = aws_ecs_service.frontend.desired_count
}

output "backend_desired_count" {
  value = aws_ecs_service.backend.desired_count
}
