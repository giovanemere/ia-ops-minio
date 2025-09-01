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

echo -e "${BLUE}🔨 Building IA-Ops MinIO Integrated Image${NC}"
echo "=========================================="

cd "$PROJECT_DIR"

# Load environment variables
if [ -f "docker/.env.docker" ]; then
    source docker/.env.docker
    echo -e "${GREEN}✅ Docker environment loaded${NC}"
else
    echo -e "${RED}❌ Docker environment file not found${NC}"
    exit 1
fi

# Build integrated image locally
echo -e "${YELLOW}🏗️  Building integrated image locally...${NC}"
docker compose -f docker-compose.integrated.yml build --no-cache

echo -e "${GREEN}✅ Local build completed${NC}"

# Test local build
echo -e "${YELLOW}🧪 Testing local build...${NC}"
if docker compose -f docker-compose.integrated.yml up -d; then
    sleep 20
    
    # Health checks
    if curl -f http://localhost:6540/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Local build test passed${NC}"
        docker compose -f docker-compose.integrated.yml down
    else
        echo -e "${RED}❌ Local build test failed${NC}"
        docker compose -f docker-compose.integrated.yml down
        exit 1
    fi
else
    echo -e "${RED}❌ Failed to start services for testing${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Build process completed successfully!${NC}"
