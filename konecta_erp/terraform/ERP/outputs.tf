output "cluster_ids" {
  description = "IDs of all ECS clusters"
  value       = module.ecs.cluster_ids
}

output "frontend_service_names" {
  description = "Names of all frontend ECS services"
  value       = module.ecs.frontend_service_names
}

output "backend_service_names" {
  description = "Names of all backend ECS services"
  value       = module.ecs.backend_service_names
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
  value = module.rds.rds_endpoint
}
