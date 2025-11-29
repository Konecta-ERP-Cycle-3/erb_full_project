
# ===========================
# ECS CLUSTER
# ===========================
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ===========================
# CLOUDWATCH LOG GROUP
# ===========================
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 7
}

# ===========================
# SERVICE DISCOVERY NAMESPACE
# ===========================
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.project_name}.local"
  description = "Service discovery namespace for ${var.project_name}"
  vpc         = var.vpc_id
}

# ===========================
# LOCALS FOR COMMON ENV VARIABLES
# ===========================
locals {
  common_env_vars = [
    { name = "SPRING__CLOUD__CONFIG__URI", value = "http://config-server.${aws_service_discovery_private_dns_namespace.main.name}:8888" },
    { name = "SPRING__CLOUD__CONFIG__FAILFAST", value = "true" },
    { name = "Consul__Host", value = "http://consul.${aws_service_discovery_private_dns_namespace.main.name}:8500" }
  ]
}

# ===========================
# ECS TASK DEFINITIONS
# ===========================

# ---------------------------
# Authentication Service
# ---------------------------
resource "aws_ecs_task_definition" "authentication_service" {
  family                   = "${var.project_name}-authentication-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([{
    name      = "authentication-service"
    image     = var.authentication_service_image
    essential = true
    portMappings = [{ containerPort = 7280, hostPort = 7280 }]
    environment = concat(
      [
        { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
        { name = "ASPNETCORE_URLS", value = "http://+:7280" },
        { name = "SPRING__APPLICATION__NAME", value = "authentication-service" },
        { name = "ConnectionStrings__DefaultConnection", value = "Server=${replace(var.rds_endpoint, ":1433", "")},1433;Database=Konecta_Auth;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;MultipleActiveResultSets=True;" },
        { name = "RabbitMQ__HostName", value = "rabbitmq.${aws_service_discovery_private_dns_namespace.main.name}" },
        { name = "RabbitMQ__Port", value = "5672" },
        { name = "RabbitMQ__UserName", value = "guest" },
        { name = "RabbitMQ__Password", value = "guest" },
        { name = "RabbitMQ__VirtualHost", value = "/" },
        { name = "RabbitMQ__Exchange", value = "konecta.erp" }
      ],
      local.common_env_vars
    )
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "authentication-service"
      }
    }
  }])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

# ---------------------------
# User Management Service
# ---------------------------
resource "aws_ecs_task_definition" "user_management_service" {
  family                   = "${var.project_name}-user-management-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([{
    name      = "user-management-service"
    image     = var.user_management_service_image
    essential = true
    portMappings = [{ containerPort = 5078, hostPort = 5078 }]
    environment = concat(
      [
        { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
        { name = "ASPNETCORE_URLS", value = "http://+:5078" },
        { name = "SPRING__APPLICATION__NAME", value = "user-management-service" },
        { name = "ConnectionStrings__DefaultConnection", value = "Server=${replace(var.rds_endpoint, ":1433", "")},1433;Database=Konecta_UserManagement;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;MultipleActiveResultSets=True;" },
        { name = "RabbitMQ__HostName", value = "rabbitmq.${aws_service_discovery_private_dns_namespace.main.name}" },
        { name = "RabbitMQ__Port", value = "5672" },
        { name = "RabbitMQ__UserName", value = "guest" },
        { name = "RabbitMQ__Password", value = "guest" },
        { name = "RabbitMQ__VirtualHost", value = "/" },
        { name = "RabbitMQ__Exchange", value = "konecta.erp" }
      ],
      local.common_env_vars
    )
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "user-management-service"
      }
    }
  }])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

# ---------------------------
# Finance Service
# ---------------------------
resource "aws_ecs_task_definition" "finance_service" {
  family                   = "${var.project_name}-finance-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([{
    name      = "finance-service"
    image     = var.finance_service_image
    essential = true
    portMappings = [{ containerPort = 5003, hostPort = 5003 }]
    environment = concat(
      [
        { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
        { name = "ASPNETCORE_URLS", value = "http://+:5003" },
        { name = "SPRING__APPLICATION__NAME", value = "finance-service" },
        { name = "ConnectionStrings__DefaultConnection", value = "Server=${replace(var.rds_endpoint, ":1433", "")},1433;Database=Konecta_Finance;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;MultipleActiveResultSets=True;" },
        { name = "RabbitMQ__HostName", value = "rabbitmq.${aws_service_discovery_private_dns_namespace.main.name}" },
        { name = "RabbitMQ__Port", value = "5672" },
        { name = "RabbitMQ__UserName", value = "guest" },
        { name = "RabbitMQ__Password", value = "guest" },
        { name = "RabbitMQ__VirtualHost", value = "/" },
        { name = "RabbitMQ__Exchange", value = "konecta.erp" }
      ],
      local.common_env_vars
    )
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "finance-service"
      }
    }
  }])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

# ---------------------------
# HR Service
# ---------------------------
resource "aws_ecs_task_definition" "hr_service" {
  family                   = "${var.project_name}-hr-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([{
    name      = "hr-service"
    image     = var.hr_service_image
    essential = true
    portMappings = [{ containerPort = 5005, hostPort = 5005 }]
    environment = concat(
      [
        { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
        { name = "ASPNETCORE_URLS", value = "http://+:5005" },
        { name = "SPRING__APPLICATION__NAME", value = "hr-service" },
        { name = "ConnectionStrings__DefaultConnection", value = "Server=${replace(var.rds_endpoint, ":1433", "")},1433;Database=Konecta_Hr;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;MultipleActiveResultSets=True;" },
        { name = "RabbitMQ__HostName", value = "rabbitmq.${aws_service_discovery_private_dns_namespace.main.name}" },
        { name = "RabbitMQ__Port", value = "5672" },
        { name = "RabbitMQ__UserName", value = "guest" },
        { name = "RabbitMQ__Password", value = "guest" },
        { name = "RabbitMQ__VirtualHost", value = "/" },
        { name = "RabbitMQ__Exchange", value = "konecta.erp" }
      ],
      local.common_env_vars
    )
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "hr-service"
      }
    }
  }])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

# ---------------------------
# Inventory Service
# ---------------------------
resource "aws_ecs_task_definition" "inventory_service" {
  family                   = "${var.project_name}-inventory-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([{
    name      = "inventory-service"
    image     = var.inventory_service_image
    essential = true
    portMappings = [{ containerPort = 5020, hostPort = 5020 }]
    environment = concat(
      [
        { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
        { name = "ASPNETCORE_URLS", value = "http://+:5020" },
        { name = "SPRING__APPLICATION__NAME", value = "inventory-service" },
        { name = "ConnectionStrings__DefaultConnection", value = "Server=${replace(var.rds_endpoint, ":1433", "")},1433;Database=Konecta_Inventory;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;MultipleActiveResultSets=True;" }
      ],
      local.common_env_vars
    )
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "inventory-service"
      }
    }
  }])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

# ---------------------------
# API Gateway
# ---------------------------
resource "aws_ecs_task_definition" "api_gateway" {
  family                   = "${var.project_name}-api-gateway-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([{
    name      = "api-gateway"
    image     = var.api_gateway_image
    essential = true
    portMappings = [{ containerPort = 8080, hostPort = 8080 }]
    environment = [
      { name = "SPRING_APPLICATION_NAME", value = "api-gateway" },
      { name = "SPRING_CLOUD_CONFIG_URI", value = "http://config-server.${aws_service_discovery_private_dns_namespace.main.name}:8888" },
      { name = "SPRING_CLOUD_CONFIG_FAILFAST", value = "true" },
      { name = "CONSUL_HOST", value = "consul.${aws_service_discovery_private_dns_namespace.main.name}" },
      { name = "CONSUL_PORT", value = "8500" },
      { name = "AUTH_SERVICE_URI", value = "http://authentication-service.${aws_service_discovery_private_dns_namespace.main.name}:7280" },
      { name = "USER_MANAGEMENT_SERVICE_URI", value = "http://user-management-service.${aws_service_discovery_private_dns_namespace.main.name}:5078" },
      { name = "FINANCE_SERVICE_URI", value = "http://finance-service.${aws_service_discovery_private_dns_namespace.main.name}:5003" },
      { name = "HR_SERVICE_URI", value = "http://hr-service.${aws_service_discovery_private_dns_namespace.main.name}:5005" },
      { name = "INVENTORY_SERVICE_URI", value = "http://inventory-service.${aws_service_discovery_private_dns_namespace.main.name}:5020" },
      { name = "REPORTING_SERVICE_URI", value = "http://reporting-service.${aws_service_discovery_private_dns_namespace.main.name}:8085" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "api-gateway"
      }
    }
  }])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

# ---------------------------
# Reporting Service
# ---------------------------
resource "aws_ecs_task_definition" "reporting_service" {
  family                   = "${var.project_name}-reporting-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([{
    name      = "reporting-service"
    image     = var.reporting_service_image
    essential = true
    portMappings = [{ containerPort = 8085, hostPort = 8085 }]
    environment = [
      { name = "SPRING_APPLICATION_NAME", value = "reporting-service" },
      { name = "SPRING_CLOUD_CONFIG_URI", value = "http://config-server.${aws_service_discovery_private_dns_namespace.main.name}:8888" },
      { name = "SPRING_CLOUD_CONFIG_FAILFAST", value = "true" },
      { name = "FINANCE_SERVICE_URI", value = "http://finance-service.${aws_service_discovery_private_dns_namespace.main.name}:5003" },
      { name = "HR_SERVICE_URI", value = "http://hr-service.${aws_service_discovery_private_dns_namespace.main.name}:5005" },
      { name = "INVENTORY_SERVICE_URI", value = "http://inventory-service.${aws_service_discovery_private_dns_namespace.main.name}:5020" },
      { name = "CONSUL_HOST", value = "consul.${aws_service_discovery_private_dns_namespace.main.name}" },
      { name = "CONSUL_PORT", value = "8500" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "reporting-service"
      }
    }
  }])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

# ---------------------------
# Config Server
# ---------------------------
resource "aws_ecs_task_definition" "config_server" {
  family                   = "${var.project_name}-config-server-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([{
    name      = "config-server"
    image     = var.config_server_image
    essential = true
    portMappings = [{ containerPort = 8888, hostPort = 8888 }]
    environment = [
      { name = "SERVER_PORT", value = "8888" },
      { name = "CONSUL_HOST", value = "consul.${aws_service_discovery_private_dns_namespace.main.name}" },
      { name = "CONSUL_PORT", value = "8500" },
      { name = "CONSUL_ENDPOINT", value = "http://consul.${aws_service_discovery_private_dns_namespace.main.name}:8500" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "config-server"
      }
    }
  }])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

# ---------------------------
# HR Model (AI)
# ---------------------------
resource "aws_ecs_task_definition" "hr_model" {
  family                   = "${var.project_name}-hr-model-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([{
    name      = "hr-model"
    image     = var.hr_model_image
    essential = true
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "hr-model"
      }
    }
  }])

  lifecycle {
    ignore_changes = [container_definitions]
  }
}
