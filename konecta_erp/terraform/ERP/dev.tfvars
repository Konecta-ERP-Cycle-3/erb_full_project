aws_region     = "us-east-1"
db_password    = "KonectaERP2024!DevPass"

# Docker Hub Authentication (to avoid rate limits)
docker_hub_secret_arn = "arn:aws:secretsmanager:us-east-1:585768179815:secret:konecta-ass1-dev-docker-hub-credentials-oLW5ta"

# Service Images
authentication_service_image = "mohamed710/authentication-service:latest"
user_management_service_image = "mohamed710/user-management-service:latest"
finance_service_image        = "mohamed710/finance-service:latest"
hr_service_image             = "mohamed710/hr-service:latest"
inventory_service_image      = "mohamed710/inventory-service:latest"
api_gateway_image            = "mohamed710/api-gateway:latest"
reporting_service_image      = "mohamed710/reporting-service:latest"
config_server_image          = "mohamed710/config-server:latest"
hr_model_image               = "mohamed710/hr-model:latest"
prophet_model_image          = "mohamed710/prophet-model:latest"