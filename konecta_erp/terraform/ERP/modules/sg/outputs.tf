# modules/sg/outputs.tf
output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "api_gateway_sg_id" {
  value = aws_security_group.api_gateway.id
}

output "backend_sg_id" {
  value = aws_security_group.backend_ecs.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}


