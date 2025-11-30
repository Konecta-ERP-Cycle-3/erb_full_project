# ECS Outputs
output "cluster_id" {
  description = "ECS Cluster ID"
  value       = module.ecs.cluster_id
}

output "cluster_name" {
  description = "ECS Cluster Name"
  value       = module.ecs.cluster_name
}

output "alb_dns_name" {
  description = "ALB DNS Name (API Gateway endpoint)"
  value       = module.ecs.alb_dns_name
}

output "service_discovery_namespace" {
  description = "Service Discovery Namespace for internal service communication"
  value       = module.ecs.service_discovery_namespace
}

# Service Names
output "api_gateway_service_name" {
  description = "API Gateway Service Name"
  value       = module.ecs.api_gateway_service_name
}

output "authentication_service_name" {
  description = "Authentication Service Name"
  value       = module.ecs.authentication_service_name
}

# VPC outputs
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

# RDS output
output "rds_endpoint" {
  description = "RDS Database Endpoint"
  value       = module.rds.rds_endpoint
}
