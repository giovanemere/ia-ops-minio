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

echo -e "${BLUE}🚀 Publishing Integrated Image to Docker Hub${NC}"
echo "============================================="

cd "$PROJECT_DIR"

# Load environment variables
if [ -f "docker/.env.docker" ]; then
    source docker/.env.docker
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
docker build -f Dockerfile.integrated -t "${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}" .
docker build -f Dockerfile.integrated -t "${DOCKER_USERNAME}/${IMAGE_NAME}:$(date +%Y%m%d-%H%M%S)" .

echo -e "${GREEN}✅ Image built and tagged${NC}"

# Push to Docker Hub
echo -e "${YELLOW}📤 Pushing to Docker Hub...${NC}"
docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
docker push "${DOCKER_USERNAME}/${IMAGE_NAME}:$(date +%Y%m%d-%H%M%S)"

echo -e "${GREEN}✅ Images pushed successfully${NC}"

# Update docker-compose to use published image
echo -e "${YELLOW}🔄 Creating production docker-compose...${NC}"

cat > docker-compose.integrated.prod.yml << EOF
version: '3.8'

services:
  ia-ops-minio-integrated:
    image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
    container_name: ia-ops-minio-portal
    restart: unless-stopped
    ports:
      - "6540:6540"       # Dashboard principal
      - "9898:9000"       # MinIO API (mantener puerto actual)
      - "9899:9001"       # MinIO Console (mantener puerto actual)
      - "8848:8848"       # REST API (mantener puerto actual)
      - "6541:6541"       # Docs (mantener puerto actual)
    volumes:
      - ./data:/data
      - ./logs:/app/logs
    environment:
      - MINIO_ROOT_USER=\${MINIO_ROOT_USER:-minioadmin}
      - MINIO_ROOT_PASSWORD=\${MINIO_ROOT_PASSWORD:-minioadmin123}
    networks:
      - minio-integrated
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6540/health"]
      interval: 30s
      timeout: 20s
      retries: 3
      start_period: 60s

networks:
  minio-integrated:
    driver: bridge
    name: ia-ops-minio-integrated
EOF

echo -e "${GREEN}✅ Production docker-compose created${NC}"

# Logout from Docker Hub
docker logout

echo -e "${GREEN}🎉 Publication completed successfully!${NC}"
echo -e "${BLUE}📦 Published image: ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}${NC}"
echo -e "${BLUE}🚀 Use: docker-compose.integrated.prod.yml for production${NC}"
