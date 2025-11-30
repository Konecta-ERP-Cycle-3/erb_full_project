# ===========================
# ALB Security Group
# ===========================
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
}

# ===========================
# Unified ECS Security Group (for all microservices)
# ===========================
resource "aws_security_group" "frontend_ecs" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-sg-"
  vpc_id      = var.vpc_id

  # Allow traffic from ALB to API Gateway
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Allow inter-service communication on all service ports
  ingress {
    from_port       = 7280
    to_port         = 7280
    protocol        = "tcp"
    self            = true
    description     = "Authentication service"
  }

  ingress {
    from_port       = 5005
    to_port         = 5005
    protocol        = "tcp"
    self            = true
    description     = "HR service"
  }

  ingress {
    from_port       = 5003
    to_port         = 5003
    protocol        = "tcp"
    self            = true
    description     = "Finance service"
  }

  ingress {
    from_port       = 5020
    to_port         = 5020
    protocol        = "tcp"
    self            = true
    description     = "Inventory service"
  }

  ingress {
    from_port       = 5078
    to_port         = 5078
    protocol        = "tcp"
    self            = true
    description     = "User management service"
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    self            = true
    description     = "API Gateway"
  }

  ingress {
    from_port       = 8085
    to_port         = 8085
    protocol        = "tcp"
    self            = true
    description     = "Reporting service"
  }

  ingress {
    from_port       = 8888
    to_port         = 8888
    protocol        = "tcp"
    self            = true
    description     = "Config server"
  }

  ingress {
    from_port       = 8000
    to_port         = 8001
    protocol        = "tcp"
    self            = true
    description     = "ML model services"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ecs-sg"
  }
}

# ===========================
# RDS Security Group
# ===========================
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_ecs.id]
    description     = "Allow ECS services to access RDS"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  }
}

