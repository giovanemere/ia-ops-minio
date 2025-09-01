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
IMAGE_NAME="ia-ops-minio-integrated"

echo -e "${BLUE}🗄️  IA-Ops MinIO Setup${NC}"
echo "=================================="

# Check prerequisites
echo -e "${YELLOW}📋 Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose is not available${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites checked${NC}"

# Create directories
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p "$PROJECT_DIR/data"
mkdir -p "$PROJECT_DIR/logs"

echo -e "${GREEN}✅ Directories created${NC}"

# Setup environment file
echo -e "${YELLOW}⚙️  Setting up environment...${NC}"
if [ ! -f "$PROJECT_DIR/.env" ]; then
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    echo -e "${GREEN}✅ Environment file created${NC}"
else
    echo -e "${GREEN}✅ Environment file already exists${NC}"
fi

# Check if image exists locally
echo -e "${YELLOW}🔍 Checking for local image...${NC}"
if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$IMAGE_NAME:latest"; then
    echo -e "${GREEN}✅ Image $IMAGE_NAME:latest found locally${NC}"
else
    echo -e "${YELLOW}🔨 Building image $IMAGE_NAME:latest...${NC}"
    cd "$PROJECT_DIR"
    docker build -f Dockerfile.integrated -t "$IMAGE_NAME:latest" .
    echo -e "${GREEN}✅ Image built successfully${NC}"
fi

# Start services
echo -e "${YELLOW}🚀 Starting MinIO services...${NC}"
cd "$PROJECT_DIR"
docker compose -f docker-compose.integrated.yml up -d

# Wait for services
echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
sleep 15

# Verify services
echo -e "${YELLOW}🔍 Verifying services...${NC}"
if curl -f http://localhost:6540/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Portal Dashboard is healthy${NC}"
else
    echo -e "${RED}❌ Portal Dashboard is not responding${NC}"
fi

if curl -f http://localhost:9898/minio/health/live > /dev/null 2>&1; then
    echo -e "${GREEN}✅ MinIO API is healthy${NC}"
else
    echo -e "${RED}❌ MinIO API is not responding${NC}"
fi

if curl -f http://localhost:8848/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ REST API is healthy${NC}"
else
    echo -e "${RED}❌ REST API is not responding${NC}"
fi

echo ""
echo -e "${GREEN}🎉 MinIO Portal setup completed!${NC}"
echo ""
echo -e "${BLUE}📊 Access URLs:${NC}"
echo -e "   Portal Dashboard: ${YELLOW}http://localhost:6540${NC}"
echo -e "   MinIO Console:    ${YELLOW}http://localhost:9899${NC}"
echo -e "   MinIO API:        ${YELLOW}http://localhost:9898${NC}"
echo -e "   REST API:         ${YELLOW}http://localhost:8848${NC}"
echo -e "   Documentation:    ${YELLOW}http://localhost:6541${NC}"
echo ""
echo -e "${BLUE}🔑 Default Credentials:${NC}"
echo -e "   Username: ${YELLOW}minioadmin${NC}"
echo -e "   Password: ${YELLOW}minioadmin123${NC}"
