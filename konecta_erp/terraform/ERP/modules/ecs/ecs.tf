# ===========================
# Locals - Format RDS endpoint for SQL Server connection strings
# ===========================
locals {
  # RDS endpoint format: hostname:port, SQL Server needs: hostname,port
  rds_server = replace(var.rds_endpoint, ":", ",")
}

# ===========================
# ECS Cluster (Single cluster for all services)
# ===========================
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ===========================
# CloudWatch Logs
# ===========================
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 30
}

# ===========================
# AWS Service Discovery
# ===========================
resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "${var.project_name}.local"
  description = "Service discovery namespace for ${var.project_name}"
  vpc         = var.vpc_id
}

# ===========================
# ALB + Target Groups for API Gateway
# ===========================
resource "aws_lb" "alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "api_gateway" {
  name        = "${var.project_name}-${var.environment}-api-gateway-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 10
    interval            = 30
    path                = "/actuator/health"
    matcher             = "200"
    protocol            = "HTTP"
  }

  deregistration_delay = 30

  tags = {
    Name = "${var.project_name}-${var.environment}-api-gateway-tg"
  }
}

resource "aws_lb_listener" "api_gateway" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_gateway.arn
  }
}

# ===========================
# ECS Task Definitions - Config Server (must start first)
# ===========================
resource "aws_ecs_task_definition" "config_server" {
  family                   = "${var.project_name}-${var.environment}-config-server"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "config-server"
    image     = var.config_server_image
    essential = true
    portMappings = [{
      containerPort = 8888
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "SERVER_PORT"
        value = "8888"
      },
      {
        name  = "CONSUL_HOST"
        value = var.consul_host
      },
      {
        name  = "CONSUL_PORT"
        value = "8500"
      }
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
}

# ===========================
# ECS Task Definitions - Authentication Service
# ===========================
resource "aws_ecs_task_definition" "authentication_service" {
  family                   = "${var.project_name}-${var.environment}-authentication-service"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([{
    name      = "authentication-service"
    image     = var.authentication_service_image
    essential = true
    portMappings = [{
      containerPort = 7280
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.environment
      },
      {
        name  = "SPRING__APPLICATION__NAME"
        value = "authentication-service"
      },
      {
        name  = "SPRING__CLOUD__CONFIG__URI"
        value = "http://config-server.${aws_service_discovery_private_dns_namespace.this.name}:8888"
      },
      {
        name  = "Consul__Host"
        value = var.consul_host
      },
      {
        name  = "ConnectionStrings__DefaultConnection"
        value = "Server=${local.rds_server};Database=Konecta_Auth;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "authentication-service"
      }
    }
  }])
}

# ===========================
# ECS Task Definitions - HR Service
# ===========================
resource "aws_ecs_task_definition" "hr_service" {
  family                   = "${var.project_name}-${var.environment}-hr-service"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([{
    name      = "hr-service"
    image     = var.hr_service_image
    essential = true
    portMappings = [{
      containerPort = 5005
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.environment
      },
      {
        name  = "SPRING__APPLICATION__NAME"
        value = "hr-service"
      },
      {
        name  = "SPRING__CLOUD__CONFIG__URI"
        value = "http://config-server.${aws_service_discovery_private_dns_namespace.this.name}:8888"
      },
      {
        name  = "Consul__Host"
        value = var.consul_host
      },
      {
        name  = "ConnectionStrings__DefaultConnection"
        value = "Server=${local.rds_server};Database=Konecta_HR;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;"
      },
      {
        name  = "JwtSettings__JwksUri"
        value = "http://authentication-service.${aws_service_discovery_private_dns_namespace.this.name}:7280/.well-known/jwks.json"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "hr-service"
      }
    }
  }])
}

# ===========================
# ECS Task Definitions - Finance Service
# ===========================
resource "aws_ecs_task_definition" "finance_service" {
  family                   = "${var.project_name}-${var.environment}-finance-service"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([{
    name      = "finance-service"
    image     = var.finance_service_image
    essential = true
    portMappings = [{
      containerPort = 5003
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.environment
      },
      {
        name  = "SPRING__APPLICATION__NAME"
        value = "finance-service"
      },
      {
        name  = "SPRING__CLOUD__CONFIG__URI"
        value = "http://config-server.${aws_service_discovery_private_dns_namespace.this.name}:8888"
      },
      {
        name  = "Consul__Host"
        value = var.consul_host
      },
      {
        name  = "ConnectionStrings__DefaultConnection"
        value = "Server=${local.rds_server};Database=Konecta_Finance;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;"
      },
      {
        name  = "JwtSettings__JwksUri"
        value = "http://authentication-service.${aws_service_discovery_private_dns_namespace.this.name}:7280/.well-known/jwks.json"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "finance-service"
      }
    }
  }])
}

# ===========================
# ECS Task Definitions - Inventory Service
# ===========================
resource "aws_ecs_task_definition" "inventory_service" {
  family                   = "${var.project_name}-${var.environment}-inventory-service"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([{
    name      = "inventory-service"
    image     = var.inventory_service_image
    essential = true
    portMappings = [{
      containerPort = 5020
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.environment
      },
      {
        name  = "SPRING__APPLICATION__NAME"
        value = "inventory-service"
      },
      {
        name  = "SPRING__CLOUD__CONFIG__URI"
        value = "http://config-server.${aws_service_discovery_private_dns_namespace.this.name}:8888"
      },
      {
        name  = "Consul__Host"
        value = var.consul_host
      },
      {
        name  = "ConnectionStrings__DefaultConnection"
        value = "Server=${local.rds_server};Database=Konecta_Inventory;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;"
      },
      {
        name  = "JwtSettings__JwksUri"
        value = "http://authentication-service.${aws_service_discovery_private_dns_namespace.this.name}:7280/.well-known/jwks.json"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "inventory-service"
      }
    }
  }])
}

# ===========================
# ECS Task Definitions - User Management Service
# ===========================
resource "aws_ecs_task_definition" "user_management_service" {
  family                   = "${var.project_name}-${var.environment}-user-management-service"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([{
    name      = "user-management-service"
    image     = var.user_management_service_image
    essential = true
    portMappings = [{
      containerPort = 5078
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = var.environment
      },
      {
        name  = "SPRING__APPLICATION__NAME"
        value = "user-management-service"
      },
      {
        name  = "SPRING__CLOUD__CONFIG__URI"
        value = "http://config-server.${aws_service_discovery_private_dns_namespace.this.name}:8888"
      },
      {
        name  = "Consul__Host"
        value = var.consul_host
      },
      {
        name  = "ConnectionStrings__DefaultConnection"
        value = "Server=${local.rds_server};Database=Konecta_UserManagement;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;"
      },
      {
        name  = "JwtSettings__JwksUri"
        value = "http://authentication-service.${aws_service_discovery_private_dns_namespace.this.name}:7280/.well-known/jwks.json"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "user-management-service"
      }
    }
  }])
}

# ===========================
# ECS Task Definitions - API Gateway
# ===========================
resource "aws_ecs_task_definition" "api_gateway" {
  family                   = "${var.project_name}-${var.environment}-api-gateway"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([{
    name      = "api-gateway"
    image     = var.api_gateway_image
    essential = true
    portMappings = [{
      containerPort = 8080
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "SERVER_PORT"
        value = "8080"
      },
      {
        name  = "SPRING_APPLICATION_NAME"
        value = "api-gateway"
      },
      {
        name  = "SPRING_CLOUD_CONFIG_URI"
        value = "http://config-server.${aws_service_discovery_private_dns_namespace.this.name}:8888"
      },
      {
        name  = "SPRING_CLOUD_CONFIG_FAILFAST"
        value = "false"
      },
      {
        name  = "CONSUL_HOST"
        value = var.consul_host
      },
      {
        name  = "CONSUL_PORT"
        value = "8500"
      },
      {
        name  = "CONSUL_REGISTER"
        value = "false"
      },
      {
        name  = "AUTH_SERVICE_URI"
        value = "http://authentication-service.${aws_service_discovery_private_dns_namespace.this.name}:7280"
      },
      {
        name  = "AUTH_JWKS_URI"
        value = "http://authentication-service.${aws_service_discovery_private_dns_namespace.this.name}:7280/.well-known/jwks.json"
      },
      {
        name  = "HR_SERVICE_URI"
        value = "http://hr-service.${aws_service_discovery_private_dns_namespace.this.name}:5005"
      },
      {
        name  = "USER_MANAGEMENT_SERVICE_URI"
        value = "http://user-management-service.${aws_service_discovery_private_dns_namespace.this.name}:5078"
      },
      {
        name  = "INVENTORY_SERVICE_URI"
        value = "http://inventory-service.${aws_service_discovery_private_dns_namespace.this.name}:5020"
      },
      {
        name  = "FINANCE_SERVICE_URI"
        value = "http://finance-service.${aws_service_discovery_private_dns_namespace.this.name}:5003"
      },
      {
        name  = "REPORTING_SERVICE_URI"
        value = "http://reporting-service.${aws_service_discovery_private_dns_namespace.this.name}:8085"
      }
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
}

# ===========================
# ECS Task Definitions - Reporting Service
# ===========================
resource "aws_ecs_task_definition" "reporting_service" {
  family                   = "${var.project_name}-${var.environment}-reporting-service"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  container_definitions = jsonencode([{
    name      = "reporting-service"
    image     = var.reporting_service_image
    essential = true
    portMappings = [{
      containerPort = 8085
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "SPRING_APPLICATION_NAME"
        value = "reporting-service"
      },
      {
        name  = "SPRING_CLOUD_CONFIG_URI"
        value = "http://config-server.${aws_service_discovery_private_dns_namespace.this.name}:8888"
      },
      {
        name  = "FINANCE_SERVICE_URI"
        value = "http://finance-service.${aws_service_discovery_private_dns_namespace.this.name}:5003"
      },
      {
        name  = "HR_SERVICE_URI"
        value = "http://hr-service.${aws_service_discovery_private_dns_namespace.this.name}:5005"
      },
      {
        name  = "INVENTORY_SERVICE_URI"
        value = "http://inventory-service.${aws_service_discovery_private_dns_namespace.this.name}:5020"
      }
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
}

# ===========================
# ECS Task Definitions - HR Model Service
# ===========================
resource "aws_ecs_task_definition" "hr_model" {
  family                   = "${var.project_name}-${var.environment}-hr-model"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"

  container_definitions = jsonencode([{
    name      = "hr-model"
    image     = var.hr_model_image
    essential = true
    portMappings = [{
      containerPort = 8000
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "hr-model"
      }
    }
  }])
}

# ===========================
# ECS Task Definitions - Prophet Model Service
# ===========================
resource "aws_ecs_task_definition" "prophet_model" {
  family                   = "${var.project_name}-${var.environment}-prophet-model"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"

  container_definitions = jsonencode([{
    name      = "prophet-model"
    image     = var.prophet_model_image
    essential = true
    portMappings = [{
      containerPort = 8001
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "prophet-model"
      }
    }
  }])
}

# ===========================
# Service Discovery Services
# ===========================
resource "aws_service_discovery_service" "config_server" {
  name = "config-server"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "authentication_service" {
  name = "authentication-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "hr_service" {
  name = "hr-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "finance_service" {
  name = "finance-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "inventory_service" {
  name = "inventory-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "user_management_service" {
  name = "user-management-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "api_gateway" {
  name = "api-gateway"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "reporting_service" {
  name = "reporting-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# ===========================
# ECS Services - Config Server (must start first)
# ===========================
resource "aws_ecs_service" "config_server" {
  name            = "${var.project_name}-${var.environment}-config-server"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.config_server.arn
  desired_count   = var.config_server_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.config_server.arn
  }
}

# ===========================
# ECS Services - Authentication Service
# ===========================
resource "aws_ecs_service" "authentication_service" {
  name            = "${var.project_name}-${var.environment}-authentication-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.authentication_service.arn
  desired_count   = var.authentication_service_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.authentication_service.arn
  }

  depends_on = [aws_ecs_service.config_server]
}

# ===========================
# ECS Services - HR Service
# ===========================
resource "aws_ecs_service" "hr_service" {
  name            = "${var.project_name}-${var.environment}-hr-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hr_service.arn
  desired_count   = var.hr_service_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.hr_service.arn
  }

  depends_on = [aws_ecs_service.config_server]
}

# ===========================
# ECS Services - Finance Service
# ===========================
resource "aws_ecs_service" "finance_service" {
  name            = "${var.project_name}-${var.environment}-finance-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.finance_service.arn
  desired_count   = var.finance_service_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.finance_service.arn
  }

  depends_on = [aws_ecs_service.config_server]
}

# ===========================
# ECS Services - Inventory Service
# ===========================
resource "aws_ecs_service" "inventory_service" {
  name            = "${var.project_name}-${var.environment}-inventory-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.inventory_service.arn
  desired_count   = var.inventory_service_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.inventory_service.arn
  }

  depends_on = [aws_ecs_service.config_server]
}

# ===========================
# ECS Services - User Management Service
# ===========================
resource "aws_ecs_service" "user_management_service" {
  name            = "${var.project_name}-${var.environment}-user-management-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.user_management_service.arn
  desired_count   = var.user_management_service_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.user_management_service.arn
  }

  depends_on = [aws_ecs_service.config_server]
}

# ===========================
# ECS Services - API Gateway (with ALB)
# ===========================
resource "aws_ecs_service" "api_gateway" {
  name            = "${var.project_name}-${var.environment}-api-gateway"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api_gateway.arn
  desired_count   = var.api_gateway_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_gateway.arn
    container_name   = "api-gateway"
    container_port   = 8080
  }

  service_registries {
    registry_arn = aws_service_discovery_service.api_gateway.arn
  }

  depends_on = [
    aws_ecs_service.config_server,
    aws_ecs_service.authentication_service,
    aws_lb_listener.api_gateway
  ]
}

# ===========================
# ECS Services - Reporting Service
# ===========================
resource "aws_ecs_service" "reporting_service" {
  name            = "${var.project_name}-${var.environment}-reporting-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.reporting_service.arn
  desired_count   = var.reporting_service_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.reporting_service.arn
  }

  depends_on = [
    aws_ecs_service.config_server,
    aws_ecs_service.finance_service,
    aws_ecs_service.hr_service,
    aws_ecs_service.inventory_service
  ]
}

# ===========================
# ECS Services - HR Model
# ===========================
resource "aws_ecs_service" "hr_model" {
  name            = "${var.project_name}-${var.environment}-hr-model"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hr_model.arn
  desired_count   = var.hr_model_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }
}

# ===========================
# ECS Services - Prophet Model
# ===========================
resource "aws_ecs_service" "prophet_model" {
  name            = "${var.project_name}-${var.environment}-prophet-model"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.prophet_model.arn
  desired_count   = var.prophet_model_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }
}
