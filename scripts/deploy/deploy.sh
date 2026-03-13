#!/bin/bash

# =========================================================
# DEPLOYMENT SCRIPT (SERVER SIDE)
# =========================================================
# This script is executed by GitHub Actions via SSH.
# It updates the application code and Docker containers.
#
# Usage: ./deploy.sh [VERSION_TAG]
# Example: ./deploy.sh v1.0.0
# =========================================================

set -e  # Exit immediately if a command exits with a non-zero status.

# --- Colors ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Arguments ---
VERSION_TAG=$1

if [ -z "$VERSION_TAG" ]; then
    echo -e "${RED}Error: Version tag is required.${NC}"
    echo "Usage: ./deploy.sh <version_tag>"
    exit 1
fi

echo -e "${GREEN}🚀 STARTING DEPLOYMENT: ${YELLOW}$VERSION_TAG${NC}"
echo "-------------------------------------------------------"

# 1. Update Codebase (Partial/Sparse - No Source Code)
echo -e "${YELLOW}[1/5] Updating configuration and scripts...${NC}"
# We assume the CI/CD pipeline has already transferred the necessary files (scripts/, docker-compose.prod.yml, config.json)
# via SCP/Rsync BEFORE running this script.
# Alternatively, if we use git, we fetch but don't pull app/
# For this "Enterprise" setup, we trust the files are present or updated via a separate step.
# If using git for scripts only:
# git fetch origin main
# git checkout origin/main -- scripts/ docker-compose.prod.yml config.json .env.example .env.example.backend .env.example.devops

# 2. Setup Environment Variables (Calls setup-env.sh with arguments)
echo -e "${YELLOW}[2/5] Setting up environment variables...${NC}"

# We skip the first argument ($1 is VERSION_TAG) and pass the rest to setup-env.sh
shift 1
./scripts/setup/setup-env.sh --DOCKER_IMAGE_TAG="$VERSION_TAG" "$@"

# 3. Pull Docker Images (Artifacts)
echo -e "${YELLOW}[3/5] Pulling Docker images...${NC}"
# Use the production compose file
docker compose -f docker-compose.prod.yml pull

# 4. Restart Containers
echo -e "${YELLOW}[4/5] Restarting containers...${NC}"
docker compose -f docker-compose.prod.yml up -d --remove-orphans

echo -e "${GREEN}✅ Deployment Successful! Version $VERSION_TAG is live.${NC}"
exit 0


# 3. Pull New Images
echo -e "${YELLOW}[3/5] Pulling Docker images...${NC}"
docker compose pull app app-worker app-socket

# 4. Rolling Restart
echo -e "${YELLOW}[4/5] Restarting containers...${NC}"
docker compose up -d --remove-orphans

# 5. Post-Deployment Tasks
echo -e "${YELLOW}[5/5] Running post-deployment tasks...${NC}"
# Wait for DB to be ready? (Usually already ready in rolling update)

echo "   -> Running Migrations..."
docker compose exec -T app php artisan migrate --force

echo "   -> Optimization..."
docker compose exec -T app php artisan optimize:clear
docker compose exec -T app php artisan config:cache
docker compose exec -T app php artisan route:cache
docker compose exec -T app php artisan view:cache

echo "-------------------------------------------------------"
echo -e "${GREEN}✅ DEPLOYMENT SUCCESSFUL!${NC}"
