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

# API Gateway Security Group (Public) - Entry Point
resource "aws_security_group" "api_gateway" {
  name_prefix = "${var.project_name}-${var.environment}-api-gateway-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-api-gateway-sg"
  }
}

# Backend ECS Security Group (Private) - Allows inter-service communication
resource "aws_security_group" "backend_ecs" {
  name_prefix = "${var.project_name}-${var.environment}-backend-ecs-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 7280 # Authentication Service
    to_port         = 7280
    protocol        = "tcp"
    security_groups = [aws_security_group.api_gateway.id]
  }

  ingress {
    from_port       = 5078 # User Management Service
    to_port         = 5078
    protocol        = "tcp"
    security_groups = [aws_security_group.api_gateway.id]
  }

  ingress {
    from_port       = 5003 # Finance Service
    to_port         = 5003
    protocol        = "tcp"
    security_groups = [aws_security_group.api_gateway.id, aws_security_group.backend_ecs.id]
  }

  ingress {
    from_port       = 5005 # HR Service
    to_port         = 5005
    protocol        = "tcp"
    security_groups = [aws_security_group.api_gateway.id, aws_security_group.backend_ecs.id]
  }

  ingress {
    from_port       = 5020 # Inventory Service
    to_port         = 5020
    protocol        = "tcp"
    security_groups = [aws_security_group.api_gateway.id, aws_security_group.backend_ecs.id]
  }

  ingress {
    from_port       = 8085 # Reporting Service
    to_port         = 8085
    protocol        = "tcp"
    security_groups = [aws_security_group.api_gateway.id, aws_security_group.backend_ecs.id]
  }

  ingress {
    from_port       = 8888 # Config Server
    to_port         = 8888
    protocol        = "tcp"
    security_groups = [aws_security_group.api_gateway.id, aws_security_group.backend_ecs.id]
  }

  ingress {
    from_port       = 5672 # RabbitMQ AMQP
    to_port         = 5672
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_ecs.id]
  }

  ingress {
    from_port       = 8500 # Consul
    to_port         = 8500
    protocol        = "tcp"
    security_groups = [aws_security_group.api_gateway.id, aws_security_group.backend_ecs.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-backend-ecs-sg"
  }
}

# RDS Security Group (Private) - SQL Server
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_ecs.id] # From backend services
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
    cidr_blocks = ["0.0.0.0/0"] # You can restrict this later
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow remote SSH
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
    cidr_blocks = ["0.0.0.0/0"] # You can restrict this later
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
