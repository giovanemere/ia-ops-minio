#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🚀 Complete Integrated Deployment Pipeline${NC}"
echo "=========================================="

# Step 1: Build and test locally
echo -e "${YELLOW}Step 1: Building and testing locally...${NC}"
"$SCRIPT_DIR/build-integrated.sh"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed, stopping deployment${NC}"
    exit 1
fi

# Step 2: Publish to Docker Hub
echo -e "${YELLOW}Step 2: Publishing to Docker Hub...${NC}"
"$SCRIPT_DIR/publish-integrated.sh"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Publish failed, stopping deployment${NC}"
    exit 1
fi

# Step 3: Deploy with published image
echo -e "${YELLOW}Step 3: Deploying with published image...${NC}"
cd "$(dirname "$SCRIPT_DIR")"

# Stop existing services
docker compose -f docker-compose.integrated.yml down 2>/dev/null || true

# Start with production image
docker compose -f docker-compose.integrated.prod.yml up -d

# Step 4: Final verification
echo -e "${YELLOW}Step 4: Final verification...${NC}"
sleep 30

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

echo ""
echo -e "${GREEN}🎉 Complete integrated deployment pipeline finished!${NC}"
echo ""
echo -e "${BLUE}📊 Access URLs:${NC}"
echo -e "   Dashboard:      ${YELLOW}http://localhost:6540${NC}"
echo -e "   MinIO Console:  ${YELLOW}http://localhost:9899${NC}"
echo -e "   MinIO API:      ${YELLOW}http://localhost:9898${NC}"
echo -e "   REST API:       ${YELLOW}http://localhost:8848${NC}"
echo -e "   Documentation:  ${YELLOW}http://localhost:6541${NC}"
echo ""
echo -e "${BLUE}🐳 Docker Hub:${NC}"
echo -e "   Image: ${YELLOW}edissonz8809/ia-ops-minio-integrated:latest${NC}"
