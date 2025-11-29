# modules/sg/sg.tf
# ALB Security Group
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

# Frontend ECS Security Group (Public) - ADDED EGRESS TO BACKEND
resource "aws_security_group" "frontend_ecs" {
  name_prefix = "${var.project_name}-${var.environment}-frontend-ecs-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allows frontend to call backend internally
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-frontend-ecs-sg"
  }
}

# Backend ECS Security Group (Private) - FIXED: Ingress from frontend, not RDS
resource "aws_security_group" "backend_ecs" {
  name_prefix = "${var.project_name}-${var.environment}-backend-ecs-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3000  # UPDATED: API port
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_ecs.id]  # FIXED: From frontend, not RDS
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allows outbound to RDS/internet
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-backend-ecs-sg"
  }
}

# RDS Security Group (Private)
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_ecs.id]  # Correct: From backend
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  }
}
resource "aws_security_group" "influxdb_sg" {
  name        = "${var.project_name}-${var.environment}-influxdb-sg"
  description = "Security group for InfluxDB EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow InfluxDB access"
    from_port   = 8086
    to_port     = 8086
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]     # You can restrict this later
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]     # Allow remote SSH
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "grafana_sg" {
  name        = "${var.project_name}-${var.environment}-grafana-sg"
  description = "Security group for Grafana EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow Grafana access (port 3000)"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]    # You can restrict this later
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
