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

echo -e "${BLUE}🧹 IA-Ops MinIO Clean Deployment${NC}"
echo "================================="

cd "$PROJECT_DIR"

# Step 1: Clean everything
echo -e "${YELLOW}🧹 Step 1: Cleaning old services and images...${NC}"

# Stop all services
docker compose -f docker/docker-compose.yml down --remove-orphans 2>/dev/null || true
docker compose -f docker-compose.integrated.yml down --remove-orphans 2>/dev/null || true

# Remove old containers
docker container prune -f

# Remove unused images
docker image prune -f

echo -e "${GREEN}✅ Cleanup completed${NC}"

# Step 2: Build integrated image
echo -e "${YELLOW}🏗️  Step 2: Building integrated image...${NC}"
docker compose -f docker-compose.integrated.yml build --no-cache

# Step 3: Fix permissions
echo -e "${YELLOW}🔧 Step 3: Setting correct permissions...${NC}"
./scripts/fix-permissions.sh

# Step 4: Start services
echo -e "${YELLOW}🚀 Step 4: Starting integrated services...${NC}"
docker compose -f docker-compose.integrated.yml up -d

# Step 5: Wait and verify
echo -e "${YELLOW}⏳ Step 5: Waiting for services...${NC}"
sleep 30

# Verify services
if curl -f http://localhost:6540/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Dashboard: Healthy${NC}"
else
    echo -e "${RED}❌ Dashboard: Unhealthy${NC}"
fi

if curl -f http://localhost:8848/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ API: Healthy${NC}"
else
    echo -e "${RED}❌ API: Unhealthy${NC}"
fi

if curl -f http://localhost:9899 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ MinIO Console: Healthy${NC}"
else
    echo -e "${RED}❌ MinIO Console: Unhealthy${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Clean deployment completed!${NC}"
echo ""
echo -e "${BLUE}📊 Access URLs:${NC}"
echo -e "   Dashboard:      ${YELLOW}http://localhost:6540${NC}"
echo -e "   MinIO Console:  ${YELLOW}http://localhost:9899${NC}"
echo -e "   MinIO API:      ${YELLOW}http://localhost:9898${NC}"
echo -e "   REST API:       ${YELLOW}http://localhost:8848${NC}"
echo -e "   Documentation:  ${YELLOW}http://localhost:6541${NC}"
