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

echo -e "${BLUE}🔨 Building MinIO Services${NC}"
echo "=================================="

# Load environment variables
if [ -f "$PROJECT_DIR/docker/.env.docker" ]; then
    source "$PROJECT_DIR/docker/.env.docker"
    echo -e "${GREEN}✅ Docker environment loaded${NC}"
else
    echo -e "${RED}❌ Docker environment file not found${NC}"
    exit 1
fi

# Build local images first
echo -e "${YELLOW}🏗️  Building local images...${NC}"
cd "$PROJECT_DIR/docker"
docker compose build --no-cache

echo -e "${GREEN}✅ Local build completed${NC}"

# Test local build
echo -e "${YELLOW}🧪 Testing local build...${NC}"
if docker compose up -d; then
    sleep 10
    
    # Health checks
    if curl -f http://localhost:8848/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Local build test passed${NC}"
        docker compose down
    else
        echo -e "${RED}❌ Local build test failed${NC}"
        docker compose down
        exit 1
    fi
else
    echo -e "${RED}❌ Failed to start services for testing${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Build process completed successfully!${NC}"
