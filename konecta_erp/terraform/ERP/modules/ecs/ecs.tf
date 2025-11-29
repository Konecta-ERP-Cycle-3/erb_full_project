# ===========================
# ECS Clusters
# ===========================
resource "aws_ecs_cluster" "main" {
  count = var.num_clusters
  name  = "${var.project_name}-${var.environment}-cluster-${count.index + 1}"

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
# ALB + Target Groups + Listener (Frontend Only)
# ===========================
resource "aws_lb" "alb" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-${var.environment}-frontend-tg"
  port        = var.frontend_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

# ===========================
# ECS Task Definitions
# ===========================
resource "aws_ecs_task_definition" "frontend" {
  count                    = var.num_clusters
  family                   = "${var.project_name}-${var.environment}-frontend-task-${count.index + 1}"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = var.frontend_image
    essential = true
    portMappings = [{
      containerPort = var.frontend_port
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "frontend"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "backend" {
  count                    = var.num_clusters
  family                   = "${var.project_name}-${var.environment}-backend-task-${count.index + 1}"
  execution_role_arn       = var.ecs_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory

  container_definitions = jsonencode([{
    name      = "backend"
    image     = var.backend_image
    essential = true
    portMappings = [{
      containerPort = var.backend_port
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "backend"
      }
    }
  }])
}

# ===========================
# ECS Services
# ===========================
resource "aws_ecs_service" "frontend" {
  count           = var.num_clusters
  name            = "${var.project_name}-${var.environment}-frontend-service-${count.index + 1}"
  cluster         = aws_ecs_cluster.main[count.index].id
  task_definition = aws_ecs_task_definition.frontend[count.index].arn
  desired_count   = var.frontend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = var.frontend_port
  }

  depends_on = [aws_lb_listener.frontend]
}

resource "aws_ecs_service" "backend" {
  count           = var.num_clusters
  name            = "${var.project_name}-${var.environment}-backend-service-${count.index + 1}"
  cluster         = aws_ecs_cluster.main[count.index].id
  task_definition = aws_ecs_task_definition.backend[count.index].arn
  desired_count   = var.backend_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.ecs_service_sg]
    assign_public_ip = false
  }

  # Remove load_balancer block for backend
  # depends_on is optional if backend doesn't depend on ALB
}
