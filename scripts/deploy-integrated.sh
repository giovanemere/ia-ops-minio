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

echo -e "${BLUE}🚀 IA-Ops MinIO Integrated Deployment${NC}"
echo "======================================"

cd "$PROJECT_DIR"

# Stop existing services
echo -e "${YELLOW}⏹️  Stopping existing services...${NC}"
docker compose -f docker/docker-compose.yml down 2>/dev/null || true
docker compose -f docker-compose.integrated.yml down 2>/dev/null || true

# Build integrated image
echo -e "${YELLOW}🏗️  Building integrated image...${NC}"
docker compose -f docker-compose.integrated.yml build --no-cache

# Start integrated service
echo -e "${YELLOW}🚀 Starting integrated service...${NC}"
docker compose -f docker-compose.integrated.yml up -d

# Wait for services
echo -e "${YELLOW}⏳ Waiting for services to be ready...${NC}"
sleep 30

# Verify deployment
echo -e "${YELLOW}🔍 Verifying deployment...${NC}"

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
echo -e "${GREEN}🎉 Integrated deployment completed!${NC}"
echo ""
echo -e "${BLUE}📊 Access URLs:${NC}"
echo -e "   Dashboard:      ${YELLOW}http://localhost:6540${NC}"
echo -e "   MinIO Console:  ${YELLOW}http://localhost:9899${NC}"
echo -e "   MinIO API:      ${YELLOW}http://localhost:9898${NC}"
echo -e "   REST API:       ${YELLOW}http://localhost:8848${NC}"
echo -e "   Documentation:  ${YELLOW}http://localhost:6541${NC}"
echo ""
echo -e "${BLUE}🔑 Default Credentials:${NC}"
echo -e "   Username: ${YELLOW}minioadmin${NC}"
echo -e "   Password: ${YELLOW}minioadmin123${NC}"
