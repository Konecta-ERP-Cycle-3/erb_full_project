output "frontend_ecs_sg_id" {
  description = "ECS Security Group ID (used for all microservices)"
  value       = aws_security_group.frontend_ecs.id
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds.id
}
