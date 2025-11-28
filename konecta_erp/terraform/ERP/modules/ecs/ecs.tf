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
# TASK DEFINITION - API GATEWAY (Entry Point)
# ===========================
resource "aws_ecs_task_definition" "api_gateway" {
  family                   = "${var.project_name}-api-gateway-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "api-gateway"
      image     = var.api_gateway_image
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        { name = "SPRING_APPLICATION_NAME", value = "api-gateway" },
        { name = "SPRING_CLOUD_CONFIG_URI", value = "http://config-server.${aws_service_discovery_private_dns_namespace.main.name}:8888" },
        { name = "SPRING_CLOUD_CONFIG_FAILFAST", value = "true" },
        { name = "CONSUL_HOST", value = "consul.${aws_service_discovery_private_dns_namespace.main.name}" },
        { name = "CONSUL_PORT", value = "8500" },
        { name = "CONSUL_SERVICE_HOST", value = "api-gateway" },
        { name = "AUTH_SERVICE_URI", value = "http://authentication-service.${aws_service_discovery_private_dns_namespace.main.name}:7280" },
        { name = "AUTH_JWKS_URI", value = "http://authentication-service.${aws_service_discovery_private_dns_namespace.main.name}:7280/.well-known/jwks.json" },
        { name = "HR_SERVICE_URI", value = "http://hr-service.${aws_service_discovery_private_dns_namespace.main.name}:5005" },
        { name = "USER_MANAGEMENT_SERVICE_URI", value = "http://user-management-service.${aws_service_discovery_private_dns_namespace.main.name}:5078" },
        { name = "INVENTORY_SERVICE_URI", value = "http://inventory-service.${aws_service_discovery_private_dns_namespace.main.name}:5020" },
        { name = "FINANCE_SERVICE_URI", value = "http://finance-service.${aws_service_discovery_private_dns_namespace.main.name}:5003" },
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
    }
  ])
}

# ===========================
# TASK DEFINITION - CONFIG SERVER
# ===========================
resource "aws_ecs_task_definition" "config_server" {
  family                   = "${var.project_name}-config-server-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "config-server"
      image     = var.config_server_image
      essential = true
      portMappings = [
        {
          containerPort = 8888
          hostPort      = 8888
        }
      ]
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
    }
  ])
}

# ===========================
# TASK DEFINITION - AUTHENTICATION SERVICE
# ===========================
resource "aws_ecs_task_definition" "authentication_service" {
  family                   = "${var.project_name}-authentication-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "authentication-service"
      image     = var.authentication_service_image
      essential = true
      portMappings = [
        {
          containerPort = 7280
          hostPort      = 7280
        }
      ]
      environment = [
        { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
        { name = "ASPNETCORE_URLS", value = "http://+:7280" },
        { name = "SPRING__APPLICATION__NAME", value = "authentication-service" },
        { name = "SPRING__CLOUD__CONFIG__URI", value = "http://config-server.${aws_service_discovery_private_dns_namespace.main.name}:8888" },
        { name = "SPRING__CLOUD__CONFIG__FAILFAST", value = "true" },
        { name = "ConnectionStrings__DefaultConnection", value = "Server=${replace(var.rds_endpoint, ":1433", "")},1433;Database=Konecta_Auth;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;MultipleActiveResultSets=True;" },
        { name = "RabbitMQ__HostName", value = "rabbitmq.${aws_service_discovery_private_dns_namespace.main.name}" },
        { name = "RabbitMQ__Port", value = "5672" },
        { name = "RabbitMQ__UserName", value = "guest" },
        { name = "RabbitMQ__Password", value = "guest" },
        { name = "RabbitMQ__VirtualHost", value = "/" },
        { name = "RabbitMQ__Exchange", value = "konecta.erp" },
        { name = "Consul__Host", value = "http://consul.${aws_service_discovery_private_dns_namespace.main.name}:8500" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "authentication-service"
        }
      }
    }
  ])
}

# ===========================
# TASK DEFINITION - USER MANAGEMENT SERVICE
# ===========================
resource "aws_ecs_task_definition" "user_management_service" {
  family                   = "${var.project_name}-user-management-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "user-management-service"
      image     = var.user_management_service_image
      essential = true
      portMappings = [
        {
          containerPort = 5078
          hostPort      = 5078
        }
      ]
      environment = [
        { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
        { name = "ASPNETCORE_URLS", value = "http://+:5078" },
        { name = "SPRING__APPLICATION__NAME", value = "user-management-service" },
        { name = "SPRING__CLOUD__CONFIG__URI", value = "http://config-server.${aws_service_discovery_private_dns_namespace.main.name}:8888" },
        { name = "SPRING__CLOUD__CONFIG__FAILFAST", value = "true" },
        { name = "ConnectionStrings__DefaultConnection", value = "Server=${replace(var.rds_endpoint, ":1433", "")},1433;Database=Konecta_UserManagement;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;MultipleActiveResultSets=True;" },
        { name = "RabbitMQ__HostName", value = "rabbitmq.${aws_service_discovery_private_dns_namespace.main.name}" },
        { name = "RabbitMQ__Port", value = "5672" },
        { name = "RabbitMQ__UserName", value = "guest" },
        { name = "RabbitMQ__Password", value = "guest" },
        { name = "RabbitMQ__VirtualHost", value = "/" },
        { name = "RabbitMQ__Exchange", value = "konecta.erp" },
        { name = "Consul__Host", value = "http://consul.${aws_service_discovery_private_dns_namespace.main.name}:8500" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "user-management-service"
        }
      }
    }
  ])
}

# ===========================
# TASK DEFINITION - FINANCE SERVICE
# ===========================
resource "aws_ecs_task_definition" "finance_service" {
  family                   = "${var.project_name}-finance-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "finance-service"
      image     = var.finance_service_image
      essential = true
      portMappings = [
        {
          containerPort = 5003
          hostPort      = 5003
        }
      ]
      environment = [
        { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
        { name = "ASPNETCORE_URLS", value = "http://+:5003" },
        { name = "SPRING__APPLICATION__NAME", value = "finance-service" },
        { name = "SPRING__CLOUD__CONFIG__URI", value = "http://config-server.${aws_service_discovery_private_dns_namespace.main.name}:8888" },
        { name = "SPRING__CLOUD__CONFIG__FAILFAST", value = "true" },
        { name = "ConnectionStrings__DefaultConnection", value = "Server=${replace(var.rds_endpoint, ":1433", "")},1433;Database=Konecta_Finance;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;MultipleActiveResultSets=True;" },
        { name = "RabbitMQ__HostName", value = "rabbitmq.${aws_service_discovery_private_dns_namespace.main.name}" },
        { name = "RabbitMQ__Port", value = "5672" },
        { name = "RabbitMQ__UserName", value = "guest" },
        { name = "RabbitMQ__Password", value = "guest" },
        { name = "RabbitMQ__VirtualHost", value = "/" },
        { name = "RabbitMQ__Exchange", value = "konecta.erp" },
        { name = "Consul__Host", value = "http://consul.${aws_service_discovery_private_dns_namespace.main.name}:8500" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "finance-service"
        }
      }
    }
  ])
}

# ===========================
# TASK DEFINITION - HR SERVICE
# ===========================
resource "aws_ecs_task_definition" "hr_service" {
  family                   = "${var.project_name}-hr-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "hr-service"
      image     = var.hr_service_image
      essential = true
      portMappings = [
        {
          containerPort = 5005
          hostPort      = 5005
        }
      ]
      environment = [
        { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
        { name = "ASPNETCORE_URLS", value = "http://+:5005" },
        { name = "SPRING__APPLICATION__NAME", value = "hr-service" },
        { name = "SPRING__CLOUD__CONFIG__URI", value = "http://config-server.${aws_service_discovery_private_dns_namespace.main.name}:8888" },
        { name = "SPRING__CLOUD__CONFIG__FAILFAST", value = "true" },
        { name = "ConnectionStrings__DefaultConnection", value = "Server=${replace(var.rds_endpoint, ":1433", "")},1433;Database=Konecta_Hr;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;MultipleActiveResultSets=True;" },
        { name = "RabbitMQ__HostName", value = "rabbitmq.${aws_service_discovery_private_dns_namespace.main.name}" },
        { name = "RabbitMQ__Port", value = "5672" },
        { name = "RabbitMQ__UserName", value = "guest" },
        { name = "RabbitMQ__Password", value = "guest" },
        { name = "RabbitMQ__VirtualHost", value = "/" },
        { name = "RabbitMQ__Exchange", value = "konecta.erp" },
        { name = "Consul__Host", value = "http://consul.${aws_service_discovery_private_dns_namespace.main.name}:8500" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "hr-service"
        }
      }
    }
  ])
}

# ===========================
# TASK DEFINITION - INVENTORY SERVICE
# ===========================
resource "aws_ecs_task_definition" "inventory_service" {
  family                   = "${var.project_name}-inventory-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "inventory-service"
      image     = var.inventory_service_image
      essential = true
      portMappings = [
        {
          containerPort = 5020
          hostPort      = 5020
        }
      ]
      environment = [
        { name = "ASPNETCORE_ENVIRONMENT", value = "Production" },
        { name = "ASPNETCORE_URLS", value = "http://+:5020" },
        { name = "SPRING__APPLICATION__NAME", value = "inventory-service" },
        { name = "SPRING__CLOUD__CONFIG__URI", value = "http://config-server.${aws_service_discovery_private_dns_namespace.main.name}:8888" },
        { name = "SPRING__CLOUD__CONFIG__FAILFAST", value = "true" },
        { name = "ConnectionStrings__DefaultConnection", value = "Server=${replace(var.rds_endpoint, ":1433", "")},1433;Database=Konecta_Inventory;User Id=${var.db_username};Password=${var.db_password};TrustServerCertificate=True;MultipleActiveResultSets=True;" },
        { name = "Consul__Host", value = "http://consul.${aws_service_discovery_private_dns_namespace.main.name}:8500" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "inventory-service"
        }
      }
    }
  ])
}

# ===========================
# TASK DEFINITION - REPORTING SERVICE
# ===========================
resource "aws_ecs_task_definition" "reporting_service" {
  family                   = "${var.project_name}-reporting-service-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "reporting-service"
      image     = var.reporting_service_image
      essential = true
      portMappings = [
        {
          containerPort = 8085
          hostPort      = 8085
        }
      ]
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
    }
  ])
}

# ===========================
# SERVICE DISCOVERY
# ===========================
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${var.project_name}.local"
  description = "Service discovery namespace for ${var.project_name}"
  vpc         = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_service_discovery_service" "api_gateway" {
  name = "api-gateway"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "config_server" {
  name = "config-server"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "authentication_service" {
  name = "authentication-service"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "user_management_service" {
  name = "user-management-service"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "finance_service" {
  name = "finance-service"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "hr_service" {
  name = "hr-service"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "inventory_service" {
  name = "inventory-service"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "reporting_service" {
  name = "reporting-service"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

# ===========================
# ECS SERVICE - API GATEWAY (Entry Point)
# ===========================
resource "aws_ecs_service" "api_gateway" {
  name            = "${var.project_name}-api-gateway-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api_gateway.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.api_gateway_sg_id]
    subnets          = var.public_subnet_ids
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.api_gateway.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_gateway_tg.arn
    container_name   = "api-gateway"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.http]
}

# ===========================
# ECS SERVICE - CONFIG SERVER
# ===========================
resource "aws_ecs_service" "config_server" {
  name            = "${var.project_name}-config-server-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.config_server.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.backend_sg_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.config_server.arn
  }
}

# ===========================
# ECS SERVICE - AUTHENTICATION SERVICE
# ===========================
resource "aws_ecs_service" "authentication_service" {
  name            = "${var.project_name}-authentication-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.authentication_service.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.backend_sg_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.authentication_service.arn
  }
}

# ===========================
# ECS SERVICE - USER MANAGEMENT SERVICE
# ===========================
resource "aws_ecs_service" "user_management_service" {
  name            = "${var.project_name}-user-management-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.user_management_service.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.backend_sg_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.user_management_service.arn
  }
}

# ===========================
# ECS SERVICE - FINANCE SERVICE
# ===========================
resource "aws_ecs_service" "finance_service" {
  name            = "${var.project_name}-finance-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.finance_service.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.backend_sg_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.finance_service.arn
  }
}

# ===========================
# ECS SERVICE - HR SERVICE
# ===========================
resource "aws_ecs_service" "hr_service" {
  name            = "${var.project_name}-hr-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hr_service.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.backend_sg_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.hr_service.arn
  }
}

# ===========================
# ECS SERVICE - INVENTORY SERVICE
# ===========================
resource "aws_ecs_service" "inventory_service" {
  name            = "${var.project_name}-inventory-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.inventory_service.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.backend_sg_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.inventory_service.arn
  }
}

# ===========================
# ECS SERVICE - REPORTING SERVICE
# ===========================
resource "aws_ecs_service" "reporting_service" {
  name            = "${var.project_name}-reporting-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.reporting_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.backend_sg_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.reporting_service.arn
  }
}

# ===========================
# TASK DEFINITION - RABBITMQ
# ===========================
resource "aws_ecs_task_definition" "rabbitmq" {
  family                   = "${var.project_name}-rabbitmq-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "rabbitmq"
      image     = "rabbitmq:3.13-management"
      essential = true
      portMappings = [
        {
          containerPort = 5672
          hostPort      = 5672
        },
        {
          containerPort = 15672
          hostPort      = 15672
        }
      ]
      environment = [
        { name = "RABBITMQ_DEFAULT_USER", value = "guest" },
        { name = "RABBITMQ_DEFAULT_PASS", value = "guest" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "rabbitmq"
        }
      }
    }
  ])
}

# ===========================
# TASK DEFINITION - CONSUL
# ===========================
resource "aws_ecs_task_definition" "consul" {
  family                   = "${var.project_name}-consul-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "consul"
      image     = "hashicorp/consul:1.18"
      essential = true
      portMappings = [
        {
          containerPort = 8500
          hostPort      = 8500
        }
      ]
      command = ["agent", "-server", "-bootstrap", "-ui", "-client=0.0.0.0"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "consul"
        }
      }
    }
  ])
}

# ===========================
# SERVICE DISCOVERY - RABBITMQ & CONSUL
# ===========================
resource "aws_service_discovery_service" "rabbitmq" {
  name = "rabbitmq"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "consul" {
  name = "consul"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

# ===========================
# ECS SERVICE - RABBITMQ
# ===========================
resource "aws_ecs_service" "rabbitmq" {
  name            = "${var.project_name}-rabbitmq-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.rabbitmq.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.backend_sg_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.rabbitmq.arn
  }
}

# ===========================
# ECS SERVICE - CONSUL
# ===========================
resource "aws_ecs_service" "consul" {
  name            = "${var.project_name}-consul-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.consul.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.backend_sg_id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.consul.arn
  }
}

# ===========================
# APPLICATION LOAD BALANCER
# ===========================
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "api_gateway_tg" {
  name        = "${var.project_name}-api-gateway-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_gateway_tg.arn
  }
}
