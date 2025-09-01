#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}🚀 Publishing to Docker Hub${NC}"
echo "=================================="

# Load environment variables
if [ -f "$PROJECT_DIR/docker/.env.docker" ]; then
    source "$PROJECT_DIR/docker/.env.docker"
    echo -e "${GREEN}✅ Docker environment loaded${NC}"
else
    echo -e "${RED}❌ Docker environment file not found${NC}"
    exit 1
fi

# Docker login
echo -e "${YELLOW}🔐 Logging into Docker Hub...${NC}"
echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USERNAME" --password-stdin

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker Hub login successful${NC}"
else
    echo -e "${RED}❌ Docker Hub login failed${NC}"
    exit 1
fi

# Build and tag image for Docker Hub
echo -e "${YELLOW}🏗️  Building image for Docker Hub...${NC}"
cd "$PROJECT_DIR/api"
docker build -t "${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}" .
docker build -t "${DOCKER_USERNAME}/${IMAGE_NAME}:$(date +%Y%m%d-%H%M%S)" .

echo -e "${GREEN}✅ Image built and tagged${NC}"

# Push to Docker Hub
echo -e "${YELLOW}📤 Pushing to Docker Hub...${NC}"
docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:$(date +%Y%m%d-%H%M%S)"

echo -e "${GREEN}✅ Images pushed successfully${NC}"

# Update docker-compose to use published image
echo -e "${YELLOW}🔄 Updating docker-compose.yml...${NC}"
cd "$PROJECT_DIR/docker"

# Create backup
cp docker-compose.yml docker-compose.yml.backup

# Update image reference
sed -i "s|build:|# build:|g" docker-compose.yml
sed -i "s|context: ../api|# context: ../api|g" docker-compose.yml
sed -i "s|dockerfile: Dockerfile|# dockerfile: Dockerfile|g" docker-compose.yml
sed -i "/# build:/a\\    image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}" docker-compose.yml

echo -e "${GREEN}✅ docker-compose.yml updated${NC}"

# Logout from Docker Hub
docker logout

echo -e "${GREEN}🎉 Publication completed successfully!${NC}"
echo -e "${BLUE}📦 Published image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}${NC}"
