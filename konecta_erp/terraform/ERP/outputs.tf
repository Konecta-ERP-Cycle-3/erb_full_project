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

output "api_gateway_service_name" {
  description = "API Gateway ECS Service Name"
  value       = module.ecs.api_gateway_service_name
}

output "alb_dns_name" {
  description = "ALB DNS Name"
  value       = module.ecs.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}