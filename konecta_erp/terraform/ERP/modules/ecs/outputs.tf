output "cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "api_gateway_service_name" {
  value = aws_ecs_service.api_gateway.name
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "api_gateway_desired_count" {
  value = aws_ecs_service.api_gateway.desired_count
}
