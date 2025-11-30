##############################################
# VPC MODULE
##############################################
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones

  project_name = var.project_name
  environment  = var.environment
}

##############################################
# SECURITY GROUPS MODULE
##############################################
module "security_groups" {
  source = "./modules/sg"

  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  environment  = var.environment
}

##############################################
# ECR MODULE - Container Repositories
##############################################
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

##############################################
# IAM MODULE
##############################################
module "iam" {
  source = "./modules/iam"

  project_name        = var.project_name
  environment         = var.environment
  docker_hub_secret_arn = var.docker_hub_secret_arn
}

##############################################
# RDS MODULE
##############################################
module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  environment        = var.environment
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.security_groups.rds_sg_id

  db_username = var.db_username
  db_password = var.db_password
  # db_name not used for SQL Server - databases created separately after instance creation
  db_name     = ""
}

##############################################
# ECS MODULE - All 10 Services
##############################################
module "ecs" {
  source = "./modules/ecs"

  ecs_execution_role_arn = module.iam.ecs_execution_role_arn

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  # VPC & Subnet info
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  # Security groups
  ecs_service_sg = module.security_groups.frontend_ecs_sg_id
  alb_sg_id      = module.security_groups.alb_sg_id

  # Service Images (using ECR repositories)
  authentication_service_image = "${module.ecr.authentication_service_repository_url}:latest"
  user_management_service_image = "${module.ecr.user_management_service_repository_url}:latest"
  finance_service_image        = "${module.ecr.finance_service_repository_url}:latest"
  hr_service_image             = "${module.ecr.hr_service_repository_url}:latest"
  inventory_service_image      = "${module.ecr.inventory_service_repository_url}:latest"
  api_gateway_image            = "${module.ecr.api_gateway_repository_url}:latest"
  reporting_service_image      = "${module.ecr.reporting_service_repository_url}:latest"
  config_server_image          = "${module.ecr.config_server_repository_url}:latest"
  hr_model_image               = "${module.ecr.hr_model_repository_url}:latest"
  prophet_model_image          = "${module.ecr.prophet_model_repository_url}:latest"

  # Service Desired Counts
  authentication_service_desired_count = var.authentication_service_desired_count
  user_management_service_desired_count = var.user_management_service_desired_count
  finance_service_desired_count        = var.finance_service_desired_count
  hr_service_desired_count             = var.hr_service_desired_count
  inventory_service_desired_count      = var.inventory_service_desired_count
  api_gateway_desired_count            = var.api_gateway_desired_count
  reporting_service_desired_count      = var.reporting_service_desired_count
  config_server_desired_count          = var.config_server_desired_count
  hr_model_desired_count               = var.hr_model_desired_count
  prophet_model_desired_count          = var.prophet_model_desired_count

  # Database Configuration
  rds_endpoint = module.rds.rds_endpoint
  db_username  = var.db_username
  db_password  = var.db_password

  # Consul (optional - for service discovery fallback)
  consul_host = "" # Can be configured if using Consul

  # Docker Hub Authentication
  docker_hub_secret_arn = var.docker_hub_secret_arn
}
