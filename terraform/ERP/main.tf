module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  availability_zones = var.availability_zones

  project_name = var.project_name
  environment  = var.environment
}

module "security_groups" {
  source = "./modules/sg"

  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  environment  = var.environment
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  environment        = var.environment
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.security_groups.rds_sg_id

  db_username = var.db_username
  db_password = var.db_password
  db_name     = "dbuser"
}

module "ecs" {
  source = "./modules/ecs"

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  alb_sg_id      = module.security_groups.alb_sg_id
  frontend_sg_id = module.security_groups.frontend_sg_id
  backend_sg_id  = module.security_groups.backend_sg_id

  ecs_execution_role_arn = module.iam.ecs_execution_role_arn

  aws_region    = var.aws_region
  project_name  = var.project_name
  environment   = var.environment

  # Service Images
  authentication_service_image = var.authentication_service_image
  user_management_service_image = var.user_management_service_image
  finance_service_image        = var.finance_service_image
  hr_service_image             = var.hr_service_image
  inventory_service_image      = var.inventory_service_image
  api_gateway_image            = var.api_gateway_image
  reporting_service_image      = var.reporting_service_image
  config_server_image          = var.config_server_image
  hr_model_image               = var.hr_model_image
  prophet_model_image          = var.prophet_model_image

  db_username = var.db_username
  db_password = var.db_password
  rds_endpoint = module.rds.rds_endpoint
}
