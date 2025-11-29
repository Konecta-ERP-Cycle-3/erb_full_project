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
# IAM MODULE
##############################################
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
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
  db_name     = "dbuser"
}

##############################################
# ECS MODULE (with ALB handled internally)
##############################################
module "ecs" {
  source = "./modules/ecs"

  ecs_execution_role_arn = module.iam.ecs_execution_role_arn

  aws_region   = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  num_clusters = var.num_clusters

  # NEW: Pass VPC & Subnet info
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids

  # Security groups
  ecs_service_sg = module.security_groups.frontend_ecs_sg_id
  alb_sg_id      = module.security_groups.alb_sg_id

  # Docker images
  frontend_image = var.frontend_image
  backend_image  = var.backend_image

  # Desired counts
  frontend_desired_count = var.frontend_desired_count
  backend_desired_count  = var.backend_desired_count
}
