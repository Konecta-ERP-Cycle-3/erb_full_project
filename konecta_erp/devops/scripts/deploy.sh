#!/bin/bash

set -e

echo "========================================="
echo "Konecta ERP Deployment Script"
echo "========================================="

# Configuration
DOCKER_COMPOSE_FILE="/tmp/docker-compose.yml"
DOCKER_COMPOSE_PROD_FILE="/tmp/docker-compose.prod.yml"
DEPLOYMENT_DIR="/opt/konecta-erp"
BACKUP_DIR="/opt/konecta-erp-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Use docker compose (v2) if available, otherwise docker-compose (v1)
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    DOCKER_COMPOSE_CMD="docker-compose"
fi

print_message "Using: $DOCKER_COMPOSE_CMD"

# Create deployment directory if it doesn't exist
if [ ! -d "$DEPLOYMENT_DIR" ]; then
    print_message "Creating deployment directory: $DEPLOYMENT_DIR"
    sudo mkdir -p "$DEPLOYMENT_DIR"
    sudo chown $USER:$USER "$DEPLOYMENT_DIR"
fi

# Create docker directory for SQL scripts if it doesn't exist
if [ ! -d "$DEPLOYMENT_DIR/docker/sqlserver" ]; then
    print_message "Creating docker/sqlserver directory..."
    sudo mkdir -p "$DEPLOYMENT_DIR/docker/sqlserver"
    sudo chown $USER:$USER "$DEPLOYMENT_DIR/docker/sqlserver"
fi

# Copy SQL seed scripts if they exist
if [ -d "/tmp/docker/sqlserver" ]; then
    print_message "Copying SQL seed scripts..."
    cp -r /tmp/docker/sqlserver/* "$DEPLOYMENT_DIR/docker/sqlserver/" 2>/dev/null || true
elif [ -d "$PROJECT_ROOT/docker/sqlserver" ]; then
    print_message "Copying SQL seed scripts from project root..."
    cp -r "$PROJECT_ROOT/docker/sqlserver"/* "$DEPLOYMENT_DIR/docker/sqlserver/" 2>/dev/null || true
fi

# Create backup directory
if [ ! -d "$BACKUP_DIR" ]; then
    print_message "Creating backup directory: $BACKUP_DIR"
    sudo mkdir -p "$BACKUP_DIR"
    sudo chown $USER:$USER "$BACKUP_DIR"
fi

# Backup existing deployment if it exists
if [ -f "$DEPLOYMENT_DIR/docker-compose.yml" ]; then
    print_message "Backing up existing deployment..."
    sudo cp -r "$DEPLOYMENT_DIR" "$BACKUP_DIR/backup_$TIMESTAMP" || true
fi

# Stop existing containers
if [ -f "$DEPLOYMENT_DIR/docker-compose.yml" ]; then
    print_message "Stopping existing containers..."
    cd "$DEPLOYMENT_DIR"
    $DOCKER_COMPOSE_CMD down || true
fi

# Get Docker Hub username from environment
DOCKER_USERNAME=${DOCKER_USERNAME:-"your-dockerhub-username"}

# Check if production docker-compose file exists, otherwise use the regular one
if [ -f "/tmp/docker-compose.prod.yml" ]; then
    print_message "Using production docker-compose file..."
    cp "/tmp/docker-compose.prod.yml" "$DEPLOYMENT_DIR/docker-compose.yml"
    # Replace DOCKER_USERNAME placeholder
    sed -i "s|\${DOCKER_USERNAME:-your-dockerhub-username}|${DOCKER_USERNAME}|g" "$DEPLOYMENT_DIR/docker-compose.yml"
else
    print_message "Using development docker-compose file and converting to production..."
    cp "$DOCKER_COMPOSE_FILE" "$DEPLOYMENT_DIR/docker-compose.yml"
    cd "$DEPLOYMENT_DIR"
    
    # Comment out build sections and add image references
    # This is a fallback if prod file doesn't exist
    python3 << EOF || print_warning "Python not available, using sed fallback"
import re
import os

with open('docker-compose.yml', 'r') as f:
    content = f.read()

# Services that need image replacement
docker_username = os.environ.get("DOCKER_USERNAME", "your-dockerhub-username")
services = {
    'config-server': f'{docker_username}/config-server:latest',
    'api-gateway': f'{docker_username}/api-gateway:latest',
    'reporting-service': f'{docker_username}/reporting-service:latest',
    'authentication-service': f'{docker_username}/authentication-service:latest',
    'hr-service': f'{docker_username}/hr-service:latest',
    'inventory-service': f'{docker_username}/inventory-service:latest',
    'finance-service': f'{docker_username}/finance-service:latest',
    'user-management-service': f'{docker_username}/user-management-service:latest',
}

for service, image in services.items():
    # Comment out build section
    content = re.sub(r'(\s+)(build:)', r'\1# \2', content)
    content = re.sub(r'(\s+)(dockerfile:)', r'\1# \2', content)
    # Add image after container_name
    pattern = f'(container_name: {service})'
    replacement = f'\\1\n    image: {image}'
    content = re.sub(pattern, replacement, content)

with open('docker-compose.yml', 'w') as f:
    f.write(content)
EOF

    # Fallback to sed if Python failed
    if [ $? -ne 0 ]; then
        print_warning "Using sed fallback method..."
        sed -i.bak "s|build:|# build:|g" docker-compose.yml
        sed -i.bak "s|dockerfile:|# dockerfile:|g" docker-compose.yml
        sed -i.bak "/container_name: config-server/a\    image: ${DOCKER_USERNAME}/config-server:latest" docker-compose.yml
        sed -i.bak "/container_name: api-gateway/a\    image: ${DOCKER_USERNAME}/api-gateway:latest" docker-compose.yml
        sed -i.bak "/container_name: reporting-service/a\    image: ${DOCKER_USERNAME}/reporting-service:latest" docker-compose.yml
        sed -i.bak "/container_name: authentication-service/a\    image: ${DOCKER_USERNAME}/authentication-service:latest" docker-compose.yml
        sed -i.bak "/container_name: hr-service/a\    image: ${DOCKER_USERNAME}/hr-service:latest" docker-compose.yml
        sed -i.bak "/container_name: inventory-service/a\    image: ${DOCKER_USERNAME}/inventory-service:latest" docker-compose.yml
        sed -i.bak "/container_name: finance-service/a\    image: ${DOCKER_USERNAME}/finance-service:latest" docker-compose.yml
        sed -i.bak "/container_name: user-management-service/a\    image: ${DOCKER_USERNAME}/user-management-service:latest" docker-compose.yml
        rm -f docker-compose.yml.bak
    fi
fi

cd "$DEPLOYMENT_DIR"

# Pull latest images
print_message "Pulling latest Docker images..."
$DOCKER_COMPOSE_CMD pull || print_warning "Some images failed to pull, continuing..."

# Start services
print_message "Starting services..."
$DOCKER_COMPOSE_CMD up -d

# Wait for services to be healthy
print_message "Waiting for services to start..."
sleep 30

# Check service status
print_message "Checking service status..."
$DOCKER_COMPOSE_CMD ps

# Health check
print_message "Performing health checks..."
HEALTH_CHECK_FAILED=0

# Check if containers are running
if ! $DOCKER_COMPOSE_CMD ps | grep -q "Up"; then
    print_error "Some containers failed to start!"
    HEALTH_CHECK_FAILED=1
fi

# Check API Gateway
if curl -f http://localhost:8080/actuator/health &> /dev/null || curl -f http://localhost:8080 &> /dev/null; then
    print_message "API Gateway is responding"
else
    print_warning "API Gateway health check failed (may still be starting)"
fi

if [ $HEALTH_CHECK_FAILED -eq 0 ]; then
    print_message "========================================="
    print_message "Deployment completed successfully!"
    print_message "========================================="
    print_message "Services are available at:"
    print_message "  - API Gateway: http://localhost:8080"
    print_message "  - RabbitMQ Management: http://localhost:15672"
    print_message "  - Consul UI: http://localhost:8500"
    print_message "  - MailHog: http://localhost:8025"
    exit 0
else
    print_error "Deployment completed with errors. Please check logs:"
    print_error "  $DOCKER_COMPOSE_CMD logs"
    exit 1
fi

