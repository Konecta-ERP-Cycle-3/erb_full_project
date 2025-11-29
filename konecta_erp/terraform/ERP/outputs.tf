# terraform/outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "cluster_id" {
  description = "ECS Cluster ID"
  value       = module.ecs.cluster_id
}

output "frontend_service_name" {
  description = "Frontend ECS Service Name"
  value       = module.ecs.frontend_service_name
}

output "backend_service_name" {
  description = "Backend ECS Service Name"
  value       = module.ecs.backend_service_name
}

output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = module.ecs.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}