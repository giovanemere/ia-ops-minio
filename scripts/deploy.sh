#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🚀 Complete Deployment Pipeline${NC}"
echo "=================================="

# Step 1: Build and test locally
echo -e "${YELLOW}Step 1: Building and testing locally...${NC}"
"$SCRIPT_DIR/build.sh"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed, stopping deployment${NC}"
    exit 1
fi

# Step 2: Publish to Docker Hub
echo -e "${YELLOW}Step 2: Publishing to Docker Hub...${NC}"
"$SCRIPT_DIR/publish.sh"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Publish failed, stopping deployment${NC}"
    exit 1
fi

# Step 3: Deploy with published image
echo -e "${YELLOW}Step 3: Deploying with published image...${NC}"
"$SCRIPT_DIR/start.sh"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi

# Step 4: Final verification
echo -e "${YELLOW}Step 4: Final verification...${NC}"
sleep 15
"$SCRIPT_DIR/status.sh"

echo -e "${GREEN}🎉 Complete deployment pipeline finished successfully!${NC}"
echo ""
echo -e "${BLUE}📊 Access URLs:${NC}"
echo -e "   MinIO Console:  ${YELLOW}http://localhost:9899${NC}"
echo -e "   MinIO API:      ${YELLOW}http://localhost:9898${NC}"
echo -e "   REST API:       ${YELLOW}http://localhost:8848${NC}"
