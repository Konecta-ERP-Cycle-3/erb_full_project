# ===========================
# ECR Repositories for All Services
# ===========================

resource "aws_ecr_repository" "authentication_service" {
  name                 = "${var.project_name}-${var.environment}-authentication-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-authentication-service"
    Environment = var.environment
    Service     = "authentication-service"
  }
}

resource "aws_ecr_repository" "user_management_service" {
  name                 = "${var.project_name}-${var.environment}-user-management-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-user-management-service"
    Environment = var.environment
    Service     = "user-management-service"
  }
}

resource "aws_ecr_repository" "finance_service" {
  name                 = "${var.project_name}-${var.environment}-finance-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-finance-service"
    Environment = var.environment
    Service     = "finance-service"
  }
}

resource "aws_ecr_repository" "hr_service" {
  name                 = "${var.project_name}-${var.environment}-hr-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-hr-service"
    Environment = var.environment
    Service     = "hr-service"
  }
}

resource "aws_ecr_repository" "inventory_service" {
  name                 = "${var.project_name}-${var.environment}-inventory-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-inventory-service"
    Environment = var.environment
    Service     = "inventory-service"
  }
}

resource "aws_ecr_repository" "api_gateway" {
  name                 = "${var.project_name}-${var.environment}-api-gateway"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-api-gateway"
    Environment = var.environment
    Service     = "api-gateway"
  }
}

resource "aws_ecr_repository" "reporting_service" {
  name                 = "${var.project_name}-${var.environment}-reporting-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-reporting-service"
    Environment = var.environment
    Service     = "reporting-service"
  }
}

resource "aws_ecr_repository" "config_server" {
  name                 = "${var.project_name}-${var.environment}-config-server"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-config-server"
    Environment = var.environment
    Service     = "config-server"
  }
}

resource "aws_ecr_repository" "hr_model" {
  name                 = "${var.project_name}-${var.environment}-hr-model"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-hr-model"
    Environment = var.environment
    Service     = "hr-model"
  }
}

resource "aws_ecr_repository" "prophet_model" {
  name                 = "${var.project_name}-${var.environment}-prophet-model"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-prophet-model"
    Environment = var.environment
    Service     = "prophet-model"
  }
}

